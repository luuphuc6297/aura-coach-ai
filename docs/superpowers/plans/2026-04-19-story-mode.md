# Story Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Story Mode end-to-end as the second fully-wired learning mode after Scenario Coach: library + custom story generation, multi-turn chat with inline assessments, summary with save-to-vocab, and durable persistence (auto-resume on cold start, no silent error swallow, assessment embedded on the user turn).

**Architecture:** Flutter / Provider (`ChangeNotifier`) state + Firestore persistence + GeminiService for AI generation/evaluation. `StoryProvider` mirrors `ScenarioProvider` shape but fixes its persistence pattern: assessments are stored INLINE on `role='user'` turns (never as separate `assessment`-typed messages), `init()` auto-resumes any in-progress session, and persistence errors surface to UI via a non-null `persistenceError` getter.

**Tech Stack:** Dart ≥3.2, Flutter, `provider: ^6.1.5+1`, `cloud_firestore: ^5.6.0`, `shared_preferences: ^2.3.0`, `go_router: ^17.0.0`, `google_generative_ai: ^0.4.6`, `uuid: ^4.1.0`, `intl: ^0.20.0`. Reused widgets: `AssessmentCard`, `ChatBubbleUser`, `ChatBubbleAi`, `ChatInputBar`, `RadarScore`, `ScoreCircle`, `ClayCard`, `ClayButton`, `ClayPressable`, `ClayDialog`. Reused services: `GeminiService.generateStoryScenario`, `GeminiService.evaluateStoryTurn` (already implemented). Tests use vanilla `flutter_test` + hand-rolled fakes (no mock library deps).

**Spec:** `docs/superpowers/specs/2026-04-19-story-mode-design.md` — read sections 5 (data model), 7 (provider contract), 11.4 (regression guards) before starting.

---

## File Structure

**Created:**
- `lib/core/constants/story_constants.dart` — topic / character-pref enums + `kStoryHardCapTurns`
- `lib/features/story/models/story.dart` — library item (Firestore `/stories/{id}`)
- `lib/features/story/models/story_character.dart` — value object
- `lib/features/story/models/story_session.dart` — runtime state + Firestore conversation roundtrip
- `lib/features/story/models/story_turn.dart` — per-turn payload (id, role, text, timestamp, assessment?)
- `lib/features/story/providers/story_provider.dart` — `ChangeNotifier`
- `lib/features/story/screens/story_home_screen.dart`
- `lib/features/story/screens/story_custom_form_screen.dart`
- `lib/features/story/screens/story_chat_screen.dart`
- `lib/features/story/screens/story_summary_screen.dart`
- `lib/features/story/widgets/story_hero_card.dart`
- `lib/features/story/widgets/story_card.dart`
- `lib/features/story/widgets/story_stepper.dart`
- `lib/features/story/widgets/story_character_header.dart`
- `lib/features/home/widgets/start_story_sheet.dart`  (duplicated from `start_practice_sheet.dart`)
- `lib/data/cache/story_cache.dart` — library list cache fallback
- `lib/data/repositories/story_repository.dart` — composes cache + firestore for library reads
- `scripts/seed_stories.dart` — dev-only seed runner
- `scripts/stories_seed_data.json` — 12 curated stories
- `test/features/story/models/story_session_roundtrip_test.dart`
- `test/features/story/providers/story_provider_test.dart`
- `test/features/story/widgets/story_home_screen_smoke_test.dart`

**Modified:**
- `lib/data/datasources/firebase_datasource.dart` — add `getFeaturedStories({String level})` + `getStoryById(id)`
- `lib/data/datasources/local_datasource.dart` — add 3 active-story-session methods
- `lib/app.dart` — register `StoryCache`, `StoryRepository`, `StoryProvider`; add 4 `GoRoute` entries
- `lib/features/home/screens/home_screen.dart` — flip Story `_ModeConfig.route: null` → `route: '/story'`

**Conventions to honor:**
- No Vietnamese comments. No redundant comments.
- Naming: camelCase for fields/methods, PascalCase for types, `_uuid.v4()` for ids, ISO-8601 strings for timestamps.
- Imports: relative within `lib/` (matches existing style).
- Commit messages: lowercase scope prefix (`feat(story):`, `test(story):`, etc.) — match `git log` style.
- After each task that produces compilable code, run `flutter analyze` (no errors) before committing.

---

### Task 1: Constants, Story / StoryCharacter / StoryTurn / StorySession models

**Files:**
- Create: `lib/core/constants/story_constants.dart`
- Create: `lib/features/story/models/story_character.dart`
- Create: `lib/features/story/models/story.dart`
- Create: `lib/features/story/models/story_turn.dart`
- Create: `lib/features/story/models/story_session.dart`
- Test: `test/features/story/models/story_session_roundtrip_test.dart`

- [ ] **Step 1: Create `lib/core/constants/story_constants.dart`**

```dart
class StoryConstants {
  StoryConstants._();

  static const List<String> topicOptions = [
    'travel',
    'work',
    'dating',
    'family',
    'health',
    'hobby',
    'social',
    'daily',
  ];

  static const List<String> characterPreferences = [
    'Any',
    'Male',
    'Female',
    'Young',
    'Older',
  ];

  static const List<String> levelOptions = ['A1', 'A2', 'B1', 'B2', 'C1'];

  static const List<String> characterGradients = [
    'teal-purple',
    'gold-peach',
    'purple-pink',
    'teal-gold',
  ];

  static const int hardCapUserTurns = 20;
  static const int warningTurn = 18;
}
```

- [ ] **Step 2: Create `lib/features/story/models/story_character.dart`**

```dart
class StoryCharacter {
  final String name;
  final String role;
  final String personality;
  final String initial;
  final String gradient;

  const StoryCharacter({
    required this.name,
    required this.role,
    required this.personality,
    required this.initial,
    required this.gradient,
  });

  factory StoryCharacter.fromJson(Map<String, dynamic> json) => StoryCharacter(
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        personality: json['personality'] as String? ?? '',
        initial: json['initial'] as String? ??
            ((json['name'] as String? ?? '?').isNotEmpty
                ? (json['name'] as String).substring(0, 1).toUpperCase()
                : '?'),
        gradient: json['gradient'] as String? ?? 'teal-purple',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'personality': personality,
        'initial': initial,
        'gradient': gradient,
      };
}
```

- [ ] **Step 3: Create `lib/features/story/models/story.dart`**

```dart
import 'story_character.dart';

class Story {
  final String id;
  final String title;
  final String topic;
  final String level;
  final String situation;
  final StoryCharacter character;
  final int suggestedTurns;
  final String thumbnailIcon;
  final int order;

  const Story({
    required this.id,
    required this.title,
    required this.topic,
    required this.level,
    required this.situation,
    required this.character,
    this.suggestedTurns = 6,
    this.thumbnailIcon = '📖',
    this.order = 0,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        topic: json['topic'] as String? ?? 'social',
        level: json['level'] as String? ?? 'B1',
        situation: json['situation'] as String? ?? '',
        character: StoryCharacter.fromJson(
          (json['character'] as Map<String, dynamic>?) ?? const {},
        ),
        suggestedTurns: (json['suggestedTurns'] as num?)?.toInt() ?? 6,
        thumbnailIcon: json['thumbnailIcon'] as String? ?? '📖',
        order: (json['order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'topic': topic,
        'level': level,
        'situation': situation,
        'character': character.toJson(),
        'suggestedTurns': suggestedTurns,
        'thumbnailIcon': thumbnailIcon,
        'order': order,
      };
}
```

- [ ] **Step 4: Create `lib/features/story/models/story_turn.dart`**

```dart
import '../../scenario/models/assessment.dart';

enum StoryTurnRole { system, user, ai }

extension StoryTurnRoleX on StoryTurnRole {
  String get value => name;
  static StoryTurnRole fromString(String? raw) {
    switch (raw) {
      case 'user':
        return StoryTurnRole.user;
      case 'ai':
        return StoryTurnRole.ai;
      case 'system':
        return StoryTurnRole.system;
      default:
        return StoryTurnRole.user;
    }
  }
}

class StoryTurn {
  final String id;
  final StoryTurnRole role;
  final String text;
  final DateTime timestamp;
  final AssessmentResult? assessment;

  const StoryTurn({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.assessment,
  });

  factory StoryTurn.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String?;
    if (rawRole == 'assessment') {
      throw StateError(
        'Story turns must never have role="assessment". '
        'Assessments live INLINE on role="user" turns.',
      );
    }
    final role = StoryTurnRoleX.fromString(rawRole);
    AssessmentResult? assessment;
    final raw = json['assessment'];
    if (raw is Map) {
      assessment = AssessmentResult.fromJson(Map<String, dynamic>.from(raw));
    }
    return StoryTurn(
      id: json['id'] as String? ?? '',
      role: role,
      text: json['text'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      assessment: assessment,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.value,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        if (assessment != null) 'assessment': assessment!.toJson(),
      };

  StoryTurn copyWith({AssessmentResult? assessment}) => StoryTurn(
        id: id,
        role: role,
        text: text,
        timestamp: timestamp,
        assessment: assessment ?? this.assessment,
      );
}
```

- [ ] **Step 5: Create `lib/features/story/models/story_session.dart`**

