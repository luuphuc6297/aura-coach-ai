import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/quota_constants.dart';
import '../../../core/constants/story_constants.dart';
import '../../../data/cache/story_cache.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/helpers.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../../../data/repositories/story_repository.dart';
import '../../my_library/models/saved_item.dart';
import '../../scenario/models/assessment.dart';
import '../models/story.dart';
import '../models/story_character.dart';
import '../models/story_session.dart';
import '../models/story_turn.dart';

/// State container for Story Mode. Owns:
/// - Featured library fetch (via [StoryRepository])
/// - Daily quota check against [QuotaConstants]
/// - Session lifecycle: start from library / custom, send messages with
///   INLINE assessment, end, abandon, resume from a Firestore doc
/// - Vocab save handoff (Improvement -> SavedItem)
///
/// Invariants:
/// - Assessments are stored INLINE on the user's own [StoryTurn] — there is
///   no separate `role='assessment'` turn.
/// - Daily quota is only charged on a successful generation.
/// - Resume is driven by the Home entry-flow popup. No SharedPreferences
///   auto-resume in MVP.
class StoryProvider extends ChangeNotifier {
  StoryProvider({
    required GeminiService gemini,
    required FirebaseDatasource firebase,
    required LocalDatasource local,
    required StoryCache cache,
    required StoryRepository repository,
  })  : _gemini = gemini,
        _firebase = firebase,
        _local = local,
        _cache = cache,
        _repository = repository;

  final GeminiService _gemini;
  final FirebaseDatasource _firebase;
  // Reserved for dormant local-cache resume. Kept so MVP can enable it later
  // without a signature change.
  // ignore: unused_field
  final LocalDatasource _local;
  // ignore: unused_field
  final StoryCache _cache;
  final StoryRepository _repository;
  final Uuid _uuid = const Uuid();

  String? _uid;
  String _tier = 'free';
  String _level = 'B1';

  List<Story> _featured = const [];
  List<Story> _otherLevels = const [];
  StorySession? _session;
  Map<String, int> _usage = const {};
  final List<String> _recentTitles = [];
  bool _isLoading = false;
  String? _error;
  Object? _persistenceError;

  /// Monotonically increasing id for the current in-flight [sendUserMessage]
  /// call. Bumped on every new send AND on [cancelCurrentMessage] — any
  /// in-flight awaits check the captured seq against this field and silently
  /// drop their result if the user already cancelled.
  int _sendSeq = 0;

  /// Turn count BEFORE the current in-flight send appended its placeholder.
  /// Lets [cancelCurrentMessage] truncate the turn list back to the exact
  /// pre-send snapshot even if the Gemini call already returned and applied
  /// assessment + agent reply while persist was still awaiting.
  int? _pendingSendBaseCount;

  /// Per-turn seq for in-flight translations. [translateAiMessage] captures
  /// the current value; on a new send, [_invalidateTranslations] bumps the
  /// counter for every active turn so stale results are dropped.
  final Map<String, int> _translateSeqs = {};

  /// Translation cache keyed by turn id. Populated on demand when the user
  /// taps "Translate" on an AI bubble. Never persisted — a fresh app launch
  /// will re-translate on request.
  final Map<String, String> _aiTranslations = {};

  /// Set of turn ids currently being translated. Drives per-bubble spinner
  /// state in the chat screen.
  final Set<String> _translatingIds = {};

  /// Level1/2/3 hints for the CURRENT AI turn awaiting the learner's reply.
  /// Reset every time a new AI turn arrives so hints never carry across
  /// turns. On the very first turn these are populated from the cached
  /// [StorySession.openingHints]; later turns generate fresh hints via
  /// [GeminiService.generateStoryReplyHints].
  List<String>? _currentHints;

  /// How many hints the user has revealed so far (0-3). Increments on each
  /// tap of the "Hint" affordance up to the length of [_currentHints].
  int _revealedHintLevel = 0;

  /// True while [requestNextHint] is loading fresh hints from Gemini.
  bool _isHintLoading = false;

