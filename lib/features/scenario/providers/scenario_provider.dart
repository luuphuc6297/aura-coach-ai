// lib/features/scenario/providers/scenario_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/datasources/gemini_datasource.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../core/constants/quota_constants.dart';
import '../models/scenario.dart';
import '../models/chat_message.dart';
import '../models/assessment.dart';
import '../data/scenario_catalog.dart';

const Duration _kGeminiTimeout = Duration(seconds: 12);

bool _isGeminiKeyConfigured() {
  final key = ApiConstants.geminiApiKey.trim();
  if (key.isEmpty) return false;
  if (key.startsWith('your-')) return false;
  return true;
}

class ScenarioProvider extends ChangeNotifier {
  final GeminiDatasource _gemini;
  final FirebaseDatasource _firebase;
  final LocalDatasource _local;
  final _uuid = const Uuid();

  ScenarioProvider({
    required GeminiDatasource gemini,
    required FirebaseDatasource firebase,
    required LocalDatasource local,
  })  : _gemini = gemini,
        _firebase = firebase,
        _local = local;

  // Session state
  String? _uid;
  String? _userTier;
  Scenario? _currentScenario;
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

  // Quota state
  Map<String, int> _dailyUsage = {};
  bool _quotaExceeded = false;

  // Getters
  Scenario? get currentScenario => _currentScenario;
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

    // Load daily usage for quota check
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
      // Fallback to local cache
      _dailyUsage = _local.getCachedDailyUsage(_todayDate) ?? {};
    }
    final limit = roleplayLimitToday;
    _quotaExceeded = limit != -1 && roleplayUsedToday >= limit;
  }

  /// Check if user can start a new session (quota not exceeded).
  bool canStartSession() {
    final limit = roleplayLimitToday;
    if (limit == -1) return true; // Unlimited
    return roleplayUsedToday < limit;
  }

  /// Start a new roleplay session. Generates scenario via Gemini AI.
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
      final selectedTopic = topic ?? (_userTopics..shuffle()).first;
      final selectedDifficulty = difficulty ?? _userLevel;

      Scenario? scenario;

      if (_isGeminiKeyConfigured()) {
        try {
          final rawJson = await _gemini
              .generateScenarioLesson(selectedTopic, selectedDifficulty)
              .timeout(_kGeminiTimeout);
          final json = GeminiDatasource.parseJson(rawJson);
          if (json.isNotEmpty && json['vietnameseSentence'] != null) {
            scenario = Scenario(
              id: _uuid.v4(),
              topic: selectedTopic,
              vietnameseSentence: json['vietnameseSentence'] as String,
              englishTranslation: json['englishTranslation'] as String? ?? '',
              context: json['scenarioContext'] as String? ?? selectedTopic,
              difficulty: json['difficulty'] as String? ?? selectedDifficulty,
              hints: List<String>.from(json['hints'] ?? []),
              vocabularyPrep: List<String>.from(json['vocabularyPrep'] ?? []),
            );
          }
        } catch (_) {
          // AI failed or timed out — fall through to catalog
        }
      }

      // Fallback to static catalog if AI skipped or failed
      scenario ??= _pickCatalogScenario(selectedTopic, selectedDifficulty);
      if (scenario == null) {
        _error = 'No scenarios available for this topic.';
        return;
      }

      _currentScenario = scenario;
      _conversationId = _uuid.v4();
      _messages.clear();
      _hintsRevealed = 0;
      _sessionStartTime = DateTime.now();
      _scenarioIndex++;
      _direction = 'vn-to-en';

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.ai,
        text:
            'Great! Let\'s practice this scenario.\n\n**Topic:** ${scenario.topic}\n**Difficulty:** ${scenario.difficulty}\n\n**Your task:** Translate the sentence above into English.',
        timestamp: DateTime.now(),
      ));

      // Fire-and-forget: never block UI on Firestore writes
      _dailyUsage['roleplayCount'] = roleplayUsedToday + 1;
      unawaited(_firebase
          .incrementDailyUsage(_uid!, _todayDate, 'roleplay')
          .catchError((_) {}));
      unawaited(_saveConversationToFirestore());
    } catch (e) {
      _error = 'Failed to start scenario: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Scenario? _pickCatalogScenario(String topic, String difficulty) {
    final exact = scenarioCatalog
        .where((s) =>
            s.topic == topic &&
            s.difficulty == difficulty &&
            s.id != _currentScenario?.id)
        .toList();
    if (exact.isNotEmpty) {
      exact.shuffle();
      return exact.first;
    }
    final anyForTopic =
        scenarioCatalog.where((s) => s.topic == topic).toList();
    if (anyForTopic.isNotEmpty) {
      anyForTopic.shuffle();
      return anyForTopic.first;
    }
    return null;
  }

  /// Send user message and get AI assessment.
  Future<void> sendUserMessage(String text) async {
    if (_currentScenario == null) return;

    // Add user message immediately
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
      if (!_isGeminiKeyConfigured()) {
        throw StateError('Gemini API key not configured');
      }
      final rawJson = await _gemini
          .evaluateUserResponse(
            userText: text,
            scenarioContext: _currentScenario!.context,
            vietnameseSentence: _direction == 'vn-to-en'
                ? _currentScenario!.vietnameseSentence
                : _currentScenario!.englishTranslation,
            proficiencyLevel: _userLevel,
            direction: _direction,
          )
          .timeout(_kGeminiTimeout);

      final json = GeminiDatasource.parseJson(rawJson);
      final assessment = AssessmentResult.fromJson(json);

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.assessment,
        text: '',
        timestamp: DateTime.now(),
        assessment: assessment,
      ));

      unawaited(_saveConversationToFirestore());
    } catch (e) {
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

  /// Start a new scenario with optional difficulty adjustment.
  Future<void> startNewScenario({String? difficulty}) async {
    final adjustedDifficulty = _adjustDifficulty(difficulty);
    await startSession(difficulty: adjustedDifficulty);
  }

  String _adjustDifficulty(String? adjustment) {
    if (adjustment == null) return _userLevel;
    final levels = ['beginner', 'intermediate', 'advanced'];
    final currentIndex = levels.indexOf(_currentScenario?.difficulty ?? _userLevel);
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
    if (_hintsRevealed < _currentScenario!.hints.length) {
      _hintsRevealed++;
      notifyListeners();
    }
  }

  /// Save current conversation state to Firestore.
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
          'scenarioContext': _currentScenario!.context,
          'vietnameseSentence': _currentScenario!.vietnameseSentence,
          'englishTranslation': _currentScenario!.englishTranslation,
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

      // Also cache locally
      await _local.cacheActiveConversation({
        'conversationId': _conversationId,
        'scenarioId': _currentScenario!.id,
        'topic': _currentScenario!.topic,
      });
    } catch (_) {
      // Silently fail — local cache is the fallback
    }
  }

  /// End the current session and mark as completed in Firestore.
  /// Fire-and-forget — never block the UI on the write.
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

  /// Get session summary data for the summary screen.
  Map<String, dynamic> getSessionSummary() {
    return {
      'topic': _currentScenario?.topic ?? '',
      'difficulty': _currentScenario?.difficulty ?? '',
      'context': _currentScenario?.context ?? '',
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
    _conversationId = null;
    _messages.clear();
    _isAiTyping = false;
    _isLoading = false;
    _hintsRevealed = 0;
    _sessionStartTime = null;
    _direction = 'vn-to-en';
    _scenarioIndex = 0;
    _error = null;
    notifyListeners();
  }
}
