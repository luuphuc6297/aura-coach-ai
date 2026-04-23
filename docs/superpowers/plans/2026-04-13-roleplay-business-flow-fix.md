# Roleplay (Scenario Coach) — Business Flow Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all critical gaps between the Roleplay feature's current implementation and its business flow specification — add Gemini AI integration, Firestore persistence, quota enforcement, proper routing, and missing screens (Lesson Selection, Session Summary).

**Architecture:** The current codebase has solid UI widgets (AssessmentCard, ChatBubbles, LessonCard, RadarScore, etc.) but zero backend integration. This plan adds: (1) `GeminiDatasource` for real AI calls, (2) Firestore conversation persistence via `FirebaseDatasource`, (3) daily usage quota tracking, (4) `ScenarioProvider` rebuilt with proper dependency injection, (5) two missing screens, (6) proper GoRouter routes with params. The existing UI widgets are preserved and reused.

**Tech Stack:** Flutter 3.x, Provider (ChangeNotifier), GoRouter v17+, Cloud Firestore, Google Generative AI SDK (`google_generative_ai`), SharedPreferences, Clay Design System tokens.

---

## File Structure

```
lib/
├── core/constants/
│   ├── api_constants.dart              — CREATE: Gemini model names, API key loader, quotas
│   └── quota_constants.dart            — CREATE: Usage limits per tier
├── data/datasources/
│   ├── firebase_datasource.dart        — MODIFY: Add conversation + usage CRUD methods
│   ├── gemini_datasource.dart          — CREATE: All Gemini AI functions for roleplay
│   └── local_datasource.dart           — MODIFY: Add conversation cache methods
├── features/scenario/
│   ├── models/
│   │   ├── scenario.dart               — KEEP (no changes)
│   │   ├── chat_message.dart           — KEEP (no changes)
│   │   └── assessment.dart             — MODIFY: Add fromJson factory
│   ├── data/
│   │   └── scenario_catalog.dart       — KEEP (fallback data)
│   ├── providers/
│   │   └── scenario_provider.dart      — REWRITE: Full DI, AI calls, persistence, quota
│   ├── screens/
│   │   ├── scenario_select_screen.dart — CREATE: Topic + difficulty picker
│   │   ├── scenario_chat_screen.dart   — MODIFY: Wire to new provider API
│   │   ├── session_summary_screen.dart — CREATE: End-of-session stats
│   │   └── conversation_history_screen.dart — MODIFY: Read from Firestore
│   └── widgets/
│       └── (all existing widgets kept unchanged)
├── app.dart                            — MODIFY: Routes + provider DI
└── pubspec.yaml                        — MODIFY: Add google_generative_ai + flutter_dotenv
```

---

## Task 1: Add Dependencies (pubspec.yaml)

**Files:**
- Modify: `pubspec.yaml`
- Create: `.env` (project root, gitignored)

- [ ] **Step 1: Add google_generative_ai and flutter_dotenv to pubspec.yaml**

```yaml
# Add under dependencies: (after uuid: ^4.1.0)
  google_generative_ai: ^0.4.6
  flutter_dotenv: ^5.2.1
```

- [ ] **Step 2: Create .env file in project root**

```
GEMINI_API_KEY=your-gemini-api-key-here
```

- [ ] **Step 3: Add .env to .gitignore**

Append to `.gitignore`:
```
.env
```

- [ ] **Step 4: Add .env to flutter assets in pubspec.yaml**

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
```

- [ ] **Step 5: Update main.dart to load dotenv**

In `lib/main.dart`, add dotenv loading before `runApp`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  runApp(AuraCoachApp(prefs: prefs));
}
```

- [ ] **Step 6: Run flutter pub get**

```bash
cd /sessions/kind-quirky-hypatia/mnt/aura-coach-ai && flutter pub get
```

Expected: Dependencies resolve successfully.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock .gitignore lib/main.dart
git commit -m "chore: add google_generative_ai + flutter_dotenv dependencies"
```

---

## Task 2: Create ApiConstants and QuotaConstants

**Files:**
- Create: `lib/core/constants/api_constants.dart`
- Create: `lib/core/constants/quota_constants.dart`

- [ ] **Step 1: Create api_constants.dart**

```dart
// lib/core/constants/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const modelFlash = 'gemini-2.0-flash';
  static const modelPro = 'gemini-2.0-pro';

  static const temperature = 0.7;
  static const topP = 0.95;
  static const topK = 40;
  static const maxTokensFlash = 2048;
  static const maxTokensPro = 4096;
}
```

- [ ] **Step 2: Create quota_constants.dart**

```dart
// lib/core/constants/quota_constants.dart
class QuotaConstants {
  QuotaConstants._();

  // Free tier limits (per day)
  static const freeRoleplayQuota = 5;
  static const freeStoryQuota = 3;
  static const freeTranslatorQuota = 10;
  static const freeDictionaryQuota = 5;
  static const freeMindMapQuota = 3;
  static const freeTtsQuota = 5;

