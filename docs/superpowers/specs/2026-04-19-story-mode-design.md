# Story Mode — Design Spec

**Date:** 2026-04-19
**Author:** Luu (luuphuc6297@gmail.com) + AI brainstorming session
**Status:** Approved, ready for implementation plan
**Target mode:** Story Mode (2nd learning mode after Scenario Coach)

---

## 1. Goal

Build Story Mode end-to-end so it is the second fully-wired learning mode after Scenario Coach. Ship the Home card from silent no-op to a working flow: library discovery, custom story generation, multi-turn dialogue chat with inline assessment, and session summary with save-to-vocab integration.

The design intentionally addresses the persistence gap observed in Scenario Coach — assessment cards must survive app cold starts and direct-navigation reloads from day one.

## 2. Non-goals (MVP)

The following are explicitly out of scope for this delivery:

- Character portrait illustrations (use initial-in-gradient-circle avatars)
- Voice / TTS playback of agent messages (text-only dialogue)
- Video generation or animated backgrounds
- Story rating, user-submitted library stories, community sharing
- Retroactive fix for Scenario Coach persistence (tracked as separate PR)
- Custom-story "remix" or fork of a library story

## 3. Scope decisions (locked)

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Both library + custom stories | Library = fast onramp; custom = deeper engagement for returning users |
| 2 | Entry UX = Hero card + single featured grid (Option B) | Simplest, most discoverable CTA, lowest impl effort |
| 3 | Library = Firestore `/stories/{id}` x 12 curated (4 per level A2/B1/B2) | Editable without app release; cacheable; room to grow |
| 4 | Custom flow = Full-screen 4-step form (topic → level → character → context) | User wants control; character-preference field makes stories feel personalized |
| 5 | Session shape = free-form, user-ended; hard safety cap = 20 user turns (= 20 exchanges) | User explicitly chose free-form; cap prevents cost runaway |
| 6 | End-of-session = dedicated summary screen (Option A pattern) | Radar chart + top 3 corrections + per-correction Save-to-vocab CTA; matches Scenario pattern |
| 7 | Quota unit = 1 session start = 1 quota charge | Existing `QuotaConstants` limits unchanged: free=3/day, pro=10/day, premium=∞ |
| 8 | Persistence = auto-resume on init, no silent catch, assessment embedded in user turn | Fixes the "assessment card lost on reload" bug at the design level |

## 4. User flow

### 4.0 Entry flow — Home "Begin Story" tap (mirror Scenario)

This flow MUST mirror Scenario's `_startRoleplay()` pattern 1:1 (see `lib/features/home/screens/home_screen.dart` line 57-147). No deviation.

1. User taps Story mode card on Home → `_startStory()` runs (mirror of `_startRoleplay()`)
2. `StoryProvider.init({uid, tier, level})` runs if not already initialized
3. Quota check: if `!canStartSession()` → show `PaywallDialog`, abort
4. `loadUserStoryConversations()` fetches conversations with `mode='story'` filter → filter `status == 'in-progress'` → build `inProgressList`
5. Branch on `inProgressList.length`:
   - **Empty** → `context.push('/story')` directly (land on library hub — no popup)
   - **Non-empty** → `showStartStorySheet(context, conversations: inProgressList)` (bottom sheet popup mirroring `start_practice_sheet.dart`)
6. Popup actions return `StartStoryAction`:
   - **Tap "New Story" gradient CTA** → `context.push('/story')` (land on library hub)
   - **Tap resume card** → `StoryProvider.resumeSession(conversationId)` rehydrates from Firestore → `context.push('/story/chat')`

**Note:** No cache-based auto-resume on cold start. Resume happens only via explicit tap on popup. This mirrors Scenario exactly.

### 4.1 Happy path — library story

