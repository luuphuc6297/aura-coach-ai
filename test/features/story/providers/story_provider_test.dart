// ignore_for_file: subtype_of_sealed_class

import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/data/datasources/firebase_datasource.dart';
import 'package:aura_coach_ai/data/datasources/local_datasource.dart';
import 'package:aura_coach_ai/data/gemini/gemini_service.dart';
import 'package:aura_coach_ai/data/prompts/prompt_constants.dart';
import 'package:aura_coach_ai/data/repositories/story_repository.dart';
import 'package:aura_coach_ai/features/story/models/story.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:aura_coach_ai/features/story/models/story_session.dart';
import 'package:aura_coach_ai/features/story/providers/story_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NeverFirestore extends Fake implements FirebaseFirestore {}

class _FakeFirebase extends FirebaseDatasource {
  _FakeFirebase() : super(db: _NeverFirestore());

  Map<String, int> usage = {'storyCount': 0};
  List<Story> stories = [];
  List<Map<String, dynamic>> savedConversations = [];
  List<Map<String, dynamic>> userConversations = [];

  @override
  Future<Map<String, int>> getDailyUsage(String uid, String date) async =>
      usage;

  @override
  Future<void> incrementDailyUsage(
      String uid, String date, String feature) async {
    usage['${feature}Count'] = (usage['${feature}Count'] ?? 0) + 1;
  }

  @override
  Future<List<Story>> getFeaturedStories({String? level}) async => stories;

  @override
  Future<void> saveConversation({
    required String uid,
    required String conversationId,
    required Map<String, dynamic> data,
  }) async {
    savedConversations.add({'id': conversationId, ...data});
  }

  @override
  Future<List<Map<String, dynamic>>> getConversations(
    String uid, {
    String? mode,
  }) async {
    final list = userConversations;
    if (mode != null) return list.where((m) => m['mode'] == mode).toList();
    return list;
  }
}

class _BrokenSaveFirebase extends _FakeFirebase {
  bool brokenForSave = false;

  @override
  Future<void> saveConversation({
    required String uid,
    required String conversationId,
    required Map<String, dynamic> data,
  }) async {
    if (brokenForSave) throw StateError('save down');
    return super.saveConversation(
      uid: uid,
      conversationId: conversationId,
      data: data,
    );
  }
}

class _ResumeFakeFirebase extends _FakeFirebase {
  _ResumeFakeFirebase({required this.savedDoc});
  Map<String, dynamic> savedDoc;

  @override
  Future<Map<String, dynamic>?> getConversation(
      String uid, String conversationId) async {
    if (savedDoc['conversationId'] == conversationId) return savedDoc;
    return null;
  }
}

class _FakeGemini extends GeminiService {
  _FakeGemini() : super();
}

class _ScriptedGemini extends GeminiService {
  _ScriptedGemini({required this.scenarioJson}) : super();
  final String scenarioJson;

  @override
  Future<String> generateStoryScenario({
    required CefrLevel level,
    required String topic,
    required List<String> previousTitles,
    String? customContext,
  }) async {
    return scenarioJson;
  }
}

class _AlwaysFailGemini extends GeminiService {
  _AlwaysFailGemini() : super();

  @override
  Future<String> generateStoryScenario({
    required CefrLevel level,
    required String topic,
    required List<String> previousTitles,
    String? customContext,
  }) async {
    throw StateError('gemini down');
  }
}

class _EvalGemini extends _ScriptedGemini {
  _EvalGemini({required super.scenarioJson, required this.evalJson});
  final String evalJson;

  @override
  Future<String> evaluateStoryTurn({
    required String situation,
    required String agentName,
    required String agentLastMessage,
    required String userReply,
    required CefrLevel targetLevel,
  }) async {
    return evalJson;
  }
}