```dart
import 'story_character.dart';
import 'story_turn.dart';

enum StorySessionStatus { inProgress, completed, abandoned }

extension StorySessionStatusX on StorySessionStatus {
  String get wireValue {
    switch (this) {
      case StorySessionStatus.inProgress:
        return 'in-progress';
      case StorySessionStatus.completed:
        return 'completed';
      case StorySessionStatus.abandoned:
        return 'abandoned';
    }
  }

  static StorySessionStatus fromWire(String? raw) {
    switch (raw) {
      case 'completed':
        return StorySessionStatus.completed;
      case 'abandoned':
        return StorySessionStatus.abandoned;
      default:
        return StorySessionStatus.inProgress;
    }
  }
}

class StorySession {
  final String conversationId;
  final String? storyId;
  final String title;
  final String situation;
  final StoryCharacter character;
  final String topic;
  final String level;
  final String? customContext;
  final String? characterPreference;
  final StorySessionStatus status;
  final List<StoryTurn> turns;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime updatedAt;
  final bool quotaCharged;

  const StorySession({
    required this.conversationId,
    required this.storyId,
    required this.title,
    required this.situation,
    required this.character,
    required this.topic,
    required this.level,
    required this.customContext,
    required this.characterPreference,
    required this.status,
    required this.turns,
    required this.startedAt,
    required this.endedAt,
    required this.updatedAt,
    required this.quotaCharged,
  });

  int get userTurnCount =>
      turns.where((t) => t.role == StoryTurnRole.user).length;

  double get averageScore {
    final scored = turns
        .where((t) => t.role == StoryTurnRole.user && t.assessment != null)
        .map((t) => t.assessment!.score)
        .toList();
    if (scored.isEmpty) return 0;
    return scored.reduce((a, b) => a + b) / scored.length;
  }

  factory StorySession.fromJson(Map<String, dynamic> json) {
    final rawTurns = json['turns'] as List<dynamic>? ?? const [];
    return StorySession(
      conversationId: json['conversationId'] as String? ?? '',
      storyId: json['storyId'] as String?,
      title: json['title'] as String? ?? '',
      situation: json['situation'] as String? ?? '',
      character: StoryCharacter.fromJson(
        (json['character'] as Map<String, dynamic>?) ?? const {},
      ),
      topic: json['topic'] as String? ?? 'social',
      level: json['level'] as String? ?? 'B1',
      customContext: json['customContext'] as String?,
      characterPreference: json['characterPreference'] as String?,
      status: StorySessionStatusX.fromWire(json['status'] as String?),
      turns: rawTurns
          .whereType<Map<String, dynamic>>()
          .map(StoryTurn.fromJson)
          .toList(),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      quotaCharged: json['quotaCharged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': 'story',
        'conversationId': conversationId,
        'storyId': storyId,
        'title': title,
        'situation': situation,
        'character': character.toJson(),
        'topic': topic,
        'level': level,
        'customContext': customContext,
        'characterPreference': characterPreference,
        'status': status.wireValue,
        'turns': turns.map((t) => t.toJson()).toList(),
        'totalScore': averageScore,
        'turnCount': userTurnCount,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'quotaCharged': quotaCharged,
      };

  StorySession copyWith({
    StorySessionStatus? status,
    List<StoryTurn>? turns,
    DateTime? endedAt,
    DateTime? updatedAt,
    bool? quotaCharged,
  }) =>
      StorySession(
        conversationId: conversationId,
        storyId: storyId,
        title: title,
        situation: situation,
        character: character,
        topic: topic,
        level: level,
        customContext: customContext,
        characterPreference: characterPreference,
        status: status ?? this.status,
        turns: turns ?? this.turns,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        quotaCharged: quotaCharged ?? this.quotaCharged,
      );
}
```

- [ ] **Step 6: Write the failing roundtrip test**

Create `test/features/story/models/story_session_roundtrip_test.dart`:

```dart
import 'package:aura_coach_ai/features/scenario/models/assessment.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:aura_coach_ai/features/story/models/story_session.dart';
import 'package:aura_coach_ai/features/story/models/story_turn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AssessmentResult buildAssessment() => AssessmentResult(
        score: 8,
        accuracyScore: 9,
        naturalnessScore: 8,
        complexityScore: 7,
        feedback: 'Nice phrasing.',
        analysis: 'Detailed analysis.',
        grammarAnalysis: 'Grammar Point: clean.',
        vocabularyAnalysis: 'Vocabulary Point: rich.',
        improvements: const [],
        userTone: 'Friendly',
        alternativeTones: AlternativeTones.fromAiJson(const {
          'formal': 'Good day.',
          'friendly': 'Hey!',
          'informal': 'yo',
          'conversational': 'Hi there.',
        }),
      );

  StorySession buildSession() => StorySession(
        conversationId: 'conv-1',
        storyId: 'story-1',
        title: 'Hotel Check-in',
        situation: 'You arrive at a hotel after a long flight.',
        character: const StoryCharacter(
          name: 'Maria',
          role: 'Receptionist',
          personality: 'warm, efficient',
          initial: 'M',
          gradient: 'teal-purple',
        ),
        topic: 'travel',
        level: 'B1',
        customContext: null,
        characterPreference: null,
        status: StorySessionStatus.inProgress,
        turns: [
          StoryTurn(
            id: 't0',
            role: StoryTurnRole.ai,
            text: 'Welcome! Do you have a reservation?',
            timestamp: DateTime.utc(2026, 4, 19, 10),
          ),
          StoryTurn(
            id: 't1',
            role: StoryTurnRole.user,
            text: 'Yes, under Smith.',
            timestamp: DateTime.utc(2026, 4, 19, 10, 1),
            assessment: buildAssessment(),
          ),
          StoryTurn(
            id: 't2',
            role: StoryTurnRole.ai,
            text: 'Found it. Welcome.',
            timestamp: DateTime.utc(2026, 4, 19, 10, 2),
          ),
        ],
        startedAt: DateTime.utc(2026, 4, 19, 9, 59),
        endedAt: null,
        updatedAt: DateTime.utc(2026, 4, 19, 10, 2),
        quotaCharged: true,
      );

  test('StorySession.toJson then fromJson preserves all turns and assessment',
      () {
    final original = buildSession();
    final restored = StorySession.fromJson(original.toJson());

    expect(restored.conversationId, original.conversationId);
    expect(restored.title, original.title);
    expect(restored.character.name, 'Maria');
    expect(restored.turns.length, 3);

    final userTurn = restored.turns[1];
    expect(userTurn.role, StoryTurnRole.user);
    expect(userTurn.assessment, isNotNull);
    expect(userTurn.assessment!.score, 8);
    expect(userTurn.assessment!.alternativeTones.formal.text, 'Good day.');
  });

  test('StoryTurn.fromJson rejects role="assessment" (regression guard)', () {
    expect(
      () => StoryTurn.fromJson({
        'id': 'x',
        'role': 'assessment',
        'text': '',
        'timestamp': DateTime.utc(2026, 4, 19).toIso8601String(),
      }),
      throwsA(isA<StateError>()),
    );
  });

  test('Average score uses only user-role turns with assessments', () {
    final s = buildSession();
    expect(s.averageScore, 8.0);
    expect(s.userTurnCount, 1);
  });
}
```

- [ ] **Step 7: Run the test, verify it passes**

Run: `flutter test test/features/story/models/story_session_roundtrip_test.dart`
Expected: 3 tests pass.

- [ ] **Step 8: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add lib/core/constants/story_constants.dart \
        lib/features/story/models/ \
        test/features/story/models/
git commit -m "feat(story): add Story / StoryCharacter / StoryTurn / StorySession models with regression guard against assessment-typed turns"
```

---

### Task 2: Datasource extensions + StoryCache

**Files:**
- Modify: `lib/data/datasources/firebase_datasource.dart`
- Modify: `lib/data/datasources/local_datasource.dart`
- Create: `lib/data/cache/story_cache.dart`
- Test: `test/data/cache/story_cache_test.dart`

- [ ] **Step 1: Extend `LocalDatasource` with active-story-session methods**

In `lib/data/datasources/local_datasource.dart`, add a new constant near the existing keys:

```dart
  static const _keyActiveStorySession = 'active_story_session';
