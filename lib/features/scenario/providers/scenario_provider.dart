// lib/features/scenario/providers/scenario_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/quota_constants.dart';
import '../../../data/cache/scenario_cache.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../data/gemini/config.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/helpers.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../models/assessment.dart';
import '../models/chat_message.dart';
import '../models/scenario.dart';
import '../models/session.dart';

// Bumped from 30s → 60s. Preview Gemini models (gemini-3-flash-preview)
// can spike to 40-50s under load even though /generateContent benchmarks
// in <2s. Evaluation in particular generates a heavy structured-JSON
// assessment + grammarBreakdown + alternativeTones in one shot, so the
// long-tail latency is real. 60s matches the headroom mobile users will
// tolerate before they assume the app crashed.
const Duration _kGeminiScenarioTimeout = Duration(seconds: 60);
const Duration _kGeminiEvaluateTimeout = Duration(seconds: 60);
const Duration _kSeenLoadTimeout = Duration(seconds: 5);

/// Max retries when the LLM keeps returning a Vietnamese sentence the user
/// has already practiced. After this many attempts we accept the duplicate
/// rather than fail the session — a slightly stale sentence is better than
/// an error toast.
const int _kDedupMaxRetries = 3;

final RegExp _kVietnameseWhitespaceRe = RegExp(r'\s+');
final RegExp _kVietnameseTrailingPunctRe = RegExp(r'[.?!,;…]+$');

/// Fallback source marker for UI banners when we couldn't reach Gemini.
enum ScenarioSource { live, cache }

class ScenarioProvider extends ChangeNotifier {
  final GeminiService _gemini;
  final FirebaseDatasource _firebase;
  final LocalDatasource _local;
  final ScenarioCache _cache;
  final _uuid = const Uuid();

  ScenarioProvider({
    required GeminiService gemini,
    required FirebaseDatasource firebase,
    required LocalDatasource local,
    required ScenarioCache cache,
  })  : _gemini = gemini,
        _firebase = firebase,
        _local = local,
        _cache = cache;

  // Session state
  String? _uid;
  String? _userTier;
  Scenario? _currentScenario;
  ScenarioSource _currentScenarioSource = ScenarioSource.live;
  String? _conversationId;
  final List<ChatMessage> _messages = [];
  bool _isAiTyping = false;
  bool _isLoading = false;
  int _hintsRevealed = 0;
  DateTime? _sessionStartTime;
  String _direction = 'vn-to-en';
  int _scenarioIndex = 0;
  String? _error;
  List<String> _userTopics = [];
  String _userLevel = '';
  final List<String> _recentTitles = [];

  // Cross-session uniqueness state: SHA-1 hashes of normalized Vietnamese
  // sentences the user has already been asked to translate. Loaded lazily
  // from `users/{uid}/seenSentences` once per app lifetime (see
  // [_ensureSeenLoaded]). In-memory writes are optimistic — if session
  // abort happens before Firestore persists, the next cold-start reload
  // heals the set.
  final Set<String> _seenSentenceHashes = {};
  bool _seenLoaded = false;
  Future<void>? _seenLoadingFuture;

  // Quota state
  Map<String, int> _dailyUsage = {};
  bool _quotaExceeded = false;

  // -- Practice session state --
  //
  // A "session" here is the user-facing PracticeSession (group of scenarios
  // played in a row), NOT the single-scenario lifecycle that the legacy
  // [startSession] method controls. Lives at `users/{uid}/sessions/{id}` in
  // Firestore — see plan doc `2026-05-11-scenario-session-replay.md`.
  String? _activeSessionId;
  DateTime? _activeSessionStartedAt;
  final List<SessionScenarioMeta> _sessionMetas = [];
  bool _didCheckActiveSession = false;

  // Replay state. When [_isReplayMode] is true, the chat screen renders a
  // past scenario read-only. We stash the active-scenario in-memory state in
  // [_replaySnapshot] so exiting replay restores it without re-fetching.
  bool _isReplayMode = false;
  _ReplaySnapshot? _replaySnapshot;

  /// Monotonically increasing id for the current in-flight [sendUserMessage]
  /// call. Bumped on every new send AND on [cancelCurrentMessage] — any
  /// in-flight await checks the captured seq against this field and silently
  /// drops its result if the user already cancelled.
  int _sendSeq = 0;

  /// Number of messages BEFORE the current in-flight send appended its user
  /// bubble. On cancel we truncate back to `baseCount + 1` so the user's own
  /// bubble is preserved but anything the call appended on top of it (AI
  /// reply / assessment) is rolled back.
  int? _pendingSendBaseCount;