1. From entry flow above, user landed on `/story` (library hub)
2. `StoryHomeScreen` renders: Hero "Create Your Own Story" card (gradient teal→purple) + "Featured · {level}" section header + grid of 4 library cards filtered by user's CEFR level band
3. User taps a library card → `StoryProvider.startFromLibrary(story)` runs: quota check → `generateStoryScenario(level, topic=story.topic, previousTitles=<last 5 completed story titles for this user>, customContext=story.situation)` → on success, increments `storyCount` in `/users/{uid}/usage/{date}`, creates new `/users/{uid}/conversations/{conversationId}` doc with `mode='story'`, routes to `/story/chat`
4. `StoryChatScreen` shows character header (avatar initial + name + role) + opening agent message bubble + input bar + "End" button in top-right
5. User types reply → `StoryProvider.sendUserMessage(text)` → `evaluateStoryTurn(...)` → appends user turn (with assessment) + ai turn → renders as: user bubble → inline `AssessmentCard` directly below the user bubble → ai reply bubble
6. User continues chatting (free-form, no turn limit from UI); each exchange saves full `turns[]` to Firestore
7. User taps "End" → `StoryProvider.endSession()` marks conversation `status='completed'`, navigates to `/story/summary`
8. `StorySummaryScreen` renders trophy hero (avg score/100), 3-axis radar (accuracy / naturalness / complexity averaged across all turns), stats row (turns count, duration, new-words count), top 3 corrections cards with per-correction "💾 Save phrase" button, and CTA row (Back to Home / New story)

### 4.2 Custom story path

1. From `StoryHomeScreen`, user taps hero "Create Your Own Story" CTA → navigates to `/story/custom`
2. `StoryCustomFormScreen` shows 4-step stepper dots + scrollable form:
   - Step 1: Topic chips (work / travel / dating / family / health / hobby) + free-text fallback ("Or type your own topic…")
   - Step 2: Level chips (A1 / A2 / B1 / B2 / C1) — pre-selected to user's profile CEFR
   - Step 3: Character preference chips (Any / Male / Female / Young / Older)
   - Step 4: Specific context textarea (optional, 3 rows, placeholder example)
3. "Next →" primary button at bottom (clay-shadow style: teal bg, 2px warm-dark border, 3×3 shadow)
4. On submit → `StoryProvider.startFromCustom({topic, level, characterPreference, customContext})` → same generation flow as library story (storyId=null on the conversation doc)
5. Rest of flow is identical to 4.1 steps 4–8

### 4.3 Resume path (popup-driven, no cold-start auto-resume)

1. App cold starts → `StoryProvider.init()` runs lazily (first Home tap on Story card)
2. Resume path is driven exclusively by the entry flow popup (Section 4.0 step 5-6), not by SharedPreferences cache
3. `StoryProvider.resumeSession(conversationId)` reads the conversation doc from Firestore and sets `activeSession` with full `turns[]` including inline assessments
4. If user navigates directly to `/story/chat` (deep link, back stack) and `activeSession == null`, screen redirects to `/story` to prevent empty chat
5. The `LocalDatasource` cache methods (`cacheActiveStorySession`/`readActiveStorySession`/`clearActiveStorySession`) exist as dormant code for potential future use (e.g. offline draft preservation). `StoryProvider` does NOT call them in MVP.

### 4.4 Error / paywall paths

- Quota exhausted on tap → show `ClayDialog` with tier upgrade CTA (reuse `PaywallDialog` from Scenario)
- `generateStoryScenario` fails → toast "Couldn't generate story, please try again" + keep quota NOT charged (only charge on success)
- `evaluateStoryTurn` fails mid-session → show inline retry banner on the user's last bubble, preserve input text so user can re-send
- Firestore save fails → set `persistenceError` field on provider, show small "Saving…" indicator that goes red; do NOT silently swallow

## 5. Data model

### 5.1 Firestore — library collection (new, admin-writable)

Path: `/stories/{storyId}` — read-only for clients, seeded by admin.