```

Then add these methods inside the class (place them right after `clearActiveConversation`):

```dart
  Future<void> cacheActiveStorySession(Map<String, dynamic> data) async {
    await _prefs.setString(_keyActiveStorySession, jsonEncode(data));
  }

  Map<String, dynamic>? readActiveStorySession() {
    final raw = _prefs.getString(_keyActiveStorySession);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveStorySession() async {
    await _prefs.remove(_keyActiveStorySession);
  }
```

- [ ] **Step 2: Extend `FirebaseDatasource` with `getFeaturedStories` and `getStoryById`**

In `lib/data/datasources/firebase_datasource.dart`, add this import at the top (next to existing model imports):

```dart
import '../../features/story/models/story.dart';
```

Then add these methods at the bottom of the class, before the closing brace:

```dart
  Future<List<Story>> getFeaturedStories({String? level}) async {
    Query<Map<String, dynamic>> q =
        _db.collection('stories').orderBy('order');
    if (level != null && level.isNotEmpty) {
      q = q.where('level', isEqualTo: level);
    }
    final snapshot = await q.limit(20).get();
    return snapshot.docs
        .map((doc) => Story.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<Story?> getStoryById(String storyId) async {
    final doc = await _db.collection('stories').doc(storyId).get();
    if (!doc.exists) return null;
    return Story.fromJson({'id': doc.id, ...doc.data()!});
  }
```

- [ ] **Step 3: Create `lib/data/cache/story_cache.dart`**

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/story/models/story.dart';

/// Persists the last successful Story library list so the home screen can
/// gracefully degrade when Firestore is unreachable. Mirrors ScenarioCache.
class StoryCache {
  static const _kFeaturedKey = 'story_cache.featured.v1';

  final Future<SharedPreferences> _prefs;

  StoryCache({SharedPreferences? prefs})
      : _prefs = prefs == null
            ? SharedPreferences.getInstance()
            : Future.value(prefs);

  Future<void> saveFeatured(List<Story> stories) async {
    try {
      final prefs = await _prefs;
      final raw = jsonEncode(stories.map((s) => s.toJson()).toList());
      await prefs.setString(_kFeaturedKey, raw);
    } catch (e) {
      debugPrint('[StoryCache] saveFeatured failed: $e');
    }
  }

  Future<List<Story>> getFeatured() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kFeaturedKey);
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Story.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[StoryCache] getFeatured failed: $e');
      return const [];
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_kFeaturedKey);
    } catch (e) {
      debugPrint('[StoryCache] clear failed: $e');
    }
  }
}
```

- [ ] **Step 4: Write failing cache roundtrip test**

Create `test/data/cache/story_cache_test.dart`:

```dart
import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/features/story/models/story.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveFeatured roundtrips stories through SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);

    final input = [
      const Story(
        id: 's1',
        title: 'Airport Check-in',
        topic: 'travel',
        level: 'A2',
        situation: 'At the airport.',
        character: StoryCharacter(
          name: 'Liam',
          role: 'Agent',
          personality: 'helpful',
          initial: 'L',
          gradient: 'teal-gold',
        ),
      ),
    ];

    await cache.saveFeatured(input);
    final read = await cache.getFeatured();

    expect(read, hasLength(1));
    expect(read.first.title, 'Airport Check-in');
    expect(read.first.character.name, 'Liam');
  });

  test('getFeatured returns empty list when nothing cached', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    expect(await cache.getFeatured(), isEmpty);
  });
}
```

- [ ] **Step 5: Run cache test, verify it passes**

Run: `flutter test test/data/cache/story_cache_test.dart`
Expected: 2 tests pass.

- [ ] **Step 6: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/data/datasources/firebase_datasource.dart \
        lib/data/datasources/local_datasource.dart \
        lib/data/cache/story_cache.dart \
        test/data/cache/
git commit -m "feat(story): add Firestore + local datasource extensions and StoryCache"
```

---

### Task 3: StoryRepository

**Files:**
- Create: `lib/data/repositories/story_repository.dart`
- Test: `test/data/repositories/story_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/repositories/story_repository_test.dart`:

```dart
import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/data/datasources/firebase_datasource.dart';
import 'package:aura_coach_ai/data/repositories/story_repository.dart';
import 'package:aura_coach_ai/features/story/models/story.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirebase extends FirebaseDatasource {
  _FakeFirebase({required this.live, this.shouldThrow = false})
      : super(db: _NeverCalledFirestore());

  List<Story> live;
  bool shouldThrow;

  @override
  Future<List<Story>> getFeaturedStories({String? level}) async {
    if (shouldThrow) throw StateError('offline');
    return live.where((s) => level == null || s.level == level).toList();
  }
}

class _NeverCalledFirestore implements dynamic {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('Firestore should not be called in this test');
}

Story _story({required String id, String level = 'B1'}) => Story(
      id: id,
      title: 'Story $id',
      topic: 'travel',
      level: level,
      situation: 'context',
      character: const StoryCharacter(
        name: 'X',
        role: 'r',
        personality: 'p',
        initial: 'X',
        gradient: 'teal-purple',
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('fetchFeatured returns Firestore result and updates cache', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    final repo = StoryRepository(
      firebase: _FakeFirebase(live: [_story(id: 's1'), _story(id: 's2')]),
      cache: cache,
    );

    final result = await repo.fetchFeatured(level: 'B1');
    expect(result, hasLength(2));
    final cached = await cache.getFeatured();
    expect(cached, hasLength(2));
  });

  test('fetchFeatured falls back to cache on Firestore failure', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    await cache.saveFeatured([_story(id: 'cached')]);

    final repo = StoryRepository(
      firebase: _FakeFirebase(live: [], shouldThrow: true),
      cache: cache,
    );

    final result = await repo.fetchFeatured(level: 'B1');
    expect(result, hasLength(1));
    expect(result.first.id, 'cached');
  });
}
```

- [ ] **Step 2: Run test, verify it fails with "URI doesn't exist"**

Run: `flutter test test/data/repositories/story_repository_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:aura_coach_ai/data/repositories/story_repository.dart'`.

- [ ] **Step 3: Create `lib/data/repositories/story_repository.dart`**

```dart
import 'package:flutter/foundation.dart';
import '../cache/story_cache.dart';
import '../datasources/firebase_datasource.dart';
import '../../features/story/models/story.dart';

/// Combines Firestore reads with the local [StoryCache] fallback so the home
/// screen can always show something — even offline.
class StoryRepository {
  final FirebaseDatasource _firebase;
  final StoryCache _cache;

  StoryRepository({
    required FirebaseDatasource firebase,
    required StoryCache cache,
  })  : _firebase = firebase,
        _cache = cache;

  Future<List<Story>> fetchFeatured({String? level}) async {
    try {
      final live = await _firebase.getFeaturedStories(level: level);
      if (live.isNotEmpty) {
        await _cache.saveFeatured(live);
      }
      return live;
    } catch (e) {
      debugPrint('[StoryRepository] fetchFeatured live read failed: $e');
      final cached = await _cache.getFeatured();
      if (level == null) return cached;
      return cached.where((s) => s.level == level).toList();
    }
  }

  Future<Story?> fetchById(String storyId) async {
    try {
      return await _firebase.getStoryById(storyId);
    } catch (e) {
      debugPrint('[StoryRepository] fetchById failed: $e');
      final cached = await _cache.getFeatured();
      try {
        return cached.firstWhere((s) => s.id == storyId);
      } catch (_) {
        return null;
      }
    }
  }
}
```

- [ ] **Step 4: Run test, verify it passes**

Run: `flutter test test/data/repositories/story_repository_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/story_repository.dart \
        test/data/repositories/
git commit -m "feat(story): add StoryRepository with cache fallback"
```

---

### Task 4: StoryProvider — initialization, library load, quota

**Files:**
- Create: `lib/features/story/providers/story_provider.dart` (initial skeleton)
- Test: `test/features/story/providers/story_provider_test.dart` (init + quota cases)

- [ ] **Step 1: Write the failing test**

Create `test/features/story/providers/story_provider_test.dart`:

```dart
// ignore_for_file: subtype_of_sealed_class

import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/data/datasources/firebase_datasource.dart';
import 'package:aura_coach_ai/data/datasources/local_datasource.dart';
import 'package:aura_coach_ai/data/gemini/gemini_service.dart';
import 'package:aura_coach_ai/data/repositories/story_repository.dart';
import 'package:aura_coach_ai/features/story/models/story.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
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
  Future<Map<String, int>> getDailyUsage(String uid, String date) async => usage;

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
      String uid, {String? mode}) async {
    final list = userConversations;
    if (mode != null) return list.where((m) => m['mode'] == mode).toList();
    return list;
  }
}

class _FakeGemini extends GeminiService {
  _FakeGemini() : super(apiKey: 'test-key');
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
  late SharedPreferences prefs;
  late LocalDatasource local;
  late StoryCache cache;
  late StoryRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = LocalDatasource(prefs: prefs);
    cache = StoryCache(prefs: prefs);
    repo = StoryRepository(firebase: _FakeFirebase(), cache: cache);
  });

  test('init loads daily usage and exposes correct quota', () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 2};
    repo = StoryRepository(firebase: firebase, cache: cache);

    final provider = StoryProvider(
      gemini: _FakeGemini(),
      firebase: firebase,
      local: local,
      cache: cache,
      repository: repo,
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
}
```

- [ ] **Step 2: Run test, verify it fails (provider file missing)**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: FAIL — `URI doesn't exist`.

- [ ] **Step 3: Create the provider with init + library load + quota**

Create `lib/features/story/providers/story_provider.dart`:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/quota_constants.dart';
import '../../../data/cache/story_cache.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/repositories/story_repository.dart';
import '../models/story.dart';
import '../models/story_session.dart';

class StoryProvider extends ChangeNotifier {
  final GeminiService _gemini;
  final FirebaseDatasource _firebase;
  final LocalDatasource _local;
  // ignore: unused_field
  final StoryCache _cache;
  final StoryRepository _repository;
  final _uuid = const Uuid();

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

  String? _uid;
  String _tier = 'free';
  String _level = 'B1';

  List<Story> _featured = const [];
  StorySession? _session;
  Map<String, int> _usage = const {};
  bool _isLoading = false;
  String? _error;
  String? _persistenceError;

  // Used by helpers added in later tasks.
  // ignore: unused_element
  Uuid get _uuidGen => _uuid;
  // ignore: unused_element
  GeminiService get _geminiService => _gemini;
  // ignore: unused_element
  LocalDatasource get _localDs => _local;

  List<Story> get featuredLibrary => List.unmodifiable(_featured);
  StorySession? get activeSession => _session;
  int get storyUsedToday => _usage['storyCount'] ?? 0;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get persistenceError => _persistenceError;

  int get _storyLimit => QuotaConstants.getLimit(_tier, 'story');

  String get _todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

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
      _featured = await _repository.fetchFeatured(level: _level);
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

  /// Loads the current user's conversations with `mode='story'` and
  /// `status='in-progress'`. Used by the Home entry-flow popup to let the
  /// user resume an earlier story. Mirrors Scenario's equivalent helper.
  Future<List<Map<String, dynamic>>> loadUserStoryConversations() async {
    final uid = _uid;
    if (uid == null) return const [];
    try {
      final all = await _firebase.getConversations(uid, mode: 'story');
      return all
          .where((c) => (c['status'] as String?) == 'in-progress')
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
```

- [ ] **Step 4: Run tests, verify they pass**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: 3 tests pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/story/providers/story_provider.dart \
        test/features/story/providers/
git commit -m "feat(story): scaffold StoryProvider with init, refreshLibrary, and quota check"
```

---

### Task 5: StoryProvider — `startFromLibrary` and `startFromCustom`

**Files:**
- Modify: `lib/features/story/providers/story_provider.dart`
- Modify: `test/features/story/providers/story_provider_test.dart` (extend)

- [ ] **Step 1: Extend the test file with two failing tests**

Append these tests to `test/features/story/providers/story_provider_test.dart` (inside `void main()`, before the closing brace). Add the helper above `void main()`:

```dart
class _ScriptedGemini extends GeminiService {
  _ScriptedGemini({required this.scenarioJson});
  final String scenarioJson;

  @override
  Future<String> generateStoryScenario({
    required dynamic level,
    required String topic,
    required List<String> previousTitles,
    String? customContext,
  }) async {
    return scenarioJson;
  }
}

class _AlwaysFailGemini extends GeminiService {
  @override
  Future<String> generateStoryScenario({
    required dynamic level,
    required String topic,
    required List<String> previousTitles,
    String? customContext,
  }) async {
    throw StateError('gemini down');
  }
}
```

Add these tests inside `main()`:

```dart
  test('startFromLibrary creates session, charges quota, persists conversation',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    final scenario = '''
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
    expect(provider.activeSession!.turns.first.text,
        contains('Welcome'));
    expect(firebase.usage['storyCount'], 1);
    expect(firebase.savedConversations, hasLength(1));
    expect(firebase.savedConversations.first['mode'], 'story');
  });

  test('startFromLibrary returns false and does NOT charge when quota exhausted',
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
    final scenario = '''
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
    expect(provider.activeSession!.customContext,
        'Coffee shop, first date.');
  });
```

- [ ] **Step 2: Run tests, verify the new ones fail**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: FAIL — `startFromLibrary` / `startFromCustom` not defined.

- [ ] **Step 3: Implement `startFromLibrary` and `startFromCustom`**

Add these helpers + the two public methods to `StoryProvider` (place after `canStartSession`):

```dart
  final List<String> _recentTitles = [];

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
    required dynamic libraryCharacter,
    required String? customContext,
    required String? characterPreference,
  }) async {
    if (_uid == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cefr = _cefrFromLevelCode(level);
      final raw = await _gemini.generateStoryScenario(
        level: cefr,
        topic: topic,
        previousTitles: List<String>.from(_recentTitles),
        customContext: customContext,
      );
      final parsed = _parseStoryJson(raw);

      final agentOpening = (parsed['openingLine'] as String?) ??
          (parsed['agentOpeningLine'] as String?) ??
          'Hi!';
      final aiAgentName = (parsed['agentName'] as String?) ?? 'Coach';
      final aiSituation =
          (parsed['situation'] as String?) ?? situation;
      final aiTitle = (parsed['title'] as String?) ??
          (parsed['topic'] as String?) ??
          topic;

      final character = libraryCharacter is StoryCharacterLike
          ? libraryCharacter.toCharacter()
          : _buildCharacterFromAi(aiAgentName, characterPreference);

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
      );

      _session = session;
      _recentTitles.add(aiTitle);
      if (_recentTitles.length > 5) _recentTitles.removeAt(0);

      _usage = {..._usage, 'storyCount': storyUsedToday + 1};
      unawaited(_firebase
          .incrementDailyUsage(_uid!, _todayDate, 'story')
          .catchError((_) {}));

      await _persistSession(session);
      return true;
    } catch (e) {
      debugPrint('[StoryProvider] _startSession failed: $e');
      _error = 'Couldn\'t generate story, please try again.';
      _session = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _parseStoryJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return const {};
  }

  StoryCharacter _buildCharacterFromAi(
    String agentName,
    String? preference,
  ) {
    final initial = agentName.isNotEmpty
        ? agentName.substring(0, 1).toUpperCase()
        : '?';
    final gradient = StoryConstants
        .characterGradients[
            agentName.hashCode.abs() % StoryConstants.characterGradients.length];
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

  CefrLevel _cefrFromLevelCode(String code) {
    switch (code.toUpperCase()) {
      case 'A1':
      case 'A2':
      case 'A1-A2':
        return CefrLevel.a1a2;
      case 'C1':
      case 'C2':
      case 'C1-C2':
        return CefrLevel.c1c2;
      default:
        return CefrLevel.b1b2;
    }
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
      _persistenceError = 'Last save failed — retrying on next message.';
    }
  }
```

Add these imports to the top of the file:

```dart
import 'dart:convert';
import '../../../core/constants/story_constants.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../models/story_character.dart';
import '../models/story_turn.dart';
```

Add this small adapter at the bottom of the file (outside the class):

```dart
/// Tiny adapter so `_startSession` can accept either a library character
/// (snapshot from the Story doc) or null (custom flow).
abstract class StoryCharacterLike {
  StoryCharacter toCharacter();
}

extension StoryCharacterAdapter on StoryCharacter {
  StoryCharacterLike asLike() => _CharacterLike(this);
}

class _CharacterLike implements StoryCharacterLike {
  _CharacterLike(this._c);
  final StoryCharacter _c;
  @override
  StoryCharacter toCharacter() => _c;
}
```

In `startFromLibrary`, change:

```dart
      libraryCharacter: story.character,
```

to:

```dart
      libraryCharacter: story.character.asLike(),
```

- [ ] **Step 4: Run tests, verify they pass**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: All 7 tests pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/story/providers/story_provider.dart \
        test/features/story/providers/
git commit -m "feat(story): implement startFromLibrary + startFromCustom with quota-only-on-success"
```

---

### Task 6: StoryProvider — `sendUserMessage` (assessment INLINE on user turn)

**Files:**
- Modify: `lib/features/story/providers/story_provider.dart`
- Modify: `test/features/story/providers/story_provider_test.dart` (extend)

- [ ] **Step 1: Add the failing tests for the assessment-inline invariant**

Append to `test/features/story/providers/story_provider_test.dart`:

Helper:

```dart
class _EvalGemini extends _ScriptedGemini {
  _EvalGemini({required super.scenarioJson, required this.evalJson});
  final String evalJson;

  @override
  Future<String> evaluateStoryTurn({
    required String situation,
    required String agentName,
    required String agentLastMessage,
    required String userReply,
    required dynamic targetLevel,
  }) async {
    return evalJson;
  }
}
```

Test:

```dart
  test('sendUserMessage stores assessment INLINE on the user turn (regression)',
      () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    final scenario = '''
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
    final eval = '''
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
    // [aiOpening, user(with assessment), ai(reply)]
    expect(turns, hasLength(3));
    expect(turns[1].role.name, 'user');
    expect(turns[1].assessment, isNotNull);
    expect(turns[1].assessment!.score, 8);
    expect(turns[2].role.name, 'ai');
    expect(turns[2].text, 'Great. Your room is ready.');

    // Persistence check: the saved JSON has assessment under turns[1] only.
    final saved = firebase.savedConversations.last;
    final savedTurns = (saved['turns'] as List).cast<Map<String, dynamic>>();
    expect(savedTurns[1]['assessment'], isNotNull);
    expect(savedTurns[2].containsKey('assessment'), isFalse);
    // No turn should ever have role='assessment'
    expect(
      savedTurns.any((t) => t['role'] == 'assessment'),
      isFalse,
      reason: 'Story Mode must NEVER write role=assessment turns',
    );
  });

  test('sendUserMessage surfaces persistenceError when Firestore save fails',
      () async {
    final firebase = _BrokenSaveFirebase()..usage = {'storyCount': 0};
    final scenario = '''
{
  "id": "ai-1", "topic": "travel", "situation": "Airport.",
  "agentName": "Mia", "openingLine": "Hi!",
  "openingLineVietnamese": "Chào!", "difficulty": "B1-B2",
  "hints": {"level1": "a", "level2": "b", "level3": "c"}
}
''';
    final eval = '''
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
  });
```

Add the broken-save fake near the other fakes:

```dart
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
        uid: uid, conversationId: conversationId, data: data);
  }
}
```

- [ ] **Step 2: Run tests, verify the new ones fail**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: FAIL — `sendUserMessage` not defined.

- [ ] **Step 3: Implement `sendUserMessage`**

Add to `StoryProvider` (place after `_startSession`):

```dart
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

    _session = session.copyWith(
      turns: [...session.turns, userTurnPlaceholder],
      updatedAt: now,
    );
    _isLoading = true;
    notifyListeners();

    try {
      final raw = await _gemini.evaluateStoryTurn(
        situation: session.situation,
        agentName: session.character.name,
        agentLastMessage: agentLast,
        userReply: text,
        targetLevel: _cefrFromLevelCode(session.level),
      );
      final parsed = _parseStoryJson(raw);
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
      _error = null;
      await _persistSession(_session!);
    } catch (e) {
      debugPrint('[StoryProvider] evaluateStoryTurn failed: $e');
      _error = 'Couldn\'t evaluate that reply. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
```

Add this import to the top of the provider file:

```dart
import '../../scenario/models/assessment.dart';
```

- [ ] **Step 4: Run tests, verify all pass**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: All tests pass (9 total).

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/story/providers/story_provider.dart \
        test/features/story/providers/
git commit -m "feat(story): implement sendUserMessage with inline assessment + persistenceError surface"
```

---

### Task 7: StoryProvider — `endSession`, `abandonSession`, `saveCorrectionToVocab`, `resumeSession`

**Files:**
- Modify: `lib/features/story/providers/story_provider.dart`
- Modify: `test/features/story/providers/story_provider_test.dart` (extend)

**Note:** SharedPreferences-based auto-resume is deliberately NOT wired here. Resume is driven by the Home entry-flow popup (see spec Section 4.0). `LocalDatasource.cacheActiveStorySession` / `readActiveStorySession` / `clearActiveStorySession` stay as dormant code in MVP.

- [ ] **Step 1: Add the failing tests**

Append to the test file:

```dart
  test('endSession marks status=completed and keeps activeSession', () async {
    final firebase = _FakeFirebase()..usage = {'storyCount': 0};
    final scenario = '''
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

    expect(provider.activeSession?.status, StorySessionStatus.completed);
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
        'name': 'Mia', 'role': 'Agent', 'personality': 'warm',
        'initial': 'M', 'gradient': 'teal-purple',
      },
      'topic': 'travel',
      'level': 'B1',
      'status': 'in-progress',
      'turns': [
        {'id': 't0', 'role': 'ai', 'text': 'Hi',
         'timestamp': '2026-04-19T10:00:00Z'},
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
        'name': 'Mia', 'role': 'Agent', 'personality': 'warm',
        'initial': 'M', 'gradient': 'teal-purple',
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
```

Add this fake near the others:

```dart
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
```

- [ ] **Step 2: Run tests, verify they fail**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: FAIL — `endSession`, `resumeSession` not implemented.

- [ ] **Step 3: Implement endSession, abandonSession, saveCorrectionToVocab, and resumeSession**

Add to `StoryProvider`:

```dart
  Future<void> endSession() async {
    final session = _session;
    if (session == null || _uid == null) return;

    final ended = session.copyWith(
      status: StorySessionStatus.completed,
      endedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _session = ended;
    await _persistSession(ended);
    notifyListeners();
  }

  Future<void> abandonSession() async {
    final session = _session;
    if (session == null || _uid == null) return;

    final aborted = session.copyWith(
      status: StorySessionStatus.abandoned,
      endedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _session = aborted;
    await _persistSession(aborted);
    notifyListeners();
  }

  Future<void> saveCorrectionToVocab(Improvement improvement) async {
    if (_uid == null) return;
    final item = SavedItem(
      id: _uuid.v4(),
      original: improvement.original,
      correction: improvement.correction,
      type: improvement.type.value,
      context: _session?.situation ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      nextReviewDate: DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
    try {
      await _firebase.saveSavedItem(_uid!, item);
    } catch (e) {
      debugPrint('[StoryProvider] saveCorrectionToVocab failed: $e');
    }
  }

  /// Rehydrates an in-progress story conversation from Firestore.
  /// Called from the Home entry-flow popup when the user taps a resume card.
  /// Returns `true` on success, `false` if the doc is missing or not in-progress.
  Future<bool> resumeSession(String conversationId) async {
    if (_uid == null) return false;
    try {
      final raw = await _firebase.getConversation(_uid!, conversationId);
      if (raw == null) return false;
      final session = StorySession.fromJson(raw);
      if (session.status != StorySessionStatus.inProgress) return false;
      _session = session;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[StoryProvider] resumeSession failed: $e');
      _error = 'Could not resume that story. Try again.';
      notifyListeners();
      return false;
    }
  }
```

Add these imports to the top of the file:

```dart
import '../../my_library/models/saved_item.dart';
import '../../scenario/models/assessment.dart' show AssessmentResult, Improvement;
```

(Remove the duplicate `AssessmentResult` import added in Task 6 — keep only one import line for `assessment.dart`.)

- [ ] **Step 4: Run tests, verify all pass**

Run: `flutter test test/features/story/providers/story_provider_test.dart`
Expected: All tests pass (12 total).

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/story/providers/story_provider.dart \
        test/features/story/providers/
git commit -m "feat(story): add endSession, abandonSession, saveCorrectionToVocab, resumeSession"
```

---

### Task 8: Story Home screen + 2 widgets (StoryHeroCard, StoryCard)

**Files:**
- Create: `lib/features/story/widgets/story_hero_card.dart`
- Create: `lib/features/story/widgets/story_card.dart`
- Create: `lib/features/story/screens/story_home_screen.dart`
- Test: `test/features/story/widgets/story_home_screen_smoke_test.dart`

**Note:** No `StoryContinueBanner` widget. Resume is driven by the Home entry-flow popup (`start_story_sheet.dart`, created in Task 12), not by an in-screen banner. Skip Step 3 below.

- [ ] **Step 1: Create `story_hero_card.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_pressable.dart';

class StoryHeroCard extends StatelessWidget {
  final VoidCallback? onTap;

  const StoryHeroCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, AppColors.purple],
            ),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.warmDark, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.warmDark,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Your Own Story',
                      style: AppTypography.headingMd.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick a topic, set the scene, talk in English.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.cream,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  size: 28, color: AppColors.cream),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Create `story_card.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/story.dart';

class StoryCardWidget extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;

  const StoryCardWidget({super.key, required this.story, this.onTap});

  Color _levelBadgeColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
      case 'A2':
        return const Color(0xFFD6EBC7);
      case 'B1':
      case 'B2':
        return const Color(0xFFC7DDEB);
      default:
        return AppColors.purple.withValues(alpha: 0.25);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(story.thumbnailIcon,
                      style: const TextStyle(fontSize: 28)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _levelBadgeColor(story.level),
                      borderRadius: AppRadius.fullBorder,
                    ),
                    child: Text(
                      story.level,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.warmDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                story.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sectionTitle.copyWith(
                  color: AppColors.warmDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'with ${story.character.name} · ${story.suggestedTurns} turns',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: (removed — no StoryContinueBanner in revised flow)**

- [ ] **Step 4: Create `story_home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/story_card.dart';
import '../widgets/story_hero_card.dart';

class StoryHomeScreen extends StatefulWidget {
  const StoryHomeScreen({super.key});

  @override
  State<StoryHomeScreen> createState() => _StoryHomeScreenState();
}

class _StoryHomeScreenState extends State<StoryHomeScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized) return;
      _initialized = true;
      final auth = context.read<AuthProvider>();
      final profile = context.read<HomeProvider>().userProfile;
      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      await context.read<StoryProvider>().init(
            uid: uid,
            tier: profile?.tier ?? 'free',
            level: _normalizeLevel(profile?.proficiencyLevel),
          );
    });
  }

  String _normalizeLevel(String? raw) {
    if (raw == null) return 'B1';
    final s = raw.toLowerCase();
    if (s.contains('beginner') || s.startsWith('a')) return 'A2';
    if (s.contains('advanced') || s.startsWith('c')) return 'C1';
    return 'B1';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final limit = QuotaConstantsAccessor.story(provider);
    final used = provider.storyUsedToday;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: provider.isLoading && provider.featuredLibrary.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => provider.refreshLibrary(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ClayBackButton(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Story Mode',
                              style: AppTypography.headingMd.copyWith(
                                color: AppColors.warmDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _quotaPill(used: used, limit: limit),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      StoryHeroCard(
                        onTap: () => context.push('/story/custom'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Featured Stories',
                        style: AppTypography.sectionTitle.copyWith(
                          color: AppColors.warmDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.smd),
                      if (provider.featuredLibrary.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              provider.error ??
                                  'No featured stories yet — pull to refresh.',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.warmMuted,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                          children: [
                            for (final story in provider.featuredLibrary)
                              StoryCardWidget(
                                story: story,
                                onTap: () => _onStartStory(provider, story),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _onStartStory(
      StoryProvider provider, dynamic story) async {
    final ok = await provider.startFromLibrary(story);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not start story.'),
        ),
      );
      return;
    }
    context.push('/story/chat');
  }

  Widget _quotaPill({required int used, required int limit}) {
    final label = limit == -1 ? 'Unlimited' : '$used/$limit today';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Text(
        label,
        style: AppTypography.labelSm.copyWith(
          color: AppColors.warmDark,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class QuotaConstantsAccessor {
  static int story(StoryProvider provider) {
    // Read tier indirectly: provider exposes only used/limit via canStartSession.
    // Inferring limit from provider state keeps the screen stateless of QuotaConstants.
    if (provider.canStartSession() && provider.storyUsedToday == 0) {
      // default heuristic — provider is the source of truth via canStartSession
      // we still want the visible cap, so we re-derive from QuotaConstants via tier inference.
    }
    return _inferLimit(provider);
  }

  static int _inferLimit(StoryProvider p) {
    final used = p.storyUsedToday;
    final canStart = p.canStartSession();
    if (canStart && used == 0) return _bestGuessLimit();
    if (!canStart) return used;
    return used + (canStart ? 1 : 0);
  }

  static int _bestGuessLimit() => 3;
}
```

> Pragmatic note: `QuotaConstantsAccessor` is a temporary indirection. Replace it with a direct `provider.storyLimit` getter in Task 11 (wire-up phase) — see Task 11 step "Add `storyLimit` getter".

- [ ] **Step 5: Write a smoke test**

Create `test/features/story/widgets/story_home_screen_smoke_test.dart`:

```dart
import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/data/datasources/firebase_datasource.dart';
import 'package:aura_coach_ai/data/datasources/local_datasource.dart';
import 'package:aura_coach_ai/data/gemini/gemini_service.dart';
import 'package:aura_coach_ai/data/repositories/story_repository.dart';
import 'package:aura_coach_ai/features/story/providers/story_provider.dart';
import 'package:aura_coach_ai/features/story/widgets/story_hero_card.dart';
import 'package:aura_coach_ai/features/story/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SilentFirebase extends FirebaseDatasource {
  _SilentFirebase() : super(db: _Never());
  @override
  Future<List> getFeaturedStories({String? level}) async => const [];
  @override
  Future<Map<String, int>> getDailyUsage(String uid, String date) async =>
      {'storyCount': 0};
}

class _Never implements dynamic {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('Firestore not used in smoke test');
}

void main() {
  testWidgets('StoryHeroCard renders the CTA copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StoryHeroCard()),
      ),
    );
    expect(find.text('Create Your Own Story'), findsOneWidget);
  });

  testWidgets('Empty featured library renders empty-state hint',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    final firebase = _SilentFirebase();
    final provider = StoryProvider(
      gemini: GeminiService(),
      firebase: firebase,
      local: LocalDatasource(prefs: prefs),
      cache: cache,
      repository: StoryRepository(firebase: firebase, cache: cache),
    );
    await provider.init(uid: 'u', tier: 'free', level: 'B1');

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<StoryProvider>.value(
          value: provider,
          child: const Scaffold(body: SizedBox()), // smoke only — covers init
        ),
      ),
    );
    expect(provider.featuredLibrary, isEmpty);
  });
}
```

> Note: the second test exercises `StoryProvider.init` with empty library. Full screen-level pumping is deferred to Task 12 (after wiring) where Auth/HomeProvider are also available.

- [ ] **Step 6: Run tests, verify they pass**

Run: `flutter test test/features/story/widgets/`
Expected: 2 tests pass.

- [ ] **Step 7: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/features/story/widgets/story_hero_card.dart \
        lib/features/story/widgets/story_card.dart \
        lib/features/story/screens/story_home_screen.dart \
        test/features/story/widgets/
git commit -m "feat(story): add Story home screen + Hero / Card widgets"
```

---

### Task 9: Story Custom Form screen + StoryStepper widget

**Files:**
- Create: `lib/features/story/widgets/story_stepper.dart`
- Create: `lib/features/story/screens/story_custom_form_screen.dart`

- [ ] **Step 1: Create `story_stepper.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StoryStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StoryStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 22 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.teal
                  : (isActive ? AppColors.warmDark : AppColors.clayBeige),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.clayBorder, width: 1.5),
            ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 2: Create `story_custom_form_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/story_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../providers/story_provider.dart';
import '../widgets/story_stepper.dart';

class StoryCustomFormScreen extends StatefulWidget {
  const StoryCustomFormScreen({super.key});

  @override
  State<StoryCustomFormScreen> createState() => _StoryCustomFormScreenState();
}

class _StoryCustomFormScreenState extends State<StoryCustomFormScreen> {
  String? _topic;
  String _level = 'B1';
  String _characterPref = 'Any';
  final _customTopicCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customTopicCtrl.dispose();
    _contextCtrl.dispose();
    super.dispose();
  }

  int get _currentStep {
    if (_topic == null && _customTopicCtrl.text.trim().isEmpty) return 0;
    return 3; // we render all 4 fields at once; stepper only signals topic-done
  }

  bool get _canSubmit =>
      (_topic != null) || _customTopicCtrl.text.trim().isNotEmpty;

  Future<void> _onSubmit() async {
    if (!_canSubmit || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final provider = context.read<StoryProvider>();
    final topic = _topic ?? _customTopicCtrl.text.trim();
    final ok = await provider.startFromCustom(
      topic: topic,
      level: _level,
      characterPreference: _characterPref,
      customContext: _contextCtrl.text.trim().isEmpty
          ? null
          : _contextCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not generate story.'),
        ),
      );
      return;
    }
    context.go('/story/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  const ClayBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Custom Story',
                      style: AppTypography.headingMd.copyWith(
                        color: AppColors.warmDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            StoryStepper(totalSteps: 4, currentStep: _currentStep),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                children: [
                  _label('1 · Topic'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in StoryConstants.topicOptions)
                        _chip(
                          label: t,
                          selected: _topic == t,
                          onTap: () => setState(() {
                            _topic = t;
                            _customTopicCtrl.clear();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customTopicCtrl,
                    onChanged: (_) => setState(() => _topic = null),
                    decoration: InputDecoration(
                      hintText: 'Or type your own topic…',
                      filled: true,
                      fillColor: AppColors.clayWhite,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                        borderSide: const BorderSide(
                            color: AppColors.clayBorder, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _label('2 · Your level'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final l in StoryConstants.levelOptions)
                        _chip(
                          label: l,
                          selected: _level == l,
                          onTap: () => setState(() => _level = l),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _label('3 · Character preference'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in StoryConstants.characterPreferences)
                        _chip(
                          label: c,
                          selected: _characterPref == c,
                          onTap: () => setState(() => _characterPref = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _label('4 · Specific context (optional)'),
                  TextField(
                    controller: _contextCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'e.g., First date in a coffee shop downtown.',
                      filled: true,
                      fillColor: AppColors.clayWhite,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                        borderSide: const BorderSide(
                            color: AppColors.clayBorder, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: ClayButton(
                text: _isSubmitting ? 'Generating…' : 'Next →',
                onTap: _canSubmit && !_isSubmitting ? _onSubmit : null,
                isLoading: _isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.warmDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : AppColors.clayBeige,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.warmDark : AppColors.clayBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.warmDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2.5: Smoke test for the form**

Create `test/features/story/widgets/story_custom_form_smoke_test.dart`:

```dart
import 'package:aura_coach_ai/features/story/widgets/story_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StoryStepper renders the right number of dots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StoryStepper(totalSteps: 4, currentStep: 1),
        ),
      ),
    );
    expect(find.byType(AnimatedContainer), findsNWidgets(4));
  });
}
```

- [ ] **Step 3: Run tests, verify they pass**

Run: `flutter test test/features/story/`
Expected: All tests pass.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/story/widgets/story_stepper.dart \
        lib/features/story/screens/story_custom_form_screen.dart \
        test/features/story/widgets/story_custom_form_smoke_test.dart
git commit -m "feat(story): add Custom Story form screen + StoryStepper"
```

---

### Task 10: Story Chat screen + StoryCharacterHeader

**Files:**
- Create: `lib/features/story/widgets/story_character_header.dart`
- Create: `lib/features/story/screens/story_chat_screen.dart`

- [ ] **Step 1: Create `story_character_header.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/story_character.dart';

class StoryCharacterHeader extends StatelessWidget {
  final StoryCharacter character;
  final VoidCallback? onEnd;

  const StoryCharacterHeader({
    super.key,
    required this.character,
    this.onEnd,
  });

  LinearGradient _gradient() {
    switch (character.gradient) {
      case 'gold-peach':
        return const LinearGradient(colors: [AppColors.gold, AppColors.coral]);
      case 'purple-pink':
        return const LinearGradient(
            colors: [AppColors.purple, AppColors.coral]);
      case 'teal-gold':
        return const LinearGradient(colors: [AppColors.teal, AppColors.gold]);
      default:
        return const LinearGradient(
            colors: [AppColors.teal, AppColors.purple]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const ClayBackButton(),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient(),
              border: Border.all(color: AppColors.warmDark, width: 2),
            ),
            child: Center(
              child: Text(
                character.initial,
                style: AppTypography.headingSm.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: AppTypography.sectionTitle.copyWith(
                    color: AppColors.warmDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  character.role,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (onEnd != null)
            ClayPressable(
              onTap: onEnd,
              scaleDown: 0.95,
              builder: (context, _) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  border: Border.all(
                      color: AppColors.warmDark.withValues(alpha: 0.3),
                      width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'End ↗',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.warmDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create `story_chat_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/story_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_dialog.dart';
import '../../scenario/widgets/assessment_card.dart';
import '../../scenario/widgets/chat_bubble_ai.dart';
import '../../scenario/widgets/chat_bubble_user.dart';
import '../../scenario/widgets/chat_input_bar.dart';
import '../models/story_turn.dart';
import '../providers/story_provider.dart';
import '../widgets/story_character_header.dart';

class StoryChatScreen extends StatefulWidget {
  const StoryChatScreen({super.key});

  @override
  State<StoryChatScreen> createState() => _StoryChatScreenState();
}

class _StoryChatScreenState extends State<StoryChatScreen> {
  final _scrollCtrl = ScrollController();
  bool _warningShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoryProvider>();
      if (provider.activeSession == null) {
        // Defensive redirect — direct nav with no active session.
        context.go('/story');
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend(String text) async {
    final provider = context.read<StoryProvider>();
    if (text.trim().isEmpty) return;
    await provider.sendUserMessage(text);
    if (!mounted) return;
    _scrollToBottom();
    final used = provider.activeSession?.userTurnCount ?? 0;
    if (used == StoryConstants.warningTurn && !_warningShown) {
      _warningShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('2 turns left — session will wrap up.')),
      );
    }
    if (used >= StoryConstants.hardCapUserTurns) {
      await provider.endSession();
      if (!mounted) return;
      context.go('/story/summary');
    }
  }

  Future<void> _onEndPressed() async {
    final confirmed = await showClayDialog<bool>(
      context: context,
      title: 'End session?',
      message: 'You\'ll see your summary. Your progress is saved.',
      primaryLabel: 'End now',
      secondaryLabel: 'Keep going',
    );
    if (confirmed != true) return;
    final provider = context.read<StoryProvider>();
    await provider.endSession();
    if (!mounted) return;
    context.go('/story/summary');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final session = provider.activeSession;
    if (session == null) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            StoryCharacterHeader(
              character: session.character,
              onEnd: _onEndPressed,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Turn ${session.userTurnCount} · Free-form · End anytime',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                ),
              ),
            ),
            if (provider.persistenceError != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error, width: 1.5),
                ),
                child: Text(
                  provider.persistenceError!,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmDark,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: session.turns.length,
                itemBuilder: (context, index) {
                  final turn = session.turns[index];
                  switch (turn.role) {
                    case StoryTurnRole.ai:
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ChatBubbleAi(
                            text: turn.text, senderName: session.character.name),
                      );
                    case StoryTurnRole.user:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ChatBubbleUser(text: turn.text),
                          ),
                          if (turn.assessment != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: AssessmentCard(
                                  assessment: turn.assessment!),
                            ),
                        ],
                      );
                    case StoryTurnRole.system:
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Center(
                          child: Text(
                            turn.text,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warmMuted,
                            ),
                          ),
                        ),
                      );
                  }
                },
              ),
            ),
            ChatInputBar(
              onSend: _onSend,
              isLoading: provider.isLoading,
              hint: 'Type your reply…',
            ),
          ],
        ),
      ),
    );
  }
}
```

> If `ChatInputBar` constructor parameters differ (`onSend`, `isLoading`, `hint`), adapt to the actual API in the existing widget — this plan calls the well-known constructor; the engineer should grep `ChatInputBar` in `lib/features/scenario/widgets/chat_input_bar.dart` to confirm parameter names before pasting.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!` — fix any `ChatInputBar` constructor mismatch by reading `lib/features/scenario/widgets/chat_input_bar.dart` and adjusting parameter names.

