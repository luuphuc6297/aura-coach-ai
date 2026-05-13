# Scenario Session + Replay

**Date:** 2026-05-11
**Status:** Shipped 2026-05-11. All 7 phases complete. Pending real-device smoke after `flutter analyze` on Luu's box.
**Mode scope:** Scenario Coach (Story Mode mirrors later, same engine)

---

## Problem

After tapping Same / Easier / Harder, the previous scenario disappears from view. User cannot review what they just answered, the assessment, or the grammar breakdown. Data IS saved to Firestore but UI has no surfacing during the active session.

Premium tier has ~130 turns/month → realistic 40-100 scenarios in a long session. Pill bar / stacked-feed UX breaks at 20+. Need a scalable architecture.

## Locked decisions

| ID | Decision |
|----|----------|
| Q1 | Session boundary: **explicit Start / End buttons** — user controls when a session begins and ends |
| Q2 | Replay readonly + **"Branch from this"** action (Same/Easier/Harder on old scenario starts a new one appended to current session) |
| Q3 | Filter chips: **Score bucket only** (All / ⭐9+ / ⭐7-8 / ⭐<6) |
| UX root | **Compact header chip** + **bottom sheet Session Panel** + **replay route** |

## Architecture

### Data model

**Firestore additions:**

```
users/{uid}/sessions/{sessionId}
{
  id: string,
  mode: 'scenario' | 'story',
  startedAt: Timestamp,
  endedAt: Timestamp | null,    // null = active
  scenarioCount: int,            // cached for cheap chip display
  avgScore: double,              // cached, recomputed on each scenario save
}
```

**Existing `users/{uid}/conversations/{conversationId}` modification:**

Add field `sessionId: string` (optional for backward compat). Legacy docs without sessionId surface in History screen only (not in Session Panel).

**Firestore index:** `(sessionId, doneAt DESC)` for Session Panel query.

### Mobile state (ScenarioProvider)

```dart
class ScenarioProvider {
  // existing
  Scenario? _currentScenario;
  List<ChatMessage> _messages;
  AssessmentResult? _lastAssessment;

  // NEW
  String? _activeSessionId;
  DateTime? _sessionStartedAt;
  List<SessionScenarioMeta> _sessionMetas;  // in-memory metadata cache
  bool _isReplayMode;  // when viewing a past scenario from panel
}
```

### Models

```dart
class Session {
  final String id;
  final String mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int scenarioCount;
  final double avgScore;
  bool get isActive => endedAt == null;
}

class SessionScenarioMeta {
  final String conversationId;
  final int orderInSession;        // 1, 2, 3, ...
  final String sourcePhrase;       // truncated, ~60 chars
  final String situation;          // truncated
  final int totalScore;            // 1-10
  final String? tenseDetected;     // from grammarBreakdown.userVersion.tense — null if not available
  final DateTime doneAt;
}
```

Metadata is lightweight (~200 bytes/item × 100 items = 20KB). Full conversation loaded lazily when user taps to view replay.

---

## Phases

### Phase 1 — Data layer (1-2h)

1. Add `Session` + `SessionScenarioMeta` models in `lib/features/scenario/models/session.dart`
2. Extend `FirebaseDatasource`:
   - `createSession(uid, mode) → sessionId`
   - `endSession(uid, sessionId)`
   - `loadActiveSession(uid, mode) → Session?`
   - `listSessionScenarios(uid, sessionId) → List<SessionScenarioMeta>`
   - `loadConversation(uid, conversationId) → ConversationDoc` (for replay)
3. Modify `saveConversation()` to include `sessionId` field + update session aggregates atomically (use Firestore transaction or merge write)
4. Add Firestore composite index for `(sessionId, doneAt DESC)` in `firestore.indexes.json`
5. Firestore rules: allow read/write on `sessions/{sessionId}` for owner only

### Phase 2 — Provider state (2-3h)

1. Add session lifecycle methods:
   - `startSession()` — create Firestore doc, set `_activeSessionId`, clear meta list, load first scenario
   - `endSession()` — mark `endedAt`, clear in-memory state, navigate to home
   - `resumeActiveSession()` — on app launch / mode entry, check for active session, prompt user
