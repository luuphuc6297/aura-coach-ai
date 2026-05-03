# Grammar Coach — Mode replacing Tone Translator

**Date:** 2026-04-29
**Owner:** Luu
**Status:** Spec finalized — ready for Phase A

---

## 1. Goal

Replace Tone Translator with **Grammar Coach**, a guided practice mode that:

1. Lists every English grammar topic / tense organized by CEFR level (A1 → C2).
2. Lets users pick a topic and study its rules + examples (Cambridge / Oxford reference standard).
3. Lets users pick a practice mode and grind exercises until they choose to stop.
4. Tracks mastery per topic and surfaces mistakes into the existing Library / SRS pipeline.

Tone Translator stays in code behind a feature flag — not deleted, not user-facing.

---

## 2. Locked decisions (from intake)

| # | Decision | Note |
|---|---|---|
| 1 | Tone Translator → keep behind feature flag | `featureFlags.toneTranslatorEnabled = false` (default) |
| 2 | Catalog scope = full A1 → C2 | ~55 topics, hand-curated |
| 3 | Practice modes = 3 user-selectable at session start | Translate · Fill-in-blank · Transform |
| 4 | Catalog source = Cambridge + Oxford grammar references | Curated in code, version-tracked |
| 5 | Daily quota = unlimited for now | Subscription gating deferred |
| 6 | Session length = open-ended | User taps "End session" when done |
| 7 | Save mistakes to Library = explicit button | Consistent with Vocab Hub UX |
| 8 | UX/visual lineage = trace from Story Mode + Vocab Hub | Same feature-card hub + sub-routes pattern |

---

## 3. Mode identity

- **Name:** Grammar Coach
- **Tagline (EN):** "Master English grammar by level. Pick a structure, practice with AI."
- **Tagline (VI):** "Làm chủ ngữ pháp tiếng Anh theo trình độ. Chọn cấu trúc, luyện với AI."
- **Accent color:** `AppColors.gold` (kế thừa từ Tone — palette stability, không cần thêm token)
- **Icon:** new Cloudinary asset `grammar-coach_<hash>.webp` — 3D clay illustration of an open book with checkmarks (TBD; placeholder = `Icons.menu_book_rounded` until artwork ships).
- **Badge text:** `STRUCTURED` (EN) / `CÓ HỆ THỐNG` (VI)

---

## 4. Grammar catalog (curated)

Source of truth: `lib/features/grammar/data/grammar_catalog.dart` — Dart constants, no AI generation. Each entry is a `GrammarTopic` (model in §6).

### 4.1 Level taxonomy (~55 topics)

#### A1 — Beginner
1. Verb "to be" (am/is/are)
2. Subject pronouns + possessive adjectives
3. Articles: a / an / the
4. Plural nouns
5. Present Simple
6. Present Continuous
7. Imperatives
8. Prepositions of place (in / on / at)
9. There is / there are
10. Question words (what / where / when / who)

#### A2 — Elementary
11. Past Simple (regular & irregular)
12. Future: "going to"
13. Future: "will" (predictions, offers)
14. Comparatives & Superlatives
15. Countable / Uncountable nouns
16. Quantifiers: some / any / much / many
17. Modal: can / can't (ability + permission)
18. Modal: must / mustn't
19. Modal: should / shouldn't
20. Adverbs of frequency
21. Object pronouns

#### B1 — Intermediate
22. Past Continuous
23. Present Perfect (introduction)
24. Present Perfect Continuous
25. Past Perfect
26. 1st Conditional
27. Passive Voice (Present + Past Simple)
28. Reported Speech (statements)
29. Relative Clauses (defining)
30. Gerund vs Infinitive
31. used to / would
32. Prepositions of time (in / on / at / for / since)