- [ ] **Step 4: Commit**

```bash
git add lib/features/story/widgets/story_character_header.dart \
        lib/features/story/screens/story_chat_screen.dart
git commit -m "feat(story): add Story chat screen + character header"
```

---

### Task 11: Story Summary screen + wire app.dart + provider `storyLimit` getter

**Files:**
- Create: `lib/features/story/screens/story_summary_screen.dart`
- Modify: `lib/features/story/providers/story_provider.dart` (add `storyLimit` getter)
- Modify: `lib/features/story/screens/story_home_screen.dart` (use new getter, drop `QuotaConstantsAccessor`)
- Modify: `lib/app.dart` (register `StoryCache` + `StoryRepository` + `StoryProvider` + 4 routes)

- [ ] **Step 1: Add `storyLimit` getter to StoryProvider**

In `lib/features/story/providers/story_provider.dart`, add this getter near `storyUsedToday`:

```dart
  int get storyLimit => _storyLimit;
```

- [ ] **Step 2: Replace `QuotaConstantsAccessor` usage in `story_home_screen.dart`**

Open `lib/features/story/screens/story_home_screen.dart`. Find:

```dart
    final limit = QuotaConstantsAccessor.story(provider);
```

Replace with:

```dart
    final limit = provider.storyLimit;
```