  // Getters
  Scenario? get currentScenario => _currentScenario;
  ScenarioSource get currentScenarioSource => _currentScenarioSource;
  bool get isOfflineFallback => _currentScenarioSource == ScenarioSource.cache;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isAiTyping => _isAiTyping;
  bool get isLoading => _isLoading;
  int get hintsRevealed => _hintsRevealed;
  String get direction => _direction;
  int get scenarioIndex => _scenarioIndex;
  String? get error => _error;
  bool get isVnToEn => _direction == 'vn-to-en';
  bool get quotaExceeded => _quotaExceeded;
  int get roleplayUsedToday => _dailyUsage['roleplayCount'] ?? 0;

  int get roleplayLimitToday =>
      QuotaConstants.getLimit(_userTier ?? 'free', 'roleplay');

  // Practice session getters
  String? get activeSessionId => _activeSessionId;
  DateTime? get activeSessionStartedAt => _activeSessionStartedAt;
  bool get hasActiveSession => _activeSessionId != null;
  List<SessionScenarioMeta> get sessionMetas =>
      List.unmodifiable(_sessionMetas);
  int get sessionScenarioCount => _sessionMetas.length;
  double get sessionAvgScore {
    if (_sessionMetas.isEmpty) return 0;
    final total = _sessionMetas.fold<int>(0, (a, m) => a + m.totalScore);
    return total / _sessionMetas.length;
  }

  bool get isReplayMode => _isReplayMode;

  int get sessionDurationMinutes {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inMinutes;
  }

  /// Wall-clock elapsed since the current session started, or null if no
  /// session is active. Exposed so the end-session dialog can show a live
  /// duration without reaching into provider internals.
  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  int get totalTurns =>
      _messages.where((m) => m.type == MessageType.user).length;

  double get averageScore {
    final assessments = _messages
        .where((m) => m.type == MessageType.assessment && m.assessment != null)
        .map((m) => m.assessment!.score)
        .toList();
    if (assessments.isEmpty) return 0;
    return assessments.reduce((a, b) => a + b) / assessments.length;
  }

  String get _todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Initialize with user context. Call from HomeScreen before navigating.
  Future<void> init({
    required String uid,
    required String tier,
    required List<String> topics,
    required String level,
  }) async {
    _uid = uid;
    _userTier = tier;
    _userTopics = topics;
    _userLevel = level;
    await _loadDailyUsage();
    // Kick off seen-sentence preload so dedup data is ready by the time the
    // learner taps "Start practice". Fire-and-forget — startSession awaits
    // [_ensureSeenLoaded] defensively.
    unawaited(_ensureSeenLoaded());
    notifyListeners();
  }

  Future<void> _loadDailyUsage() async {
    if (_uid == null) return;
    try {
      _dailyUsage = await _firebase
          .getDailyUsage(_uid!, _todayDate)
          .timeout(const Duration(seconds: 5));
      _local.cacheDailyUsage(_todayDate, _dailyUsage);
    } catch (_) {
      _dailyUsage = _local.getCachedDailyUsage(_todayDate) ?? {};
    }
    final limit = roleplayLimitToday;
    _quotaExceeded = limit != -1 && roleplayUsedToday >= limit;
  }

  bool canStartSession() {
    final limit = roleplayLimitToday;
    if (limit == -1) return true;
    return roleplayUsedToday < limit;
  }