  // Pro tier limits
  static const proRoleplayQuota = 15;
  static const proStoryQuota = 10;
  static const proTranslatorQuota = -1; // Unlimited
  static const proDictionaryQuota = -1;
  static const proMindMapQuota = 10;
  static const proTtsQuota = 15;

  // Premium = all unlimited (-1)

  static int getLimit(String tier, String feature) {
    final limits = {
      'free': {
        'roleplay': freeRoleplayQuota,
        'story': freeStoryQuota,
        'translator': freeTranslatorQuota,
        'dictionary': freeDictionaryQuota,
        'mindmap': freeMindMapQuota,
        'tts': freeTtsQuota,
      },
      'pro': {
        'roleplay': proRoleplayQuota,
        'story': proStoryQuota,
        'translator': proTranslatorQuota,
        'dictionary': proDictionaryQuota,
        'mindmap': proMindMapQuota,
        'tts': proTtsQuota,
      },
      'premium': {
        'roleplay': -1,
        'story': -1,
        'translator': -1,
        'dictionary': -1,
        'mindmap': -1,
        'tts': -1,
      },
    };
    return limits[tier]?[feature] ?? 0;
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/api_constants.dart lib/core/constants/quota_constants.dart
git commit -m "feat: add ApiConstants (Gemini config) and QuotaConstants (tier limits)"
```

---

## Task 3: Create GeminiDatasource

**Files:**
- Create: `lib/data/datasources/gemini_datasource.dart`

- [ ] **Step 1: Create GeminiDatasource with roleplay AI functions**

```dart
// lib/data/datasources/gemini_datasource.dart
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';
import '../../features/scenario/models/assessment.dart';

class GeminiDatasource {
  late final GenerativeModel _model;

  GeminiDatasource() {
    _model = GenerativeModel(
      model: ApiConstants.modelFlash,
      apiKey: ApiConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: ApiConstants.temperature,
        topP: ApiConstants.topP,
        topK: ApiConstants.topK,
        maxOutputTokens: ApiConstants.maxTokensFlash,
      ),
    );
  }

  /// Generate a scenario lesson context + AI opening line.
  /// Returns raw text with SCENARIO_CONTEXT and OPENING_LINE markers.
  Future<String> generateScenarioLesson(String topic, String proficiency) async {
    final prompt = '''
You are an English conversation coach. Generate a realistic scenario for practicing English.

Topic: $topic
Proficiency Level: $proficiency

Create a scenario that:
1. Is realistic and relatable
2. Matches the proficiency level (beginner = simple vocab, advanced = complex idioms)
3. Includes context (location, time, who you're talking to)
4. Starts with an opening line from the AI (role-player)
5. Includes a Vietnamese sentence for the student to translate to English

Format your response as JSON:
{
  "scenarioContext": "You are at a hotel reception desk...",
  "vietnameseSentence": "Xin chào, tôi muốn đặt phòng...",
  "englishTranslation": "Hello, I would like to book a room...",
  "openingLine": "Welcome to the Grand Hotel! How can I help you today?",
  "vocabularyPrep": ["check-in", "reservation", "room type"],
  "hints": [
    "Start with a polite greeting",
    "Specify what you need clearly",
    "Mention relevant details like dates or preferences"
  ],
  "difficulty": "$proficiency"
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '{}';
  }

  /// Evaluate user's roleplay response. Returns JSON string for AssessmentResult parsing.
  Future<String> evaluateUserResponse({
    required String userText,
    required String scenarioContext,
    required String vietnameseSentence,
    required String proficiencyLevel,
    required String direction,
  }) async {
    final prompt = '''
You are an English conversation coach evaluating a student's translation/response.

Student's Response: "$userText"
Original Sentence: "$vietnameseSentence"
Translation Direction: $direction
Scenario Context: $scenarioContext
Proficiency Level: $proficiencyLevel

Evaluate and return JSON (no markdown, pure JSON only):
{
  "score": 8,
  "accuracyScore": 9,
  "naturalnessScore": 8,
  "complexityScore": 7,
  "feedback": "Good translation! Your response captures the main idea clearly.",
  "correction": "Corrected version if needed, or null",
  "betterAlternative": "A more natural way to say it",
  "analysis": "Overall analysis of the response",
  "grammarAnalysis": "Grammar-specific feedback",
  "vocabularyAnalysis": "Vocabulary usage feedback",
  "improvements": [
    {
      "original": "what user said",
      "suggestion": "better version",
      "explanation": "why this is better"
    }
  ],
  "userTone": "Neutral",
  "alternativeTones": {
    "formal": {"text": "Formal version of the response", "color": "#6366F1"},
    "friendly": {"text": "Friendly version", "color": "#9A7B3D"},
    "informal": {"text": "Informal/casual version", "color": "#D98A8A"},
    "conversational": {"text": "Conversational version", "color": "#7BC6A0"}
  }
}

Score scale: 1-10 for each metric.
Respond with ONLY the JSON object, no extra text.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '{}';
  }

  /// Generate progressive hints for a scenario.
  Future<String> generateProgressiveHints({
    required String scenarioContext,
    required String vietnameseSentence,
    required int hintLevel,
  }) async {
    final prompt = '''
You are helping a student who is struggling with translating a sentence.

Scenario: $scenarioContext
Sentence to translate: "$vietnameseSentence"
Hint Level: $hintLevel (1=vocab hint, 2=structure hint, 3=full example)

Generate 3 progressive hints:
1. Vocabulary hint: Key words to use
2. Structure hint: Sentence pattern "I want to [verb]..."
3. Full example: A complete sentence they can adapt

Return JSON only:
{
  "hints": ["hint 1", "hint 2", "hint 3"]
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '{"hints": []}';
  }

  /// Parse JSON from Gemini response, handling markdown code blocks.
  static Map<String, dynamic> parseJson(String text) {
    var cleaned = text.trim();
    // Remove markdown code blocks if present
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/datasources/gemini_datasource.dart
git commit -m "feat: add GeminiDatasource with roleplay AI functions (lesson gen, evaluation, hints)"
```

---

## Task 4: Add Assessment fromJson Factory

**Files:**
- Modify: `lib/features/scenario/models/assessment.dart`

- [ ] **Step 1: Add fromJson factories to Assessment models**

Add these factory constructors to the existing classes in `assessment.dart`:

```dart
// Add to AssessmentResult class:
factory AssessmentResult.fromJson(Map<String, dynamic> json) {
  return AssessmentResult(
    score: (json['score'] as num?)?.toInt() ?? 5,
    accuracyScore: (json['accuracyScore'] as num?)?.toInt() ?? 5,
    naturalnessScore: (json['naturalnessScore'] as num?)?.toInt() ?? 5,
    complexityScore: (json['complexityScore'] as num?)?.toInt() ?? 5,
    feedback: json['feedback'] as String? ?? 'No feedback available.',
    correction: json['correction'] as String?,
    betterAlternative: json['betterAlternative'] as String?,
    analysis: json['analysis'] as String? ?? '',
    grammarAnalysis: json['grammarAnalysis'] as String? ?? '',
    vocabularyAnalysis: json['vocabularyAnalysis'] as String? ?? '',
    improvements: (json['improvements'] as List<dynamic>?)
            ?.map((e) => Improvement.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    userTone: json['userTone'] as String? ?? 'Neutral',
    alternativeTones: json['alternativeTones'] != null
        ? AlternativeTones.fromJson(
            json['alternativeTones'] as Map<String, dynamic>)
        : AlternativeTones(
            formal: ToneVariation(text: '', color: '#6366F1'),
            friendly: ToneVariation(text: '', color: '#9A7B3D'),
            informal: ToneVariation(text: '', color: '#D98A8A'),
            conversational: ToneVariation(text: '', color: '#7BC6A0'),
          ),
    nextAgentReply: json['nextAgentReply'] as String?,
    nextAgentReplyVietnamese: json['nextAgentReplyVietnamese'] as String?,
  );
}

Map<String, dynamic> toJson() => {
      'score': score,
      'accuracyScore': accuracyScore,
      'naturalnessScore': naturalnessScore,
      'complexityScore': complexityScore,
      'feedback': feedback,
      'correction': correction,
      'betterAlternative': betterAlternative,
      'analysis': analysis,
      'grammarAnalysis': grammarAnalysis,
      'vocabularyAnalysis': vocabularyAnalysis,
      'improvements': improvements.map((e) => e.toJson()).toList(),
      'userTone': userTone,
      'alternativeTones': alternativeTones.toJson(),
    };
```

```dart
// Add to AlternativeTones class:
factory AlternativeTones.fromJson(Map<String, dynamic> json) {
  return AlternativeTones(
    formal: _parseTone(json['formal']),
    friendly: _parseTone(json['friendly']),
    informal: _parseTone(json['informal']),
    conversational: _parseTone(json['conversational']),
  );
}

static ToneVariation _parseTone(dynamic value) {
  if (value is Map<String, dynamic>) {
    return ToneVariation.fromJson(value);
  }
  if (value is String) {
    return ToneVariation(text: value);
  }
  return const ToneVariation(text: '');
}

Map<String, dynamic> toJson() => {
      'formal': formal.toJson(),
      'friendly': friendly.toJson(),
      'informal': informal.toJson(),
      'conversational': conversational.toJson(),
    };
```

```dart
// Add to ToneVariation class:
factory ToneVariation.fromJson(Map<String, dynamic> json) {
  return ToneVariation(
    text: json['text'] as String? ?? '',
    color: json['color'] as String?,
  );
}

Map<String, dynamic> toJson() => {
      'text': text,
      'color': color,
    };
```

```dart
// Add to Improvement class:
factory Improvement.fromJson(Map<String, dynamic> json) {
  return Improvement(
    original: json['original'] as String? ?? '',
    suggestion: json['suggestion'] as String? ?? '',
    explanation: json['explanation'] as String? ?? '',
  );
}

Map<String, dynamic> toJson() => {
      'original': original,
      'suggestion': suggestion,
      'explanation': explanation,
    };
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/models/assessment.dart
git commit -m "feat: add fromJson/toJson to Assessment models for Gemini + Firestore serialization"
```

---

## Task 5: Extend FirebaseDatasource — Conversations + Usage

**Files:**
- Modify: `lib/data/datasources/firebase_datasource.dart`

- [ ] **Step 1: Add conversation and usage methods to FirebaseDatasource**

Add these methods to the existing `FirebaseDatasource` class (after the existing methods):

```dart
// --- Conversation persistence ---

Future<void> saveConversation({
  required String uid,
  required String conversationId,
  required Map<String, dynamic> data,
}) async {
  await _db
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .doc(conversationId)
      .set(data, SetOptions(merge: true));
}

Future<void> addMessageToConversation({
  required String uid,
  required String conversationId,
  required Map<String, dynamic> message,
}) async {
  await _db
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .doc(conversationId)
      .update({
    'turns': FieldValue.arrayUnion([message]),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<List<Map<String, dynamic>>> getConversations(String uid) async {
  final snapshot = await _db
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .get();
  return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
}

Future<Map<String, dynamic>?> getConversation(
    String uid, String conversationId) async {
  final doc = await _db
      .collection('users')
      .doc(uid)
      .collection('conversations')
      .doc(conversationId)
      .get();
  if (!doc.exists) return null;
  return {'id': doc.id, ...doc.data()!};
}

// --- Daily usage tracking ---

Future<Map<String, int>> getDailyUsage(String uid, String date) async {
  final doc = await _db
      .collection('users')
      .doc(uid)
      .collection('usage')
      .doc(date)
      .get();
  if (!doc.exists) {
    return {
      'roleplayCount': 0,
      'storyCount': 0,
      'translatorCount': 0,
      'dictionaryCount': 0,
      'mindmapCount': 0,
      'ttsCount': 0,
    };
  }
  final data = doc.data()!;
  return {
    'roleplayCount': data['roleplayCount'] as int? ?? 0,
    'storyCount': data['storyCount'] as int? ?? 0,
    'translatorCount': data['translatorCount'] as int? ?? 0,
    'dictionaryCount': data['dictionaryCount'] as int? ?? 0,
    'mindmapCount': data['mindmapCount'] as int? ?? 0,
    'ttsCount': data['ttsCount'] as int? ?? 0,
  };
}

Future<void> incrementDailyUsage(
    String uid, String date, String feature) async {
  final fieldName = '${feature}Count';
  await _db
      .collection('users')
      .doc(uid)
      .collection('usage')
      .doc(date)
      .set(
    {
      fieldName: FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/datasources/firebase_datasource.dart
git commit -m "feat: add conversation CRUD + daily usage tracking to FirebaseDatasource"
```

---

## Task 6: Extend LocalDatasource — Conversation Cache

**Files:**
- Modify: `lib/data/datasources/local_datasource.dart`

- [ ] **Step 1: Add conversation caching to LocalDatasource**

Add these methods to the existing `LocalDatasource` class:

```dart
import 'dart:convert';

// Add these constants at the top of the class:
static const _keyActiveConversation = 'active_conversation';
static const _keyDailyUsagePrefix = 'daily_usage_';

// Add these methods:

Future<void> cacheActiveConversation(Map<String, dynamic> data) async {
  await _prefs.setString(_keyActiveConversation, jsonEncode(data));
}

Map<String, dynamic>? getCachedActiveConversation() {
  final raw = _prefs.getString(_keyActiveConversation);
  if (raw == null) return null;
  try {
    return jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

Future<void> clearActiveConversation() async {
  await _prefs.remove(_keyActiveConversation);
}

Future<void> cacheDailyUsage(String date, Map<String, int> usage) async {
  await _prefs.setString(
    '$_keyDailyUsagePrefix$date',
    jsonEncode(usage),
  );
}

Map<String, int>? getCachedDailyUsage(String date) {
  final raw = _prefs.getString('$_keyDailyUsagePrefix$date');
  if (raw == null) return null;
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as int));
  } catch (_) {
    return null;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/datasources/local_datasource.dart
git commit -m "feat: add conversation cache + daily usage cache to LocalDatasource"
```

---

## Task 7: Rewrite ScenarioProvider with Full DI + AI + Persistence

**Files:**
- Rewrite: `lib/features/scenario/providers/scenario_provider.dart`

This is the core task. The provider is rewritten to inject all dependencies and replace mock logic with real AI calls + Firestore persistence.

- [ ] **Step 1: Rewrite ScenarioProvider**

Replace the entire content of `lib/features/scenario/providers/scenario_provider.dart`:

```dart
// lib/features/scenario/providers/scenario_provider.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../data/datasources/gemini_datasource.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../core/constants/quota_constants.dart';
import '../models/scenario.dart';
import '../models/chat_message.dart';
import '../models/assessment.dart';
import '../data/scenario_catalog.dart';

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
      _dailyUsage = await _firebase.getDailyUsage(_uid!, _todayDate);
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

      // Try AI-generated scenario first
      Scenario? scenario;
      try {
        final rawJson = await _gemini.generateScenarioLesson(
          selectedTopic,
          selectedDifficulty,
        );
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
        // AI generation failed — fall through to catalog fallback
      }

      // Fallback to static catalog if AI failed
      if (scenario == null) {
        final candidates = scenarioCatalog
            .where((s) =>
                s.topic == selectedTopic &&
                s.difficulty == selectedDifficulty &&
                s.id != _currentScenario?.id)
            .toList();
        if (candidates.isEmpty) {
          final anyCandidates = scenarioCatalog
              .where((s) => s.topic == selectedTopic)
              .toList();
          if (anyCandidates.isEmpty) {
            _error = 'No scenarios available for this topic.';
            _isLoading = false;
            notifyListeners();
            return;
          }
          anyCandidates.shuffle();
          scenario = anyCandidates.first;
        } else {
          candidates.shuffle();
          scenario = candidates.first;
        }
      }

      _currentScenario = scenario;
      _conversationId = _uuid.v4();
      _messages.clear();
      _hintsRevealed = 0;
      _sessionStartTime = DateTime.now();
      _scenarioIndex++;
      _direction = 'vn-to-en';

      // Add AI opening message
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.ai,
        text:
            'Great! Let\'s practice this scenario.\n\n**Topic:** ${scenario.topic}\n**Difficulty:** ${scenario.difficulty}\n\n**Your task:** Translate the sentence above into English.',
        timestamp: DateTime.now(),
      ));

      // Increment daily usage
      await _firebase.incrementDailyUsage(_uid!, _todayDate, 'roleplay');
      _dailyUsage['roleplayCount'] = roleplayUsedToday + 1;

      // Save conversation to Firestore (background)
      _saveConversationToFirestore();
    } catch (e) {
      _error = 'Failed to start scenario: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
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
      // Call Gemini for real evaluation
      final rawJson = await _gemini.evaluateUserResponse(
        userText: text,
        scenarioContext: _currentScenario!.context,
        vietnameseSentence: _direction == 'vn-to-en'
            ? _currentScenario!.vietnameseSentence
            : _currentScenario!.englishTranslation,
        proficiencyLevel: _userLevel,
        direction: _direction,
      );

      final json = GeminiDatasource.parseJson(rawJson);
      final assessment = AssessmentResult.fromJson(json);

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.assessment,
        text: '',
        timestamp: DateTime.now(),
        assessment: assessment,
      ));

      // Persist to Firestore (background)
      _saveConversationToFirestore();
    } catch (e) {
      // On AI failure, show error in chat
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        type: MessageType.ai,
        text:
            'Sorry, I couldn\'t evaluate your response right now. Please try again.',
        timestamp: DateTime.now(),
      ));
      _error = 'Evaluation failed: ${e.toString()}';
    }

    _isAiTyping = false;
    notifyListeners();
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
  Future<void> endSession() async {
    if (_uid != null && _conversationId != null) {
      try {
        await _firebase.saveConversation(
          uid: _uid!,
          conversationId: _conversationId!,
          data: {
            'status': 'completed',
            'totalScore': averageScore,
            'duration': sessionDurationMinutes,
            'totalTurns': totalTurns,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      } catch (_) {}
    }
    await _local.clearActiveConversation();
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/providers/scenario_provider.dart
git commit -m "feat: rewrite ScenarioProvider with Gemini AI, Firestore persistence, and quota enforcement"
```

---

## Task 8: Create Scenario Select Screen

**Files:**
- Create: `lib/features/scenario/screens/scenario_select_screen.dart`

- [ ] **Step 1: Create ScenarioSelectScreen**

```dart
// lib/features/scenario/screens/scenario_select_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/topic_constants.dart';
import '../providers/scenario_provider.dart';

class ScenarioSelectScreen extends StatefulWidget {
  const ScenarioSelectScreen({super.key});

  @override
  State<ScenarioSelectScreen> createState() => _ScenarioSelectScreenState();
}

class _ScenarioSelectScreenState extends State<ScenarioSelectScreen> {
  String? _selectedTopic;
  String _selectedDifficulty = 'intermediate';

  static const _difficulties = ['beginner', 'intermediate', 'advanced'];

  static const _topicEmojis = {
    'travel': '✈️',
    'business': '💼',
    'social': '🥂',
    'daily': '🏠',
    'tech': '💻',
    'food': '🍽️',
    'medical': '🏥',
    'shopping': '🛍️',
    'entertainment': '🎬',
    'sports': '⚽',
    'education': '🎓',
    'environment': '🌿',
    'finance': '💰',
    'relationships': '❤️',
    'legal': '⚖️',
    'property': '🔑',
  };

  static const _topicLabels = {
    'travel': 'Travel',
    'business': 'Business',
    'social': 'Social',
    'daily': 'Daily Life',
    'tech': 'Technology',
    'food': 'Food & Dining',
    'medical': 'Medical',
    'shopping': 'Shopping',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScenarioProvider>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Choose a Topic',
                    style: AppTypography.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  _buildTopicGrid(provider),
                  const SizedBox(height: 24),
                  Text(
                    'Difficulty Level',
                    style: AppTypography.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  _buildDifficultyRow(),
                  const SizedBox(height: 24),
                  if (provider.quotaExceeded) _buildQuotaBanner(provider),
                  const SizedBox(height: 12),
                  _buildStartButton(context, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Text('‹', style: AppTypography.h1.copyWith(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Scenario Coach',
            style: AppTypography.h2.copyWith(
              fontSize: 18,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid(ScenarioProvider provider) {
    final topics = _topicLabels.keys.toList();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: topics.map((topic) {
        final isSelected = _selectedTopic == topic;
        final emoji = _topicEmojis[topic] ?? '📌';
        final label = _topicLabels[topic] ?? topic;
        return GestureDetector(
          onTap: () => setState(() => _selectedTopic = topic),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.teal.withValues(alpha: 0.15)
                  : AppColors.clayWhite,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: isSelected ? AppColors.teal : AppColors.clayBorder,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected ? [] : AppShadows.soft,
            ),
            child: Text(
              '$emoji $label',
              style: AppTypography.labelSm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.teal : AppColors.warmDark,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyRow() {
    return Row(
      children: _difficulties.map((d) {
        final isSelected = _selectedDifficulty == d;
        final color = d == 'beginner'
            ? AppColors.success
            : d == 'intermediate'
                ? AppColors.gold
                : AppColors.error;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = d),
            child: Container(
              margin: EdgeInsets.only(
                right: d != 'advanced' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.clayWhite,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: isSelected ? color : AppColors.clayBorder,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Text(
                d[0].toUpperCase() + d.substring(1),
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : AppColors.warmMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuotaBanner(ScenarioProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You\'ve used ${provider.roleplayUsedToday}/${provider.roleplayLimitToday} sessions today. Upgrade to Pro for more!',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF9A7B3D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, ScenarioProvider provider) {
    final canStart = _selectedTopic != null && !provider.quotaExceeded;
    return GestureDetector(
      onTap: canStart
          ? () async {
              await provider.startSession(
                topic: _selectedTopic,
                difficulty: _selectedDifficulty,
              );
              if (provider.error == null && context.mounted) {
                context.push('/scenario/chat');
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: canStart
              ? AppColors.teal
              : AppColors.clayBeige,
          borderRadius: AppRadius.mdBorder,
          boxShadow: canStart
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    offset: const Offset(3, 3),
                  ),
                ]
              : [],
        ),
        child: provider.isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              )
            : Text(
                provider.quotaExceeded ? 'Upgrade to Continue' : 'Start Practice',
                textAlign: TextAlign.center,
                style: AppTypography.labelMd.copyWith(
                  color: canStart ? Colors.white : AppColors.warmLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/scenario_select_screen.dart
git commit -m "feat: add ScenarioSelectScreen with topic picker, difficulty selector, and quota display"
```

---

## Task 9: Create Session Summary Screen

**Files:**
- Create: `lib/features/scenario/screens/session_summary_screen.dart`

- [ ] **Step 1: Create SessionSummaryScreen**

```dart
// lib/features/scenario/screens/session_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/scenario_provider.dart';
import '../widgets/score_circle.dart';
import '../widgets/radar_score.dart';
import '../models/assessment.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  Color _getScoreColor(double score) {
    if (score < 5) return AppColors.error;
    if (score < 8) return AppColors.gold;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ScenarioProvider>();
    final summary = provider.getSessionSummary();
    final avgScore = (summary['averageScore'] as double);
    final assessments = summary['assessments'] as List<AssessmentResult>;
    final scoreColor = _getScoreColor(avgScore);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildScoreHeader(summary, avgScore, scoreColor),
                  const SizedBox(height: 16),
                  _buildStatsRow(summary),
                  const SizedBox(height: 16),
                  if (assessments.isNotEmpty)
                    _buildAverageRadar(assessments),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Text('✕', style: AppTypography.h2.copyWith(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Session Summary',
            style: AppTypography.h2.copyWith(
              fontSize: 18,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(
      Map<String, dynamic> summary, double avgScore, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.lifted,
      ),
      child: Column(
        children: [
          ScoreCircle(
            score: avgScore.round(),
            size: 80,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            avgScore >= 8
                ? 'Excellent Session!'
                : avgScore >= 6
                    ? 'Good Progress!'
                    : 'Keep Practicing!',
            style: AppTypography.h2.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary['topic']} · ${summary['difficulty']}',
            style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> summary) {
    return Row(
      children: [
        _statCard('⏱️', '${summary['duration']}m', 'Duration'),
        const SizedBox(width: 10),
        _statCard('💬', '${summary['totalTurns']}', 'Turns'),
        const SizedBox(width: 10),
        _statCard('📊', '#${summary['scenarioIndex']}', 'Scenario'),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: AppColors.clayBorder, width: 1.5),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.h2.copyWith(fontSize: 18),
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.warmMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageRadar(List<AssessmentResult> assessments) {
    final avgAccuracy =
        assessments.map((a) => a.accuracyScore).reduce((a, b) => a + b) /
            assessments.length;
    final avgNaturalness =
        assessments.map((a) => a.naturalnessScore).reduce((a, b) => a + b) /
            assessments.length;
    final avgComplexity =
        assessments.map((a) => a.complexityScore).reduce((a, b) => a + b) /
            assessments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Text(
            'Performance Overview',
            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Center(
            child: RadarScore(
              accuracyScore: avgAccuracy.round(),
              naturalnessScore: avgNaturalness.round(),
              complexityScore: avgComplexity.round(),
              size: 160,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ScenarioProvider provider) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              provider.endSession();
              context.go('/home');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.clayWhite,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: AppColors.clayBorder, width: 2),
              ),
              child: Text(
                'Back to Home',
                textAlign: TextAlign.center,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmDark,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await provider.startNewScenario();
              if (context.mounted) {
                context.go('/scenario/chat');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: AppRadius.mdBorder,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Text(
                'New Scenario',
                textAlign: TextAlign.center,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/session_summary_screen.dart
git commit -m "feat: add SessionSummaryScreen with score, stats, radar chart, and action buttons"
```

---

## Task 10: Update ScenarioChatScreen — Wire to New Provider API

**Files:**
- Modify: `lib/features/scenario/screens/scenario_chat_screen.dart`

- [ ] **Step 1: Update ScenarioChatScreen to add End Session + navigate to summary**

In the existing `ScenarioChatScreen`, make these changes:

1. In `ScenarioAppBar`, change `onBack` to show a confirmation dialog that calls `provider.endSession()` + navigates to summary:

Replace the `onBack` in the `ScenarioAppBar` widget from:
```dart
onBack: () => context.pop(),
```
to:
```dart
onBack: () => _showEndSessionDialog(context, provider),
```

2. Add a helper method to the `ScenarioChatScreen` class:

```dart
void _showEndSessionDialog(BuildContext context, ScenarioProvider provider) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.clayWhite,
      title: Text('End Session?', style: AppTypography.h2.copyWith(fontSize: 18)),
      content: Text(
        'Your progress will be saved.',
        style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Continue', style: TextStyle(color: AppColors.warmMuted)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await provider.endSession();
            if (context.mounted) {
              context.go('/scenario/summary');
            }
          },
          child: Text('End & Review', style: TextStyle(color: AppColors.teal)),
        ),
      ],
    ),
  );
}
```

3. In the `AssessmentCard`'s difficulty callbacks, update to use `async`:

```dart
return AssessmentCard(
  assessment: msg.assessment!,
  onEasier: () async {
    await provider.startNewScenario(difficulty: 'easier');
  },
  onSameDifficulty: () async {
    await provider.startNewScenario(difficulty: 'same');
  },
  onHarder: () async {
    await provider.startNewScenario(difficulty: 'harder');
  },
);
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/scenario_chat_screen.dart
git commit -m "feat: wire ScenarioChatScreen to end session dialog + summary navigation"
```

---

## Task 11: Update ConversationHistoryScreen — Read from Firestore

**Files:**
- Modify: `lib/features/scenario/screens/conversation_history_screen.dart`

- [ ] **Step 1: Read and examine current conversation_history_screen.dart to understand its structure, then rewrite to read from Firestore**

The screen should use `FirebaseDatasource.getConversations()` via Provider to list past sessions instead of reading from in-memory data.

Read the current file first, then update its `build()` to:
1. Get `FirebaseDatasource` from `context.read<FirebaseDatasource>()`
2. Get current user UID from `context.read<AuthProvider>().currentUser?.uid`
3. Use a `FutureBuilder` to load conversations from Firestore
4. Display each conversation as a card showing topic, difficulty, date, score, status

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/screens/conversation_history_screen.dart
git commit -m "feat: update ConversationHistoryScreen to read from Firestore"
```

---

## Task 12: Update app.dart — Routes + Provider DI

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Add GeminiDatasource creation and update ScenarioProvider DI**

In `_AuraCoachAppState.initState()`, add:

```dart
late final GeminiDatasource _geminiDatasource;
```

In `initState()`, after `_localDatasource = ...`:

```dart
_geminiDatasource = GeminiDatasource();
```

Update `_scenarioProvider` initialization from:
```dart
_scenarioProvider = ScenarioProvider();
```
to:
```dart
_scenarioProvider = ScenarioProvider(
  gemini: _geminiDatasource,
  firebase: _firebaseDatasource,
  local: _localDatasource,
);
```

- [ ] **Step 2: Add new routes**

In the `routes:` list, replace:
```dart
GoRoute(path: '/scenario', builder: (_, __) => const ScenarioChatScreen()),
```
with:
```dart
GoRoute(path: '/scenario', builder: (_, __) => const ScenarioSelectScreen()),
GoRoute(path: '/scenario/chat', builder: (_, __) => const ScenarioChatScreen()),
GoRoute(path: '/scenario/summary', builder: (_, __) => const SessionSummaryScreen()),
```

- [ ] **Step 3: Add imports for new files**

Add at the top of `app.dart`:
```dart
import 'data/datasources/gemini_datasource.dart';
import 'features/scenario/screens/scenario_select_screen.dart';
import 'features/scenario/screens/session_summary_screen.dart';
```

- [ ] **Step 4: Update HomeScreen navigation**

In `home_screen.dart`, change the Scenario Coach mode card's `onTap` from directly calling `scenarioProvider.init()` + `startSession()` to just navigating to the selection screen:

Replace:
```dart
if (mode.route == '/scenario') {
  final profile = context.read<HomeProvider>().userProfile;
  final scenarioProvider = context.read<ScenarioProvider>();
  scenarioProvider.init(
    profile?.selectedTopics ?? ['travel', 'business', 'food'],
    profile?.proficiencyLevel ?? 'intermediate',
  );
  scenarioProvider.startSession();
}
context.push(mode.route!);
```
with:
```dart
if (mode.route == '/scenario') {
  final authProvider = context.read<app.AuthProvider>();
  final profile = context.read<HomeProvider>().userProfile;
  final scenarioProvider = context.read<ScenarioProvider>();
  scenarioProvider.init(
    uid: authProvider.currentUser?.uid ?? '',
    tier: profile?.tier ?? 'free',
    topics: profile?.selectedTopics ?? ['travel', 'business', 'food'],
    level: profile?.proficiencyLevel ?? 'intermediate',
  );
}
context.push(mode.route!);
```

- [ ] **Step 5: Commit**

```bash
git add lib/app.dart lib/features/home/screens/home_screen.dart
git commit -m "feat: update routing (select → chat → summary) + ScenarioProvider DI with Gemini/Firestore"
```

---

## Task 13: Verify Build

- [ ] **Step 1: Run flutter analyze**

```bash
cd /sessions/kind-quirky-hypatia/mnt/aura-coach-ai && flutter analyze
```

Expected: No errors (warnings are acceptable).

- [ ] **Step 2: Fix any analysis errors**

If there are import errors or type mismatches, fix them. Common issues:
- Missing `import 'package:flutter_dotenv/flutter_dotenv.dart'` in main.dart
- Mismatched `AuthProvider` alias (`app.AuthProvider` vs `AuthProvider`)
- Missing `import '../../auth/providers/auth_provider.dart' as app;` in home_screen.dart

- [ ] **Step 3: Commit fixes if any**

```bash
git add -A
git commit -m "fix: resolve analysis errors from roleplay business flow integration"
```

---

## Summary of What This Plan Fixes

| Gap | Fix |
|-----|-----|
| AI Integration (0%) | `GeminiDatasource` with `generateScenarioLesson` + `evaluateUserResponse` + `generateProgressiveHints` |
| Data Persistence (0%) | `FirebaseDatasource` CRUD for conversations + usage; `LocalDatasource` caching |
| Business Logic (25%) | Full `ScenarioProvider` rewrite: AI-first with catalog fallback, real evaluation |
| Quota System (0%) | `QuotaConstants` + daily usage tracking + quota check before session start |
| Missing Screens (3/5) | `ScenarioSelectScreen` (topic+difficulty picker), `SessionSummaryScreen` (stats+radar) |
| Routing (30%) | `/scenario` → select, `/scenario/chat` → chat, `/scenario/summary` → summary |
| Provider Architecture (30%) | Full DI: `ScenarioProvider(gemini, firebase, local)` |