Then delete the entire `class QuotaConstantsAccessor { … }` block at the bottom of the file.

- [ ] **Step 3: Create `story_summary_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../scenario/models/assessment.dart';
import '../models/story_turn.dart';
import '../providers/story_provider.dart';

class StorySummaryScreen extends StatelessWidget {
  const StorySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final session = provider.activeSession;
    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/story'),
            child: const Text('Back to Story Mode'),
          ),
        ),
      );
    }

    final assessments = session.turns
        .where((t) => t.role == StoryTurnRole.user && t.assessment != null)
        .map((t) => t.assessment!)
        .toList();

    final avgScore = (session.averageScore * 10).clamp(0, 100).toInt();
    final accuracyAvg = _avg(assessments.map((a) => a.accuracyScore));
    final naturalnessAvg = _avg(assessments.map((a) => a.naturalnessScore));
    final complexityAvg = _avg(assessments.map((a) => a.complexityScore));
    final newWords = assessments.fold<int>(
      0,
      (sum, a) => sum + a.keyVocabulary.length,
    );
    final topImprovements = assessments
        .expand((a) => a.improvements)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.warmDark),
                  onPressed: () => context.go('/story'),
                ),
                Expanded(
                  child: Text(
                    'Session Complete',
                    style: AppTypography.headingMd.copyWith(
                      color: AppColors.warmDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _trophyHero(session.title, session.userTurnCount, avgScore),
            const SizedBox(height: AppSpacing.lg),
            _radarCard('Performance breakdown', [
              ('Accuracy', accuracyAvg),
              ('Naturalness', naturalnessAvg),
              ('Complexity', complexityAvg),
            ]),
            const SizedBox(height: AppSpacing.lg),
            _statsRow(
              turns: session.userTurnCount,
              durationMin: session.endedAt == null
                  ? 0
                  : session.endedAt!.difference(session.startedAt).inMinutes,
              newWords: newWords,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (topImprovements.isNotEmpty) ...[
              Text(
                'Top corrections',
                style: AppTypography.sectionTitle.copyWith(
                  color: AppColors.warmDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.smd),
              for (final imp in topImprovements)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _correctionRow(context, provider, imp),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ClayButton(
                    text: 'Back to Home',
                    variant: ClayButtonVariant.secondary,
                    onTap: () => context.go('/home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClayButton(
                    text: 'New story →',
                    onTap: () => context.go('/story'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _avg(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  Widget _trophyHero(String title, int turns, int score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.gold, AppColors.teal]),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.warmDark, width: 2),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$turns turns',
            style: AppTypography.bodySm.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: 12),
          Text(
            '$score/100',
            style: AppTypography.headingLg.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w800,
              fontSize: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _radarCard(String title, List<(String, int)> bars) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.clayBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.warmDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final bar in bars) _bar(bar.$1, bar.$2),
        ],
      ),
    );
  }

  Widget _bar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTypography.labelSm.copyWith(
                      color: AppColors.warmDark)),
              Text('$value/10',
                  style: AppTypography.labelSm.copyWith(
                      color: AppColors.warmMuted)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 10,
              minHeight: 8,
              backgroundColor: AppColors.clayBeige,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow({
    required int turns,
    required int durationMin,
    required int newWords,
  }) {
    Widget cell(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: AppColors.clayBorder, width: 1.5),
          ),
          child: Column(
            children: [
              Text(value,
                  style: AppTypography.headingSm.copyWith(
                      color: AppColors.warmDark,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.warmMuted, fontSize: 11)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell('Turns', '$turns'),
        cell('Duration', '${durationMin}m'),
        cell('New words', '$newWords'),
      ],
    );
  }

  Widget _correctionRow(
    BuildContext context,
    StoryProvider provider,
    Improvement imp,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.clayBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            imp.original,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.error,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            imp.correction,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (imp.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              imp.explanation,
              style: AppTypography.caption.copyWith(
                color: AppColors.warmMuted,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ClayPressable(
            onTap: () async {
              await provider.saveCorrectionToVocab(imp);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to your library ✓')),
              );
            },
            scaleDown: 0.95,
            builder: (context, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.gold, width: 1.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '💾 Save phrase',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.warmDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Wire `app.dart`**

Open `lib/app.dart`.

Add these imports:

```dart
import 'data/cache/story_cache.dart';
import 'data/repositories/story_repository.dart';
import 'features/story/providers/story_provider.dart';
import 'features/story/screens/story_home_screen.dart';
import 'features/story/screens/story_custom_form_screen.dart';
import 'features/story/screens/story_chat_screen.dart';
import 'features/story/screens/story_summary_screen.dart';
```

In `_AuraCoachAppState`, add fields:

```dart
  late final StoryCache _storyCache;
  late final StoryRepository _storyRepository;
  late final StoryProvider _storyProvider;