```
{
  id: string                              // doc id
  title: string                           // "Airport Check-in"
  topic: string                           // enum: travel | work | dating | family | health | hobby | social | daily
  level: string                           // enum: A2 | B1 | B2 (MVP covers 3 bands)
  situation: string                       // 2-4 sentence rich context prompt for Gemini
  character: {
    name: string                          // "Maria"
    role: string                          // "Hotel Receptionist"
    personality: string                   // "warm, efficient"
    initial: string                       // "M" (derived from name[0])
    gradient: string                      // 'teal-purple' | 'gold-peach' | 'purple-pink' | 'teal-gold'
  }
  suggestedTurns: number                  // UI hint (5-8), not enforced
  thumbnailIcon: string                   // emoji '☕' or Cloudinary key
  order: number                           // sort key for featured list
  createdAt: timestamp
  updatedAt: timestamp
}
```

MVP seed: 12 stories = 4 per level × 3 levels (A2, B1, B2). Topic distribution curated so each level covers travel, work, daily, social. Seed script commits the JSON + a small Dart admin helper (`scripts/seed_stories.dart`) that writes the collection via Firebase Admin creds (dev-only, not in prod APK).

### 5.2 Firestore — conversation (extend existing)

Path: `/users/{uid}/conversations/{conversationId}` — reuse existing schema with `mode='story'`.

```
{
  mode: 'story'
  conversationId: string                  // uuid v4
  storyId: string | null                  // null = custom story
  situation: string                       // snapshot at session start
  character: { name, role, personality, initial, gradient }  // snapshot
  topic: string
  level: string
  customContext: string | null            // only for custom
  characterPreference: string | null      // only for custom: Any | Male | Female | Young | Older
  status: 'in-progress' | 'completed' | 'abandoned'
  turns: [
    {
      id: string                          // uuid
      role: 'user' | 'ai' | 'system'
      text: string
      timestamp: iso8601 string
      assessment?: AssessmentResult.toJson // INLINE on user turns only (role='user')
    }
  ]
  totalScore: number                      // averaged on end
  turnCount: number                       // derived, stored for history list perf
  startedAt: iso8601 string
  endedAt: iso8601 string | null
  updatedAt: iso8601 string
  quotaCharged: boolean                   // true only after successful generation
}
```

**Critical invariant:** assessment lives INLINE on the user turn (role='user'), not as a separate turn type. This differs from Scenario's 3-message pattern (user / assessment-type / ai) and avoids the orphan-assessment drop on rehydrate.

### 5.3 Firestore — usage (extend existing)

Path: `/users/{uid}/usage/{yyyy-MM-dd}` — add one field.

```
{
  roleplayCount: number                   // existing
  storyCount: number                      // NEW — +1 on successful story generation
  translatorCount: number                 // reserved
  dictionaryCount: number                 // reserved
  mindmapCount: number                    // reserved
  ttsCount: number                        // reserved
  updatedAt: timestamp
}
```

### 5.4 LocalDatasource — active session cache (DORMANT in MVP)

SharedPreferences key: `active_story_session`

```json
{
  "conversationId": "uuid",
  "storyId": "uuid-or-null",
  "topic": "travel",
  "startedAt": "2026-04-19T10:30:00Z"
}
```

**Status:** Methods exist on `LocalDatasource` (already shipped in Batch 1) but are NOT called by `StoryProvider` in MVP. Resume is driven exclusively by the popup flow (Section 4.0). The methods stay as dormant code for potential offline-draft use post-MVP.

## 6. Module architecture

### 6.1 New files