2. Modify `startNewScenario(difficulty)`:
   - Before clearing `_messages`: ensure current scenario is saved with `_activeSessionId`
   - Append new `SessionScenarioMeta` to `_sessionMetas` list
   - Notify listeners
3. Add `enterReplayMode(conversationId)`:
   - Set `_isReplayMode = true`
   - Load conversation doc, hydrate `_currentScenario` + `_messages` + `_lastAssessment` from saved data
   - UI uses `_isReplayMode` to disable chat input + swap Same/Easier/Harder labels to "Branch from this"
4. Add `exitReplayMode()` — restore active scenario state OR if user chose "Branch", trigger `startNewScenario(difficulty)`

### Phase 3 — Session chip in header (30min)

1. New widget `lib/features/scenario/widgets/session_chip.dart`
2. Shows `[📋 N · ⭐X.X]` — N = `_sessionMetas.length`, ⭐ = avg score
3. Embedded in `scenario_chat_screen.dart` app bar trailing
4. Tap → `showModalBottomSheet` opens Session Panel
5. Hide if `_activeSessionId == null` (no active session)

### Phase 4 — Session Panel bottom sheet (2-3h)

1. New widget `lib/features/scenario/widgets/session_panel_sheet.dart`
2. Layout:
   - Header: title + count + avg + close button
   - Filter row: All / ⭐9+ / ⭐7-8 / ⭐<6 — `Chip` style matching existing filter chips
   - List body: `ListView.builder` over filtered metas, lazy render
   - Footer: "End session" button (destructive style)
3. Row item:
   - Order badge `#N`
   - Score badge (color-coded: green ≥8, gold 6-7, coral <6)
   - Source phrase (max 1 line, ellipsis)
   - Tense pill (if detected)
   - "now" / "2m ago" / "5m ago" delta
   - Active scenario row highlighted with mode accent ring
4. Tap row → push `/scenario/replay/:conversationId` (only for completed scenarios, NOT active)

### Phase 5 — Replay route (2-3h)

1. New screen `lib/features/scenario/screens/scenario_replay_screen.dart`
2. Route `/scenario/replay/:conversationId` in `app.dart`
3. On mount: provider.enterReplayMode(conversationId) → load conversation
4. Layout: identical to `scenario_chat_screen.dart` BUT:
   - Chat input DISABLED + grayed out + helper text "Replay mode — read only"
   - Pre-populate `_messages` from loaded conversation turns
   - Show `AssessmentCard` for the assessment of THIS conversation (full feature: grammar breakdown, alternative tones, etc. — already supported via existing widget)
   - Same/Easier/Harder buttons label changed to "Branch — Same / Easier / Harder"
5. Tap branch button:
   - Call `provider.exitReplayMode()` → return to scenario chat screen
   - Call `provider.startNewScenario(branchDifficulty)` → new scenario appended to session
   - Pop replay route

### Phase 6 — Start / end session UX (1-2h)

1. On entering Scenario Coach screen:
   - If `_activeSessionId == null` → show empty state with "Start new session" CTA
   - If active session exists → auto-load latest scenario + show session chip
2. After tapping "End session" in panel:
   - Confirmation dialog: "End session? You can start a new one anytime."
   - On confirm: call `endSession()`, navigate back to home OR show "Session ended" summary screen with avg score + scenario count + best/worst scenarios (defer summary screen if too much scope, just go back to home)
3. "Start new session" entry point also exposed in:
   - Empty state when no active session
   - Optional: end-of-session summary

### Phase 7 — i18n + verify (1h)