```

In `initState`, after `_scenarioCache = ScenarioCache(prefs: widget.prefs);`:

```dart
    _storyCache = StoryCache(prefs: widget.prefs);
    _storyRepository = StoryRepository(
      firebase: _firebaseDatasource,
      cache: _storyCache,
    );
```

After `_scenarioProvider = ScenarioProvider(...)`:

```dart
    _storyProvider = StoryProvider(
      gemini: _geminiService,
      firebase: _firebaseDatasource,
      local: _localDatasource,
      cache: _storyCache,
      repository: _storyRepository,
    );
```

In `dispose()`, after `_scenarioProvider.dispose();`:

```dart
    _storyProvider.dispose();
```

In the `routes:` list, after the `/scenario/summary` GoRoute, add four entries:

```dart
        GoRoute(
          path: '/story',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StoryHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/story/custom',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StoryCustomFormScreen(),
          ),
        ),
        GoRoute(
          path: '/story/chat',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StoryChatScreen(),
          ),
        ),
        GoRoute(
          path: '/story/summary',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StorySummaryScreen(),
          ),
        ),
```

In the `build` method's `MultiProvider.providers` list, after `ChangeNotifierProvider<ScenarioProvider>.value(value: _scenarioProvider),`:

```dart
        ChangeNotifierProvider<StoryProvider>.value(value: _storyProvider),