  /// Surfaced to the chat screen so the hint sheet can render a specific
  /// error ("Couldn't load hint — try again") instead of the chat-level
  /// error banner.
  String? _hintError;

  List<Story> get featuredLibrary => List.unmodifiable(_featured);

  /// Stories outside the learner's proficiency band, sorted closest first.
  /// Rendered as the "Other Levels" section on the Story Home screen so
  /// users can stretch up or ease back without re-opening settings.
  List<Story> get otherLevels => List.unmodifiable(_otherLevels);

  StorySession? get activeSession => _session;
  int get storyUsedToday => _usage['storyCount'] ?? 0;

  /// Daily cap for the current tier. Returns -1 for unlimited (premium).
  /// Exposed so the Home entry sheet can render a quota badge without
  /// reaching into [QuotaConstants] itself.
  int get storyLimit => _storyLimit;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Object? get persistenceError => _persistenceError;

  /// Number of revealed hints. `0` means the user has not tapped Hint yet.
  int get revealedHintLevel => _revealedHintLevel;

  /// Loaded hints list (length 3). Null before the first hint request for
  /// the current turn. Only the first [_revealedHintLevel] entries should be
  /// shown to the user.
  List<String>? get currentHints =>
      _currentHints == null ? null : List.unmodifiable(_currentHints!);

  bool get isHintLoading => _isHintLoading;
  String? get hintError => _hintError;

  /// Translation of [turnId] if available, otherwise null.
  String? translationFor(String turnId) => _aiTranslations[turnId];

  /// True while the translation for [turnId] is in flight.
  bool isTranslatingTurn(String turnId) => _translatingIds.contains(turnId);

  int get _storyLimit => QuotaConstants.getLimit(_tier, 'story');

  String get _todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ---------- Init + library ----------

  Future<void> init({
    required String uid,
    required String tier,
    required String level,
  }) async {
    _uid = uid;
    _tier = tier;
    _level = level;
    _isLoading = true;
    notifyListeners();

    try {
      _usage = await _firebase
          .getDailyUsage(uid, _todayDate)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      _usage = const {'storyCount': 0};
    }

    await refreshLibrary();
  }