  /// Start a new roleplay session. Order: Gemini call → on failure, fall back
  /// to last cached lesson with a "offline" banner. If no cache exists either,
  /// surface an error to the UI so user can retry.
  Future<void> startSession({String? topic, String? difficulty}) async {
    if (_uid == null || _userTopics.isEmpty) return;

    if (!canStartSession()) {
      _quotaExceeded = true;
      _error = 'Daily limit reached. Upgrade for more sessions.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final selectedDifficulty = difficulty ?? _userLevel;
      final cefrLevel = CefrLevel.fromProficiencyId(selectedDifficulty);
      final topics = topic != null ? [topic] : _userTopics;

      Scenario? scenario;
      ScenarioSource source = ScenarioSource.live;

      if (GeminiConfig.isApiKeyConfigured) {
        try {
          final outcome = await _generateUniqueScenario(
            level: cefrLevel,
            topics: topics,
          );

          final parsed = parseJsonObject(outcome.rawJson);
          scenario = Scenario.fromJson(parsed).copyWith(
            id: _uuid.v4(),
            topic: parsed['topic'] as String? ?? outcome.chosenTopic,
            sentenceType:
                parsed['sentenceType'] as String? ?? outcome.chosenSentenceType,
          );
          if (scenario.title.isNotEmpty) {
            _recentTitles.add(scenario.title);
            if (_recentTitles.length > 20) _recentTitles.removeAt(0);
          }
          unawaited(_cache.saveLastLesson(scenario));
        } catch (e) {
          debugPrint('[ScenarioProvider] Gemini generateNextLesson failed: $e');
          scenario = await _cache.getLastLesson();
          source = ScenarioSource.cache;
        }
      } else {
        scenario = await _cache.getLastLesson();
        source = ScenarioSource.cache;
      }

      if (scenario == null) {
        _error =
            'AI is unavailable and no previous lesson is cached. Please try again when you are online.';
        return;
      }

      // Finalize the previous scenario in the active session BEFORE we
      // overwrite the in-memory state. No-op when there is no active
      // session or the previous scenario was never answered.
      await _finalizeCurrentScenarioInSession();

      _currentScenario = scenario;
      _currentScenarioSource = source;
      _conversationId = _uuid.v4();
      _messages.clear();
      _hintsRevealed = 0;
      _sessionStartTime = DateTime.now();
      _scenarioIndex++;
      _direction = 'vn-to-en';

      if (source == ScenarioSource.cache) {
        _messages.add(ChatMessage(
          id: _uuid.v4(),
          type: MessageType.system,
          text:
              'Showing your last cached lesson — AI is unavailable right now.',
          timestamp: DateTime.now(),
        ));
      }

      if (source == ScenarioSource.live) {
        _dailyUsage['roleplayCount'] = roleplayUsedToday + 1;
        unawaited(_firebase
            .incrementDailyUsage(_uid!, _todayDate, 'roleplay')
            .catchError((_) {}));
        unawaited(_saveConversationToFirestore());
        _persistSeenSentence(scenario.vietnamesePhrase);
      }
    } catch (e) {
      _error = 'Failed to start scenario: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send user message and get AI assessment.
  Future<void> sendUserMessage(String text) async {
    if (_currentScenario == null) return;

    // Capture turn-list snapshot BEFORE the user bubble is appended so
    // cancelCurrentMessage can truncate back precisely.
    _pendingSendBaseCount = _messages.length;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isAiTyping = true;
    _error = null;
    final seq = ++_sendSeq;
    notifyListeners();

    try {
      if (!GeminiConfig.isApiKeyConfigured) {
        throw StateError('Gemini API key not configured');
      }
      final rawJson = await _gemini
          .evaluateResponse(
            userInput: text,
            sourcePhrase: _direction == 'vn-to-en'
                ? _currentScenario!.vietnamesePhrase
                : _currentScenario!.englishPhrase,
            situation: _currentScenario!.situation,
            targetLevel: CefrLevel.fromProficiencyId(_userLevel),
            direction: _direction,
          )
          .timeout(_kGeminiEvaluateTimeout);

      // The learner tapped Stop while this call was in flight. Drop the
      // result silently — cancelCurrentMessage already cleared the loading
      // state and trimmed the turn list.
      if (seq != _sendSeq) return;

      final assessment = AssessmentResult.fromJson(parseJsonObject(rawJson));

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.assessment,
        text: '',
        timestamp: DateTime.now(),
        assessment: assessment,
      ));

      unawaited(_cache.saveLastAssessment(assessment));
      unawaited(_saveConversationToFirestore());
    } catch (e) {
      if (seq != _sendSeq) return;
      debugPrint('[ScenarioProvider] evaluateResponse failed: $e');
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.ai,
        text:
            'Sorry, I couldn\'t evaluate your response right now. Please try again.',
        timestamp: DateTime.now(),
      ));
      _error = 'Evaluation failed: ${e.toString()}';
    } finally {
      if (seq == _sendSeq) {
        _isAiTyping = false;
        _pendingSendBaseCount = null;
        notifyListeners();
      }
    }
  }

  /// Cancel the current in-flight [sendUserMessage]. Truncates the message
  /// list back to `baseCount + 1` — the learner's own bubble is preserved
  /// but any AI reply the call may have already appended is rolled back.
  /// The in-flight Gemini request keeps running (cannot be killed from
  /// Dart) but the seq check in [sendUserMessage] drops its result.
  void cancelCurrentMessage() {
    if (!_isAiTyping) return;
    _sendSeq++;
    final baseCount = _pendingSendBaseCount;
    if (baseCount != null) {
      final keepUpTo = baseCount + 1;
      if (_messages.length > keepUpTo) {
        _messages.removeRange(keepUpTo, _messages.length);
      }
    }
    _pendingSendBaseCount = null;
    _isAiTyping = false;
    _error = null;
    notifyListeners();
  }

  Future<void> startNewScenario({String? difficulty}) async {
    final adjustedDifficulty = _adjustDifficulty(difficulty);
    await startSession(difficulty: adjustedDifficulty);
  }

  String _adjustDifficulty(String? adjustment) {
    if (adjustment == null) return _userLevel;
    final levels = ['A1-A2', 'B1-B2', 'C1-C2'];
    final current =
        CefrLevel.fromProficiencyId(_currentScenario?.difficulty ?? _userLevel)
            .code;
    final currentIndex = levels.indexOf(current).clamp(0, levels.length - 1);
    switch (adjustment) {
      case 'easier':
        return levels[(currentIndex - 1).clamp(0, 2)];
      case 'harder':
        return levels[(currentIndex + 1).clamp(0, 2)];
      default:
        return _currentScenario?.difficulty ?? _userLevel;
    }
  }

  void toggleDirection() {
    _direction = _direction == 'vn-to-en' ? 'en-to-vn' : 'vn-to-en';
    notifyListeners();
  }

  void revealNextHint() {
    if (_currentScenario == null) return;
    if (_hintsRevealed < _currentScenario!.hints.toFlatList().length) {
      _hintsRevealed++;
      notifyListeners();
    }
  }

  // ---------- Practice session lifecycle ----------

  /// Start a brand-new practice session: creates the Firestore session doc
  /// and loads the first scenario. Clears any in-memory metadata from a
  /// previous session so the chip starts at 0.
  ///
  /// If an active session already exists, callers should resolve the
  /// resume-vs-new prompt via [hasActiveSession] + [resumeActiveSession]
  /// FIRST. Calling this method always replaces the active session.
  Future<void> startPracticeSession({String? topic, String? difficulty}) async {
    if (_uid == null) return;
    // End the previous session quietly so we don't leak a dangling
    // endedAt-null doc when the user starts fresh without explicit "End".
    if (_activeSessionId != null) {
      await _finalizeCurrentScenarioInSession();
      try {
        await _firebase.endSession(
            uid: _uid!, sessionId: _activeSessionId!);
      } catch (e) {
        debugPrint('[ScenarioProvider] auto-endSession failed: $e');
      }
    }
    final newSessionId = _uuid.v4();
    try {
      await _firebase.createSession(
        uid: _uid!,
        sessionId: newSessionId,
        mode: 'roleplay',
      );
    } catch (e) {
      debugPrint('[ScenarioProvider] createSession failed: $e');
      // Continue anyway — the conversation save path will retry session
      // doc creation implicitly via merge when aggregates write later.
    }
    _activeSessionId = newSessionId;
    _activeSessionStartedAt = DateTime.now();
    _sessionMetas.clear();
    _didCheckActiveSession = true;
    notifyListeners();

    await startSession(topic: topic, difficulty: difficulty);
  }

  /// End the active session. Saves the current scenario (if any) as
  /// completed, stamps `endedAt`, and clears in-memory state. Caller is
  /// responsible for navigating away from the chat screen.
  Future<void> endPracticeSession() async {
    if (_activeSessionId == null || _uid == null) return;
    final sessionId = _activeSessionId!;
    await _finalizeCurrentScenarioInSession();
    try {
      await _firebase.endSession(uid: _uid!, sessionId: sessionId);
    } catch (e) {
      debugPrint('[ScenarioProvider] endSession failed: $e');
    }
    _activeSessionId = null;
    _activeSessionStartedAt = null;
    _sessionMetas.clear();
    _currentScenario = null;
    _conversationId = null;
    _messages.clear();
    _isReplayMode = false;
    _replaySnapshot = null;
    notifyListeners();
  }

  /// Look up the user's currently-active session (if any) and hydrate the
  /// in-memory state from Firestore. Idempotent within a provider lifetime
  /// — guarded by [_didCheckActiveSession] so repeated calls during widget
  /// rebuilds don't burn reads.
  ///
  /// Returns the resolved session so the UI can decide whether to prompt
  /// the user to resume vs. start fresh.
  Future<PracticeSession?> resumeActiveSession() async {
    if (_uid == null) return null;
    if (_didCheckActiveSession) {
      if (_activeSessionId == null) return null;
      // Already hydrated — return a synthetic PracticeSession built from
      // current in-memory state rather than re-reading Firestore.
      return PracticeSession(
        id: _activeSessionId!,
        mode: 'roleplay',
        startedAt: _activeSessionStartedAt ?? DateTime.now(),
        scenarioCount: _sessionMetas.length,
        avgScore: sessionAvgScore,
      );
    }
    _didCheckActiveSession = true;
    try {
      final session = await _firebase
          .loadActiveSession(uid: _uid!, mode: 'roleplay')
          .timeout(const Duration(seconds: 5));
      if (session == null) return null;
      _activeSessionId = session.id;
      _activeSessionStartedAt = session.startedAt;
      final metas = await _firebase
          .listSessionScenarios(uid: _uid!, sessionId: session.id)
          .timeout(const Duration(seconds: 8));
      _sessionMetas
        ..clear()
        ..addAll(metas);
      notifyListeners();
      return session;
    } catch (e) {
      debugPrint('[ScenarioProvider] resumeActiveSession failed: $e');
      return null;
    }
  }

  // ---------- Replay mode ----------

  /// Enter readonly replay of a past scenario. Stashes the active in-memory
  /// state and hydrates [_currentScenario] + [_messages] from the saved
  /// conversation doc so the chat screen renders it like a regular session.
  /// [exitReplayMode] (or [branchFromReplay]) MUST be called to restore.
  Future<void> enterReplayMode(String conversationId) async {
    if (_uid == null) return;
    if (_isReplayMode) {
      debugPrint(
          '[ScenarioProvider] enterReplayMode called while already replaying');
      return;
    }

    Map<String, dynamic>? doc;
    try {
      doc = await _firebase
          .getConversation(_uid!, conversationId)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[ScenarioProvider] enterReplayMode load failed: $e');
      return;
    }
    if (doc == null) return;

    _replaySnapshot = _ReplaySnapshot(
      scenario: _currentScenario,
      source: _currentScenarioSource,
      conversationId: _conversationId,
      messages: List.of(_messages),
      hintsRevealed: _hintsRevealed,
      direction: _direction,
    );

    _currentScenario = Scenario(
      id: (doc['id'] as String?) ?? conversationId,
      topic: (doc['topic'] as String?) ?? '',
      title: (doc['title'] as String?) ?? '',
      situation: (doc['situation'] as String?) ?? '',
      vietnamesePhrase: (doc['vietnamesePhrase'] as String?) ?? '',
      englishPhrase: (doc['englishPhrase'] as String?) ?? '',
      difficulty: (doc['difficulty'] as String?) ?? _userLevel,
      sentenceType: (doc['sentenceType'] as String?) ?? '',
      hints: const ScenarioHints(level1: '', level2: '', level3: ''),
    );
    _conversationId = conversationId;
    _direction = (doc['direction'] as String?) ?? 'vn-to-en';
    _hintsRevealed = 0;
    _messages
      ..clear()
      ..addAll(_messagesFromConversationDoc(doc));
    _isReplayMode = true;
    notifyListeners();
  }

  /// Restore the active-scenario state captured at [enterReplayMode]. If no
  /// snapshot exists (defensive), clears replay flag only.
  void exitReplayMode() {
    if (!_isReplayMode) return;
    final snap = _replaySnapshot;
    if (snap != null) {
      _currentScenario = snap.scenario;
      _currentScenarioSource = snap.source;
      _conversationId = snap.conversationId;
      _messages
        ..clear()
        ..addAll(snap.messages);
      _hintsRevealed = snap.hintsRevealed;
      _direction = snap.direction;
    }
    _replaySnapshot = null;
    _isReplayMode = false;
    notifyListeners();
  }

  /// User tapped "Branch — Same / Easier / Harder" from a replay. We exit
  /// replay first (so the active state is restored) and then immediately
  /// start a new scenario in the current session, using the requested
  /// difficulty adjustment. The replayed scenario itself stays unchanged.
  Future<void> branchFromReplay({String? difficulty}) async {
    if (!_isReplayMode) return;
    exitReplayMode();
    await startNewScenario(difficulty: difficulty);
  }

  /// Walk the persisted `turns` array and rebuild [ChatMessage] instances.
  /// Used by [enterReplayMode] to hydrate the chat view from Firestore.
  List<ChatMessage> _messagesFromConversationDoc(Map<String, dynamic> doc) {
    final rawTurns = doc['turns'];
    if (rawTurns is! List) return const [];
    final result = <ChatMessage>[];
    for (final raw in rawTurns) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final typeStr = (map['type'] as String?) ?? 'user';
      MessageType type;
      switch (typeStr) {
        case 'ai':
          type = MessageType.ai;
          break;
        case 'system':
          type = MessageType.system;
          break;
        case 'assessment':
          type = MessageType.assessment;
          break;
        default:
          type = MessageType.user;
      }
      final tsRaw = map['timestamp'] as String?;
      final ts = tsRaw != null ? DateTime.tryParse(tsRaw) : null;
      AssessmentResult? assessment;
      final assessmentRaw = map['assessment'];
      if (assessmentRaw is Map) {
        assessment = AssessmentResult.fromJson(
            Map<String, dynamic>.from(assessmentRaw));
      }
      result.add(ChatMessage(
        id: (map['id'] as String?) ?? _uuid.v4(),
        type: type,
        text: (map['text'] as String?) ?? '',
        timestamp: ts ?? DateTime.now(),
        assessment: assessment,
      ));
    }
    return result;
  }

  Future<void> _saveConversationToFirestore({String? statusOverride}) async {
    if (_uid == null || _conversationId == null || _currentScenario == null) {
      return;
    }
    try {
      await _firebase.saveConversation(
        uid: _uid!,
        conversationId: _conversationId!,
        data: {
          'mode': 'roleplay',
          if (_activeSessionId != null) 'sessionId': _activeSessionId,
          'topic': _currentScenario!.topic,
          'difficulty': _currentScenario!.difficulty,
          'direction': _direction,
          'situation': _currentScenario!.situation,
          'title': _currentScenario!.title,
          'vietnamesePhrase': _currentScenario!.vietnamesePhrase,
          'englishPhrase': _currentScenario!.englishPhrase,
          'sentenceType': _currentScenario!.sentenceType,
          'status': statusOverride ?? 'in-progress',
          'turns': _messages
              .map((m) => {
                    'id': m.id,
                    'type': m.type.name,
                    'text': m.text,
                    'timestamp': m.timestamp.toIso8601String(),
                    if (m.assessment != null)
                      'assessment': m.assessment!.toJson(),
                  })
              .toList(),
          'totalScore': averageScore,
          'createdAt': _sessionStartTime?.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await _local.cacheActiveConversation({
        'conversationId': _conversationId,
        'scenarioId': _currentScenario!.id,
        'topic': _currentScenario!.topic,
      });
    } catch (_) {
      // Silently fail — next successful write will heal
    }
  }

  /// Mark the current scenario as completed, append its metadata to the
  /// in-memory session list, and bump session aggregates. Idempotent — safe
  /// to call multiple times if state allows it; subsequent runs skip when
  /// the scenario id already exists in [_sessionMetas].
  Future<void> _finalizeCurrentScenarioInSession() async {
    if (_activeSessionId == null ||
        _uid == null ||
        _conversationId == null ||
        _currentScenario == null) {
      return;
    }
    // Don't finalize a scenario the learner never answered.
    final hasUserTurn = _messages.any((m) => m.type == MessageType.user);
    if (!hasUserTurn) return;

    final convId = _conversationId!;
    if (_sessionMetas.any((m) => m.conversationId == convId)) return;

    // Persist with `completed` status so listSessionScenarios + history
    // surfaces it correctly.
    await _saveConversationToFirestore(statusOverride: 'completed');

    final score = averageScore.round().clamp(0, 10);
    final tense = _tenseFromLastAssessment();
    _sessionMetas.add(SessionScenarioMeta(
      conversationId: convId,
      orderInSession: _sessionMetas.length + 1,
      sourcePhrase: _direction == 'en-to-vn'
          ? _currentScenario!.englishPhrase
          : _currentScenario!.vietnamesePhrase,
      situation: _currentScenario!.situation,
      totalScore: score,
      tenseDetected: tense,
      doneAt: DateTime.now(),
      status: 'completed',
    ));

    try {
      await _firebase.updateSessionAggregates(
        uid: _uid!,
        sessionId: _activeSessionId!,
        newScore: score,
      );
    } catch (e) {
      debugPrint('[ScenarioProvider] updateSessionAggregates failed: $e');
    }
  }

  /// Walk messages in reverse for the latest assessment that carries a
  /// `grammarBreakdown.userVersion.tense`. Mirrors the same logic used by
  /// [SessionScenarioMeta.fromConversationDoc] so panel rows stay consistent
  /// whether populated locally or rehydrated from Firestore.
  String? _tenseFromLastAssessment() {
    for (final msg in _messages.reversed) {
      final assessment = msg.assessment;
      if (assessment == null) continue;
      final tense = assessment.grammarBreakdown?.userVersion.tense.trim();
      if (tense != null && tense.isNotEmpty) return tense;
    }
    return null;
  }

  /// Fetch roleplay conversations belonging to the current user so the
  /// Start Practice popup can offer to resume an in-progress session.
  Future<List<Map<String, dynamic>>> loadUserConversations() async {
    if (_uid == null) return const [];
    try {
      return await _firebase.getConversations(_uid!, mode: 'roleplay');
    } catch (e) {
      debugPrint('[ScenarioProvider] loadUserConversations failed: $e');
      return const [];
    }
  }

  /// Rehydrate an existing conversation document into an active session. Used
  /// when the learner taps a history card to continue where they left off.
  Future<bool> resumeConversation(String conversationId) async {
    if (_uid == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _firebase.getConversation(_uid!, conversationId);
      if (data == null) {
        _error = 'Conversation not found.';
        return false;
      }

      _currentScenario = Scenario(
        id: data['scenarioId'] as String? ?? _uuid.v4(),
        topic: data['topic'] as String? ?? '',
        title: data['title'] as String? ?? '',
        situation: data['situation'] as String? ?? '',
        vietnamesePhrase: data['vietnamesePhrase'] as String? ?? '',
        englishPhrase: data['englishPhrase'] as String? ?? '',
        difficulty: data['difficulty'] as String? ?? _userLevel,
        sentenceType: data['sentenceType'] as String? ?? '',
        hints: ScenarioHints.fromJson(data['hints'] as Map<String, dynamic>?),
        vocabularyPrep: (data['vocabularyPrep'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
      _currentScenarioSource = ScenarioSource.live;
      _conversationId = conversationId;
      _direction = data['direction'] as String? ?? 'vn-to-en';
      _messages.clear();

      final rawTurns = data['turns'] as List<dynamic>? ?? const [];
      for (final raw in rawTurns) {
        if (raw is! Map<String, dynamic>) continue;
        final typeName = raw['type'] as String? ?? 'user';
        final type = MessageType.values.firstWhere(
          (t) => t.name == typeName,
          orElse: () => MessageType.user,
        );
        AssessmentResult? assessment;
        final rawAssessment = raw['assessment'];
        if (rawAssessment is Map) {
          try {
            assessment = AssessmentResult.fromJson(
                Map<String, dynamic>.from(rawAssessment));
          } catch (e, st) {
            debugPrint('[ScenarioProvider] assessment parse failed: $e\n$st');
          }
        }
        // Never rehydrate an assessment-typed message without a payload —
        // AssessmentCard does `msg.assessment!` and would crash the chat.
        if (type == MessageType.assessment && assessment == null) {
          debugPrint(
              '[ScenarioProvider] dropping orphan assessment turn on resume');
          continue;
        }
        _messages.add(ChatMessage(
          id: raw['id'] as String? ?? _uuid.v4(),
          type: type,
          text: raw['text'] as String? ?? '',
          timestamp: DateTime.tryParse(raw['timestamp'] as String? ?? '') ??
              DateTime.now(),
          assessment: assessment,
        ));
      }

      _sessionStartTime =
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
              DateTime.now();
      _hintsRevealed = 0;
      _scenarioIndex++;
      return true;
    } catch (e) {
      _error = 'Could not resume conversation: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteConversationRecord(String conversationId) async {
    if (_uid == null) return;
    try {
      await _firebase.deleteConversation(
        uid: _uid!,
        conversationId: conversationId,
      );
    } catch (e) {
      debugPrint('[ScenarioProvider] deleteConversationRecord failed: $e');
      rethrow;
    }
  }

  Future<void> renameConversationRecord(
    String conversationId,
    String newTitle,
  ) async {
    if (_uid == null) return;
    try {
      await _firebase.renameConversation(
        uid: _uid!,
        conversationId: conversationId,
        newTitle: newTitle,
      );
    } catch (e) {
      debugPrint('[ScenarioProvider] renameConversationRecord failed: $e');
      rethrow;
    }
  }

  Future<void> endSession() async {
    if (_uid != null && _conversationId != null) {
      unawaited(_firebase.saveConversation(
        uid: _uid!,
        conversationId: _conversationId!,
        data: {
          'status': 'completed',
          'totalScore': averageScore,
          'duration': sessionDurationMinutes,
          'totalTurns': totalTurns,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ).catchError((_) {}));
    }
    unawaited(_local.clearActiveConversation());
  }

  Map<String, dynamic> getSessionSummary() {
    return {
      'topic': _currentScenario?.topic ?? '',
      'difficulty': _currentScenario?.difficulty ?? '',
      'situation': _currentScenario?.situation ?? '',
      'title': _currentScenario?.title ?? '',
      'duration': sessionDurationMinutes,
      'totalTurns': totalTurns,
      'averageScore': averageScore,
      'scenarioIndex': _scenarioIndex,
      'assessments': _messages
          .where(
              (m) => m.type == MessageType.assessment && m.assessment != null)
          .map((m) => m.assessment!)
          .toList(),
    };
  }

  void reset() {
    _currentScenario = null;
    _currentScenarioSource = ScenarioSource.live;
    _conversationId = null;
    _messages.clear();
    _isAiTyping = false;
    _isLoading = false;
    _hintsRevealed = 0;
    _sessionStartTime = null;
    _direction = 'vn-to-en';
    _scenarioIndex = 0;
    _error = null;
    _recentTitles.clear();
    // Intentionally do NOT clear [_seenSentenceHashes] — it is per-user
    // across the app lifetime, not per-session.
    notifyListeners();
  }

  // --- Seen-sentence dedup -------------------------------------------------

  /// Normalize a Vietnamese sentence so two semantically identical outputs
  /// produce the same hash. Steps (cheapest first):
  ///   1. lowercase + trim
  ///   2. collapse any run of whitespace into a single space
  ///   3. strip trailing sentence punctuation (`.?!,;…`)
  ///
  /// We deliberately skip full Unicode NFC normalization — Gemini outputs
  /// NFC-composed text consistently, and pulling in a normalization package
  /// for a near-zero edge case isn't worth the dep.
  String _normalizeVietnamese(String text) {
    final lower = text.toLowerCase().trim();
    final collapsed = lower.replaceAll(_kVietnameseWhitespaceRe, ' ');
    return collapsed.replaceAll(_kVietnameseTrailingPunctRe, '').trim();
  }

  String _hashSentence(String text) {
    final bytes = utf8.encode(_normalizeVietnamese(text));
    return sha1.convert(bytes).toString();
  }

  Future<void> _ensureSeenLoaded() {
    if (_seenLoaded) return Future.value();
    _seenLoadingFuture ??= _loadSeenSentences();
    return _seenLoadingFuture!;
  }

  Future<void> _loadSeenSentences() async {
    if (_uid == null) {
      _seenLoaded = true;
      return;
    }
    try {
      final hashes = await _firebase
          .listSeenSentenceHashes(_uid!)
          .timeout(_kSeenLoadTimeout);
      _seenSentenceHashes.addAll(hashes);

      // First-run backfill: existing users have roleplay history but no
      // seenSentences docs yet. Walk recent conversations, hash their
      // stored vietnamesePhrase, and persist any missing hashes so dedup
      // works from session 1 after the feature ships. getConversations
      // is already capped to 50 so the work is bounded.
      if (hashes.isEmpty) {
        await _backfillSeenFromConversations();
      }
    } catch (e) {
      debugPrint('[ScenarioProvider] _loadSeenSentences failed: $e');
    } finally {
      _seenLoaded = true;
    }
  }

  Future<void> _backfillSeenFromConversations() async {
    if (_uid == null) return;
    try {
      final conversations =
          await _firebase.getConversations(_uid!, mode: 'roleplay');
      for (final convo in conversations) {
        final phrase = convo['vietnamesePhrase'] as String?;
        final convoId = convo['id'] as String?;
        if (phrase == null || phrase.trim().isEmpty || convoId == null) {
          continue;
        }
        final hash = _hashSentence(phrase);
        if (_seenSentenceHashes.add(hash)) {
          unawaited(_firebase
              .saveSeenSentence(
                uid: _uid!,
                hash: hash,
                text: _normalizeVietnamese(phrase),
                conversationId: convoId,
              )
              .catchError((_) {}));
        }
      }
    } catch (e) {
      debugPrint('[ScenarioProvider] seen-sentence backfill failed: $e');
    }
  }

  /// Generate a scenario whose Vietnamese sentence is unique for this user.
  /// Retries up to [_kDedupMaxRetries] times, adding each rejected sentence
  /// to the LLM's exclude-list hint. Falls back to accepting a duplicate
  /// after the cap so the session never fails purely on uniqueness.
  Future<NextLessonOutcome> _generateUniqueScenario({
    required CefrLevel level,
    required List<String> topics,
  }) async {
    await _ensureSeenLoaded();

    final List<String> rejected = [];
    NextLessonOutcome? lastOutcome;
    String? lastPhrase;

    for (var attempt = 0; attempt < _kDedupMaxRetries; attempt++) {
      final outcome = await _gemini
          .generateNextLesson(
            userLevel: level,
            userTopics: topics,
            previousTitles: _recentTitles,
            excludeVietnamesePhrases: rejected,
          )
          .timeout(_kGeminiScenarioTimeout);
      lastOutcome = outcome;

      final parsed = parseJsonObject(outcome.rawJson);
      final phrase = (parsed['vietnamesePhrase'] as String? ?? '').trim();
      lastPhrase = phrase;
      if (phrase.isEmpty) return outcome;

      final hash = _hashSentence(phrase);
      if (!_seenSentenceHashes.contains(hash)) {
        _seenSentenceHashes.add(hash);
        return outcome;
      }

      debugPrint(
          '[ScenarioProvider] duplicate VN sentence on attempt ${attempt + 1}: "$phrase"');
      rejected.add(phrase);
    }

    debugPrint(
        '[ScenarioProvider] dedup exhausted after $_kDedupMaxRetries retries — accepting duplicate "$lastPhrase"');
    if (lastPhrase != null && lastPhrase.isNotEmpty) {
      _seenSentenceHashes.add(_hashSentence(lastPhrase));
    }
    return lastOutcome!;
  }

  void _persistSeenSentence(String phrase) {
    if (_uid == null || _conversationId == null) return;
    final trimmed = phrase.trim();
    if (trimmed.isEmpty) return;
    final hash = _hashSentence(trimmed);
    unawaited(_firebase
        .saveSeenSentence(
          uid: _uid!,
          hash: hash,
          text: _normalizeVietnamese(trimmed),
          conversationId: _conversationId!,
        )
        .catchError((_) {}));
  }
}

/// Captures the active scenario's in-memory state at [enterReplayMode] so
/// [exitReplayMode] can restore it without re-fetching from Firestore.
/// Snapshot is shallow — chat message list is copied so subsequent edits
/// during replay don't mutate it.
class _ReplaySnapshot {
  final Scenario? scenario;
  final ScenarioSource source;
  final String? conversationId;
  final List<ChatMessage> messages;
  final int hintsRevealed;
  final String direction;

  const _ReplaySnapshot({
    this.scenario,
    required this.source,
    this.conversationId,
    required this.messages,
    required this.hintsRevealed,
    required this.direction,
  });
}