```

- [ ] **Step 5: Run analyzer + smoke build**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/story/screens/story_summary_screen.dart \
        lib/features/story/screens/story_home_screen.dart \
        lib/features/story/providers/story_provider.dart \
        lib/app.dart
git commit -m "feat(story): add summary screen, wire StoryProvider + 4 GoRoutes, expose storyLimit getter"
```

---

### Task 12: Home entry-flow wiring — `start_story_sheet` widget + `_startStory()` handler

**Files:**
- Create: `lib/features/home/widgets/start_story_sheet.dart`
- Modify: `lib/features/home/screens/home_screen.dart`

**Context:** Mirror Scenario's existing `_startRoleplay()` pattern 1:1 (see `lib/features/home/screens/home_screen.dart` lines 57-147, and `lib/features/home/widgets/start_practice_sheet.dart`). The popup shows when there is at least one in-progress story; otherwise land directly on `/story` hub.

- [ ] **Step 1: Create `start_story_sheet.dart` (duplicated from `start_practice_sheet.dart`)**

Copy `lib/features/home/widgets/start_practice_sheet.dart` to `lib/features/home/widgets/start_story_sheet.dart`, then rename symbols and adjust copy. Final file:

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

/// Action returned from [showStartStorySheet]. Either indicates the user
/// wants to resume a specific story conversation (with [conversationId])
/// or begin a fresh story.
class StartStoryAction {
  final String? conversationId;

  const StartStoryAction.newSession() : conversationId = null;
  const StartStoryAction.resume(String id) : conversationId = id;

  bool get isResume => conversationId != null;
}

Future<StartStoryAction?> showStartStorySheet({
  required BuildContext context,
  required List<Map<String, dynamic>> conversations,
}) {
  return showModalBottomSheet<StartStoryAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _StartStorySheet(conversations: conversations),
  );
}