Story _story({required String id, String level = 'B1'}) => Story(
      id: id,
      title: 'Library Story $id',
      topic: 'travel',
      level: level,
      situation: 'At the airport.',
      character: const StoryCharacter(
        name: 'Mia',
        role: 'Agent',
        personality: 'helpful',
        initial: 'M',
        gradient: 'teal-purple',
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late LocalDatasource local;
  late StoryCache cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = LocalDatasource(prefs: prefs);
    cache = StoryCache(prefs: prefs);
  });

  // ---------- Task 4: init / refresh / quota / loadUserStoryConversations ----------

  test('init loads daily usage and exposes correct quota', () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 2};
    final provider = StoryProvider(
      gemini: _FakeGemini(),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );

    await provider.init(uid: 'u', tier: 'free', level: 'B1');

    expect(provider.storyUsedToday, 2);
    expect(provider.canStartSession(), isTrue);
  });

  test('canStartSession returns false when free quota is exhausted', () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 3};
    final provider = StoryProvider(
      gemini: _FakeGemini(),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );

    await provider.init(uid: 'u', tier: 'free', level: 'B1');

    expect(provider.canStartSession(), isFalse);
  });

  test('refreshLibrary exposes featured stories filtered by level', () async {
    final firebase = _FakeFirebase()
      ..stories = [_story(id: 's1'), _story(id: 's2')];
    final provider = StoryProvider(
      gemini: _FakeGemini(),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );

    await provider.init(uid: 'u', tier: 'pro', level: 'B1');

    expect(provider.featuredLibrary, hasLength(2));
  });

  test('loadUserStoryConversations returns only in-progress story convos',
      () async {
    final firebase = _FakeFirebase()
      ..userConversations = [
        {'id': 'c1', 'mode': 'story', 'status': 'in-progress', 'title': 'A'},
        {'id': 'c2', 'mode': 'story', 'status': 'completed', 'title': 'B'},
        {'id': 'c3', 'mode': 'scenario', 'status': 'in-progress', 'title': 'C'},
      ];
    final provider = StoryProvider(
      gemini: _FakeGemini(),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );

    await provider.init(uid: 'u', tier: 'free', level: 'B1');
    final result = await provider.loadUserStoryConversations();

    expect(result, hasLength(1));
    expect(result.first['id'], 'c1');
  });

  // ---------- Task 5: startFromLibrary / startFromCustom ----------

  test('startFromLibrary creates session, charges quota, persists conversation',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    const scenario = '''
{
  "id": "ai-1",
  "topic": "travel",
  "situation": "At the airport.",
  "agentName": "Mia",
  "openingLine": "Welcome! How can I help?",
  "openingLineVietnamese": "Chào mừng!",
  "difficulty": "B1-B2",
  "hints": {"level1": "greet", "level2": "use present tense", "level3": "boarding"}
}
''';
    final provider = StoryProvider(
      gemini: _ScriptedGemini(scenarioJson: scenario),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');

    final ok = await provider.startFromLibrary(_story(id: 'lib-1'));

    expect(ok, isTrue);
    expect(provider.activeSession, isNotNull);
    expect(provider.activeSession!.storyId, 'lib-1');
    // First turn = AI opening line
    expect(provider.activeSession!.turns, hasLength(1));
    expect(provider.activeSession!.turns.first.text, contains('Welcome'));
    expect(firebase.usage['storyCount'], 1);
    expect(firebase.savedConversations, hasLength(1));
    expect(firebase.savedConversations.first['mode'], 'story');
  });

  test(
      'startFromLibrary returns false and does NOT charge when quota exhausted',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 3};
    final provider = StoryProvider(
      gemini: _ScriptedGemini(scenarioJson: '{}'),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');

    final ok = await provider.startFromLibrary(_story(id: 'lib-1'));

    expect(ok, isFalse);
    expect(firebase.usage['storyCount'], 3);
    expect(provider.activeSession, isNull);
  });

  test('startFromLibrary does NOT charge quota when generation fails',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    final provider = StoryProvider(
      gemini: _AlwaysFailGemini(),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');

    final ok = await provider.startFromLibrary(_story(id: 'lib-1'));

    expect(ok, isFalse);
    expect(firebase.usage['storyCount'], 0);
    expect(provider.error, isNotNull);
  });

  test('startFromCustom uses provided fields and writes a conversation',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    const scenario = '''
{
  "id": "ai-2",
  "topic": "dating",
  "situation": "First date in a coffee shop.",
  "agentName": "Alex",
  "openingLine": "Hi! Glad you made it.",
  "openingLineVietnamese": "Chào!",
  "difficulty": "B1-B2",
  "hints": {"level1": "be friendly", "level2": "open question", "level3": "weekend"}
}
''';
    final provider = StoryProvider(
      gemini: _ScriptedGemini(scenarioJson: scenario),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'pro', level: 'B1');

    final ok = await provider.startFromCustom(
      topic: 'dating',
      level: 'B1',
      characterPreference: 'Female',
      customContext: 'Coffee shop, first date.',
    );

    expect(ok, isTrue);
    expect(provider.activeSession, isNotNull);
    expect(provider.activeSession!.storyId, isNull);
    expect(provider.activeSession!.characterPreference, 'Female');
    expect(provider.activeSession!.customContext, 'Coffee shop, first date.');
  });

  // ---------- Task 6: sendUserMessage (assessment INLINE) ----------

  test('sendUserMessage stores assessment INLINE on the user turn (regression)',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    const scenario = '''
{
  "id": "ai-1",
  "topic": "travel",
  "situation": "Airport check-in.",
  "agentName": "Mia",
  "openingLine": "Welcome!",
  "openingLineVietnamese": "Chào!",
  "difficulty": "B1-B2",
  "hints": {"level1": "greet", "level2": "use present tense", "level3": "ticket"}
}
''';
    const eval = '''
{
  "score": 8,
  "accuracyScore": 9,
  "naturalnessScore": 8,
  "complexityScore": 7,
  "feedback": "Nice phrasing.",
  "grammarAnalysis": "Grammar Point: clean.",
  "vocabularyAnalysis": "Vocabulary Point: rich.",
  "analysis": "Detailed.",
  "improvements": [],
  "userTone": "Friendly",
  "alternativeTones": {
    "formal": "Good day.",
    "friendly": "Hey!",
    "informal": "yo",
    "conversational": "Hi there."
  },
  "keyVocabulary": [],
  "nextAgentReply": "Great. Your room is ready.",
  "nextAgentReplyVietnamese": "Tuyệt."
}
''';
    final provider = StoryProvider(
      gemini: _EvalGemini(scenarioJson: scenario, evalJson: eval),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');
    await provider.startFromLibrary(_story(id: 'lib-1'));

    await provider.sendUserMessage('Yes, I have a reservation.');

    final turns = provider.activeSession!.turns;
    expect(turns, hasLength(3));
    expect(turns[1].role.name, 'user');
    expect(turns[1].assessment, isNotNull);
    expect(turns[1].assessment!.score, 8);
    expect(turns[2].role.name, 'ai');
    expect(turns[2].text, 'Great. Your room is ready.');

    final saved = firebase.savedConversations.last;
    final savedTurns = (saved['turns'] as List).cast<Map<String, dynamic>>();
    expect(savedTurns[1]['assessment'], isNotNull);
    expect(savedTurns[2].containsKey('assessment'), isFalse);
    expect(
      savedTurns.any((t) => t['role'] == 'assessment'),
      isFalse,
      reason: 'Story Mode must NEVER write role=assessment turns',
    );
  });

  test('sendUserMessage surfaces persistenceError when Firestore save fails',
      () async {
    final firebase = _BrokenSaveFirebase()..usage = {'storyCount': 0};
    const scenario = '''
{
  "id": "ai-1", "topic": "travel", "situation": "Airport.",
  "agentName": "Mia", "openingLine": "Hi!",
  "openingLineVietnamese": "Chào!", "difficulty": "B1-B2",
  "hints": {"level1": "a", "level2": "b", "level3": "c"}
}
''';
    const eval = '''
{
  "score": 7, "accuracyScore": 7, "naturalnessScore": 7, "complexityScore": 7,
  "feedback": "ok", "grammarAnalysis": "ok", "vocabularyAnalysis": "ok",
  "analysis": "ok", "improvements": [],
  "userTone": "Neutral",
  "alternativeTones": {"formal":"a","friendly":"b","informal":"c","conversational":"d"},
  "keyVocabulary": [],
  "nextAgentReply": "Ok."
}
''';
    final provider = StoryProvider(
      gemini: _EvalGemini(scenarioJson: scenario, evalJson: eval),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');
    await provider.startFromLibrary(_story(id: 'lib-1'));
    firebase.brokenForSave = true;

    await provider.sendUserMessage('Hi.');

    expect(provider.persistenceError, isNotNull);
    expect(provider.activeSession, isNotNull);
    expect(provider.persistenceError, isA<StateError>());
    expect((provider.persistenceError as StateError).message, 'save down');
  });

  // ---------- Task 7: endSession / abandonSession / resumeSession ----------

  test('endSession marks status=completed and keeps activeSession', () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    const scenario = '''
{"id":"a","topic":"travel","situation":"Airport.","agentName":"Mia",
 "openingLine":"Hi!","openingLineVietnamese":"Chào!","difficulty":"B1-B2",
 "hints":{"level1":"a","level2":"b","level3":"c"}}
''';
    final provider = StoryProvider(
      gemini: _ScriptedGemini(scenarioJson: scenario),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');
    await provider.startFromLibrary(_story(id: 'lib-1'));

    await provider.endSession();

    expect(provider.activeSession?.status.wireValue, 'completed');
  });

  test('resumeSession rehydrates an in-progress story from Firestore',
      () async {
    final storedDoc = {
      'id': 'conv-9',
      'mode': 'story',
      'conversationId': 'conv-9',
      'storyId': 'lib-1',
      'title': 'Resumed',
      'situation': 'Airport.',
      'character': {
        'name': 'Mia',
        'role': 'Agent',
        'personality': 'warm',
        'initial': 'M',
        'gradient': 'teal-purple',
      },
      'topic': 'travel',
      'level': 'B1',
      'status': 'in-progress',
      'turns': [
        {
          'id': 't0',
          'role': 'ai',
          'text': 'Hi',
          'timestamp': '2026-04-19T10:00:00Z',
        },
      ],
      'startedAt': '2026-04-19T10:00:00Z',
      'updatedAt': '2026-04-19T10:00:00Z',
      'quotaCharged': true,
    };
    final firebase = _ResumeFakeFirebase(savedDoc: storedDoc)
      ..usage = {'storyCount': 1};

    final provider = StoryProvider(
      gemini: _ScriptedGemini(scenarioJson: '{}'),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );

    await provider.init(uid: 'u', tier: 'free', level: 'B1');
    final ok = await provider.resumeSession('conv-9');

    expect(ok, isTrue);
    expect(provider.activeSession, isNotNull);
    expect(provider.activeSession!.conversationId, 'conv-9');
    expect(provider.activeSession!.turns, hasLength(1));
  });

  test('resumeSession returns false when conversation is not in-progress',
      () async {
    final storedDoc = {
      'id': 'conv-done',
      'mode': 'story',
      'conversationId': 'conv-done',
      'storyId': 'lib-1',
      'situation': 'Airport.',
      'character': {
        'name': 'Mia',
        'role': 'Agent',
        'personality': 'warm',
        'initial': 'M',
        'gradient': 'teal-purple',
      },
      'topic': 'travel',
      'level': 'B1',
      'status': 'completed',
      'turns': <Map<String, dynamic>>[],
      'startedAt': '2026-04-19T10:00:00Z',
      'updatedAt': '2026-04-19T10:00:00Z',
      'quotaCharged': true,
    };
    final firebase = _ResumeFakeFirebase(savedDoc: storedDoc);

    final provider = StoryProvider(
      gemini: _ScriptedGemini(scenarioJson: '{}'),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );

    await provider.init(uid: 'u', tier: 'free', level: 'B1');
    final ok = await provider.resumeSession('conv-done');

    expect(ok, isFalse);
    expect(provider.activeSession, isNull);
  });
}