#### B2 — Upper-Intermediate
33. Past Perfect Continuous
34. Future Continuous
35. Future Perfect
36. 2nd Conditional
37. 3rd Conditional
38. Mixed Conditionals
39. Passive Voice (all tenses)
40. Reported Speech (questions, commands, requests)
41. Wishes & Regrets (I wish / If only)
42. Modals of Deduction (must / might / can't have)
43. Non-defining Relative Clauses
44. Causative: have / get something done
45. Linking words: although / despite / however

#### C1 — Advanced
46. Inversion (rarely / never / not only…)
47. Cleft Sentences (It is… that / What…)
48. Participle Clauses
49. Subjunctive (introductory)
50. Ellipsis & Substitution
51. Modal Perfect (would have / could have / should have)
52. Advanced Linking (notwithstanding, albeit, given that)

#### C2 — Proficient
53. Subjunctive (formal & literary)
54. Nuanced Inversion (negative + restrictive)
55. Idiomatic Structures (had I known…, were it not for…)

> Final catalog will be locked at start of Phase A. Reordering / additions allowed during curation, but level boundaries follow Cambridge English Grammar in Use mapping.

### 4.2 Topic schema (per entry)

Each `GrammarTopic` carries:

- `id` — slug, e.g. `present_perfect`
- `title` (EN), `titleVi` (VI)
- `level` — `CefrLevel` enum (a1..c2)
- `category` — `GrammarCategory` enum (tense, modal, conditional, passive, reported, articleQuantifier, clause, comparison, linkingInversion, other)
- `summary` — 1–2 sentences, EN + VI
- `formula` — the grammatical pattern (e.g. `S + have/has + V3`)
- `useCases` — bullet list of when to use it (Cambridge style)
- `examples` — 4–6 sentences, each with EN, VI, optional gloss
- `commonMistakes` — list of `{wrong, right, why}`
- `relatedTopicIds` — cross-links (e.g. Present Perfect ↔ Past Simple, Wishes ↔ 2nd Conditional)

---

## 5. UX flows

### 5.1 Entry from Home

Mode card "Grammar Coach" → tap → `/grammar` route.
Mode deep-dive card (existing `mode_deep_dive_card.dart` pattern) shows: hero illustration, "How it works" 3 steps, feature pills.

### 5.2 Grammar Hub (`/grammar`)

Layout traces **Vocab Hub Home Screen** (feature-card grid).

- Header: title "Grammar Coach", back button, search icon
- Hero strip: user's level pill (auto-selected from profile), short tagline
- **Filter row** (sticky, horizontal scroll):
  - All · A1 · A2 · B1 · B2 · C1 · C2
  - Default = user's CEFR level
- **Sub-filter chips** (optional, second row):
  - All categories · Tense · Modal · Conditional · Passive · Reported · Clause · Linking · Other
- **Topic grid** (2 columns on phone, 1 row per topic on smaller widths):
  - Each card: title, level pill, category pill, mastery ring (0–100%), accuracy %, "Last practiced X ago"
  - Tap → Topic Detail
- **Empty state** for current filter combo: "No topics at this level yet — check back as we expand C2."

### 5.3 Topic Detail (`/grammar/:topicId`)

Same shell as Vocab Hub Word Analysis screen — full-page scroll, gold accent.

- Header: topic title, level pill, category pill, back button
- **Summary card**: formula + summary (EN + VI toggle)
- **When to use** section: bullet list
- **Examples** section: each example as a clay card with EN sentence, VI gloss, "Listen" TTS button (reuse TtsService)
- **Common mistakes** section: each as a soft warning card (`wrong → right + why`)
- **Related topics** chip row (tappable cross-links)
- **Bottom CTA**: full-width gold ClayButton "Start practice" → opens **Practice mode picker** sheet

### 5.4 Practice mode picker (bottom sheet)

Sheet with 3 ClayPressable cards:

1. **Translate**
   - Subtitle (EN): "EN ↔ VI sentence translation using this structure"
   - Subtitle (VI): "Dịch câu EN ↔ VI dùng cấu trúc này"
   - Icon: `Icons.translate_rounded`
2. **Fill in the blank**
   - Subtitle (EN): "Pick the correct form to complete the sentence"
   - Subtitle (VI): "Chọn dạng đúng để điền vào câu"
   - Icon: `Icons.edit_rounded`
3. **Transform**
   - Subtitle (EN): "Rewrite an English sentence into the correct tense, given a Vietnamese hint"
   - Subtitle (VI): "Viết lại câu tiếng Anh đúng thì, dựa trên gợi ý tiếng Việt"
   - Icon: `Icons.swap_horiz_rounded`

Tap one → `/grammar/:topicId/practice?mode=<modeId>`.

### 5.5 Practice screen (`/grammar/:topicId/practice`)

Open-ended session loop. Layout traces **Scenario Chat Screen** (header with progress strip, body with current exercise card, footer with input).

- **Header**:
  - Back button (with end-session confirm dialog if attempts > 0)
  - Topic title + level pill
  - Mode badge (Translate / Fill-blank / Transform)
  - Live counters: attempts, accuracy %, current streak
- **Body** (animated transitions between exercises):
  - **Translate mode**:
    - Prompt card: source sentence (auto direction: EN→VI or VI→EN, alternating)
    - Input: ClayTextInput, multi-line
    - Submit button: gold "Check"
  - **Fill-in-blank mode**:
    - Prompt card: sentence with `_____` blank, optional Vietnamese hint below
    - Input: single-line ClayTextInput OR 4-option multiple choice (AI decides per exercise; default = text input for production practice)
    - Submit button: gold "Check"
  - **Transform mode**:
    - Prompt card: base English sentence (neutral form) + Vietnamese rendering using target grammar
    - Instruction: "Rewrite the English sentence using **<topic name>**"
    - Input: ClayTextInput, multi-line
    - Submit button: gold "Check"
- **After Check**:
  - Result card slides in: ✓ Correct / ✗ Incorrect
  - Shows: user answer · correct answer · feedback (1–2 sentences)
  - Buttons: "Save to Library" (only on incorrect, explicit), "Next exercise" (gold)
- **Footer end-session bar**:
  - "End session" button → confirm dialog → summary screen
  - Visible always, sticky bottom

### 5.6 Practice summary screen (`/grammar/:topicId/practice/summary`)

Reused pattern from `session_summary_screen.dart`:

- Score circle (accuracy %)
- Stats row: total attempts, correct, mastery delta
- Top mistakes list — tap to "Save to Library" (batch button "Save all")
- Per-exercise breakdown (collapsed list)
- CTAs:
  - "Practice again" (returns to mode picker)
  - "Back to topic"
  - "Browse other topics"

---

## 6. Data model

### 6.1 Domain models — `lib/features/grammar/models/`

```dart
// grammar_topic.dart
enum CefrLevel { a1, a2, b1, b2, c1, c2 }
enum GrammarCategory {
  tense, modal, conditional, passive, reported,
  articleQuantifier, clause, comparison, linkingInversion, other
}

class GrammarTopic {
  final String id;
  final String title, titleVi, summary, summaryVi, formula;
  final CefrLevel level;
  final GrammarCategory category;
  final List<String> useCases, useCasesVi;
  final List<GrammarExample> examples;
  final List<GrammarMistake> commonMistakes;
  final List<String> relatedTopicIds;

  const GrammarTopic({...});
}

class GrammarExample {
  final String en, vi;
  final String? gloss; // optional grammatical highlight
}

class GrammarMistake {
  final String wrong, right, why;
}
```

```dart
// grammar_exercise.dart
enum GrammarPracticeMode { translate, fillBlank, transform }
enum GrammarExerciseDirection { enToVi, viToEn } // for translate mode

class GrammarExercise {
  final String id, topicId;
  final GrammarPracticeMode mode;
  final String prompt;          // sentence shown to user
  final String? hint;           // VI hint for transform / blank
  final GrammarExerciseDirection? direction; // translate only
  final List<String>? options;  // multiple-choice; null = free text
  final String correctAnswer;
  final String explanation;     // post-check feedback
}

class GrammarPracticeAttempt {
  final String id, topicId, exerciseId, sessionId;
  final GrammarPracticeMode mode;
  final String prompt, userAnswer, correctAnswer;
  final bool isCorrect;
  final double score; // 0..1, useful for fuzzy translate matching
  final String feedback;
  final int timestamp;
}

class UserGrammarProgress {
  final String topicId;
  int attemptCount, correctCount;
  double accuracy;       // 0..1
  double masteryScore;   // 0..1, SM-2 derived
  double easeFactor;
  int interval;
  int reviewCount;
  int? lastPracticedAt;
  int? nextReviewAt;
}
```

### 6.2 Firestore schema

```
users/{uid}/grammarProgress/{topicId}        — UserGrammarProgress
users/{uid}/grammarAttempts/{attemptId}      — GrammarPracticeAttempt
users/{uid}/grammarSessions/{sessionId}      — { topicId, mode, startedAt, endedAt, totalCount, correctCount }
```

Firestore rules: extend existing user-scoped rules to include these subcollections (read/write only own).

### 6.3 Catalog — local Dart constants

`lib/features/grammar/data/grammar_catalog.dart`:

```dart
abstract final class GrammarCatalog {
  static const List<GrammarTopic> all = [
    GrammarTopic(
      id: 'present_simple',
      title: 'Present Simple',
      titleVi: 'Hiện tại đơn',
      level: CefrLevel.a1,
      category: GrammarCategory.tense,
      formula: 'S + V(s/es) + O',
      summary: 'Used for habits, general truths, and scheduled events.',
      summaryVi: 'Dùng cho thói quen, sự thật, và lịch trình.',
      ...
    ),
    // 54 more
  ];

  static GrammarTopic byId(String id) =>
      all.firstWhere((t) => t.id == id);

  static List<GrammarTopic> byLevel(CefrLevel level) =>
      all.where((t) => t.level == level).toList();
}
```

55 topics × ~12 fields each = sizable file. Splitting strategy: one file per level (e.g. `grammar_a1.dart`, `grammar_a2.dart`) re-exported from a barrel `grammar_catalog.dart`. Keeps each file ~200 LOC.

---

## 7. AI integration (Gemini)

Two endpoints, both via existing `GeminiService` plumbing. Use **Gemini Flash** (memory note) with 30s timeout. All responses validated against JSON schemas — fail closed on parse error (fall back to "Try another exercise").

### 7.1 `generateExercise`

**Input** (assembled by `GrammarProvider`):
- topicId
- topic title + formula + 2 example sentences (for AI grounding)
- practiceMode (`translate` / `fillBlank` / `transform`)
- userLevel (CEFR)
- recentMistakeFingerprints — last 3 wrong answer patterns from current session (so AI varies the difficulty)
- requestedDirection — `enToVi` / `viToEn` (translate only; alternates 50/50)

**Schema (response JSON)**:
```json
{
  "prompt": "string",
  "hint": "string | null",
  "direction": "enToVi | viToEn | null",
  "options": ["string", ...] | null,
  "correctAnswer": "string",
  "alternateCorrectAnswers": ["string", ...],
  "explanation": "string"
}
```

**Prompt skeleton** (per mode):

- **Translate**:
  > Generate a B1-level translation exercise for "Present Perfect". Direction: EN→VI.
  > Source: an English sentence (~12 words) that NATURALLY uses Present Perfect.
  > Output JSON: `prompt` = English sentence, `correctAnswer` = natural Vietnamese translation, `alternateCorrectAnswers` = 1–2 acceptable variants, `explanation` = why this tense fits (1 sentence in Vietnamese).
  > Constraint: do not reuse vocab from these recent prompts: …

- **Fill in the blank**:
  > Generate an A2-level fill-in-the-blank for "Past Simple".
  > Output: `prompt` = sentence with one `_____`, the blank position requires a target-tense conjugation. `hint` = base form of the verb in parentheses, e.g. "(go)". `correctAnswer` = inflected form. `options` = optional 4-multiple-choice with 1 right + 3 plausible distractors. `explanation` = why this form (1 sentence).

- **Transform**:
  > Generate a B2-level transform exercise for "3rd Conditional".
  > Output: `prompt` = an English sentence in NEUTRAL/base form (e.g. "I didn't study, so I failed."). `hint` = Vietnamese rendering using target grammar (e.g. "Nếu tôi đã học thì tôi đã không trượt."). `correctAnswer` = correct English transformation ("If I had studied, I wouldn't have failed."). `alternateCorrectAnswers` = up to 2 acceptable variants. `explanation` = grammatical reasoning (1 sentence in Vietnamese).

### 7.2 `evaluateAnswer`

**Input**:
- userAnswer (raw string)
- exercise (the full `GrammarExercise` object)
- topic title + formula

**Schema (response JSON)**:
```json
{
  "isCorrect": true,
  "score": 1.0,
  "matchedAnswer": "string",
  "feedback": "string",
  "correctedAnswer": "string | null",
  "errorType": "tense | spelling | wordOrder | vocab | other | null"
}
```

**Logic**:
- For multiple-choice: client-side exact match, no AI call.
- For fill-blank with single-form expected: client checks `correctAnswer` + `alternateCorrectAnswers` exact-match (case insensitive, whitespace trimmed); only fall to AI if the user's answer matches none of them but the AI deems it semantically correct (e.g. acceptable contraction).
- For translate / transform / fill-blank with longer answers: always AI evaluate. Score is 0..1 (handles partial correctness — wrong tense but right vocab might be 0.5).
- `isCorrect` = score ≥ 0.85 — surfaced as "Correct" in UI; lower = "Almost / Incorrect" with feedback.

### 7.3 Prompt safety + caching

- Prompts include "respond ONLY with valid JSON, no markdown fences" guard.
- All AI responses validated against schema using existing `JsonSchemaValidator` pattern.
- No cross-session caching of exercises (we want variety); within-session do NOT regenerate same prompt twice — track recent IDs.

---

## 8. Feature flag (Tone Translator)

Add to existing config:

`lib/core/config/feature_flags.dart`:
```dart
abstract final class FeatureFlags {
  static const bool toneTranslatorEnabled = false;
  static const bool grammarCoachEnabled = true;
  // ...future flags
}
```

Behavior:
- Home `_buildModes(context)` returns Tone card only when `FeatureFlags.toneTranslatorEnabled == true`.
- Conversation history filter row hides "Translator" chip when flag off.
- Storage quota banner skips `tone` mode in breakdown when flag off.
- Existing user data with `mode == 'tone'` stays readable (don't break old conversation history docs).

Code under `lib/features/tone/` + the Tone deep-dive data + `modeTone*` ARB keys all stay in place — just unreachable from UI.

---

## 9. Tone → Grammar replacement checklist

### 9.1 Files to add

```
lib/core/config/feature_flags.dart
lib/features/grammar/
  data/
    grammar_catalog.dart              (barrel)
    grammar_a1.dart .. grammar_c2.dart
  models/
    grammar_topic.dart
    grammar_exercise.dart
    grammar_progress.dart
    grammar_session.dart
  providers/
    grammar_provider.dart
  services/
    grammar_gemini_service.dart       (wraps GeminiService for the 2 endpoints)
  screens/
    grammar_hub_screen.dart
    grammar_topic_detail_screen.dart
    grammar_practice_screen.dart
    grammar_practice_summary_screen.dart
  widgets/
    grammar_topic_card.dart
    grammar_level_filter.dart
    grammar_category_filter.dart
    grammar_exercise_card.dart
    grammar_result_card.dart
    grammar_practice_mode_picker.dart
docs/superpowers/plans/2026-04-29-grammar-mode.md (this file)
docs/mockups/2026-04-29-grammar-mode.html (HTML mockup, Phase A2)
```

### 9.2 Files to edit

```
lib/app.dart                                              + GoRoutes /grammar/*
lib/features/home/models/mode_deep_dive_data.dart         + Grammar deep-dive entry
lib/features/home/screens/home_screen.dart                + Grammar mode card (gated by flag)
lib/features/scenario/screens/conversation_history_screen.dart  + 'grammar' filter; tone filter hidden behind flag
lib/features/shared/providers/storage_quota_provider.dart + perMode 'grammar' label
lib/shared/widgets/storage_quota_banner.dart              + 'grammar' breakdown label
lib/l10n/app_en.arb + lib/l10n/app_vi.arb                 + ~30 new modeGrammar* + grammarHub* + grammarPractice* keys
firestore.rules                                            + grammarProgress / grammarAttempts / grammarSessions
```

### 9.3 i18n keys (initial set)

```
modeGrammarTitle, modeGrammarDescription, modeGrammarBadge, modeGrammarCta, modeGrammarQuota
grammarHubTitle, grammarHubFilterAll, grammarHubFilterByLevel, grammarHubFilterByCategory
grammarTopicLevelPill (placeholder), grammarTopicMastery (placeholder)
grammarTopicSummaryTitle, grammarTopicFormulaLabel, grammarTopicWhenToUse,
grammarTopicExamples, grammarTopicCommonMistakes, grammarTopicRelated
grammarStartPracticeCta
grammarPracticeModeTitle, grammarPracticeModeTranslate, grammarPracticeModeFillBlank, grammarPracticeModeTransform
grammarPracticeCheck, grammarPracticeNext, grammarPracticeEndSession,
grammarPracticeSaveToLibrary, grammarPracticeSaved
grammarResultCorrect, grammarResultIncorrect, grammarResultExplanationLabel
grammarSummaryTitle, grammarSummaryAccuracy, grammarSummaryAttempts, grammarSummaryMistakesTitle
grammarSummaryPracticeAgain, grammarSummaryBackToTopic, grammarSummaryBrowseOthers
conversationHistoryFilterGrammar (replaces Translator filter when flag on)
storageQuotaModeGrammar
```

---

## 10. Phasing

| Phase | Deliverable | Estimate |
|---|---|---|
| **A1** | Lock catalog (titles + level + category + formula for all 55 topics) | 0.5d |
| **A2** | HTML mockup (Hub + Topic Detail + Practice + Summary) | 0.5d |
| **A3** | Full catalog content (summary, formula, useCases, examples, commonMistakes, related) per topic | 1.5d |
| **B1** | Models (`GrammarTopic`, `GrammarExercise`, `GrammarPracticeAttempt`, `UserGrammarProgress`) | 0.5d |
| **B2** | `GrammarProvider` (hub state, topic loading, session lifecycle, attempt logging) | 0.5d |
| **B3** | Firestore datasource methods + rules update | 0.5d |
| **C** | Grammar Hub screen (filter, search, topic cards) | 1d |
| **D** | Topic Detail screen (Learn content + CTA) | 1d |
| **E1** | Practice screen scaffold + Translate mode (incl. Gemini wiring) | 1.5d |
| **E2** | Fill-in-blank mode | 0.5d |
| **E3** | Transform mode | 0.5d |
| **F** | Result card + explicit Save-to-Library button + summary screen | 0.5d |
| **G** | SRS integration (re-use SM-2 from flashcards), mastery rollups | 0.5d |
| **H** | Tone feature flag, replacement plumbing across Home / Routes / History / Quota | 0.5d |
| **I1** | i18n EN + VI for ~30 keys | 0.5d |
| **I2** | Dark mode tokens (should be free if we trace from Story / Vocab Hub patterns; verify) | 0.25d |
| **J** | Verify: `flutter analyze` + smoke per level + per practice mode + flag toggle test | 0.5d |

Total: ~10–11 working days at sustained pace.

---

## 11. Verification plan

### 11.1 Static
- `flutter analyze` returns 0 warnings.
- All ARB keys present in both `app_en.arb` and `app_vi.arb`; `flutter gen-l10n` clean.
- No `AppColors.cream/clayWhite/clayBeige/clayBorder/warmDark/warmMuted/warmLight/clayShadow` in `lib/features/grammar/` (dark mode discipline).

### 11.2 Smoke (manual)
- Toggle theme: Grammar Hub + Topic Detail + Practice + Summary all flip cleanly.
- Toggle language: every label re-renders in VI; AI prompts still produce valid output.
- Walk catalog: every level filter has ≥ 1 topic; every topic detail loads; every related-topic chip navigates correctly.
- Walk practice modes: Translate · Fill-blank · Transform each generates 3 valid exercises and evaluates them.
- Test "End session early" → confirms via dialog → summary screen.
- Test "Save to Library" on a wrong answer → item appears in Library with `type: 'grammar'`.
- Test feature flag: set `toneTranslatorEnabled = true` → Tone card reappears on Home, history filter shows Translator chip.

### 11.3 Edge cases to cover
- AI returns malformed JSON → user sees "Couldn't load — try another" + retry button.
- Network timeout (>30s) → same fallback.
- User tries to end session with 0 attempts → no summary, just pop back.
- User saves same mistake twice → idempotent (Library dedupes by content).
- User leaves practice mid-exercise (system back / app backgrounded) → in-flight attempt marked incomplete, no double-counting.
- Topic with 0 progress yet → mastery card shows "Not started", no SRS noise.

---

## 12. Open items (non-blocking, can resolve during phases)

1. **Grammar Coach icon artwork** — placeholder until Cloudinary asset shipped. Phase H can be replaced post-launch.
2. **Catalog reviewer** — Luu reviews catalog content before Phase B starts (lock it). Catalog v1 = my drafts based on Cambridge Grammar in Use + Oxford Practice Grammar; Luu signs off.
3. **Streak / daily-goal integration** — Grammar practice should count toward existing daily-time analytics. Audit `AnalyticsProvider` in Phase G.
4. **Offline mode** — for catalog content yes (it's local), for AI exercises no. Add an `error` state when network unreachable. Phase E1.
5. **TTS on examples** — reuse `TtsService.speakEnglish`. Add `TtsService.speakVietnamese`? Existing service may not support; check in Phase D.

---

**Ready to start Phase A** when Luu signs off on this spec.