1. ARB keys (en + vi):
   - `sessionChipLabel` — "{count} scenarios · ⭐{avg}"
   - `sessionPanelTitle` — "SESSION ({count})"
   - `sessionPanelFilterAll` / `FilterExcellent` / `FilterGood` / `FilterNeedsWork`
   - `sessionPanelEmpty` — "No scenarios yet. Complete one to see it here."
   - `sessionPanelActiveLabel` — "Active"
   - `sessionPanelTimeAgoNow` / `Minutes` / `Hours`
   - `sessionStartCta` — "Start new session"
   - `sessionEndCta` — "End session"
   - `sessionEndConfirmTitle` / `Body` / `ConfirmAction`
   - `replayModeBannerLabel` — "Replay — read only"
   - `replayBranchCtaSame` / `CtaEasier` / `CtaHarder` (prefix "Branch — ")
   - `replayLoading`, `replayLoadError`
2. Manual regen 3 files: `app_localizations.dart`, `_en.dart`, `_vi.dart` (sandbox has no Flutter SDK)
3. `flutter analyze` (local — sandbox limitation)
4. Smoke test:
   - Start session → make 3 scenarios → chip shows 3 → tap chip → panel shows 3 rows → tap row 1 → replay loads → "Branch Same" → returns + scenario 4 appended → chip shows 4

---

## Edge cases

| Case | Handling |
|------|----------|
| User force-kills app mid-session | Active session doc persists in Firestore (`endedAt == null`) — on next launch `resumeActiveSession()` finds it and prompts "Continue session N or start new" |
| Network offline when starting session | Generate sessionId locally (UUID), buffer Firestore write, sync on reconnect. SharedPreferences fallback. |
| Network offline mid-replay | Show cached AssessmentCard (already in `_lastAssessment` if very recent) OR show "Reconnect to view replay" inline error |
| Legacy conversation docs without sessionId | Excluded from Session Panel queries. Surfaced only in existing `conversation_history_screen.dart` under "Legacy" label. |
| User reaches monthly quota cap mid-session | After saving current scenario, "End session" is auto-suggested. New scenario blocked by QuotaEngine wall dialog (Phase E of subscription work). Existing session metadata still viewable. |
| Tap "Branch — Same" from VERY old replay (different difficulty distribution since then) | Branch uses the CURRENT user level for difficulty, NOT the old conversation's difficulty. This is correct because user level may have evolved. |
| User has 2 modes (Scenario + Story) active sessions simultaneously | Each mode tracks its own active session. Provider keyed by mode. |
| Replay loads conversation that has no `grammarBreakdown` (saved before this feature shipped) | AssessmentCard already handles `grammarBreakdown == null` → simply skips that block. No special UI needed. |

---

## Out of scope (deferred)

- Story Mode session/replay (same pattern, ship after Scenario lands and stabilizes)
- Cross-session aggregate analytics (per-tense mastery curve, etc. — Insights mode handles general)
- Sharing a session as a "challenge link" to friends
- Edit / delete a past scenario from panel
- Pin / favorite scenarios in panel
- End-of-session summary screen (defer until user feedback indicates need)
- Resume-vs-start-new prompt UX polish — v1 simple confirmation dialog enough

---

## Files touched (estimate)

**New (5 files):**
- `lib/features/scenario/models/session.dart`
- `lib/features/scenario/widgets/session_chip.dart`
- `lib/features/scenario/widgets/session_panel_sheet.dart`
- `lib/features/scenario/screens/scenario_replay_screen.dart`
- `firestore.indexes.json` additions

**Modified (~8 files):**
- `lib/features/scenario/providers/scenario_provider.dart`
- `lib/features/scenario/screens/scenario_chat_screen.dart`
- `lib/data/datasources/firebase_datasource.dart`
- `lib/app.dart` (route)
- `firestore.rules`
- `lib/l10n/app_en.arb` + `app_vi.arb`
- 3 generated localization files

---

## Effort estimate

| Phase | Hours |
|-------|-------|
| P1 Data layer | 1.5 |
| P2 Provider state | 2.5 |
| P3 Header chip | 0.5 |
| P4 Session Panel | 2.5 |
| P5 Replay route | 2.5 |
| P6 Start/end UX | 1.5 |
| P7 i18n + verify | 1 |
| **Total** | **~12 hours** |

Sequential dependencies: P1 → P2 → (P3 + P4 + P5 + P6 in parallel) → P7

---

## Next concrete action

Implement Phase 1 — data layer. After verification, move to P2.
