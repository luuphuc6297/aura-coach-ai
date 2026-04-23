# Conversational Consistency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify Story and Scenario conversational behaviour (back button, loading state, stop button, filtering), add cross-mode storage quota, and give Story Home a gentle "Other Levels" section.

**Architecture:** Introduce three shared widgets (`ThinkingIndicator`, `EndSessionDialog`, `StorageQuotaBanner`) and one new cross-mode provider (`StorageQuotaProvider`). Remove `StorySessionStatus.abandoned`. Add storage caps to `QuotaConstants`. Wire entry-point buttons on Home to the storage quota state.

**Tech Stack:** Flutter 3.x, Dart, Provider (ChangeNotifier), Firebase Firestore (aggregation `count()`), go_router, existing Clay design tokens (`AppColors`, `AppTypography`, `AppShadows`, `AppRadius`).

---

## File Structure

### New files

| Path | Responsibility |
|---|---|
| `lib/shared/widgets/thinking_indicator.dart` | Stateless shared widget: spinner + "Thinking…" text bubble used by both Story and Scenario during AI turn generation. |
| `lib/shared/widgets/end_session_dialog.dart` | Stateless shared widget: bottom-sheet dialog with stats strip + highlight line + daily quota reminder + 2 buttons (Continue / End & Review). Takes an `accentColor` param so Story (purple) and Scenario (teal) skin themselves. |
| `lib/shared/widgets/storage_quota_banner.dart` | Home banner shown when storage usage ≥ 80%. Displays per-mode breakdown + aggregate `n/cap` + `Manage` / `Upgrade` CTAs. |
| `lib/features/shared/providers/storage_quota_provider.dart` | Provider that loads and caches conversation counts per mode and exposes `totalCount`, `perMode`, `cap`, `state` (healthy / warning / cap). |

### Modified files

| Path | What changes |
|---|---|
| `lib/core/constants/quota_constants.dart` | Add `storageCapFree = 20`, `storageCapPremium = 500`, `storageWarningThreshold = 0.80`, helper `getStorageCap(tier)`. |
| `lib/features/story/models/story_session.dart` | Remove `StorySessionStatus.abandoned`. `fromWire('abandoned')` now maps to `inProgress` for backwards compat. |
| `lib/features/story/providers/story_provider.dart` | Delete `abandonSession()`. Fix `cancelCurrentMessage()` to keep the user bubble. Relax `loadUserStoryConversations()` filter to `status != 'completed'`. |
| `lib/features/story/screens/story_chat_screen.dart` | Replace `_onBackPressed` direct-abandon with shared `EndSessionDialog`. Delete local `_showEndDialog`. Delete local `_TypingRow`. Use `context.push('/story/summary')` on End. |
| `lib/features/story/screens/story_home_screen.dart` | Render two library sections: "Featured for you" and "Other Levels". Uses `StoryRepository.fetchOtherLevels()`. |
| `lib/data/repositories/story_repository.dart` | Add `fetchOtherLevels({required String userLevel})` — returns stories NOT at user's level, sorted closest-first. |
| `lib/data/datasources/firebase_datasource.dart` | Add `countConversations(uid)` using Firestore `count()` aggregation. |
| `lib/features/scenario/providers/scenario_provider.dart` | Add `cancelCurrentMessage()` with seq invalidation. Add `_sendSeq` + `_pendingSendBaseCount`. Wrap `evaluateResponse` in 30s provider-level timeout. |
| `lib/features/scenario/screens/scenario_chat_screen.dart` | Delete local `_TypingIndicator`. Use `ThinkingIndicator`. Add Stop button wiring to `ChatInputBar` (`enabled` + `onStop`). Replace local `_showEndSessionDialog` with shared `EndSessionDialog`. Use `context.push('/scenario/summary')` on End (already does). |
| `lib/features/home/screens/home_screen.dart` | Consume `StorageQuotaProvider`. Render `StorageQuotaBanner` when state is `warning` or `cap`. Gate `_startRoleplay` and `_startStory` with storage check before daily quota check. On `cap`, show snackbar instead of opening the start sheet. |
| `lib/app.dart` | Register `StorageQuotaProvider` in the root `MultiProvider`. |

---

## Task 1: Add storage caps to QuotaConstants

**Files:**
- Modify: `lib/core/constants/quota_constants.dart`

- [ ] **Step 1: Edit `quota_constants.dart`** — add storage constants and helper below the existing `getLimit` method.

Final content of the file:

```dart
class QuotaConstants {
  QuotaConstants._();

  static const freeRoleplayQuota = 5;
  static const freeStoryQuota = 3;
  static const freeTranslatorQuota = 10;
  static const freeDictionaryQuota = 5;
  static const freeMindMapQuota = 3;
  static const freeTtsQuota = 5;

  static const proRoleplayQuota = 15;
  static const proStoryQuota = 10;
  static const proTranslatorQuota = -1;
  static const proDictionaryQuota = -1;
  static const proMindMapQuota = 10;
  static const proTtsQuota = 15;

  /// Total conversations across all modes a user may keep in Firestore.
  /// Prevents unbounded per-user storage growth from heavy daily use.
  static const storageCapFree = 20;
  static const storageCapPro = 200;
  static const storageCapPremium = 500;

  /// Fraction of the cap at which the soft-warning banner kicks in.
  static const storageWarningThreshold = 0.80;

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

  /// Aggregate storage cap for [tier]. Returns -1 for unlimited (not used
  /// today — every tier currently has a numeric cap).
  static int getStorageCap(String tier) {
    switch (tier) {
      case 'premium':
        return storageCapPremium;
      case 'pro':
        return storageCapPro;
      case 'free':
      default:
        return storageCapFree;
    }
  }
}
```

- [ ] **Step 2: Verify compile**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/core/constants/quota_constants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai
git add lib/core/constants/quota_constants.dart
git commit -m "feat(quota): add storage caps per tier"
```

---

## Task 2: Remove `StorySessionStatus.abandoned`

**Files:**
- Modify: `lib/features/story/models/story_session.dart`
- Test: `test/features/story/models/story_session_test.dart` (create if missing)

- [ ] **Step 1: Write failing test**

Create / extend `test/features/story/models/story_session_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_coach_ai/features/story/models/story_session.dart';