  Future<void> refreshLibrary() async {
    try {
      final featuredFuture = _repository.fetchFeatured(level: _level);
      final otherFuture = _repository.fetchOtherLevels(userLevel: _level);
      final results = await Future.wait([featuredFuture, otherFuture]);
      _featured = results[0];
      _otherLevels = results[1];
      _error = null;
    } catch (e) {
      _error = 'Could not load library: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool canStartSession() {
    final limit = _storyLimit;
    if (limit == -1) return true;
    return storyUsedToday < limit;
  }

  /// Loads the current user's conversations with `mode='story'` and any
  /// status other than `completed`. Consumed by the Home entry-flow popup so
  /// the user can resume an earlier story. Mirrors Scenario's equivalent
  /// helper. Legacy `abandoned` docs are folded back into this list (they
  /// normalise to `inProgress` on read) so older sessions are recoverable.
  Future<List<Map<String, dynamic>>> loadUserStoryConversations() async {
    final uid = _uid;
    if (uid == null) return const [];
    try {
      final all = await _firebase.getConversations(uid, mode: 'story');
      return all.where((c) => (c['status'] as String?) != 'completed').toList();
    } catch (_) {
      return const [];
    }
  }

  // ---------- Start session ----------

  Future<bool> startFromLibrary(Story story) async {
    if (!canStartSession()) {
      _error = 'Daily limit reached. Upgrade for more sessions.';
      notifyListeners();
      return false;
    }
    return _startSession(
      storyId: story.id,
      topic: story.topic,
      level: story.level,
      situation: story.situation,
      libraryCharacter: story.character,
      customContext: story.situation,
      characterPreference: null,
    );
  }

  Future<bool> startFromCustom({
    required String topic,
    required String level,
    required String characterPreference,
    String? customContext,
  }) async {
    if (!canStartSession()) {
      _error = 'Daily limit reached. Upgrade for more sessions.';
      notifyListeners();
      return false;
    }
    return _startSession(
      storyId: null,
      topic: topic,
      level: level,
      situation: customContext ?? '',
      libraryCharacter: null,
      customContext: customContext,
      characterPreference: characterPreference,
    );
  }

  Future<bool> _startSession({
    required String? storyId,
    required String topic,
    required String level,
    required String situation,
    required StoryCharacter? libraryCharacter,
    required String? customContext,
    required String? characterPreference,
  }) async {
    if (_uid == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cefr = CefrLevel.fromProficiencyId(level);
      final raw = await _gemini
          .generateStoryScenario(
            level: cefr,
            topic: topic,
            previousTitles: List<String>.from(_recentTitles),
            customContext: customContext,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Story generation timed out. Check your connection and try again.',
            ),
          );
      final parsed = _safeParse(raw);

      final agentOpening = (parsed['openingLine'] as String?) ??
          (parsed['agentOpeningLine'] as String?) ??
          'Hi!';
      final aiAgentName = (parsed['agentName'] as String?) ?? 'Coach';
      final aiSituation = (parsed['situation'] as String?) ?? situation;
      final aiTitle =
          (parsed['title'] as String?) ?? (parsed['topic'] as String?) ?? topic;
      final openingHints = _readHintList(parsed['hints']);

      final character = libraryCharacter ??
          _buildCharacterFromAi(aiAgentName, characterPreference);

      final conversationId = _uuid.v4();
      final now = DateTime.now();

      final openingTurn = StoryTurn(
        id: _uuid.v4(),
        role: StoryTurnRole.ai,
        text: agentOpening,
        timestamp: now,
      );

      final session = StorySession(
        conversationId: conversationId,
        storyId: storyId,
        title: aiTitle,
        situation: aiSituation,
        character: character,
        topic: topic,
        level: level,
        customContext: customContext,
        characterPreference: characterPreference,
        status: StorySessionStatus.inProgress,
        turns: [openingTurn],
        startedAt: now,
        endedAt: null,
        updatedAt: now,
        quotaCharged: true,
        openingHints: openingHints,
      );

      _session = session;
      _resetTransientChatState();
      _recentTitles.add(aiTitle);
      if (_recentTitles.length > 5) _recentTitles.removeAt(0);

      _usage = {..._usage, 'storyCount': storyUsedToday + 1};
      unawaited(_firebase
          .incrementDailyUsage(_uid!, _todayDate, 'story')
          .catchError((_) {}));

      // Fire-and-forget the Firestore write so UI can navigate to chat instantly.
      // _persistSession swallows errors into _persistenceError, so dropping the
      // await is safe. Matches the pattern in endSession.
      unawaited(_persistSession(session));
      return true;
    } on TimeoutException catch (e) {
      debugPrint('[StoryProvider] _startSession timeout: $e');
      _error = e.message ??
          'Story generation timed out. Check your connection and try again.';
      _session = null;
      return false;
    } catch (e) {
      debugPrint('[StoryProvider] _startSession failed: $e');
      _error = "Couldn't generate story, please try again.";
      _session = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- Send message ----------

  Future<void> sendUserMessage(String text) async {
    final session = _session;
    if (session == null || _uid == null) return;
    if (text.trim().isEmpty) return;

    if (session.userTurnCount >= StoryConstants.hardCapUserTurns) {
      _error = 'Story session has reached the hard cap.';
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final agentLast = session.turns
        .lastWhere(
          (t) => t.role == StoryTurnRole.ai,
          orElse: () => StoryTurn(
            id: '',
            role: StoryTurnRole.ai,
            text: '',
            timestamp: now,
          ),
        )
        .text;

    final userTurnPlaceholder = StoryTurn(
      id: _uuid.v4(),
      role: StoryTurnRole.user,
      text: text,
      timestamp: now,
    );

    // Drop any in-flight translate spinners so the chat doesn't show two
    // competing loading states while the main send is running.
    _invalidateTranslations();

    _pendingSendBaseCount = session.turns.length;
    _session = session.copyWith(
      turns: [...session.turns, userTurnPlaceholder],
      updatedAt: now,
    );
    _isLoading = true;
    final seq = ++_sendSeq;
    notifyListeners();

    try {
      // 30s provider-level ceiling so a slow Gemini call surfaces as an
      // actionable error instead of a 90s hang (Gemini layer already caps
      // each attempt at 45s and retries once).
      final raw = await _gemini
          .evaluateStoryTurn(
            situation: session.situation,
            agentName: session.character.name,
            agentLastMessage: agentLast,
            userReply: text,
            targetLevel: CefrLevel.fromProficiencyId(session.level),
          )
          .timeout(const Duration(seconds: 30));
      if (seq != _sendSeq) return;
      final parsed = _safeParse(raw);
      final assessment = AssessmentResult.fromJson(parsed);

      final assessedUserTurn = userTurnPlaceholder.copyWith(
        assessment: assessment,
      );
      final agentReplyText =
          (parsed['nextAgentReply'] as String?) ?? 'Mm, go on.';
      final agentTurn = StoryTurn(
        id: _uuid.v4(),
        role: StoryTurnRole.ai,
        text: agentReplyText,
        timestamp: DateTime.now(),
      );

      final newTurns = [...session.turns, assessedUserTurn, agentTurn];
      _session = session.copyWith(turns: newTurns, updatedAt: DateTime.now());
      _resetHintState();
      _error = null;
      await _persistSession(_session!);
    } catch (e) {
      if (seq != _sendSeq) return;
      debugPrint('[StoryProvider] evaluateStoryTurn failed: $e');
      _error = "Couldn't evaluate that reply. Try again.";
    } finally {
      if (seq == _sendSeq) {
        _isLoading = false;
        _pendingSendBaseCount = null;
        notifyListeners();
      }
    }
  }

  /// Cancel the current in-flight [sendUserMessage]. Truncates the turn list
  /// back to `baseCount + 1` — i.e. we KEEP the user bubble the learner just
  /// sent but drop anything the call has already applied on top of it
  /// (assessment on the user turn, appended agent reply). The in-flight
  /// Gemini call keeps running — it cannot be killed from Dart — but the
  /// seq check in [sendUserMessage] drops its result and the persist-queue
  /// drop is idempotent.
  ///
  /// Keeping the user bubble matches how every major chat UI handles Stop:
  /// the learner's own message never disappears under them.
  void cancelCurrentMessage() {
    if (!_isLoading || _session == null) return;
    _sendSeq++;
    final baseCount = _pendingSendBaseCount;
    if (baseCount != null) {
      final keepUpTo = baseCount + 1;
      if (_session!.turns.length > keepUpTo) {
        _session = _session!.copyWith(
          turns: _session!.turns.sublist(0, keepUpTo),
          updatedAt: DateTime.now(),
        );
      }
    }
    _pendingSendBaseCount = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Invalidate every in-flight translation by bumping their per-turn seq.
  /// Called at the start of [sendUserMessage] so late translate results
  /// don't mutate session state under a different Gemini call, and the
  /// Translate pill spinner clears immediately.
  void _invalidateTranslations() {
    if (_translatingIds.isEmpty) return;
    for (final id in _translatingIds) {
      _translateSeqs[id] = (_translateSeqs[id] ?? 0) + 1;
    }
    _translatingIds.clear();
  }

  // ---------- End / abandon / resume / vocab ----------

  Future<void> endSession() async {
    final session = _session;
    if (session == null || _uid == null) return;

    final now = DateTime.now();
    final ended = session.copyWith(
      status: StorySessionStatus.completed,
      endedAt: now,
      updatedAt: now,
    );
    _session = ended;
    // Fire-and-forget the Firestore write so UI navigation is instant.
    // _persistSession already swallows errors into _persistenceError, so
    // dropping the await is safe.
    unawaited(_persistSession(ended));
    notifyListeners();
  }

  Future<void> saveCorrectionToVocab(Improvement improvement) async {
    if (_uid == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = SavedItem(
      id: _uuid.v4(),
      original: improvement.original,
      correction: improvement.correction,
      type: improvement.type.value,
      context: _session?.situation ?? '',
      timestamp: now,
      nextReviewDate: now.toDouble(),
    );
    try {
      await _firebase.saveSavedItem(_uid!, item);
    } catch (e) {
      debugPrint('[StoryProvider] saveCorrectionToVocab failed: $e');
    }
  }

  /// Rehydrates an in-progress story conversation from Firestore. Called
  /// from the Home entry-flow popup when the user taps a resume card.
  /// Returns `true` on success, `false` if the doc is missing or the
  /// conversation is not in-progress.
  Future<bool> resumeSession(String conversationId) async {
    if (_uid == null) {
      debugPrint('[StoryProvider] resumeSession: no uid set');
      return false;
    }
    try {
      final raw = await _firebase.getConversation(_uid!, conversationId);
      if (raw == null) {
        debugPrint(
          '[StoryProvider] resumeSession: doc missing ($conversationId)',
        );
        _error = 'That story was not found. It may have been deleted.';
        notifyListeners();
        return false;
      }
      final session = StorySession.fromJson(raw);
      if (session.status != StorySessionStatus.inProgress) {
        debugPrint(
          '[StoryProvider] resumeSession: status=${session.status} not in-progress',
        );
        _error = 'That story is no longer in progress.';
        notifyListeners();
        return false;
      }
      _session = session;
      _resetTransientChatState();
      _error = null;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('[StoryProvider] resumeSession failed: $e\n$st');
      _error = 'Could not resume that story. Try again.';
      notifyListeners();
      return false;
    }
  }

  // ---------- Hints ----------

  /// Reveal the next hint level for the AI turn the learner is currently
  /// responding to. First call loads the hints (from [StorySession.openingHints]
  /// on the opening turn, or a fresh Gemini call on subsequent turns) and
  /// reveals level 1. Subsequent calls reveal levels 2 and 3.
  Future<void> requestNextHint() async {
    final session = _session;
    if (session == null) return;
    if (_isHintLoading) return;
    if (_currentHints != null && _revealedHintLevel >= _currentHints!.length) {
      return; // Already revealed everything available for this turn.
    }

    // Load hints the first time the user taps on this turn.
    if (_currentHints == null) {
      _isHintLoading = true;
      _hintError = null;
      notifyListeners();

      try {
        final List<String> loaded;
        if (session.userTurnCount == 0 && session.openingHints != null) {
          loaded = session.openingHints!;
        } else {
          loaded = await _fetchReplyHints(session);
        }
        if (loaded.isEmpty) {
          _hintError = "No hints available for this turn.";
        } else {
          _currentHints = loaded;
        }
      } catch (e) {
        debugPrint('[StoryProvider] requestNextHint fetch failed: $e');
        _hintError = "Couldn't load hint. Try again.";
      } finally {
        _isHintLoading = false;
      }
    }

    if (_currentHints != null &&
        _revealedHintLevel < _currentHints!.length &&
        _hintError == null) {
      _revealedHintLevel += 1;
    }
    notifyListeners();
  }

  Future<List<String>> _fetchReplyHints(StorySession session) async {
    final lastAi = session.turns.lastWhere(
      (t) => t.role == StoryTurnRole.ai || t.role == StoryTurnRole.system,
      orElse: () => StoryTurn(
        id: '',
        role: StoryTurnRole.ai,
        text: '',
        timestamp: DateTime.now(),
      ),
    );
    if (lastAi.text.trim().isEmpty) return const [];

    final raw = await _gemini
        .generateStoryReplyHints(
          situation: session.situation,
          agentName: session.character.name,
          agentMessage: lastAi.text,
          level: CefrLevel.fromProficiencyId(session.level),
        )
        .timeout(const Duration(seconds: 20));
    return _readHintList(_safeParse(raw)) ?? const [];
  }

  void dismissHintError() {
    if (_hintError == null) return;
    _hintError = null;
    notifyListeners();
  }

  // ---------- Translation ----------

  /// Translate an AI message into Vietnamese on demand. Caches the result
  /// by turn id so repeated taps are free.
  Future<void> translateAiMessage(String turnId, String text) async {
    if (text.trim().isEmpty) return;
    if (_aiTranslations.containsKey(turnId)) return;
    if (_translatingIds.contains(turnId)) return;

    _translatingIds.add(turnId);
    final seq = _translateSeqs[turnId] ?? 0;
    notifyListeners();

    try {
      final vn = await _gemini
          .translateToVietnamese(text)
          .timeout(const Duration(seconds: 20));
      if (seq != (_translateSeqs[turnId] ?? 0)) return;
      _aiTranslations[turnId] = vn;
    } catch (e) {
      if (seq != (_translateSeqs[turnId] ?? 0)) return;
      debugPrint('[StoryProvider] translateAiMessage failed: $e');
      // Soft failure — we surface it via a transient snackbar from the
      // screen; no persistent error state for translations.
    } finally {
      if (seq == (_translateSeqs[turnId] ?? 0)) {
        _translatingIds.remove(turnId);
        notifyListeners();
      }
    }
  }

  // ---------- Helpers ----------

  /// Clear per-turn hint progression. Called after a new AI turn arrives so
  /// the next "Hint" tap starts at level 1 again.
  void _resetHintState() {
    _currentHints = null;
    _revealedHintLevel = 0;
    _isHintLoading = false;
    _hintError = null;
  }

  /// Clear chat-session transient state (hints, translations) when a new
  /// session starts or an existing one is rehydrated from Firestore.
  void _resetTransientChatState() {
    _resetHintState();
    _aiTranslations.clear();
    _translatingIds.clear();
    _translateSeqs.clear();
  }

  /// Extract a level1/level2/level3 hint list from a Gemini JSON payload.
  /// Returns null if the payload doesn't contain a usable hints block so
  /// callers can fall back to a "no hints" state.
  List<String>? _readHintList(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final hints = <String>[];
    for (final key in const ['level1', 'level2', 'level3']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        hints.add(value.trim());
      }
    }
    return hints.isEmpty ? null : hints;
  }

  /// Best-effort JSON parser. Production Gemini sometimes emits markdown
  /// fences — [parseJsonObject] strips them. Returns `{}` on malformed input
  /// so the calling code can fall back to default field values without
  /// throwing the whole flow.
  Map<String, dynamic> _safeParse(String raw) {
    try {
      return parseJsonObject(raw);
    } catch (_) {
      return const {};
    }
  }

  StoryCharacter _buildCharacterFromAi(
    String agentName,
    String? preference,
  ) {
    final initial =
        agentName.isNotEmpty ? agentName.substring(0, 1).toUpperCase() : '?';
    const gradients = StoryConstants.characterGradients;
    final gradient = gradients[agentName.hashCode.abs() % gradients.length];
    final personality = preference == null || preference == 'Any'
        ? 'warm, helpful'
        : '$preference, expressive';
    return StoryCharacter(
      name: agentName,
      role: 'Conversation partner',
      personality: personality,
      initial: initial,
      gradient: gradient,
    );
  }

  Future<void> _persistSession(StorySession session) async {
    if (_uid == null) return;
    try {
      await _firebase.saveConversation(
        uid: _uid!,
        conversationId: session.conversationId,
        data: session.toJson()
          ..addAll({'createdAt': session.startedAt.toIso8601String()}),
      );
      _persistenceError = null;
    } catch (e) {
      // Surface the raw error so callers can decide how to present it.
      // UI layer converts to a user-facing message in _PersistenceBanner.
      _persistenceError = e;
    }
  }
}