```
lib/features/story/
├── models/
│   ├── story.dart                       # Library item (Firestore /stories/{id})
│   ├── story_character.dart             # Character value object
│   ├── story_turn.dart                  # Single turn (user/ai/system) + inline assessment
│   └── story_session.dart               # Runtime state: turns, situation, character, etc.
├── providers/
│   └── story_provider.dart              # ChangeNotifier, mirrors ScenarioProvider shape
├── screens/
│   ├── story_home_screen.dart           # Hero + featured grid (NO continue banner)
│   ├── story_custom_form_screen.dart    # 4-step full-screen form
│   ├── story_chat_screen.dart           # Multi-turn chat UI
│   └── story_summary_screen.dart        # End-of-session: trophy + radar + top 3 + CTAs
└── widgets/
    ├── story_hero_card.dart             # Gradient CTA on home
    ├── story_card.dart                  # Grid item (thumbnail + title + level badge + turns)
    ├── story_stepper.dart               # 4-dot progress indicator
    └── story_character_header.dart      # Chat screen top: avatar + name + role

lib/features/home/widgets/
└── start_story_sheet.dart               # NEW — duplicated from start_practice_sheet.dart,
                                         # adapted copy ("Start Story" / character subtitles)

lib/data/
├── cache/story_cache.dart               # Mirror ScenarioCache — offline library fallback
└── repositories/story_repository.dart   # NEW — fills empty repositories/ folder

lib/core/constants/
└── story_constants.dart                 # TOPIC_OPTIONS, CHARACTER_PREFS, HARD_CAP=20

scripts/
└── seed_stories.dart                    # Dev-only admin seeder
└── stories_seed_data.json               # 12 curated stories
```

### 6.2 Extensions to existing files

- `lib/data/datasources/firebase_datasource.dart`:
  - Add `Future<List<Story>> getFeaturedStories({String level})`
  - Add `Future<void> incrementUsage(uid, date, field)` (generalize from existing `incrementRoleplayUsage`)
  - Reuse existing `saveConversation`, `getConversation`, `getConversations` with `mode='story'` filter
- `lib/data/datasources/local_datasource.dart`:
  - Add `Future<void> cacheActiveStorySession(Map<String, dynamic> payload)`
  - Add `Future<Map<String, dynamic>?> readActiveStorySession()`
  - Add `Future<void> clearActiveStorySession()`
- `lib/features/home/screens/home_screen.dart`:
  - Replace Story `_ModeConfig.route: null` with a new `_startStory()` onTap handler (mirror of existing `_startRoleplay()` at lines 57-147)
  - `_startStory()` does: init → quota check → `loadUserStoryConversations()` → filter `inProgress` → if empty `push('/story')` / else `showStartStorySheet(...)` → on resume `resumeSession + push('/story/chat')`, on new `push('/story')`
- `lib/app.dart`: register `StoryProvider` + `StoryCache` + 4 new `GoRoute` entries

### 6.3 Reuse from Scenario (no new impl)

- `AssessmentResult` model + `toJson`/`fromJson` — same schema
- `ChatBubbleUser`, `ChatBubbleAi` widgets — identical bubble rendering
- `ChatInputBar` widget — same input UX with send button
- `AssessmentCard` widget — same radar + corrections layout (rendered inline below user bubbles)
- `RadarScore`, `ScoreCircle` widgets — used on summary screen
- `ClayDialog`, `PaywallDialog` — reuse for quota-exhausted state
- `MessageEntrance` shared animation wrapper

### 6.4 New routes

```dart
GoRoute(path: '/story',         builder: (_, __) => const StoryHomeScreen()),
GoRoute(path: '/story/custom',  builder: (_, __) => const StoryCustomFormScreen()),
GoRoute(path: '/story/chat',    builder: (_, __) => const StoryChatScreen()),
GoRoute(path: '/story/summary', builder: (_, __) => const StorySummaryScreen()),
```

## 7. StoryProvider contract

Public surface (method signatures locked):

```dart
class StoryProvider extends ChangeNotifier {
  StoryProvider({
    required GeminiService gemini,
    required FirebaseDatasource firebase,
    required LocalDatasource local,
    required StoryCache cache,
  });

  // State (read-only from outside)
  List<Story> get featuredLibrary;
  StorySession? get activeSession;
  int get storyUsedToday;
  bool get isLoading;
  String? get error;                          // generation / network errors
  String? get persistenceError;               // save-failed banner text, null = healthy

  // Lifecycle
  Future<void> init({required String uid, required String tier, required String level});
  Future<void> refreshLibrary();              // re-fetch /stories/* with level filter
  void dispose();

  // Quota
  bool canStartSession();                     // uses QuotaConstants.getLimit

  // Resume support (popup-driven entry flow — Section 4.0)
  Future<List<Map<String, dynamic>>> loadUserStoryConversations();
  Future<bool> resumeSession(String conversationId);

  // Session starters (both enforce quota check first)
  Future<bool> startFromLibrary(Story story);
  Future<bool> startFromCustom({
    required String topic,
    required String level,
    required String characterPreference,      // 'Any' as default
    String? customContext,
  });

  // In-session
  Future<void> sendUserMessage(String text);  // calls evaluateStoryTurn, appends user+ai turns
  Future<void> endSession();                  // status='completed', routes to summary
  Future<void> abandonSession();              // status='abandoned', routes to home

  // Save-phrase from summary
  Future<void> saveCorrectionToVocab(Improvement improvement);  // writes to /users/{uid}/savedItems/
}
```

