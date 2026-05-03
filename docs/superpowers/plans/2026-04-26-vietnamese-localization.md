# Vietnamese Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a real, end-to-end Vietnamese (`vi`) language option driven by the existing `SettingsProvider.language` toggle. Every user-facing UI string switches to Vietnamese; AI-generated content (dictionary, conversation, story prose) stays English because that's the learning target.

**Architecture:** Foundation already exists — `flutter_localizations` + `intl` are in pubspec, `l10n.yaml` is configured, `lib/l10n/app_en.arb` and `app_vi.arb` exist with 21 keys, and `lib/l10n/app_localizations.dart` is generated. Wire `MaterialApp.locale` to `SettingsProvider.language`, migrate the remaining ~318 hardcoded strings into ARB keys, translate the new keys, and restore the picker in Settings.

**Tech Stack:** flutter_localizations, intl 0.20, gen-l10n codegen, existing SettingsProvider/SharedPreferences, Provider.

**Scope (measured):**
- 339 hardcoded strings (`Text("...")`, `hintText:`, `label:`, `title:`, `content:`, `tooltip:`)
- Of those, 21 already in ARB → ~318 to migrate
- 1 missing wire — `MaterialApp.locale` not bound to SettingsProvider yet
- 1 stub to remove — `_ComingSoonRow('Display language')` in `settings_screen.dart`
- ~100+ files touched (every screen with copy)

**Out of scope:**
- AI-generated content (Gemini dictionary, scenario lines, story prose, mindmap labels) — stays English; that's the language being learned
- System notification body strings already get formatted via NotificationTriggers — needs evaluation per kind
- Vietnamese-specific number / date formatting (intl handles automatically once locale is bound)

---

## File Structure

**New files:** none — scaffolding already in place.