void main() {
  group('StorySessionStatusX', () {
    test('fromWire("abandoned") normalises to inProgress', () {
      expect(StorySessionStatusX.fromWire('abandoned'),
          StorySessionStatus.inProgress);
    });

    test('fromWire("completed") stays completed', () {
      expect(StorySessionStatusX.fromWire('completed'),
          StorySessionStatus.completed);
    });

    test('fromWire unknown string → inProgress', () {
      expect(StorySessionStatusX.fromWire('anything-else'),
          StorySessionStatus.inProgress);
    });

    test('wireValue only emits inProgress or completed', () {
      final values = StorySessionStatus.values.map((s) => s.wireValue).toSet();
      expect(values, {'in-progress', 'completed'});
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter test test/features/story/models/story_session_test.dart`
Expected: FAIL on "wireValue only emits inProgress or completed" (three values today: in-progress, completed, abandoned).

- [ ] **Step 3: Edit the enum**

In `lib/features/story/models/story_session.dart` lines 4–28, replace:

```dart
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
```

with:

```dart
/// Two real states now that Back no longer auto-abandons: `inProgress`
/// while a session is open, `completed` once the learner has reviewed
/// and closed it. Legacy Firestore docs with `status: 'abandoned'` are
/// silently folded back into `inProgress` on read.
enum StorySessionStatus { inProgress, completed }

extension StorySessionStatusX on StorySessionStatus {
  String get wireValue {
    switch (this) {
      case StorySessionStatus.inProgress:
        return 'in-progress';
      case StorySessionStatus.completed:
        return 'completed';
    }
  }

  static StorySessionStatus fromWire(String? raw) {
    switch (raw) {
      case 'completed':
        return StorySessionStatus.completed;
      case 'abandoned':
      case 'in-progress':
      default:
        return StorySessionStatus.inProgress;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter test test/features/story/models/story_session_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/story/models/story_session.dart test/features/story/models/story_session_test.dart
git commit -m "refactor(story): drop abandoned status, fold legacy docs to in-progress"
```

---

## Task 3: Story provider — delete abandon, fix cancel, relax filter

**Files:**
- Modify: `lib/features/story/providers/story_provider.dart`
- Test: `test/features/story/providers/story_provider_cancel_test.dart` (create)

- [ ] **Step 1: Write failing test for cancel keeping user bubble**

Create `test/features/story/providers/story_provider_cancel_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:aura_coach_ai/features/story/models/story_session.dart';
import 'package:aura_coach_ai/features/story/models/story_turn.dart';
import 'package:aura_coach_ai/features/story/providers/story_provider.dart';

// Minimal test focuses on the turn-truncation math of cancelCurrentMessage
// without spinning up Firebase / Gemini. We simulate the state
// sendUserMessage leaves behind right before the Gemini await, then call
// cancelCurrentMessage and assert the user bubble survives.

void main() {
  test('cancelCurrentMessage keeps user bubble, drops AI placeholder', () {
    final provider = StoryProviderTestHarness.makeWithActiveSession(
      priorTurns: [
        StoryTurn(
          id: 'ai-1',
          role: StoryTurnRole.ai,
          text: 'Hello!',
          timestamp: DateTime(2026, 4, 21, 10),
        ),
      ],
    );

    // Simulate sendUserMessage up to the point the user bubble has been
    // appended and isLoading/_sendSeq/_pendingSendBaseCount are set.
    provider.debugBeginSend(
      userTurn: StoryTurn(
        id: 'u-1',
        role: StoryTurnRole.user,
        text: 'Hi there!',
        timestamp: DateTime(2026, 4, 21, 10, 1),
      ),
    );

    expect(provider.activeSession!.turns.length, 2,
        reason: 'user bubble should be present before cancel');

    provider.cancelCurrentMessage();

    expect(provider.activeSession!.turns.length, 2,
        reason: 'user bubble must survive cancel');
    expect(provider.activeSession!.turns.last.id, 'u-1');
    expect(provider.isLoading, false);
  });
}
```

This references a test harness we will add to `StoryProvider` to keep the test self-contained without mocking Gemini/Firebase. Add to the bottom of `lib/features/story/providers/story_provider.dart`:

```dart
/// Test-only harness. Keeps production code clean while letting us unit
/// test state-machine behaviour without a Firebase or Gemini fake.
@visibleForTesting
class StoryProviderTestHarness {
  static StoryProvider makeWithActiveSession({
    required List<StoryTurn> priorTurns,
  }) {
    final provider = StoryProvider(
      gemini: _NoopGemini(),
      firebase: _NoopFirebase(),
      local: _NoopLocal(),
      cache: _NoopCache(),
      repository: _NoopRepo(),
    );
    provider._uid = 'test-uid';
    provider._session = StorySession(
      conversationId: 'test-convo',
      storyId: null,
      title: 'Test',
      situation: 'test',
      character: const StoryCharacter(
        name: 'Coach',
        role: 'Partner',
        personality: 'warm',
        initial: 'C',
        gradient: [],
      ),
      topic: 'social',
      level: 'B1',
      customContext: null,
      characterPreference: null,
      status: StorySessionStatus.inProgress,
      turns: priorTurns,
      startedAt: DateTime(2026, 4, 21, 10),
      endedAt: null,
      updatedAt: DateTime(2026, 4, 21, 10),
      quotaCharged: true,
    );
    return provider;
  }
}

extension StoryProviderDebug on StoryProvider {
  /// Simulate sendUserMessage up to the pre-Gemini state so tests can
  /// exercise cancelCurrentMessage without real async I/O.
  @visibleForTesting
  void debugBeginSend({required StoryTurn userTurn}) {
    final session = _session!;
    _pendingSendBaseCount = session.turns.length;
    _session = session.copyWith(
      turns: [...session.turns, userTurn],
      updatedAt: DateTime.now(),
    );
    _isLoading = true;
    _sendSeq++;
    notifyListeners();
  }
}
```

Note: if adding the harness inside the production file feels heavy, move it to `test/support/story_provider_harness.dart` and import from there. The important bit is the test exercises the real `cancelCurrentMessage`.

Also add the no-op stubs at the bottom of the same file (they can remain because they are only referenced from the @visibleForTesting class, and Dart tree-shakes in release builds):

```dart
class _NoopGemini implements GeminiService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Gemini not available in test harness');
}
class _NoopFirebase implements FirebaseDatasource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Firebase not available in test harness');
}
class _NoopLocal implements LocalDatasource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Local not available in test harness');
}
class _NoopCache implements StoryCache {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Cache not available in test harness');
}
class _NoopRepo implements StoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Repo not available in test harness');
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter test test/features/story/providers/story_provider_cancel_test.dart`
Expected: FAIL — the current `cancelCurrentMessage` truncates to `_pendingSendBaseCount` (1), dropping the user bubble.

- [ ] **Step 3: Fix `cancelCurrentMessage` in `lib/features/story/providers/story_provider.dart`**

Find the method (around lines 454–468) and replace the body with:

```dart
  /// Cancel the current in-flight [sendUserMessage]. Keeps the user's own
  /// turn bubble visible (token cost was already incurred the moment we
  /// called Gemini) but drops any AI placeholder / assessment / reply the
  /// in-flight call had queued behind it. The Gemini future keeps running
  /// — the seq check in [sendUserMessage] ignores its result on return.
  void cancelCurrentMessage() {
    if (!_isLoading || _session == null) return;
    _sendSeq++;
    final baseCount = _pendingSendBaseCount;
    if (baseCount != null && _session!.turns.length > baseCount + 1) {
      // Keep everything up to and including the user bubble (baseCount + 1),
      // drop anything the Gemini resolver has already appended past that.
      _session = _session!.copyWith(
        turns: _session!.turns.sublist(0, baseCount + 1),
        updatedAt: DateTime.now(),
      );
    }
    _pendingSendBaseCount = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
```

- [ ] **Step 4: Delete `abandonSession`**

Find the method (around lines 502–515) and delete the entire method. Check for remaining references with `grep`:

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && grep -rn 'abandonSession' lib/ test/`
Expected: only reference remaining is the Story chat screen call — that will be replaced in Task 5.

- [ ] **Step 5: Relax `loadUserStoryConversations` filter**

Around lines 196–207, replace:

```dart
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
```

with:

```dart
  /// Loads the current user's story conversations that are not yet
  /// completed — i.e. every doc whose `status` is anything other than
  /// `'completed'` (missing field, `'in-progress'`, legacy `'abandoned'`).
  /// Mirrors Scenario's equivalent helper so both modes resume identically.
  Future<List<Map<String, dynamic>>> loadUserStoryConversations() async {
    final uid = _uid;
    if (uid == null) return const [];
    try {
      final all = await _firebase.getConversations(uid, mode: 'story');
      return all
          .where((c) => (c['status'] as String?) != 'completed')
          .toList();
    } catch (_) {
      return const [];
    }
  }
```

- [ ] **Step 6: Run tests + analyze**

Run:
```
cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai
flutter test test/features/story/
flutter analyze lib/features/story/providers/story_provider.dart
```
Expected: test passes; analyze clean.

- [ ] **Step 7: Commit**

```bash
git add lib/features/story/providers/story_provider.dart test/features/story/providers/story_provider_cancel_test.dart
git commit -m "refactor(story): keep user bubble on cancel, drop abandonSession, relax filter"
```

---

## Task 4: Shared `ThinkingIndicator` widget

**Files:**
- Create: `lib/shared/widgets/thinking_indicator.dart`

- [ ] **Step 1: Write the widget**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';

/// Shared "AI is thinking" bubble. Replaces the mode-specific bouncing-dots
/// indicators — the text label ("Thinking…") communicates intent more
/// clearly than abstract dots, especially during the longer assessment
/// phase where learners tend to wait 3-5 seconds.
///
/// [accentColor] skins the spinner so Story (purple) and Scenario (teal)
/// read as distinct modes without duplicating the widget.
class ThinkingIndicator extends StatelessWidget {
  final Color accentColor;
  final String label;

  const ThinkingIndicator({
    super.key,
    this.accentColor = AppColors.warmDark,
    this.label = 'Thinking…',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.clayBorder, width: 1.5),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(accentColor),
                ),
              ),
              const SizedBox(width: 8),
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
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/shared/widgets/thinking_indicator.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/thinking_indicator.dart
git commit -m "feat(shared): add ThinkingIndicator widget"
```

---

## Task 5: Shared `EndSessionDialog` widget

**Files:**
- Create: `lib/shared/widgets/end_session_dialog.dart`

- [ ] **Step 1: Write the widget**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import 'clay_pressable.dart';

/// Stats + quota summary a mode hands to [showEndSessionDialog] so learners
/// see what they're ending and how many daily starts they have left.
class EndSessionStats {
  /// Number of user turns so far.
  final int turns;

  /// Average user-turn score (0-100). Null when no assessed turn exists.
  final double? averageScore;

  /// Active session wall time. Null to hide the duration tile.
  final Duration? duration;

  /// Optional best-line highlight — something like `Best line: "I was just ..."`.
  /// Null hides the line.
  final String? highlight;

  /// Daily quota label e.g. `"2/3 sessions left today"`. Null hides the line.
  final String? quotaReminder;

  const EndSessionStats({
    required this.turns,
    this.averageScore,
    this.duration,
    this.highlight,
    this.quotaReminder,
  });
}

/// Show the shared end-session confirmation sheet. Returns `true` if the
/// learner chose "End & review", `false` or `null` otherwise (dismissed).
Future<bool?> showEndSessionDialog({
  required BuildContext context,
  required Color accentColor,
  required EndSessionStats stats,
  String title = 'End this session?',
  String continueLabel = 'Keep going',
  String endLabel = 'End & review',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EndSessionSheet(
      accentColor: accentColor,
      title: title,
      stats: stats,
      continueLabel: continueLabel,
      endLabel: endLabel,
    ),
  );
}

class _EndSessionSheet extends StatelessWidget {
  final Color accentColor;
  final String title;
  final EndSessionStats stats;
  final String continueLabel;
  final String endLabel;

  const _EndSessionSheet({
    required this.accentColor,
    required this.title,
    required this.stats,
    required this.continueLabel,
    required this.endLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.clayWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppTypography.title.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            _StatsStrip(stats: stats, accentColor: accentColor),
            if (stats.highlight != null) ...[
              const SizedBox(height: 10),
              _HighlightLine(text: stats.highlight!, accentColor: accentColor),
            ],
            if (stats.quotaReminder != null) ...[
              const SizedBox(height: 8),
              Text(
                stats.quotaReminder!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ClayPressable(
                    onTap: () => Navigator.of(context).pop(false),
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.clayBeige,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                            color: AppColors.clayBorder, width: 1.5),
                      ),
                      child: Text(
                        continueLabel,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.warmDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClayPressable(
                    onTap: () => Navigator.of(context).pop(true),
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: AppRadius.mdBorder,
                        boxShadow: AppShadows.colored(accentColor, alpha: 0.35),
                      ),
                      child: Text(
                        endLabel,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final EndSessionStats stats;
  final Color accentColor;

  const _StatsStrip({required this.stats, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final tiles = <_StatTile>[];
    tiles.add(_StatTile(
        label: 'Turns', value: '${stats.turns}', accentColor: accentColor));
    if (stats.averageScore != null) {
      tiles.add(_StatTile(
        label: 'Avg score',
        value: stats.averageScore!.toStringAsFixed(1),
        accentColor: accentColor,
      ));
    }
    if (stats.duration != null) {
      tiles.add(_StatTile(
        label: 'Duration',
        value: _formatDuration(stats.duration!),
        accentColor: accentColor,
      ));
    }
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return '${h}:${m.toString().padLeft(2, '0')}';
    }
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
            color: accentColor.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.warmMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightLine extends StatelessWidget {
  final String text;
  final Color accentColor;

  const _HighlightLine({required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 14, color: accentColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.warmDark,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/shared/widgets/end_session_dialog.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/end_session_dialog.dart
git commit -m "feat(shared): add EndSessionDialog with stats + quota reminder"
```

---

## Task 6: Story chat screen — use shared dialog + ThinkingIndicator + push nav

**Files:**
- Modify: `lib/features/story/screens/story_chat_screen.dart`

- [ ] **Step 1: Replace imports at the top of the file**

Add these imports (keep existing ones):

```dart
import '../../../shared/widgets/end_session_dialog.dart';
import '../../../shared/widgets/thinking_indicator.dart';
import '../../../core/constants/quota_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
```

Remove the now-unused import for `clay_dialog.dart`:

```dart
// delete:
// import '../../../shared/widgets/clay_dialog.dart';
```

- [ ] **Step 2: Replace `_onEndPressed` and delete `_showEndDialog`**

Delete both methods (lines ~62–101) and add:

```dart
  Future<void> _onEndPressed(StoryProvider provider) async {
    final confirmed = await _askEndConfirmation(provider);
    if (confirmed != true) return;
    await provider.endSession();
    if (!mounted) return;
    context.push('/story/summary');
  }

  Future<bool?> _askEndConfirmation(StoryProvider provider) {
    final session = provider.activeSession;
    if (session == null) return Future.value(false);

    final scored = session.turns
        .where((t) => t.role == StoryTurnRole.user && t.assessment != null)
        .toList();
    final highlight = scored
        .where((t) => (t.assessment?.score ?? 0) >= 85)
        .firstOrNull
        ?.text;
    final averageScore = scored.isEmpty ? null : session.averageScore;

    final profile = context.read<HomeProvider>().userProfile;
    final tier = profile?.tier ?? 'free';
    final dailyLimit = QuotaConstants.getLimit(tier, 'story');
    final quotaReminder = dailyLimit == -1
        ? null
        : '${(dailyLimit - provider.storyUsedToday).clamp(0, dailyLimit)}/$dailyLimit sessions left today';

    return showEndSessionDialog(
      context: context,
      accentColor: AppColors.purpleDeep,
      stats: EndSessionStats(
        turns: session.userTurnCount,
        averageScore: averageScore,
        duration: DateTime.now().difference(session.startedAt),
        highlight: highlight == null
            ? null
            : 'Best line: "${_firstWords(highlight, 6)}…"',
        quotaReminder: quotaReminder,
      ),
    );
  }

  String _firstWords(String s, int count) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.length <= count) return parts.join(' ');
    return parts.take(count).join(' ');
  }
```

- [ ] **Step 3: Replace `_onBackPressed`**

Delete the current method (lines ~103–109) and add:

```dart
  Future<void> _onBackPressed(StoryProvider provider) async {
    final confirmed = await _askEndConfirmation(provider);
    if (confirmed != true) {
      // Learner chose Keep going (or dismissed). Session stays in-progress;
      // no Firestore write, so they can resume from Home next time.
      return;
    }
    await provider.endSession();
    if (!mounted) return;
    context.push('/story/summary');
  }
```

Note: this is the key behavioural unification with Scenario. Back no longer writes anything automatically; if the learner walks away without tapping End & review, their session simply stays `in-progress`.

- [ ] **Step 4: Replace `_TypingRow` usage with `ThinkingIndicator`**

In the chat body (around line 237–239), replace:

```dart
if (index == session.turns.length &&
    provider.isLoading) {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: _TypingRow(),
  );
}
```

with:

```dart
if (index == session.turns.length &&
    provider.isLoading) {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: ThinkingIndicator(accentColor: AppColors.purpleDeep),
  );
}
```

Then delete the `_TypingRow` class entirely (lines ~385–426).

- [ ] **Step 5: Analyze + spot-check**

Run:
```
cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai
flutter analyze lib/features/story/screens/story_chat_screen.dart
grep -n 'abandonSession\|_TypingRow\|_showEndDialog' lib/features/story/screens/story_chat_screen.dart
```
Expected: analyze clean; grep returns nothing.

- [ ] **Step 6: Commit**

```bash
git add lib/features/story/screens/story_chat_screen.dart
git commit -m "feat(story): unify back/end with shared EndSessionDialog + ThinkingIndicator"
```

---

## Task 7: Scenario provider — add cancelCurrentMessage + seq + 30s timeout

**Files:**
- Modify: `lib/features/scenario/providers/scenario_provider.dart`

- [ ] **Step 1: Add seq + pending state fields**

In the state block (around lines 53–79), add after `bool _isLoading = false;`:

```dart
  /// Monotonic seq bumped on every `sendUserMessage` call AND on
  /// `cancelCurrentMessage`. In-flight awaits capture seq at send-start and
  /// drop their result if seq has moved on by the time they return.
  int _sendSeq = 0;

  /// Count of messages BEFORE the current in-flight send appended the user
  /// bubble — lets cancelCurrentMessage truncate anything the resolver has
  /// already pushed past that count while keeping the user bubble itself.
  int? _pendingSendBaseCount;
```

- [ ] **Step 2: Rewrite `sendUserMessage`**

Replace the whole method (lines 256–313) with:

```dart
  /// Send user message and get AI assessment.
  Future<void> sendUserMessage(String text) async {
    if (_currentScenario == null) return;
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
    _pendingSendBaseCount = _messages.length;
    _messages.add(userMsg);
    _isAiTyping = true;
    _error = null;
    final seq = ++_sendSeq;
    notifyListeners();

    try {
      if (!GeminiConfig.isApiKeyConfigured) {
        throw StateError('Gemini API key not configured');
      }
      // 30s provider-level ceiling so a slow Gemini call surfaces as an
      // error the learner can act on, rather than an open-ended hang.
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
          .timeout(const Duration(seconds: 30));
      if (seq != _sendSeq) return;

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

  /// Cancel the current in-flight [sendUserMessage]. Keeps the user bubble
  /// (token cost was already incurred), drops any assessment / AI reply the
  /// resolver had queued past it. The Gemini future keeps running — the seq
  /// check drops its result silently.
  void cancelCurrentMessage() {
    if (!_isAiTyping) return;
    _sendSeq++;
    final base = _pendingSendBaseCount;
    if (base != null && _messages.length > base + 1) {
      _messages.removeRange(base + 1, _messages.length);
    }
    _pendingSendBaseCount = null;
    _isAiTyping = false;
    _error = null;
    notifyListeners();
  }
```

- [ ] **Step 3: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/features/scenario/providers/scenario_provider.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenario/providers/scenario_provider.dart
git commit -m "feat(scenario): add cancelCurrentMessage with seq invalidation + 30s timeout"
```

---

## Task 8: Scenario chat screen — Stop button + ThinkingIndicator + shared dialog

**Files:**
- Modify: `lib/features/scenario/screens/scenario_chat_screen.dart`

- [ ] **Step 1: Replace imports**

Add to the existing imports:

```dart
import '../../../core/constants/quota_constants.dart';
import '../../../shared/widgets/end_session_dialog.dart';
import '../../../shared/widgets/thinking_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
```

Delete these (no longer used after the refactor):

```dart
// delete:
// import 'dart:math';
// import '../../../core/theme/app_shadows.dart';
// import '../../../core/theme/app_animations.dart';
// import '../../../shared/widgets/clay_dialog.dart';
```

- [ ] **Step 2: Replace `_showEndSessionDialog`**

Replace the whole method (lines 88–116) with:

```dart
  Future<void> _showEndSessionDialog(
    BuildContext context,
    ScenarioProvider provider,
  ) async {
    final scenario = provider.currentScenario;
    if (scenario == null) {
      context.go('/home');
      return;
    }

    final profile = context.read<HomeProvider>().userProfile;
    final tier = profile?.tier ?? 'free';
    final dailyLimit = QuotaConstants.getLimit(tier, 'roleplay');
    final quotaReminder = dailyLimit == -1
        ? null
        : '${(dailyLimit - provider.roleplayUsedToday).clamp(0, dailyLimit)}/$dailyLimit sessions left today';

    final scoredScore = provider.averageScore;
    final confirmed = await showEndSessionDialog(
      context: context,
      accentColor: AppColors.teal,
      stats: EndSessionStats(
        turns: provider.totalTurns,
        averageScore: scoredScore > 0 ? scoredScore : null,
        duration: Duration(minutes: provider.sessionDurationMinutes),
        quotaReminder: quotaReminder,
      ),
    );
    if (confirmed != true) return;
    await provider.endSession();
    if (context.mounted) context.push('/scenario/summary');
  }
```

Note: the back-button onBack handler already calls `_showEndSessionDialog(context, provider)` (see line 178), so no further change there. The Scenario header does not have a separate End button today — the existing behaviour of Back == End is the intended unified pattern.

- [ ] **Step 3: Replace `_TypingIndicator` usage**

In `build` (around line 207), replace:

```dart
if (index == provider.messages.length &&
    provider.isAiTyping) {
  return _TypingIndicator();
}
```

with:

```dart
if (index == provider.messages.length &&
    provider.isAiTyping) {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: ThinkingIndicator(accentColor: AppColors.teal),
  );
}
```

Then delete the `_TypingIndicator` and `_TypingIndicatorState` classes entirely (lines ~354–450).

- [ ] **Step 4: Wire Stop button into ChatInputBar**

Around line 220–227, replace:

```dart
SafeArea(
  top: false,
  child: ChatInputBar(
    onSend: (text) async {
      await provider.sendUserMessage(text);
    },
  ),
),
```

with:

```dart
SafeArea(
  top: false,
  child: ChatInputBar(
    enabled: !provider.isAiTyping,
    onStop: provider.cancelCurrentMessage,
    onSend: (text) async {
      await provider.sendUserMessage(text);
    },
  ),
),
```

- [ ] **Step 5: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/features/scenario/screens/scenario_chat_screen.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/scenario/screens/scenario_chat_screen.dart
git commit -m "feat(scenario): wire Stop + ThinkingIndicator + shared EndSessionDialog"
```

---

## Task 9: FirebaseDatasource — add `countConversations`

**Files:**
- Modify: `lib/data/datasources/firebase_datasource.dart`

- [ ] **Step 1: Add count helper**

Append the following method after `deleteConversation` (currently ending around line 117):

```dart
  /// Total number of conversation docs the user has stored, regardless of
  /// mode or status. Uses Firestore's `count()` aggregation — billed as one
  /// aggregate read, not a per-doc read, so this stays cheap even for
  /// long-term power users.
  ///
  /// Returns 0 on failure so the storage-quota gate fails open (prefer
  /// letting the user create a session over blocking them on a transient
  /// Firestore hiccup).
  Future<int> countConversations(String uid) async {
    try {
      final aggregate = await _db
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .count()
          .get();
      return aggregate.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Per-mode breakdown used by the storage banner. Walks the list of
  /// conversations once and tallies by the `mode` field. For users with
  /// thousands of docs this is the expensive path — the banner reads it
  /// lazily (only when storage is in warning or cap state).
  Future<Map<String, int>> breakdownConversationsByMode(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final mode = (doc.data()['mode'] as String?) ?? 'other';
        counts[mode] = (counts[mode] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return const {};
    }
  }
```

- [ ] **Step 2: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/data/datasources/firebase_datasource.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/data/datasources/firebase_datasource.dart
git commit -m "feat(firebase): add countConversations + breakdownConversationsByMode"
```

---

## Task 10: `StorageQuotaProvider`

**Files:**
- Create: `lib/features/shared/providers/storage_quota_provider.dart`
- Test: `test/features/shared/providers/storage_quota_provider_test.dart`

- [ ] **Step 1: Write the provider**

```dart
import 'package:flutter/foundation.dart';
import '../../../core/constants/quota_constants.dart';
import '../../../data/datasources/firebase_datasource.dart';

enum StorageQuotaState { healthy, warning, cap }

class StorageQuotaSnapshot {
  final int total;
  final int cap;
  final StorageQuotaState state;
  final Map<String, int> perMode;

  const StorageQuotaSnapshot({
    required this.total,
    required this.cap,
    required this.state,
    required this.perMode,
  });

  bool get canCreate => state != StorageQuotaState.cap;
  double get usageFraction => cap <= 0 ? 0 : total / cap;

  static StorageQuotaSnapshot empty() => const StorageQuotaSnapshot(
        total: 0,
        cap: QuotaConstants.storageCapFree,
        state: StorageQuotaState.healthy,
        perMode: {},
      );
}

/// Tracks how many conversations the user has stored across all modes.
///
/// - Reads the aggregate count up front via Firestore `count()` — one
///   billed read per refresh, cached for [_cacheTtl].
/// - Reads the per-mode breakdown lazily: only when the state enters
///   `warning` or `cap` (the banner needs those numbers; the healthy state
///   does not).
/// - Invalidated from the outside via [invalidate] after any create or
///   delete of a conversation doc so the next getter call refetches.
class StorageQuotaProvider extends ChangeNotifier {
  static const Duration _cacheTtl = Duration(seconds: 60);

  final FirebaseDatasource _firebase;
  String? _uid;
  String _tier = 'free';
  StorageQuotaSnapshot _snapshot = StorageQuotaSnapshot.empty();
  DateTime? _fetchedAt;
  bool _isRefreshing = false;

  StorageQuotaProvider({required FirebaseDatasource firebase})
      : _firebase = firebase;

  StorageQuotaSnapshot get snapshot => _snapshot;
  bool get isRefreshing => _isRefreshing;

  Future<void> init({required String uid, required String tier}) async {
    _uid = uid;
    _tier = tier;
    await refresh();
  }

  void invalidate() {
    _fetchedAt = null;
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    if (_isRefreshing) return;
    if (_fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < _cacheTtl) {
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    try {
      final total = await _firebase.countConversations(uid);
      final cap = QuotaConstants.getStorageCap(_tier);
      final state = _deriveState(total: total, cap: cap);

      Map<String, int> breakdown = const {};
      if (state != StorageQuotaState.healthy) {
        breakdown = await _firebase.breakdownConversationsByMode(uid);
      }

      _snapshot = StorageQuotaSnapshot(
        total: total,
        cap: cap,
        state: state,
        perMode: breakdown,
      );
      _fetchedAt = DateTime.now();
    } catch (_) {
      // Fail open — keep last snapshot. Next refresh will try again.
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  static StorageQuotaState deriveStateForTest({
    required int total,
    required int cap,
  }) =>
      _deriveState(total: total, cap: cap);

  static StorageQuotaState _deriveState({
    required int total,
    required int cap,
  }) {
    if (cap <= 0) return StorageQuotaState.healthy;
    if (total >= cap) return StorageQuotaState.cap;
    if (total >= (cap * QuotaConstants.storageWarningThreshold).floor()) {
      return StorageQuotaState.warning;
    }
    return StorageQuotaState.healthy;
  }
}
```

- [ ] **Step 2: Write unit test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_coach_ai/features/shared/providers/storage_quota_provider.dart';

void main() {
  group('StorageQuotaProvider.deriveState', () {
    test('0/20 → healthy', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 0, cap: 20),
        StorageQuotaState.healthy,
      );
    });
    test('15/20 → warning (exactly 75% ≥ 80% false, healthy)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 15, cap: 20),
        StorageQuotaState.healthy,
      );
    });
    test('16/20 → warning (80% threshold)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 16, cap: 20),
        StorageQuotaState.warning,
      );
    });
    test('19/20 → warning', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 19, cap: 20),
        StorageQuotaState.warning,
      );
    });
    test('20/20 → cap', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 20, cap: 20),
        StorageQuotaState.cap,
      );
    });
    test('25/20 → cap (over-cap stays cap)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 25, cap: 20),
        StorageQuotaState.cap,
      );
    });
    test('cap==0 is treated as healthy (fail-open)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 5, cap: 0),
        StorageQuotaState.healthy,
      );
    });
  });
}
```

- [ ] **Step 3: Run tests + analyze**

Run:
```
cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai
flutter test test/features/shared/providers/storage_quota_provider_test.dart
flutter analyze lib/features/shared/providers/storage_quota_provider.dart
```
Expected: all tests PASS, analyze clean.

- [ ] **Step 4: Commit**

```bash
git add lib/features/shared/providers/storage_quota_provider.dart test/features/shared/providers/storage_quota_provider_test.dart
git commit -m "feat(quota): StorageQuotaProvider with threshold derivation"
```

---

## Task 11: `StorageQuotaBanner` widget

**Files:**
- Create: `lib/shared/widgets/storage_quota_banner.dart`

- [ ] **Step 1: Write the widget**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../features/shared/providers/storage_quota_provider.dart';
import 'clay_pressable.dart';

/// Displayed on the Home screen whenever storage is in `warning` or `cap`
/// state. Shows a per-mode breakdown plus the aggregate count and offers
/// two CTAs: Manage (opens Conversation History) and Upgrade (paywall).
class StorageQuotaBanner extends StatelessWidget {
  final StorageQuotaSnapshot snapshot;
  final VoidCallback onManage;
  final VoidCallback onUpgrade;

  const StorageQuotaBanner({
    super.key,
    required this.snapshot,
    required this.onManage,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.state == StorageQuotaState.healthy) {
      return const SizedBox.shrink();
    }
    final isCap = snapshot.state == StorageQuotaState.cap;
    final accent = isCap ? AppColors.error : AppColors.gold;
    final breakdown = _breakdown(snapshot.perMode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.3),
          boxShadow: AppShadows.clay,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCap
                      ? Icons.block_rounded
                      : Icons.storage_rounded,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isCap
                        ? 'Storage full — delete or upgrade to start new'
                        : 'Storage almost full',
                    style: AppTypography.labelMd.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (breakdown.isNotEmpty)
              Text(
                breakdown,
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${snapshot.total}/${snapshot.cap} conversations used.',
              style: AppTypography.caption.copyWith(
                color: AppColors.warmDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClayPressable(
                    onTap: onManage,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.clayBeige,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                            color: AppColors.clayBorder, width: 1.2),
                      ),
                      child: Text(
                        'Manage',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.warmDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClayPressable(
                    onTap: onUpgrade,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: Text(
                        'Upgrade',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _breakdown(Map<String, int> perMode) {
    if (perMode.isEmpty) return '';
    const labels = {
      'roleplay': 'Scenario',
      'story': 'Story',
    };
    final parts = <String>[];
    for (final entry in perMode.entries) {
      if (entry.value == 0) continue;
      final label = labels[entry.key] ?? _capitalise(entry.key);
      parts.add('$label ${entry.value}');
    }
    if (parts.isEmpty) return '';
    return parts.join(' · ');
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
```

- [ ] **Step 2: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/shared/widgets/storage_quota_banner.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/storage_quota_banner.dart
git commit -m "feat(shared): StorageQuotaBanner with per-mode breakdown"
```

---

## Task 12: Register `StorageQuotaProvider` + Home wiring

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Register the provider**

Open `lib/app.dart` and locate the root `MultiProvider` (search for `ChangeNotifierProvider<ScenarioProvider>`). Add below the `StoryProvider` registration:

```dart
ChangeNotifierProvider<StorageQuotaProvider>(
  create: (_) => StorageQuotaProvider(firebase: firebase),
),
```

Make sure the import is added at the top of the file:

```dart
import 'features/shared/providers/storage_quota_provider.dart';
```

- [ ] **Step 2: Home screen — init + consume storage provider**

In `lib/features/home/screens/home_screen.dart`:

Add imports at the top (alongside the existing ones):

```dart
import '../../../shared/widgets/storage_quota_banner.dart';
import '../../shared/providers/storage_quota_provider.dart';
```

In `initState` (around lines 47–57), extend the post-frame callback to also init storage quota:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  final auth = context.read<AuthProvider>();
  final uid = auth.currentUser?.uid;
  if (uid != null) {
    context.read<HomeProvider>().loadProfile(uid);
    context.read<LibraryProvider>().init(uid);
    context.read<AnalyticsProvider>().init(uid);
    final profile = context.read<HomeProvider>().userProfile;
    final tier = profile?.tier ?? 'free';
    context.read<StorageQuotaProvider>().init(uid: uid, tier: tier);
  }
});
```

- [ ] **Step 3: Gate `_startRoleplay` and `_startStory` on storage state**

Extract a shared helper at the top of `_HomeScreenState`:

```dart
  /// Returns true if the user can create a new conversation. Shows a
  /// snackbar and returns false when storage is capped.
  bool _guardStorageForNewSession() {
    final snapshot = context.read<StorageQuotaProvider>().snapshot;
    if (snapshot.canCreate) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Storage full. Delete a conversation or upgrade to start a new one.',
        ),
        action: SnackBarAction(
          label: 'Upgrade',
          onPressed: () => _openUpgradePage(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    return false;
  }

  void _openUpgradePage() {
    // Hook: once paywall screen exists, replace with context.push('/upgrade').
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paywall coming soon.')),
    );
  }
```

In `_startRoleplay` (line 60), insert the guard AFTER the `scenarioProvider.init(...)` call but BEFORE `canStartSession()`. Replace the block:

```dart
      if (!scenarioProvider.canStartSession()) {
        // … existing snackbar …
        return;
      }
```

with:

```dart
      if (!_guardStorageForNewSession()) return;

      if (!scenarioProvider.canStartSession()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily limit reached. Upgrade for more sessions.'),
            ),
          );
        }
        return;
      }
```

Important: the resume path must still work when storage is capped. Move the `_guardStorageForNewSession()` call so it only fires when the user picked "new session", not resume. After the line that handles resume, replace the current start path:

```dart
if (choice.isResume) { /* … unchanged … */ return; }

// New session path below — check storage now (resume doesn't create a new doc)
if (!_guardStorageForNewSession()) return;
await scenarioProvider.startSession();
```

Move the guard accordingly. Make sure the existing daily-quota pre-check keeps working — reorder inside `_startRoleplay` so the overall flow becomes:

1. `init`
2. `loadUserConversations` (to build the resume list)
3. Show popup
4. If resume → resume (no storage gate).
5. If new session → storage gate → daily quota gate → `startSession`

Apply the equivalent reshape to `_startStory`:

1. `init`
2. `loadUserStoryConversations`
3. If there are resume candidates → show sheet; act on choice.
4. If resume → resume (no storage gate).
5. If new → storage gate → daily quota gate → navigate to `/story`.

Concretely, delete the early `canStartSession && conversations.isEmpty` fast-path and replace with:

```dart
      final conversations = await storyProvider.loadUserStoryConversations();
      if (!mounted) return;

      StartStoryAction? choice;
      if (conversations.isEmpty) {
        // No resume candidates. Check gates before auto-navigating to library.
        if (!_guardStorageForNewSession()) return;
        if (!storyProvider.canStartSession()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily limit reached. Upgrade for more stories.'),
            ),
          );
          return;
        }
        choice = const StartStoryAction.newStory();
      } else {
        choice = await showStartStorySheet(
          context: context,
          conversations: conversations,
          storyLimit: storyProvider.storyLimit,
          storiesUsedToday: storyProvider.storyUsedToday,
        );
      }
      if (!mounted || choice == null) return;

      if (choice.isResume) {
        if (!storyProvider.canStartSession()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily limit reached. Upgrade for more stories.'),
            ),
          );
          return;
        }
        final ok = await storyProvider.resumeSession(choice.conversationId!);
        if (!mounted) return;
        if (!ok || storyProvider.activeSession == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                storyProvider.error ?? 'Could not resume that story.',
              ),
            ),
          );
          return;
        }
        context.push('/story/chat');
        return;
      }

      // New story path.
      if (!_guardStorageForNewSession()) return;
      if (!storyProvider.canStartSession()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily limit reached. Upgrade for more stories.'),
          ),
        );
        return;
      }
      context.push('/story');
```

- [ ] **Step 4: Render the banner above the mode pager**

In `_buildHomeTab`, wrap the `Column` to include the banner when snapshot is non-healthy:

```dart
  Widget _buildHomeTab() {
    return Consumer<StorageQuotaProvider>(
      builder: (context, quota, _) {
        final snap = quota.snapshot;
        return Column(
          children: [
            _TopBar(accentColor: _modes[_currentMode].accentColor),
            if (snap.state != StorageQuotaState.healthy)
              StorageQuotaBanner(
                snapshot: snap,
                onManage: () => context.push('/history'),
                onUpgrade: _openUpgradePage,
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildModePageView(),
                  _buildVerticalModeDots(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
```

- [ ] **Step 5: Invalidate storage provider on conversation create/delete**

Two call-sites need `invalidate()` so the next refresh picks up the change:

**A)** In `lib/features/story/providers/story_provider.dart`, at the end of `_startSession` (right after the successful return path), the count changed. Easiest: add a public method on `StorageQuotaProvider` and call it from Home after `startSession`. Alternative that keeps `StoryProvider` pure: trigger invalidation from the Home screen after the navigation. Chosen approach — invalidate from Home. In `_startStory` and `_startRoleplay`, after a successful session start (`context.push('/story')` and `context.push('/scenario')`), call `context.read<StorageQuotaProvider>().invalidate()` BEFORE the push. Because the counted value is lazy, the next `refresh()` call on next Home focus will update.

In both `_startRoleplay` and `_startStory`, just before `context.push(...)` of a new session, insert:

```dart
context.read<StorageQuotaProvider>().invalidate();
```

**B)** Wire similar invalidation to the History screen's delete action — it already calls `storyProvider.deleteConversationRecord(...)` / `scenarioProvider.deleteConversationRecord(...)`. Find the History screen that handles delete (likely `lib/features/history/screens/history_screen.dart`). After each successful delete, call `context.read<StorageQuotaProvider>().invalidate()`. If the History screen is not trivial to modify here, skip B and document it as a known gap — invalidation still happens on a 60-second TTL so the banner is only up to 60s stale.

- [ ] **Step 6: Analyze + spot-check**

Run:
```
cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai
flutter analyze lib/app.dart lib/features/home/screens/home_screen.dart
```
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/app.dart lib/features/home/screens/home_screen.dart
git commit -m "feat(home): wire StorageQuotaProvider, gate start buttons, show banner"
```

---

## Task 13: Story Repository — add `fetchOtherLevels`

**Files:**
- Modify: `lib/data/repositories/story_repository.dart`

- [ ] **Step 1: Add closest-first sort helper + method**

Add to `lib/data/repositories/story_repository.dart` below `_filterByLevel` (line 89):

```dart
  /// Returns all stories whose CEFR level is NOT the learner's level,
  /// sorted by distance from that level (closest first). For a B1 learner
  /// the order is A2 → A1 → B2 → C1 → C2. Used by the "Other Levels"
  /// section on the Story Home screen for gentle difficulty exploration.
  Future<List<Story>> fetchOtherLevels({required String userLevel}) async {
    List<Story> pool;
    try {
      pool = await _firebase.getFeaturedStories();
      if (pool.isEmpty) pool = await _cache.getFeatured();
      if (pool.isEmpty) pool = await _loadBundledStories();
    } catch (_) {
      pool = await _cache.getFeatured();
      if (pool.isEmpty) pool = await _loadBundledStories();
    }

    final target = CefrLevel.fromProficiencyId(userLevel);
    final other =
        pool.where((s) => CefrLevel.fromProficiencyId(s.level) != target);

    int rank(CefrLevel l) => _levelRank(l);
    final sorted = other.toList()
      ..sort((a, b) {
        final distA =
            (rank(CefrLevel.fromProficiencyId(a.level)) - rank(target)).abs();
        final distB =
            (rank(CefrLevel.fromProficiencyId(b.level)) - rank(target)).abs();
        return distA.compareTo(distB);
      });
    return sorted;
  }

  int _levelRank(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1a2:
        return 0;
      case CefrLevel.b1b2:
        return 1;
      case CefrLevel.c1c2:
        return 2;
    }
  }
```

Note: `_levelRank` assumes the enum values are `a1a2`, `b1b2`, `c1c2` (matching `CefrLevel.fromProficiencyId`). If the enum uses different names, adjust accordingly — check `lib/data/prompts/prompt_constants.dart` for the actual enum.

- [ ] **Step 2: Analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze lib/data/repositories/story_repository.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/data/repositories/story_repository.dart
git commit -m "feat(story): add fetchOtherLevels closest-first for Other Levels section"
```

---

## Task 14: Story Home — render "Other Levels" section

**Files:**
- Modify: `lib/features/story/providers/story_provider.dart` (expose otherLevels)
- Modify: `lib/features/story/screens/story_home_screen.dart`

- [ ] **Step 1: Add `otherLevels` state to `StoryProvider`**

In `lib/features/story/providers/story_provider.dart`, add after `_featured` (line ~63):

```dart
  List<Story> _otherLevels = const [];
  List<Story> get otherLevels => List.unmodifiable(_otherLevels);
```

And update `refreshLibrary` (lines 175–184) to fetch both lists in parallel:

```dart
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
```

- [ ] **Step 2: Render the section in `story_home_screen.dart`**

In `_buildLibrary` (around line 318), after the existing `gridStories` section, add the Other Levels section:

```dart
        if (provider.otherLevels.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: _SectionHeader(
              title: 'Other Levels',
              subtitle: 'Stretch up or ease back when you want a change.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.otherLevels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                final story = provider.otherLevels[i];
                final isThisStarting = _startingStoryId == story.id;
                final isAnotherBusy = _isBusy && !isThisStarting;
                return StoryCard(
                  story: story,
                  isLoading: isThisStarting,
                  disabled: isAnotherBusy,
                  onTap: () => _startFromLibrary(story),
                );
              },
            ),
          ),
        ],
```

Note: `_buildLibrary` is an instance method on `_StoryHomeScreenState` — the parameter for `provider` isn't currently passed in. Refactor `_buildLibrary` signature to take the provider:

```dart
Widget _buildLibrary(
  StoryProvider provider,
  List<Story> heroStories,
  List<Story> gridStories,
) {
```

And update the call site (around line 236):

```dart
: _buildLibrary(provider, heroStories, gridStories),
```

- [ ] **Step 3: Analyze**

Run:
```
cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai
flutter analyze lib/features/story/providers/story_provider.dart lib/features/story/screens/story_home_screen.dart
```
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/story/providers/story_provider.dart lib/features/story/screens/story_home_screen.dart
git commit -m "feat(story): render Other Levels section below Featured library"
```

---

## Task 15: Verification pass

**Files:**
- No new files. Verification only.

- [ ] **Step 1: Full analyze**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter analyze`
Expected: `No issues found!`

If any new warnings surface (typically unused imports left behind after deletions), clean them up inline.

- [ ] **Step 2: Run the full test suite**

Run: `cd /sessions/keen-relaxed-darwin/mnt/aura-coach-ai && flutter test`
Expected: all tests pass, including:
- `test/features/story/models/story_session_test.dart` (Task 2)
- `test/features/story/providers/story_provider_cancel_test.dart` (Task 3)
- `test/features/shared/providers/storage_quota_provider_test.dart` (Task 10)

- [ ] **Step 3: Manual QA checklist**

Run the app against a real Firebase project (dev env) and verify:

**Story Mode — back button:**
- [ ] Start a story, send 2 user turns, tap Back. Dialog appears showing Turns=2, Avg score, Duration, quota line.
- [ ] Tap "Keep going" → dialog dismisses, chat resumes.
- [ ] Tap Back again → dialog. Tap "End & review" → summary screen. Press device Back from summary → lands on Home (or wherever the learner came from), not immediately kicked to Home.
- [ ] Start a new story, send no turns, tap Back → dialog shows Turns=0, no "Avg score" tile.

**Story Mode — stop button:**
- [ ] Start a story, type a reply, send. While "Thinking…" shows, tap the Stop button (red). User bubble remains. Input re-enables. Typing a new reply works.

**Story Mode — history popup:**
- [ ] Complete the above flow (at least one in-progress session exists). Go to Home, tap "Begin Story". Popup appears listing the in-progress session.
- [ ] Tap "End & review" on the resumed session. From Home, tap "Begin Story" again. Popup should still be reachable if any *other* in-progress session exists.

**Story Mode — Other Levels:**
- [ ] Profile shows proficiency B1 (intermediate). Story Home renders "Featured for you" (B1 stories) plus "Other Levels" with A1/C1 stories sorted closest-first.

**Scenario Coach — stop + thinking:**
- [ ] Start a Scenario session. Send a reply. While thinking shows text "Thinking…" (not 3 dots). Tap Stop. User bubble remains. Sent again works.

**Scenario Coach — end session:**
- [ ] Tap Back from Scenario chat. New bottom-sheet dialog shows stats + quota. Tap "End & review" → summary screen.

**Storage quota — warning state:**
- [ ] Manually create 16 conversation documents via Firestore console for a free-tier user (or lower `storageCapFree` to 5 temporarily). Cold-start Home.
- [ ] Banner appears with per-mode breakdown and `n/cap` line.
- [ ] Tapping Manage opens Conversation History. Tapping Upgrade shows paywall placeholder snackbar.

**Storage quota — cap state:**
- [ ] Fill to exactly `cap` (e.g. 20 for free). Cold-start Home.
- [ ] Tapping "Begin Story" shows snackbar "Storage full. Delete a conversation or upgrade to start a new one." Upgrade button opens placeholder.
- [ ] Tapping a resume card (existing in-progress conversation) still works — storage cap only blocks *new* creation.

- [ ] **Step 4: Final commit (optional — fixes surfaced during QA)**

If QA uncovers fixes, apply them and commit with:

```bash
git commit -m "fix(consistency): QA follow-ups from 2026-04-21 pass"
```

Otherwise no commit needed — verification does not change code.

---

## Notes

- **Legacy `abandoned` docs:** existing Firestore conversations with `status: 'abandoned'` will read as `inProgress` and therefore appear on the Home resume popup again. This is acceptable per the spec — users can end them properly from the chat screen. No backfill script required.
- **Breaking change:** `StorySessionStatus.abandoned` removal is source-compatible for read paths (JSON is tolerant). Any external caller referencing `StorySessionStatus.abandoned` directly would fail to compile — a repo-wide grep was part of Task 3 to confirm there are none.
- **`context.push` vs `context.go`:** Navigation changes from `go` to `push` on Story summary so `pop` returns the learner to the chat screen naturally. Scenario was already using `push` for summary; this brings Story in line.
- **`pro` tier storage cap:** Added `storageCapPro = 200` as a reasonable middle ground since `pro` exists in `QuotaConstants.getLimit` but wasn't mentioned in the spec. Luu can retune before launch.