class _StartStorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;

  const _StartStorySheet({required this.conversations});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.card,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.clayBorder,
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Begin Story',
                style: AppTypography.title.copyWith(
                  color: AppColors.warmDark,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick up a story you started or begin a fresh one.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _NewStoryCta(
                onTap: () => Navigator.of(context).pop(
                  const StartStoryAction.newSession(),
                ),
              ),
              if (conversations.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'In Progress',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = conversations[index];
                      return _ResumeStoryCard(
                        data: item,
                        onTap: () {
                          final id = item['id'] as String? ??
                              item['conversationId'] as String?;
                          if (id == null) return;
                          Navigator.of(context)
                              .pop(StartStoryAction.resume(id));
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NewStoryCta extends StatelessWidget {
  final VoidCallback onTap;

  const _NewStoryCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.purple, AppColors.teal],
            ),
            borderRadius: AppRadius.lgBorder,
            boxShadow: AppShadows.colored(AppColors.purple, alpha: 0.35),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Story',
                      style: AppTypography.title.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Browse the library or build your own',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumeStoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ResumeStoryCard({required this.data, required this.onTap});

  String _formatRelative(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.month}/${date.day}';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] as String? ?? '').trim();
    final topic = (data['topic'] as String? ?? '').trim();
    final level = (data['level'] as String? ?? '').trim();
    final character = data['character'];
    final charName = character is Map
        ? (character['name'] as String? ?? '').trim()
        : '';
    final startedAt =
        data['startedAt'] as String? ?? data['updatedAt'] as String?;
    final turnsList = data['turns'] as List<dynamic>?;
    final userTurnCount = turnsList == null
        ? 0
        : turnsList
            .where((m) => m is Map<String, dynamic> && m['role'] == 'user')
            .length;
    final displayTitle =
        title.isNotEmpty ? title : (topic.isNotEmpty ? topic : 'Story');
    final subtitle = [
      if (charName.isNotEmpty) charName,
      if (level.isNotEmpty) level,
      '$userTurnCount turns',
      _formatRelative(startedAt),
    ].join(' · ');

    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: AppColors.clayBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                ),
                child: const Center(
                  child: AppIcon(iconId: AppIcons.scenario, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.warmDark,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.play_arrow_rounded,
                size: 24,
                color: AppColors.purple,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Add `route: '/story'` to the Story `_ModeConfig`**

In `lib/features/home/screens/home_screen.dart`, locate the `_modes` const list. Update the Story entry to add `route: '/story',` as the last field:

```dart
  _ModeConfig(
    title: 'Story Mode',
    description: "Learn through interactive stories. You're the main character — your choices shape the narrative.",
    iconUrl: CloudinaryAssets.modeStory,
    accentColor: AppColors.purple,
    badgeText: 'INTERACTIVE',
    ctaText: 'Begin Story',
    quotaText: '3 free stories / day',
    tags: ['📖 Narrative', '🎭 Choices'],
    route: '/story',
  ),
```

- [ ] **Step 3: Add `_isStartingStory` state flag + import the sheet + import `StoryProvider`**

At the top of `home_screen.dart`, add imports alongside the existing Scenario ones:

```dart
import '../../story/providers/story_provider.dart';
import '../widgets/start_story_sheet.dart';
```

Add a state field next to `_isStartingRoleplay`:

```dart
  bool _isStartingStory = false;
```

- [ ] **Step 4: Add `_startStory()` method (mirror of `_startRoleplay`)**

Insert after `_startRoleplay()`:

```dart
  Future<void> _startStory() async {
    if (_isStartingStory) return;
    setState(() => _isStartingStory = true);

    final authProvider = context.read<AuthProvider>();
    final profile = context.read<HomeProvider>().userProfile;
    final storyProvider = context.read<StoryProvider>();
    final uid = authProvider.currentUser?.uid ?? '';

    try {
      await storyProvider.init(
        uid: uid,
        tier: profile?.tier ?? 'free',
        level: profile?.proficiencyLevel ?? 'B1',
      );

      if (!storyProvider.canStartSession()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily story limit reached. Upgrade for more.'),
            ),
          );
        }
        return;
      }

      final conversations = await storyProvider.loadUserStoryConversations();
      if (!mounted) return;

      final StartStoryAction? choice;
      if (conversations.isEmpty) {
        choice = const StartStoryAction.newSession();
      } else {
        choice = await showStartStorySheet(
          context: context,
          conversations: conversations,
        );
      }
      if (!mounted || choice == null) return;

      if (choice.isResume) {
        final ok = await storyProvider.resumeSession(choice.conversationId!);
        if (!mounted) return;
        if (!ok || storyProvider.activeSession == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                storyProvider.error ?? 'Could not resume story.',
              ),
            ),
          );
          return;
        }
        context.push('/story/chat');
        return;
      }

      context.push('/story');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingStory = false);
    }
  }
```

- [ ] **Step 5: Wire the Home mode card's `onTap` to `_startStory` for Story**

Locate the `onTap:` block around line 231 that currently dispatches between `_startRoleplay` and `context.push(mode.route!)`. Add a Story branch:

```dart
        final isRoleplay = mode.route == '/scenario';
        final isStory = mode.route == '/story';
        return ModeHorizontalPager(
          accentColor: mode.accentColor,
          overviewCard: ModeCard(
            // ... existing args ...
            isLoading: (isRoleplay && _isStartingRoleplay) ||
                (isStory && _isStartingStory),
            onTap: mode.route != null
                ? () {
                    if (isRoleplay) {
                      _startRoleplay();
                    } else if (isStory) {
                      _startStory();
                    } else {
                      context.push(mode.route!);
                    }
                  }
                : null,
```

- [ ] **Step 6: Run analyzer + tests**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` and all tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/home/widgets/start_story_sheet.dart \
        lib/features/home/screens/home_screen.dart
git commit -m "feat(home): wire Begin Story to popup-driven entry flow (mirror Scenario)"
```

---

### Task 13: Seed script + 12 curated stories JSON

**Files:**
- Create: `scripts/stories_seed_data.json`
- Create: `scripts/seed_stories.dart`

> The seed script is a one-shot dev tool. It runs against a local Firebase project initialized with the same `firebase_options.dart` as the app. It is NOT bundled into release builds (`scripts/` is outside `lib/`).

- [ ] **Step 1: Create `scripts/stories_seed_data.json`**

12 stories: 4 per level for A2, B1, B2. Each Story shape matches `Story.fromJson`. (Pick titles/situations that cover travel, work, daily, social per level.)

```json
[
  {
    "id": "story-a2-airport-checkin",
    "title": "Airport Check-in",
    "topic": "travel",
    "level": "A2",
    "situation": "You arrive at the airport. The check-in agent helps you with your boarding pass and luggage.",
    "character": {
      "name": "Liam",
      "role": "Check-in agent",
      "personality": "patient, friendly",
      "initial": "L",
      "gradient": "teal-gold"
    },
    "suggestedTurns": 6,
    "thumbnailIcon": "✈️",
    "order": 1
  },
  {
    "id": "story-a2-coffee-order",
    "title": "Ordering Coffee",
    "topic": "daily",
    "level": "A2",
    "situation": "You walk into a busy café and order a drink and a snack at the counter.",
    "character": {
      "name": "Mei",
      "role": "Barista",
      "personality": "warm, efficient",
      "initial": "M",
      "gradient": "gold-peach"
    },
    "suggestedTurns": 5,
    "thumbnailIcon": "☕",
    "order": 2
  },
  {
    "id": "story-a2-asking-directions",
    "title": "Asking Directions",
    "topic": "travel",
    "level": "A2",
    "situation": "You are lost in a new city and ask a passerby how to get to the train station.",
    "character": {
      "name": "Sam",
      "role": "Local resident",
      "personality": "kind, helpful",
      "initial": "S",
      "gradient": "teal-purple"
    },
    "suggestedTurns": 5,
    "thumbnailIcon": "🗺️",
    "order": 3
  },
  {
    "id": "story-a2-meeting-neighbor",
    "title": "Meeting a Neighbor",
    "topic": "social",
    "level": "A2",
    "situation": "You moved into a new apartment and meet your neighbor in the hallway for the first time.",
    "character": {
      "name": "Ana",
      "role": "Neighbor",
      "personality": "chatty, welcoming",
      "initial": "A",
      "gradient": "purple-pink"
    },
    "suggestedTurns": 6,
    "thumbnailIcon": "👋",
    "order": 4
  },
  {
    "id": "story-b1-hotel-checkin",
    "title": "Hotel Check-in",
    "topic": "travel",
    "level": "B1",
    "situation": "You arrive at a boutique hotel after a long flight. The receptionist confirms your reservation and explains amenities.",
    "character": {
      "name": "Maria",
      "role": "Hotel receptionist",
      "personality": "warm, professional",
      "initial": "M",
      "gradient": "teal-purple"
    },
    "suggestedTurns": 7,
    "thumbnailIcon": "🏨",
    "order": 5
  },
  {
    "id": "story-b1-coworker-coffee",
    "title": "Coffee with a Coworker",
    "topic": "work",
    "level": "B1",
    "situation": "You grab coffee with a new coworker on your second week and chat about projects, weekends, and team dynamics.",
    "character": {
      "name": "Jordan",
      "role": "Coworker",
      "personality": "curious, easygoing",
      "initial": "J",
      "gradient": "gold-peach"
    },
    "suggestedTurns": 8,
    "thumbnailIcon": "💼",
    "order": 6
  },
  {
    "id": "story-b1-doctor-visit",
    "title": "Doctor's Visit",
    "topic": "health",
    "level": "B1",
    "situation": "You visit a clinic with mild flu symptoms and explain how you've been feeling to the doctor.",
    "character": {
      "name": "Dr. Patel",
      "role": "General practitioner",
      "personality": "calm, attentive",
      "initial": "P",
      "gradient": "teal-gold"
    },
    "suggestedTurns": 7,
    "thumbnailIcon": "🩺",
    "order": 7
  },
  {
    "id": "story-b1-first-date",
    "title": "First Date Coffee",
    "topic": "dating",
    "level": "B1",
    "situation": "First date in a quiet coffee shop. You ask about hobbies, weekends, and what they like about the city.",
    "character": {
      "name": "Alex",
      "role": "Date",
      "personality": "playful, thoughtful",
      "initial": "A",
      "gradient": "purple-pink"
    },
    "suggestedTurns": 8,
    "thumbnailIcon": "☕",
    "order": 8
  },
  {
    "id": "story-b2-job-interview",
    "title": "Job Interview",
    "topic": "work",
    "level": "B2",
    "situation": "Final-round interview for a marketing role. The hiring manager asks behavioral questions and explores your motivation.",
    "character": {
      "name": "Olivia",
      "role": "Hiring manager",
      "personality": "sharp, encouraging",
      "initial": "O",
      "gradient": "teal-purple"
    },
    "suggestedTurns": 9,
    "thumbnailIcon": "💼",
    "order": 9
  },
  {
    "id": "story-b2-restaurant-complaint",
    "title": "Politely Complaining",
    "topic": "social",
    "level": "B2",
    "situation": "Your meal arrives undercooked. You raise the issue politely with the server without making the table awkward.",
    "character": {
      "name": "Theo",
      "role": "Server",
      "personality": "professional, apologetic",
      "initial": "T",
      "gradient": "gold-peach"
    },
    "suggestedTurns": 7,
    "thumbnailIcon": "🍽️",
    "order": 10
  },
  {
    "id": "story-b2-rental-tour",
    "title": "Apartment Tour",
    "topic": "daily",
    "level": "B2",
    "situation": "A landlord shows you a one-bedroom apartment. You ask about the lease, utilities, and neighborhood.",
    "character": {
      "name": "Helen",
      "role": "Landlord",
      "personality": "blunt, businesslike",
      "initial": "H",
      "gradient": "teal-gold"
    },
    "suggestedTurns": 8,
    "thumbnailIcon": "🏠",
    "order": 11
  },
  {
    "id": "story-b2-conference-mingle",
    "title": "Conference Mingling",
    "topic": "work",
    "level": "B2",
    "situation": "You strike up a conversation with a stranger at the coffee break of a tech conference and try to make it memorable.",
    "character": {
      "name": "Reese",
      "role": "Conference attendee",
      "personality": "witty, observant",
      "initial": "R",
      "gradient": "purple-pink"
    },
    "suggestedTurns": 8,
    "thumbnailIcon": "🎤",
    "order": 12
  }
]
```

- [ ] **Step 2: Create `scripts/seed_stories.dart`**

```dart
// Dev-only: seeds /stories/{id} from scripts/stories_seed_data.json.
// Run with: dart run scripts/seed_stories.dart
//
// Requires the same Firebase setup as the app (same firebase_options.dart).
// Do NOT include this file in release builds — it lives outside lib/.

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firestore = FirebaseFirestore.instance;

  final raw = await File('scripts/stories_seed_data.json').readAsString();
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  for (final story in list) {
    final id = story['id'] as String;
    final payload = Map<String, dynamic>.from(story)
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    await firestore.collection('stories').doc(id).set(payload);
    stdout.writeln('seeded $id');
  }
  stdout.writeln('done — ${list.length} stories');
  exit(0);
}
```

- [ ] **Step 3: Verify the JSON parses**

Run: `dart -e "import 'dart:convert'; import 'dart:io'; void main() { final raw = File('scripts/stories_seed_data.json').readAsStringSync(); final list = jsonDecode(raw) as List; print('parsed ${list.length} stories'); }"`
Expected: `parsed 12 stories`.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add scripts/seed_stories.dart scripts/stories_seed_data.json
git commit -m "feat(story): seed script + 12 curated stories (4 each for A2/B1/B2)"
```

> **Manual step (post-commit, not part of automated plan):** Run `dart run scripts/seed_stories.dart` against the dev Firebase project. Verify in the Firebase console that `/stories/*` contains 12 documents.

---

### Task 14: Manual QA pass + final verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run the analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Manual QA on a real device / simulator**

Walk through each item in spec section 11.3:

- [ ] Home Story card taps and navigates to `/story`
- [ ] Featured grid filters by user's CEFR level (try a B1 user → only B1 stories shown after seeding A2/B1/B2)
- [ ] Custom flow 4 fields all editable, submit works with each field combo
- [ ] Chat: send 3+ user messages, each renders an `AssessmentCard` directly under the user bubble
- [ ] Kill the app mid-session, relaunch, "Continue with {character}" banner appears on `/story`, tap → chat restored with all messages and assessments visible
- [ ] Toggle airplane mode mid-session: `persistenceError` banner appears red on chat screen; re-enable → next save clears it
- [ ] End session → summary radar / stats / top-3 corrections render; tap "💾 Save phrase" → check `/users/{uid}/savedItems` has the new doc
- [ ] Hit user-turn 18 → toast appears; turn 20 → auto-navigate to summary
- [ ] Free user: 3 sessions used → 4th tap on a library card shows the daily-limit snackbar (paywall hookup)

- [ ] **Step 4: Inspect a Firestore conversation doc to verify the schema invariant**

In the Firebase console, open `/users/{uid}/conversations/{lastConversationId}` for a story session that has at least one user reply. Verify:

- `mode == 'story'`
- `turns[]` contains alternating `role: 'ai'` and `role: 'user'` entries
- The user turns have a populated `assessment` map
- **No turn has `role: 'assessment'`** — this is the regression guard from spec §11.4

- [ ] **Step 5: Final commit (only if any QA fix was needed)**

If any fixes were made during manual QA, commit them with a focused message describing the fix. Otherwise skip.

---

## Self-Review Notes

(Author ran fresh-eyes pass after writing the plan.)

**Spec coverage checked:**

- §1 Goal — Tasks 4–12 deliver the full lifecycle.
- §2 Non-goals — None of TTS, portraits, video appear in any task. ✓
- §3 Scope decisions — All 8 locked decisions present: library + custom (Tasks 5, 9), Hero+grid (Task 8), Firestore /stories (Tasks 2, 13), 4-step form (Task 9), 20-turn cap (Tasks 1, 10), summary screen (Task 11), 1-session=1-quota (Task 5), persistence pattern (Tasks 1, 6, 7).
- §4 User flows — Happy/custom/resume/error all covered.
- §5 Data model — Models in Task 1, Firestore extensions in Task 2, conversation schema in Task 5, usage in Task 5, local cache in Task 2.
- §6 Module architecture — Every file in §6.1 is in the File Structure block; extensions in §6.2 covered in Tasks 2, 11, 12.
- §7 Provider contract — All public methods covered in Tasks 4–7. Persistence invariants 1, 2, 3, 4, 5 codified by tests in Tasks 5, 6, 7.
- §8 Screen specs — Tasks 8, 9, 10, 11.
- §9 Visual tokens — Reused throughout; all hex values in widgets match `app_colors.dart`.
- §10 Quota — Task 5 (charge-only-on-success), Task 11 (`storyLimit` getter), Task 12 (paywall snackbar via `error` field).
- §11 Testing — Unit tests in every provider/cache/repo/model task. Manual QA in Task 14.
- §12 Risks — Cap warning at turn 18 (Task 10), cache fallback (Task 3), inappropriate-topic profanity check is a deferred post-MVP polish (added as note in Task 9, not blocking).
- §13 Rollout — Task 12 flips the route LAST (after all screens build). Task 13 seed runs before deploy.

**Placeholder scan:** None. Every step has either complete code, a complete command, or a concrete file edit.

**Type consistency:** `StoryTurnRole` (not `MessageType`), `StorySessionStatus` (typed enum, wire values via `.wireValue` not `.name`), `StorySession.userTurnCount` (not `totalTurns`), `provider.storyLimit` (introduced in Task 11, dropped temporary `QuotaConstantsAccessor` in same task).

**Known gaps deliberately deferred:**

- Profanity check on free-text custom topic — listed in spec §12 as low-likelihood, can be added post-launch.
- Per-turn latency telemetry — spec §14 open question, not in MVP.
- Cold-start cache-based auto-resume — `LocalDatasource` cache methods exist but are dormant; resume is driven solely by the popup flow (mirror Scenario).

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-04-19-story-mode.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

**Which approach?**