**Modified — foundation:**
- `lib/app.dart` — wire `MaterialApp.locale` + `localizationsDelegates` + `supportedLocales`
- `lib/features/profile/screens/settings_screen.dart` — replace `_ComingSoonRow` for Display Language with real picker
- `lib/features/profile/providers/settings_provider.dart` — verify `setLanguage` exists (it does per Task #118)

**Modified — ARB files:**
- `lib/l10n/app_en.arb` — add new keys for every migrated string
- `lib/l10n/app_vi.arb` — translate every new key
- `lib/l10n/app_localizations*.dart` — auto-regenerated via `flutter gen-l10n`

**Migrated by feature (string counts approximate, will sharpen during inventory):**
- `lib/features/auth/**` — ~15 strings
- `lib/features/onboarding/**` — ~30 strings (most already in ARB)
- `lib/features/home/**` — ~25 strings (BottomNav, header, mode cards)
- `lib/features/profile/**` — ~50 strings (Settings rows, dialogs, Privacy doc, Edit Profile)
- `lib/features/my_library/**` — ~30 strings
- `lib/features/vocab_hub/**` — ~50 strings
- `lib/features/scenario/**` — ~30 strings
- `lib/features/story/**` — ~25 strings
- `lib/features/tone_translator/**` — ~20 strings
- `lib/features/notifications/**` — ~15 strings
- `lib/features/ai_agent/**` — ~20 strings
- `lib/features/insights/**` — ~25 strings
- Shared dialogs / banners / error states — ~15 strings

---

## Naming Conventions

ARB key style: `feature_screen_role`, snake_case lowercase. Examples:
- `library_search_hint` — search input hint on My Library
- `settings_dark_mode_label` — row label in Settings
- `flashcards_empty_title` — empty-state title
- `auth_continue_with_google` — primary button
- `common_cancel`, `common_save`, `common_delete` — shared verbs (use sparingly to avoid mistranslation in context)

For parameterized strings, use intl placeholders:
```json
"library_due_count": "{count, plural, =0{No items due} =1{1 item due} other{{count} items due}}",
"library_due_count": {
  "placeholders": { "count": { "type": "int" } }
}
```

---

## Task 1: Wire MaterialApp.locale + delegates

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Read current MaterialApp config**

Read `lib/app.dart` lines 425-450 to confirm where MaterialApp is built. The existing line:
```dart
themeMode: settings.themeMode,
```
exists. Confirm `localizationsDelegates`, `supportedLocales`, and `locale` are NOT yet present.

- [ ] **Step 2: Add the delegates and locale binding**

In the MaterialApp.router config, after `themeMode:`, add:

```dart
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
],
supportedLocales: const [
  Locale('en'),
  Locale('vi'),
],
locale: _localeFromCode(settings.language),
```

Add the helper at file scope:
```dart
Locale? _localeFromCode(String code) {
  switch (code) {
    case 'vi': return const Locale('vi');
    case 'en': return const Locale('en');
    default:   return null; // null → follow system
  }
}
```

Add imports at the top of `lib/app.dart`:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
```

- [ ] **Step 3: Verify codegen + build**

Run: `flutter gen-l10n`
Expected: regenerates `lib/l10n/app_localizations*.dart` cleanly.

Run: `flutter analyze lib/app.dart`
Expected: PASS.

Run: `flutter run`
Expected: app launches with English UI (default) — no visible change yet because `SettingsProvider.language` defaults to `'en'` and no strings have been migrated.

- [ ] **Step 4: Commit**

```bash
git add lib/app.dart lib/l10n/
git commit -m "feat(i18n): wire MaterialApp.locale to SettingsProvider.language

Adds AppLocalizations + Material/Cupertino/Widgets delegates and
binds locale to the existing SettingsProvider toggle. Strings migrated
in subsequent commits."
```

---

## Task 2: String inventory pass

Before bulk migration, build the full key inventory in `app_en.arb`. This locks the naming schema and lets us translate `app_vi.arb` in chunks instead of round-tripping per-screen.

**Files:**
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Walk every feature folder and extract strings**

For each feature folder (in this order: auth, onboarding, home, profile, my_library, vocab_hub, scenario, story, tone_translator, notifications, ai_agent, insights), run:

```bash
grep -rnE "(Text\(\s*['\"]|hintText:\s*['\"]|labelText:\s*['\"]|title:\s*['\"]|content:\s*['\"]|tooltip:\s*['\"])" lib/features/<feature>/ --include="*.dart"
```

For each match:
1. Extract the literal string
2. Generate a semantic key following the naming convention
3. Add to `app_en.arb` with the exact source string as the value
4. Add a `@key` metadata entry with description + placeholder spec if parameterized

Example additions:
```json
{
  "library_title": "My Learning Library",
  "@library_title": {
    "description": "Title shown at the top of the My Library screen"
  },

  "library_search_hint": "Search saved items",
  "@library_search_hint": {
    "description": "Placeholder text in the library search input"
  },

  "library_total_items": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@library_total_items": {
    "description": "Stats row — total saved items count",
    "placeholders": { "count": { "type": "int" } }
  },

  "library_due_count": "{count, plural, =0{0 due} =1{1 due} other{{count} due}}",
  "@library_due_count": {
    "placeholders": { "count": { "type": "int" } }
  }
}
```

DO NOT migrate code yet. This is inventory-only.

- [ ] **Step 2: Skip strings that should stay code-side**

Don't add ARB keys for:
- Debug `debugPrint` strings
- Asset URLs / IDs
- Firestore field names
- LLM prompt text (system instructions, schema descriptors)
- Test data / fixture strings

- [ ] **Step 3: Sort the ARB file by key**

This makes diffs reviewable and translation chunks predictable. Use `python3 -c "import json,sys; d=json.load(open('lib/l10n/app_en.arb')); print(json.dumps({k:d[k] for k in sorted(d)}, ensure_ascii=False, indent=2))" > /tmp/sorted.arb && mv /tmp/sorted.arb lib/l10n/app_en.arb`.

- [ ] **Step 4: Run codegen + analyze**

Run: `flutter gen-l10n`
Run: `flutter analyze lib/l10n/`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "i18n(en): inventory all user-facing strings into ARB

~318 new keys covering every feature screen. Translations to
app_vi.arb land in the next commit; code migration follows."
```

---

## Task 3: Translate `app_vi.arb`

Vietnamese translation must be UX-aware, not mechanical. App is for English learners; copy must feel native to a Vietnamese speaker but preserve any English terms that are part of the learning material (e.g. "flashcards" can stay English in onboarding context, but "Lưu" instead of "Save" is correct).

**Files:**
- Modify: `lib/l10n/app_vi.arb`

- [ ] **Step 1: Translate by feature chunk**