### Persistence invariants (must be tested)

1. After any successful `sendUserMessage`, the full `turns[]` in Firestore equals `activeSession.turns` including every assessment payload.
2. After app cold restart, `StoryProvider.init()` rehydrates any `in-progress` conversation, and `activeSession.turns` is byte-for-byte identical to what was last saved.
3. If a save fails, `persistenceError` is non-null and is displayed in the chat UI as a small warning banner — NEVER swallowed silently.
4. Quota is only charged on successful `generateStoryScenario` — if generation throws, `storyCount` is not incremented.
5. Assessments are stored inline on `role='user'` turns — never as a separate `role='assessment'` turn. This is a schema contract.

## 8. Screen specs

### 8.1 StoryHomeScreen (`/story`)

**Layout:**
- App bar: back button (←) + title "Story Mode" (Fredoka 20px 700 #2D3047) + quota pill (gold bg, "N/3 today")
- Scrollable body:
  - Hero `StoryHeroCard` (gradient teal→purple, 2px warm-dark border, clay shadow 3×3)
  - Section header "Featured Stories · {user.level}" (Fredoka 16px 700) + count label
  - 2-column grid of `StoryCard` items (image 80px thumbnail + title + level badge + suggestedTurns label)

**Interactions:**
- Tap hero CTA → `context.push('/story/custom')`
- Tap story card → `provider.startFromLibrary(story)` → on success `context.push('/story/chat')`, on quota-exhausted → showClayDialog paywall

**Note:** Continue banner removed — resume is handled by `start_story_sheet` popup invoked from Home, not from this screen.

### 8.2 StoryCustomFormScreen (`/story/custom`)

**Layout:**
- App bar: back button + title "Custom Story" + quota pill
- 4-dot `StoryStepper` (active dot = warm-dark, done = teal, pending = clay-border)
- Scrollable form with 4 sections separated by `form-label` + content:
  1. Topic — 6 chips + free-text input
  2. Your level — 5 chips (pre-selected from profile)
  3. Character preference — 5 chips (default "Any")
  4. Specific context — optional textarea (3 rows)
- Fixed bottom: primary "Next →" button (clay-shadow style, teal bg, 2px warm-dark border, 3×3 shadow, Nunito 15px 700)

**Interactions:**
- Chips are single-select within each section, tap toggles active state
- Level chip pre-selects from `_userLevel`
- "Next →" disabled until topic selected; on tap → `provider.startFromCustom(...)` → same routing as library path

### 8.3 StoryChatScreen (`/story/chat`)

**Layout:**
- `StoryCharacterHeader` (chat app bar): avatar circle (40px, gradient bg, initial letter in Fredoka 18px 700) + name + role + "End ↗" button right side
- Session info strip (12px muted text): "Turn {count} · Free-form · End anytime"
- Persistence banner: if `persistenceError != null`, show red banner "⚠ Last message not saved — retrying…"
- `chat-scroll` (cream bg, padding 12×16):
  - Agent bubble (clay-white bg, clay-border, left-aligned, rounded with bottom-left 4px)
  - User bubble (teal bg, right-aligned, rounded with bottom-right 4px)
  - Inline `AssessmentCard` rendered directly below user bubbles where `turn.assessment != null`
- `ChatInputBar` at bottom (reuse existing widget with TTS disabled for MVP)

**Interactions:**
- Submit input → `provider.sendUserMessage(text)` → optimistic user bubble → loading indicator → assessment + ai bubble append
- At user turn 18 → show info toast "2 turns left — session will wrap up"; at user turn 20 → agent generates closing message, no further user input allowed, auto-navigate to `/story/summary` after agent reply
- "End ↗" button → ClayDialog confirm "End session now?" → `provider.endSession()` → navigate

### 8.4 StorySummaryScreen (`/story/summary`)

**Layout:**
- App bar: close (✕) + title "Session Complete"
- Scrollable body:
  - Trophy hero card: gradient gold→teal, 🏆 emoji, story title, "{turnCount} turns", big score "{avg}/100" (Fredoka 48px 800)
  - Radar card: "Performance breakdown" title + 3 horizontal bars (Accuracy / Naturalness / Complexity) averaged across all turns
  - Stats row: 3 stat cards (Turns / Duration / New words flagged)
  - Top corrections card: title "Top corrections" + 3 mistake rows, each with original (strikethrough red) / correction (bold green) / note / "💾 Save phrase" clay-button
  - CTA row: "Back to Home" (clay-white secondary) + "New story →" (teal primary)

**Interactions:**
- "Save phrase" per correction → `provider.saveCorrectionToVocab(improvement)` → writes to `/users/{uid}/savedItems/` with correct `sm2.*` nested schema (not flat `interval/easeFactor`), shows ephemeral ✓ toast
- "Back to Home" → `context.go('/home')`, clears activeSession
- "New story →" → `context.go('/story')`, clears activeSession

## 9. Visual design (Clay Design tokens)

All visual decisions use existing Clay Design tokens from `lib/core/theme/app_colors.dart`:

| Element | Token / value |
|---------|---------------|
| App background | `#FFF8F0` (cream) |
| Card background | `#FEFCF9` (clay-white) |
| Card border | `1.5px solid #E8DFD3` (clay-border) |
| Primary CTA | `#7ECEC5` bg (teal) + `2px solid #2D3047` border + `3px 3px 0 #2D3047` shadow |
| Quota pill | `#E8C77B` bg (gold) + Nunito 11px 700 |
| Hero gradient | `linear-gradient(135deg, #7ECEC5 → #A78BCA)` (teal → purple) |
| Title font | Fredoka 20px weight 700 color #2D3047 |
| Body font | Inter 13px weight 400 color #2D3047 |
| Button label font | Nunito 15px weight 700 color #2D3047 |
| Chip active | `#7ECEC5` bg + warm-dark border |
| Chip idle | `#F5EDE3` bg (clay-beige) |
| Level badge A2 | `#D6EBC7` bg |
| Level badge B1 | `#C7DDEB` bg |
| Radius tokens | sm=8, md=12, lg=20, full=9999 |

Mockups committed at:
- `docs/mockup-design/mockups-story-mode-entry.html`
- `docs/mockup-design/mockups-story-mode-custom-flow.html`
- `docs/mockup-design/mockups-story-mode-end-session.html`
- `docs/mockup-design/mockups-story-mode-quota.html`

## 10. Quota integration

Reuse existing `QuotaConstants.getLimit(tier, 'story')`:
- Free: 3 sessions/day
- Pro: 10 sessions/day
- Premium: unlimited (-1)

Charge point: `_incrementStoryQuota()` is called ONLY after `generateStoryScenario` returns successfully. If generation fails, quota is not charged.

Paywall trigger: `canStartSession()` returns false when `storyUsedToday >= limit` (and limit != -1). UI shows `PaywallDialog` with upgrade CTA → deep-link to Settings > Subscription (existing).

## 11. Testing strategy

### 11.1 Unit tests

- `StoryProvider.startFromLibrary` happy path + quota-exhausted + generation-fail
- `StoryProvider.startFromCustom` with each field combination
- `StoryProvider.sendUserMessage` appends user turn with assessment + ai turn; `turns[]` shape matches schema
- `StoryProvider.endSession` marks status and clears local cache
- `StoryProvider.init` auto-resumes from cached conversationId; clears stale cache if doc missing
- `StoryCache` fallback when Firestore offline

### 11.2 Integration tests (Firestore emulator)

- Full session lifecycle: start → 3 turns → end → summary data matches persisted doc
- Assessment round-trip: save user turn with full `AssessmentResult.toJson()`, re-read, verify `fromJson` recovers identical object
- Cold-start rehydration: save 5-turn in-progress session, destroy provider, re-init, verify 5 turns + all assessments render
- Quota enforcement: 3 consecutive library starts on free tier; 4th call returns false and shows paywall

### 11.3 Manual QA checklist

- [ ] Home Story card taps and navigates to `/story` (not silent no-op)
- [ ] Featured grid filters by user's CEFR level
- [ ] Custom flow 4 steps all editable, submit works with each field combination
- [ ] Chat screen: send 3+ user messages, each produces assessment card inline below user bubble
- [ ] Kill app mid-session, relaunch, "Continue last story" banner appears on `/story`, tap → chat restored with all messages + assessments
- [ ] Simulate Firestore offline → persistence banner appears red; coming back online → banner clears on next successful save
- [ ] End session → summary radar + stats + top 3 corrections render; tap Save phrase → item appears in My Library
- [ ] Hit turn 20 → agent sends closing message → auto-navigate to summary
- [ ] Free user: 3 sessions used → 4th tap shows paywall dialog

### 11.4 Explicit regression guards

- Snapshot test on `StorySession.toJson` — assessment lives under `turns[n].assessment`, never as separate turn
- Log assertion in dev build: if any `role='assessment'` turn is encountered, crash loudly (we are not doing Scenario's 3-message pattern)

## 12. Risks & mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Gemini generates story with wrong level (too hard / too easy) | Medium | Prompt includes explicit CEFR anchor + vocabulary ceiling; manual QA with A2 and B1 users |
| User chats 20+ turns hitting hard cap abruptly | Low | Warning toast at turn 18; agent prompted to wrap up at turn 19 |
| `/stories/{id}` Firestore read cost spikes if library grows | Low at 12 items | `StoryCache` caches library list locally; refresh once per day on init |
| User creates custom story with inappropriate topic | Medium | Gemini safety filters handle most; add client-side basic profanity check on free-text topic |
| Save-to-vocab writes conflict with existing Scenario save pattern | Low | Same `/savedItems` path; reuse existing `LibraryProvider.saveItem` method unchanged |
| App cold-start auto-resume shows stale/abandoned session | Medium | Auto-clear local cache if Firestore doc returns `status='completed'` or `status='abandoned'` |

## 13. Rollout

1. Seed `/stories/*` in dev Firebase project first; verify queries
2. Implement StoryProvider + datasource extensions behind no feature flag (this is the first ship of Story Mode, no existing users to protect)
3. Flip `home_screen.dart:178` Story card `route: null → '/story'` LAST, only after all 4 screens build and pass QA
4. Ship as part of a regular release (no phased rollout needed — blast radius limited to users who tap Story card)

## 14. Open questions (deferred)

These did not block design approval but should be revisited post-launch:
- Should library stories have a "play count" counter to surface popular ones?
- Should custom stories be savable/re-playable (add to "My Stories" in Profile)?
- Should character avatars evolve to AI-generated portraits (Cloudinary + style preset)?
- Should we track per-turn latency to detect Gemini slowdowns?

---

## 15. References

- Mockups: `docs/mockup-design/mockups-story-mode-*.html`
- Audit: `.auto-memory/project_aura_coach_state_2026_04_19.md`
- Business flow v2: `docs/business-flow/aura-coach-mobile-business-flows-v2.md`
- Reference impl: `lib/features/scenario/providers/scenario_provider.dart`
- Gemini service: `lib/data/gemini/gemini_service.dart` (methods `generateStoryScenario`, `evaluateStoryTurn` already implemented)
- Quota: `lib/core/constants/quota_constants.dart`
