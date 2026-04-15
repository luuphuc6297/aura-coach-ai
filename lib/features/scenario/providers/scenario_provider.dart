// lib/features/scenario/providers/scenario_provider.dart
import 'dart:async';
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

const Duration _kGeminiScenarioTimeout = Duration(seconds: 30);
const Duration _kGeminiEvaluateTimeout = Duration(seconds: 20);

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

  // Quota state
  Map<String, int> _dailyUsage = {};
  bool _quotaExceeded = false;

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

  int get sessionDurationMinutes {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inMinutes;
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
          final outcome = await _gemini
              .generateNextLesson(
                userLevel: cefrLevel,
                userTopics: topics,
                previousTitles: _recentTitles,
              )
              .timeout(_kGeminiScenarioTimeout);

          final parsed = parseJsonObject(outcome.rawJson);
          scenario = Scenario.fromJson(parsed).copyWith(
            id: _uuid.v4(),
            topic: parsed['topic'] as String? ?? outcome.chosenTopic,
            sentenceType: parsed['sentenceType'] as String? ??
                outcome.chosenSentenceType,
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

      _currentScenario = scenario;
      _currentScenarioSource = source;
      _conversationId = _uuid.v4();
      _messages.clear();
      _hintsRevealed = 0;
      _sessionStartTime = DateTime.now();
      _scenarioIndex++;
      _direction = 'vn-to-en';

      final banner = source == ScenarioSource.cache
          ? '\n\n_Showing your last cached lesson — AI is unavailable right now._'
          : '';
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.ai,
        text:
            'Great! Let\'s practice this scenario.\n\n**Topic:** ${scenario.topic}\n**Difficulty:** ${scenario.difficulty}\n\n**Your task:** Translate the sentence above into English.$banner',
        timestamp: DateTime.now(),
      ));

      if (source == ScenarioSource.live) {
        _dailyUsage['roleplayCount'] = roleplayUsedToday + 1;
        unawaited(_firebase
            .incrementDailyUsage(_uid!, _todayDate, 'roleplay')
            .catchError((_) {}));
        unawaited(_saveConversationToFirestore());
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

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isAiTyping = true;
    _error = null;
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

      final assessment =
          AssessmentResult.fromJson(parseJsonObject(rawJson));

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
      _isAiTyping = false;
      notifyListeners();
    }
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

  Future<void> _saveConversationToFirestore() async {
    if (_uid == null || _conversationId == null || _currentScenario == null) {
      return;
    }
    try {
      await _firebase.saveConversation(
        uid: _uid!,
        conversationId: _conversationId!,
        data: {
          'mode': 'roleplay',
          'topic': _currentScenario!.topic,
          'difficulty': _currentScenario!.difficulty,
          'direction': _direction,
          'situation': _currentScenario!.situation,
          'title': _currentScenario!.title,
          'vietnamesePhrase': _currentScenario!.vietnamesePhrase,
          'englishPhrase': _currentScenario!.englishPhrase,
          'sentenceType': _currentScenario!.sentenceType,
          'status': 'in-progress',
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

  Future<void> endSession() async {
    if (_uid != null && _conversationId != null) {
      unawaited(_firebase
          .saveConversation(
            uid: _uid!,
            conversationId: _conversationId!,
            data: {
              'status': 'completed',
              'totalScore': averageScore,
              'duration': sessionDurationMinutes,
              'totalTurns': totalTurns,
              'updatedAt': DateTime.now().toIso8601String(),
            },
          )
          .catchError((_) {}));
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
    notifyListeners();
  }
}