Open both ARB files side-by-side. For every key in `app_en.arb`, add the same key with translated value to `app_vi.arb`.

Translation rules:
- Tone: friendly, second-person ("bạn"). Match the existing 21 onboarding keys for voice consistency.
- Length: VI is usually 20-40% longer than EN. If a string is on a tight UI (chip, button, badge), consider a shorter VI alternative or note the layout risk.
- Plurals: VI doesn't have grammatical plural — use the `other` branch only:
  ```json
  "library_total_items": "{count, plural, other{{count} mục đã lưu}}"
  ```
- Brand / mode names stay English: "Aura", "Vocab Hub", "Scenario Coach", "Tone Translator", "Story Mode" — don't translate.
- CEFR levels stay: "A1 / A2", "B1 / B2", "C1 / C2".
- Domain terms can stay English when they ARE the learning content: "phonetic", "synonym", "POS", "stress" — but UI labels around them should be VI: "Cách phát âm", "Từ đồng nghĩa".

- [ ] **Step 2: Review chunk by chunk**

After translating each feature's keys, walk through manually:
- Does any VI translation read awkwardly?
- Any cultural mismatches (e.g. button copy that's too formal/too casual)?
- Any UI risk where length will break a chip / badge / single-line CTA?

For length-risk keys, leave a `## Layout note: ...` comment in the description.

- [ ] **Step 3: Run codegen + analyze**

Run: `flutter gen-l10n`
Expected: VI generates without missing-key warnings.

Run: `flutter analyze`
Expected: PASS.

- [ ] **Step 4: Smoke test by force-setting `language: 'vi'`**

Temporarily edit `SettingsProvider` default to `'vi'`. Run the app. Most strings still hardcoded — but the few already migrated (the 21 onboarding keys + any used in the scaffolding) should render Vietnamese. Revert.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_vi.arb
git commit -m "i18n(vi): translate all keys

UX-aware translations preserving brand / mode names and CEFR labels.
Length-risk strings noted in @key descriptions for layout review."
```

---

## Task 4: Migrate strings — Auth, Onboarding, Home

Smallest feature areas first; proves the end-to-end pipeline works before tackling bigger surfaces.

**Files:**
- `lib/features/auth/**`
- `lib/features/onboarding/**`
- `lib/features/home/**`

- [ ] **Step 1: Migrate per file**

For each `Text("...")` / `hintText: "..."` / etc., replace with `AppLocalizations.of(context)!.<keyName>`.

Pattern:
```dart
// before
Text('Search saved items')

// after
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// or, depending on l10n.yaml output:
import '../../../l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.librarySearchHint)
```

(ARB key `library_search_hint` → generated getter `librarySearchHint` — gen-l10n camelCases it.)

For parameterized:
```dart
// before
Text('${count} items')

// after
Text(AppLocalizations.of(context)!.libraryTotalItems(count))
```

Common helper to reduce noise:
```dart
extension AppLocContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
```
Then use `context.loc.librarySearchHint`.

Define this extension in `lib/l10n/app_loc_context.dart` and import it where needed.

- [ ] **Step 2: Add the extension helper**

```dart
// lib/l10n/app_loc_context.dart
import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension AppLocContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
```

- [ ] **Step 3: Migrate strings file-by-file**

Per file: read → replace each literal with `context.loc.<key>` → confirm import added.

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/features/auth/ lib/features/onboarding/ lib/features/home/`
Expected: PASS.

- [ ] **Step 5: Smoke test in BOTH locales**

Force `language: 'vi'`, run, walk Auth → Onboarding → Home. Verify:
- All copy is Vietnamese
- No string keys leak (e.g. `librarySearchHint` literal showing instead of translated)
- No layout breaks from longer VI strings

Force `language: 'en'`, repeat — confirm English still correct.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/ lib/features/onboarding/ lib/features/home/ lib/l10n/app_loc_context.dart
git commit -m "i18n: migrate auth + onboarding + home strings to AppLocalizations"
```

---

## Task 5: Migrate Profile + Settings + Privacy + Subscription

These are where the language picker actually lives — high priority for the user to see their toggle take effect.

**Files:**
- `lib/features/profile/**` (all screens + widgets)

- [ ] **Step 1: Migrate strings**

Same per-file recipe as Task 4. Settings rows have many small labels; translate carefully so each row label fits its row width.

- [ ] **Step 2: Privacy doc**

`lib/features/profile/screens/privacy_screen.dart` has 5 long sections of body copy. Each section = one ARB key (long string). VI translation should be reviewed by a human before commit; flag in PR.

- [ ] **Step 3: Edit Profile**

`lib/features/profile/screens/edit_profile_screen.dart` — section labels ("YOUR BUDDY", "YOUR NAME", etc.), name input hint, Discard dialog title/body, snackbar copy, level / daily-goal labels.

- [ ] **Step 4: Verify + smoke test**

Same pattern. Pay attention to: dialog titles, snackbar messages (VI is longer, may need 2-line snackbar).

- [ ] **Step 5: Commit**

```bash
git add lib/features/profile/
git commit -m "i18n: migrate profile + settings + privacy strings"
```

---

## Task 6: Migrate remaining feature areas

Repeat the same procedure:

- [ ] **my_library** — `lib/features/my_library/**`
- [ ] **vocab_hub** — `lib/features/vocab_hub/**` (largest area, multi-tab)
- [ ] **scenario** — `lib/features/scenario/**`
- [ ] **story** — `lib/features/story/**`
- [ ] **tone_translator** — `lib/features/tone_translator/**`
- [ ] **notifications** — `lib/features/notifications/**`
- [ ] **ai_agent** — `lib/features/ai_agent/**` (Help Center categories + canned responses — translate carefully)
- [ ] **insights** — `lib/features/insights/**`

For each, follow Task 4's recipe: token replacement → verify → smoke test → commit.

After each commit, the language picker (still stubbed, restored in Task 8) will be exercising more of the app surface. Don't proceed to the next feature until the previous one renders correctly in BOTH locales.

---

## Task 7: Audit pass — find leftover hardcoded strings

- [ ] **Step 1: Search for remaining literals**

Run:
```bash
grep -rnE "(Text\(\s*['\"][A-Z][a-z])" lib/features/ --include="*.dart" | grep -v "// "
```
(The `[A-Z][a-z]` filter narrows to likely user-facing English copy and skips identifiers / debug strings.)

For every match, decide:
- It's user-facing UI → migrate to ARB
- It's debug / asset / system → leave with a `// not user-facing` comment

- [ ] **Step 2: Verify**

Run: `flutter analyze`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add lib/
git commit -m "i18n: audit pass — clean up leftover hardcoded strings"
```

---

## Task 8: Restore the Display Language picker in Settings

**Files:**
- Modify: `lib/features/profile/screens/settings_screen.dart`

- [ ] **Step 1: Replace the stub row**

Find the `_ComingSoonRow` for "Display language" in `settings_screen.dart`. Replace with:

```dart
_ValueRow(
  icon: Icons.language_rounded,
  accent: AppColors.purple,
  label: context.loc.settingsLanguageLabel, // "Display language" / "Ngôn ngữ hiển thị"
  value: _languageLabel(settings.language),
  onTap: () => _pickLanguage(context),
),
```

Add helpers:
```dart
String _languageLabel(String code) {
  switch (code) {
    case 'vi': return 'Tiếng Việt';
    case 'en': return 'English';
    default:   return 'System';
  }
}

Future<void> _pickLanguage(BuildContext context) async {
  final settings = context.read<SettingsProvider>();
  final picked = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.clay.surface, // (or AppColors.clayWhite if dark mode not yet shipped)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in const ['en', 'vi'])
            ListTile(
              title: Text(_languageLabel(code)),
              trailing: settings.language == code
                  ? const Icon(Icons.check, color: AppColors.purple)
                  : null,
              onTap: () => Navigator.of(ctx).pop(code),
            ),
        ],
      ),
    ),
  );
  if (picked == null) return;
  await settings.setLanguage(picked);
}
```

- [ ] **Step 2: Verify SettingsProvider has `setLanguage(String)`**

Read `lib/features/profile/providers/settings_provider.dart`. Should already exist per Task #118. If missing:
```dart
Future<void> setLanguage(String code) async {
  if (_language == code) return;
  _language = code;
  notifyListeners();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', code);
}
```

- [ ] **Step 3: Smoke test the toggle**

Run: `flutter run`
- Open Settings → Display language → pick Tiếng Việt → every screen flips to VI immediately
- Background app, force-stop, reopen → still VI (persistence)
- Pick English → flips back

- [ ] **Step 4: Commit**

```bash
git add lib/features/profile/screens/settings_screen.dart lib/features/profile/providers/settings_provider.dart
git commit -m "feat(settings): restore real Display Language picker

English / Tiếng Việt options. Persists via SharedPreferences,
flips MaterialApp.locale reactively, every migrated screen
re-resolves through AppLocalizations."
```

---

## Task 9: End-to-end verification

- [ ] **Step 1: Cold-launch in each locale**

Force-stop, set `language` to each value, launch fresh:
- `'en'` (English)
- `'vi'` (Vietnamese)

- [ ] **Step 2: Walk every primary flow in Vietnamese**

- Auth → Onboarding (each step) → Home
- BottomNav: Home / Insights / AI Agent / Notifications / Profile
- Profile → Edit Profile → save → return
- Settings → every row in VI
- My Library → tap a saved item → expand explanation
- Vocab Hub → Word Analysis → Mind Map → Flashcards → Compare → Describe
- Scenario Coach → start a conversation → end session → assessment report
- Story Mode → start → swipe sentences
- Tone Translator → input → result
- Notifications → tap an item → deep-link
- AI Agent → category cards → article view → Ask AI

For each: no English copy left in UI chrome, no broken layout from longer VI strings, no missing-key fallback (would render the key name in raw form).

- [ ] **Step 3: Verify AI content stays English**

In Vietnamese mode:
- Open a saved word — its dictionary `explanation` and `examples` should still be English (Gemini output)
- Start a Scenario conversation — coach replies in English
- Open a Story — story prose is English
- Mind map node labels — English (because they're the learning vocabulary)

This is the intended behavior. UI chrome is VI; learning content is EN.

- [ ] **Step 4: Edge cases**

- Plurals — confirm "1 item" vs "5 mục đã lưu" both render correctly
- Very long names in VI for level / mode descriptions — no overflow
- Snackbars wrap to 2 lines if needed
- Date formatting uses VI locale (intl handles this once `Locale('vi')` is bound — verify on a notification timestamp)
- Switching locale mid-conversation → UI flips, message history preserved (English Gemini messages keep showing English)

- [ ] **Step 5: Run full analyze**

Run: `flutter analyze`
Expected: 0 errors, info-level lints only.

- [ ] **Step 6: Update memory + commit**

```bash
git add lib/
git commit -m "chore: i18n verification pass — all flows confirmed in VI"
```

Save a memory note:
```
project_i18n_complete_2026-XX-XX.md — Vietnamese localization shipped
end-to-end. All UI chrome migrated to AppLocalizations. AI-generated
content stays English by design. Picker live in Settings.
```

---

## Risks + Mitigations

| Risk | Mitigation |
|------|------------|
| Layout breaks from longer VI strings | Note length-risk keys in ARB descriptions; verify visually during smoke tests; soft-wrap or shorten where needed |
| Missing-key crashes (`null` returned by AppLocalizations) | gen-l10n flags missing keys at codegen time; CI should fail if any key missing in `vi.arb` |
| Mistranslating domain UX terms ("Streak", "Mastery", "Flashcards") | Reference the existing 21 onboarding keys for tone; flag uncertain translations for human review |
| Plural breakage on count zero | Always provide `=0` branch where it reads better than `other` ("No items" vs "0 items") |
| Translating learning content by accident | Audit Gemini prompts and AI-rendered content paths during Task 7 — they must NOT call `context.loc.X` for learning material |
| `_ComingSoonRow` widget no longer used after Task 8 | Leave the class — it's a useful primitive for any future "Soon" UX |

---

## Definition of Done

- [ ] `flutter analyze` clean (0 errors)
- [ ] `flutter gen-l10n` runs without missing-translation warnings
- [ ] Settings → Display language picker shows English / Tiếng Việt; each option flips the entire app
- [ ] Every screen listed in Task 9 Step 2 verified in VI visually
- [ ] AI content (dictionary, conversation, story, mind-map labels) stays English
- [ ] Locale choice persists across cold restarts
- [ ] No `Text(<English literal>)` remains in `lib/features/**` for user-facing copy
- [ ] No fake "Soon" pill remaining for Display language in Settings
- [ ] Memory note saved
