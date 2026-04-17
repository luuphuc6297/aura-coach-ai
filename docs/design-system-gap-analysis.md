# Aura Coach AI — Design System Gap Analysis

**Date:** 2026-04-17
**Audit type:** 3-way comparison (Standard checklist ↔ Documentation ↔ Codebase)
**Sources audited:**
- `docs/business-flow/aura-coach-mobile-design-system-v2.md` (UI/UX audit doc)
- `docs/superpowers/specs/2026-04-08-aura-coach-comprehensive-design.md` (comprehensive spec)
- `lib/core/theme/` (token files)
- `lib/shared/widgets/` (shared components)
- `lib/features/` (all feature screens and widgets)

---

## COVERAGE DASHBOARD

| # | Category | Doc Coverage | Code Coverage | Consistency | Priority |
|---|----------|-------------|---------------|-------------|----------|
| 1 | Foundation / Brand | 40% | N/A | — | LOW |
| 2 | Design Tokens | 70% | 60% | INCONSISTENT | HIGH |
| 3 | Color System | 75% | 65% | INCONSISTENT | HIGH |
| 4 | Typography System | 70% | 55% | INCONSISTENT | HIGH |
| 5 | Layout System | 40% | 30% | INCONSISTENT | MEDIUM |
| 6 | Spacing & Sizing | 60% | 5% | CRITICAL GAP | CRITICAL |
| 7 | Shape & Visual Style | 70% | 50% | INCONSISTENT | HIGH |
| 8 | Iconography | 50% | 40% | INCONSISTENT | MEDIUM |
| 9 | Imagery / Media | 65% | 60% | OK | LOW |
| 10 | Motion System | 60% | 30% | INCONSISTENT | HIGH |
| 11 | Interaction Principles | 55% | 35% | INCONSISTENT | MEDIUM |
| 12 | Accessibility | 0% | 0% | MISSING | MEDIUM |
| 13 | Content / UX Writing | 45% | 40% | OK | LOW |
| 14 | Core Component Standards | 65% | 50% | INCONSISTENT | MEDIUM |
| 15 | Primitive Components | 60% | 50% | OK | LOW |
| 16 | Input Components | 50% | 40% | INCONSISTENT | MEDIUM |
| 17 | Navigation Components | 60% | 40% | INCONSISTENT | HIGH |
| 18 | Feedback Components | 40% | 25% | INCONSISTENT | MEDIUM |
| 19 | Overlay Components | 20% | 15% | INCONSISTENT | MEDIUM |
| 20 | Data Display Components | 55% | 45% | OK | LOW |
| 21 | Form Patterns | 35% | 30% | OK | LOW |
| 22 | Search / Filter | 40% | 35% | OK | LOW |
| 23 | CRUD Patterns | 30% | 25% | OK | LOW |
| 24 | State Patterns | 55% | 40% | INCONSISTENT | MEDIUM |
| 25 | Page-Level Patterns | 70% | 60% | OK | LOW |
| 27 | Platform Guidelines | 15% | 10% | MISSING | MEDIUM |
| 28 | Theming | 20% | 10% | CRITICAL GAP | HIGH |
| 29 | Localization / i18n | 10% | 5% | CRITICAL GAP | HIGH |
| 30 | Design-to-Code Mapping | 60% | 50% | OK | LOW |
| 31 | Documentation System | 30% | N/A | — | LOW |

**Categories removed (N/A for mobile):** #26 Templates, #32 Figma Management, #33 Code Library/UI Kit, #34 Governance, #35 QA Audit, #36 Measurement, #37 Workflow

---

## CRITICAL FINDINGS

### FINDING-01: AppSpacing tokens exist but are NEVER used in any widget
- **Gap type:** `IMPLEMENTED_NOT_USED`
- **Severity:** CRITICAL
- **Detail:** `AppSpacing` defines 7 tokens (xs=4 through xxxl=40) but zero references exist in any widget file. All padding, margin, gap, and SizedBox values are hardcoded numeric literals throughout the entire codebase.
- **Impact:** Spacing is completely ad-hoc. No way to enforce consistency or make global spacing changes.
- **Action:** Refactor all hardcoded spacing to use AppSpacing tokens. Add missing tokens for commonly used values not in the scale (e.g., 6, 10, 14, 18, 20, 28, 48).

### FINDING-02: Dark mode infrastructure completely absent
- **Gap type:** `MISSING`
- **Severity:** HIGH
- **Detail:** Only `AppTheme.light` exists. No dark color palette, no `darkTheme` in MaterialApp, no `ThemeMode` configuration, no semantic color tokens that can swap between themes.
- **Impact:** Adding dark mode later requires refactoring every hardcoded color reference to use semantic tokens.
- **Action:** Introduce semantic color tokens (e.g., `colorSurface`, `colorOnSurface`, `colorPrimary`) that resolve to different values per theme. Refactor code to use semantic tokens instead of direct AppColors references.

### FINDING-03: Localization framework missing
- **Gap type:** `MISSING`
- **Severity:** HIGH
- **Detail:** App targets Vietnamese + English UI but has no i18n infrastructure. All strings are hardcoded in Dart files. No ARB files, no `flutter_localizations`, no `AppLocalizations` class.
- **Impact:** Cannot switch UI language without massive refactor.
- **Action:** Set up `flutter_localizations` + ARB file workflow. Extract all user-facing strings.

### FINDING-04: Zero accessibility implementation
- **Gap type:** `MISSING`
- **Severity:** MEDIUM
- **Detail:** No `Semantics` widgets anywhere. Multiple touch targets below 44x44dp minimum (32x32 action icons, 36x36 back buttons, 28x28 check circles). Caption text (#9B9DAB on #FFF8F0) fails WCAG AA contrast at 3.1:1 ratio.
- **Impact:** App Store review risk. Unusable for visually impaired users.
- **Action:** Add basic Semantics labels to all interactive widgets. Enforce 44x44dp minimum touch targets. Fix caption contrast.

---

## DETAILED GAP MATRIX

### Category 2: Design Tokens

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Color tokens | Required | ✅ Documented (comprehensive-design §2.1) | ✅ `app_colors.dart` — 16 tokens | `CONSISTENT` |
| Typography tokens | Required | ✅ Documented (comprehensive-design §2.2) | ✅ `app_typography.dart` — 17 styles | `INCONSISTENT` — doc lists 13, code has 17 (added sentence, sentenceVi, sentenceLabel, logo) |
| Spacing tokens | Required | ✅ Documented (comprehensive-design §2.3) | ❌ Defined but NEVER USED | `IMPLEMENTED_NOT_USED` |
| Sizing tokens | Required | ⚠️ Partial (button height 44px, icon sizes scattered) | ❌ No sizing token file | `DOCUMENTED_NOT_IMPLEMENTED` |
| Radius tokens | Required | ✅ Documented (comprehensive-design §2.4) | ✅ `app_radius.dart` — 5 tokens | `INCONSISTENT` — missing xs(4) and xxs(2) used in code |
| Border tokens | Required | ⚠️ Per-component in doc, no centralized border tokens | ❌ No border token file | `MISSING` |
| Shadow tokens | Required | ✅ Documented (comprehensive-design §2.5) | ✅ `app_shadows.dart` — 6 styles | `INCONSISTENT` — code has `lifted` not in doc; colored clay shadow pattern not tokenized |
| Opacity tokens | Required | ⚠️ Scattered (disabled 50%, tint 5%, AI pulse 0.7) | ❌ No opacity token file | `DOCUMENTED_NOT_IMPLEMENTED` |
| Motion tokens | Required | ✅ Documented (comprehensive-design §2.6) | ⚠️ `app_animations.dart` — 3 durations, 2 curves | `INCONSISTENT` — 200ms used 7+ times but not tokenized; `easeBackOut` defined but never used |
| Z-index tokens | Mobile: N/A | Not documented | Not needed | `N/A_MOBILE` |
| Semantic tokens | Required for theming | ❌ Not documented | ❌ Not implemented | `MISSING` |
| Theme tokens | Required for dark mode | ❌ Not documented | ❌ Not implemented | `MISSING` |
| Platform tokens | Optional | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 3: Color System

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Brand/accent colors | Required | ✅ teal, purple, gold, coral | ✅ Implemented | `CONSISTENT` |
| Neutral colors | Required | ✅ Surface palette documented | ✅ Implemented | `CONSISTENT` |
| Functional/feedback colors | Required | ✅ success, warning, error | ✅ Implemented | `INCONSISTENT` — warning==gold==friendlyTone (same hex #E8C77B), casualTone==error (same hex #D98A8A), neutralTone==success (same hex #7BC6A0) |
| Text colors | Required | ✅ warmDark, warmMuted, warmLight | ✅ Implemented | `CONSISTENT` |
| Background colors | Required | ✅ cream, clayWhite, clayBeige | ✅ Implemented | `CONSISTENT` |
| Border colors | Required | ✅ clayBorder, selected colors | ✅ Implemented | `CONSISTENT` |
| Overlay/scrim colors | Required | ⚠️ Partially documented | ❌ No overlay tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Interactive colors | Required | ✅ teal for focus/active | ✅ Implemented | `CONSISTENT` |
| Disabled colors | Required | ⚠️ "50% opacity" mentioned | ❌ No disabled color tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Dark mode colors | Required (future) | ❌ "Future phase" | ❌ Not implemented | `MISSING` |
| Hardcoded colors in widgets | Should be zero | — | ❌ 8+ hardcoded colors found | `INCONSISTENT` |
| `Colors.white` usage | Should be tokenized | ❌ No `AppColors.white` | ❌ ~15 bare `Colors.white` refs | `MISSING` |
| Dark gold #9A7B3D | Should be tokenized | ❌ Not documented | ❌ Used 4 times untokenized | `IMPLEMENTED_NOT_DOCUMENTED` |
| Contrast rules | Required | ❌ Not documented | ❌ Caption text fails WCAG AA | `MISSING` |

### Category 4: Typography System

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Typefaces (3 families) | Required | ✅ Fredoka, Nunito, Inter | ✅ Implemented via GoogleFonts | `CONSISTENT` |
| Font size scale | Required | ✅ 11-32px range | ✅ 17 styles in AppTypography | `INCONSISTENT` — doc lists 13, code has 17; 4 extra styles (sentence, sentenceVi, sentenceLabel, logo) not in doc |
| Line heights | Required | ✅ 1.2-1.5 documented | ✅ Implemented | `CONSISTENT` |
| Letter spacing | Required | ⚠️ Only logo (2px) and category tabs (0.05em) | ⚠️ bodySm (0.2), caption (0.3), sentenceLabel (0.8) in code | `INCONSISTENT` — code has more letter spacing than doc |
| Hardcoded TextStyles | Should be zero | — | ❌ 10+ hardcoded GoogleFonts calls outside AppTypography | `INCONSISTENT` |
| `fontFamily: 'Nunito'` bypass | Should use AppTypography | — | ❌ 6+ `.copyWith(fontFamily: 'Nunito')` calls | `INCONSISTENT` |
| Multilingual typography | Required (Vi+En) | ❌ Not documented | ⚠️ `sentenceVi` style with extra height for diacritics exists but not documented | `IMPLEMENTED_NOT_DOCUMENTED` |
| Text truncation rules | Required | ❌ Not documented | ❌ No standard rules | `MISSING` |
| Responsive typography | Optional (mobile) | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 5: Layout System

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Screen padding standard | Required | ⚠️ "16px or 20px varies" | ❌ Hardcoded per-screen (16, 20, 24, 28) | `INCONSISTENT` |
| Safe area handling | Required | ⚠️ "Bottom 40-60px" mentioned | ⚠️ SafeArea used inconsistently | `INCONSISTENT` |
| Grid system | Optional (mobile) | ⚠️ Only topic grid (2-col) | ⚠️ Only GridView for topics | `CONSISTENT` |
| AppBar standard | Required | ✅ 48px, cream, elevation 0 | ❌ Inconsistent — some screens use warmDark bg, some white | `INCONSISTENT` |
| Bottom nav height | Required | ✅ 56px | ✅ Implemented | `CONSISTENT` |
| Platform layout differences | Optional | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 6: Spacing & Sizing

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Spacing scale | Required | ✅ 7 values (4-40) | ✅ Defined in `app_spacing.dart` | `IMPLEMENTED_NOT_USED` — tokens exist, zero usage |
| Touch target sizing | Required | ⚠️ AudioPlayButton "28x28" noted | ❌ Multiple targets below 44x44dp (32, 36) | `INCONSISTENT` |
| Component sizing | Required | ⚠️ Scattered per-component | ❌ No centralized sizing tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Missing spacing values | — | — | ❌ Values 6, 10, 14, 18, 20, 28, 48 used but not in scale | `MISSING` |

### Category 7: Shape & Visual Style

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Border radius scale | Required | ✅ 5 values (8-999) | ✅ `app_radius.dart` | `INCONSISTENT` — missing xs(4), xxs(2) for badges/progress bars |
| Border thickness rules | Required | ✅ Per-component table | ⚠️ Not tokenized centrally | `DOCUMENTED_NOT_IMPLEMENTED` |
| Shadow system | Required | ✅ 5 shadow types | ✅ `app_shadows.dart` (6 types) | `INCONSISTENT` — `lifted` in code not in doc; colored clay shadow pattern used 6+ times but not tokenized |
| Hardcoded shadows | Should be zero | — | ❌ 7+ inline BoxShadow instances | `INCONSISTENT` |
| Hardcoded radius | Should be zero | — | ❌ 8+ `BorderRadius.circular()` with raw values | `INCONSISTENT` |
| Opacity rules | Required | ⚠️ Scattered per-component | ❌ No opacity tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Glass/blur effects | Optional | ❌ Not documented | ❌ Not used | `N/A_MOBILE` |

### Category 8: Iconography

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Icon library | Required | ✅ flutter_lucide (52 icons) | ✅ Used | `CONSISTENT` |
| Icon size scale | Required | ⚠️ Sizes scattered (16-48dp) | ❌ No icon size tokens | `DOCUMENTED_NOT_IMPLEMENTED` |
| Filled vs outline rules | Required | ❌ Not documented | ❌ Mixed usage | `MISSING` |
| Icon + label spacing | Required | ❌ Not documented | ❌ Hardcoded per-use | `MISSING` |

### Category 10: Motion System

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Duration scale | Required | ✅ 3 values (150/300/500ms) | ✅ `app_animations.dart` | `INCONSISTENT` — 200ms used 7+ times but not tokenized |
| Easing curves | Required | ✅ 4 curves | ⚠️ 2 tokenized, 2 missing (easeQuadIn, easeQuadOut) | `INCONSISTENT` |
| Unused tokens | — | — | ❌ `easeBackOut` defined, never used | `IMPLEMENTED_NOT_USED` |
| Hardcoded durations | Should be zero | — | ❌ 200ms (7x), 600ms, 1400ms, 3000ms, 2000ms hardcoded | `INCONSISTENT` |
| Page transitions | Required | ✅ FadeTransition documented | ❌ No custom transitions in code (default platform) | `DOCUMENTED_NOT_IMPLEMENTED` |
| Reduced motion a11y | Required | ❌ Not documented | ❌ Not implemented | `MISSING` |

### Category 11: Interaction Principles

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Press/tap feedback | Required | ✅ ClayCard/ClayButton have press states | ⚠️ Only ClayButton implements press animation; all other taps use GestureDetector with no feedback | `INCONSISTENT` |
| Ripple/splash | Optional (Material) | Not specified | ❌ No InkWell/ripple anywhere — all GestureDetector | `MISSING` |
| Haptic feedback | Optional | ❌ Not documented | ❌ Not implemented | `MISSING` |
| Loading state pattern | Required | ✅ Spinner in buttons, shimmer for images | ⚠️ CircularProgressIndicator everywhere, no shimmer/skeleton in CloudImage | `INCONSISTENT` |

### Category 12: Accessibility

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Contrast standards | Required | ❌ | ❌ Caption fails WCAG AA (3.1:1) | `MISSING` |
| Screen reader support | Required | ❌ | ❌ Zero Semantics widgets | `MISSING` |
| Touch target minimums | Required (44x44dp) | ❌ | ❌ Multiple targets 28-36dp | `MISSING` |
| Motion accessibility | Required | ❌ | ❌ No prefers-reduced-motion | `MISSING` |
| Color blindness | Recommended | ❌ | ❌ Not considered | `MISSING` |

### Category 17: Navigation

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Bottom nav | Required | ✅ 3 tabs spec'd | ⚠️ Tab switching NOT functional — index changes but no actual navigation | `INCONSISTENT` |
| GoRouter config | Required | ✅ Full route tree with ShellRoute | ❌ Flat routes, no ShellRoute, no nested nav | `INCONSISTENT` |
| Page transitions | Required | ✅ FadeTransition documented | ❌ Default platform transitions only | `DOCUMENTED_NOT_IMPLEMENTED` |
| Back navigation | Required | ⚠️ arrow_left in AppBar | ⚠️ Mixed `context.pop()` and `context.go()` | `INCONSISTENT` |

### Category 18: Feedback Components

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| ErrorBanner | Required | ✅ Full spec | ✅ Implemented | `CONSISTENT` |
| LoadingIndicator | Required | ✅ Full spec | ✅ Implemented | `CONSISTENT` |
| ProgressBar/dots | Required | ✅ Documented | ✅ ProgressDots implemented | `CONSISTENT` |
| Skeleton/shimmer | Recommended | ✅ Documented (shimmer for CloudImage) | ❌ Not implemented — still uses CircularProgressIndicator | `DOCUMENTED_NOT_IMPLEMENTED` |
| Toast/snackbar | Required | ⚠️ "Show toast 'Saved!'" mentioned once | ⚠️ SnackBar used but no styled component | `INCONSISTENT` |
| Dialog/confirmation | Required | ⚠️ "End session" mentioned | ⚠️ AlertDialog used inline, not shared | `INCONSISTENT` |
| Empty states | Required | ✅ Multiple defined | ✅ Implemented per-screen | `CONSISTENT` |

### Category 19: Overlay Components

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Bottom sheet | Required | ✅ SaveWordSheet, NotificationPermission | ⚠️ ConversationHistoryScreen has bottom sheet | `CONSISTENT` |
| Modal/dialog | Required | ⚠️ Mentioned but not spec'd | ⚠️ AlertDialog used inline, no shared pattern | `INCONSISTENT` |
| Scrim/backdrop | Required | ❌ Not documented | ❌ No standard scrim color | `MISSING` |
| Action sheet | Optional | ❌ Not documented | ❌ Not used | `N/A_MOBILE` |

### Category 24: State Patterns

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Default state | Required | ✅ Per-component | ✅ Implemented | `CONSISTENT` |
| Selected state | Required | ✅ ClayCard selection | ✅ Implemented | `CONSISTENT` |
| Disabled state | Required | ✅ 50% opacity | ⚠️ Inconsistent — some use opacity, some just null onTap | `INCONSISTENT` |
| Loading state | Required | ✅ Multiple patterns | ⚠️ No skeleton/shimmer; only spinners | `INCONSISTENT` |
| Empty state | Required | ✅ Per-screen | ✅ Implemented | `CONSISTENT` |
| Error state | Required | ✅ ErrorBanner | ✅ Implemented | `CONSISTENT` |
| Offline state | Recommended | ⚠️ "Dual-write" mentioned | ❌ No offline UI indicator | `DOCUMENTED_NOT_IMPLEMENTED` |
| First-time use | Required | ✅ Onboarding flow | ✅ Implemented | `CONSISTENT` |

### Category 28: Theming

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| Light mode | Required | ✅ Fully defined | ✅ `AppTheme.light` | `CONSISTENT` |
| Dark mode | Required (planned) | ❌ "Future phase" only | ❌ Not implemented | `MISSING` |
| Theme switching | Required (planned) | ❌ Not documented | ❌ Settings toggle does nothing | `MISSING` |
| Semantic tokens for theming | Required (prep) | ❌ Not documented | ❌ Not implemented | `MISSING` |
| Material component themes | Recommended | ⚠️ Only AppBar, TextTheme | ❌ Missing: ButtonTheme, InputTheme, CardTheme, etc. | `INCOMPLETE` |

### Category 29: Localization

| Sub-item | Standard | Doc Status | Code Status | Gap Type |
|----------|----------|------------|-------------|----------|
| i18n framework | Required | ❌ No ARB/flutter_localizations | ❌ Not implemented | `MISSING` |
| String externalization | Required | ❌ All strings hardcoded | ❌ Not implemented | `MISSING` |
| Vietnamese UI support | Required | ⚠️ Vietnamese content in examples | ⚠️ `sentenceVi` typography exists for diacritics | `PARTIAL` |
| Date/time formatting | Required | ❌ Not documented | ⚠️ `intl` package in pubspec but not used for formatting | `MISSING` |

---

## CODE INCONSISTENCIES SUMMARY

### Duplicate Components (should consolidate)

| Pattern | Occurrences | Files | Action |
|---------|-------------|-------|--------|
| Check circle (selection indicator) | 3 implementations | `step_level.dart` (24x24), `step_goals.dart` (24x24), `step_daily_time.dart` (28x28) | Extract to shared `SelectionCheckCircle` widget |
| Colored clay shadow | 6+ inline instances | `chat_bubble_user.dart`, `session_summary_screen.dart`, `mode_deep_dive_card.dart`, `mode_card.dart`, `home_screen.dart`, `step_name_avatar.dart` | Add `AppShadows.colored(Color c)` factory |
| Badge/chip/pill | 8+ different implementations | `_badge`, `_detailChip`, `_typeBadge`, `_posBadge`, filter chips, tag chips across multiple files | Extract to shared `ClayBadge` / `ClayChip` widget |
| AlertDialog pattern | 2+ inline | `scenario_chat_screen.dart`, `my_library_screen.dart` | Extract to shared `ClayDialog` widget |
| CTA button in cards | 3+ different | `ModeCard`, `ModeDeepDiveCard`, `SessionSummaryScreen` | Use `ClayButton` consistently |

### Tokens Defined But NEVER Used

| Token | File | Issue |
|-------|------|-------|
| `AppSpacing.*` (ALL 7 tokens) | `app_spacing.dart` | Entire spacing system unused |
| `AppShadows.clayHover` | `app_shadows.dart` | Defined for hover state, never referenced |
| `AppAnimations.easeBackOut` | `app_animations.dart` | Defined, never referenced |
| `AppColors.neutralTone` | `app_colors.dart` | Never referenced (tone check maps to `AppColors.teal` instead) |
| `AppTypography.logo` | `app_typography.dart` | AuraLogo creates own `GoogleFonts.fredoka()` |
| `AppTypography.bodyLg` | `app_typography.dart` | In TextTheme but never directly referenced in widgets |

### Values Used But NOT Tokenized

| Value | Occurrences | Suggested Token |
|-------|-------------|-----------------|
| `Duration(milliseconds: 200)` | 7+ places | `AppAnimations.durationMedium` |
| `Color(0xFF9A7B3D)` dark gold | 4 places | `AppColors.goldDark` |
| `BorderRadius.circular(4)` | 4+ places | `AppRadius.xs` |
| `BorderRadius.circular(2)` | 2 places | `AppRadius.xxs` |
| `Colors.white` | 15+ places | `AppColors.white` |
| `Offset(3, 3)` clay offset | 6+ inline | `AppShadows.clayOffset` constant |
| Colored clay shadow pattern | 6+ inline | `AppShadows.colored(Color c)` factory |
| Chat bubble radii (4/28) | 4 instances | `AppRadius.bubbleSmall` / `AppRadius.bubbleLarge` |

### Naming Inconsistencies

| Issue | Detail | Fix |
|-------|--------|-----|
| File → Widget name mismatch | `translate_prompt.dart` exports `LessonCard` | Rename file to `lesson_card.dart` |
| File → Widget name mismatch | `inline_assessment.dart` exports `AssessmentCard` | Rename file to `assessment_card.dart` |
| Enum suffix inconsistency | `ClayButtonVariant` vs `AuthButtonStyle` | Standardize to `*Variant` |
| Nav label inconsistency | "Setting" (singular) in UI and route | Change to "Settings" |
| Doc color naming vs code | Doc uses `tealClay`, `purpleClay`, `goldClay`; code uses `teal`, `purple`, `gold` | Align doc to match code (shorter names) |
| BottomNavBar mixed item types | CloudImage for 2 tabs, emoji "👤" for 1 | Use consistent item type |

---

## INCONSISTENCIES BETWEEN DOCS

| Issue | design-system-v2 says | comprehensive-design says | Code reality |
|-------|----------------------|--------------------------|--------------|
| Bottom nav border | "Top 1px" | "2px, clayBorder" | No top border in code |
| Typography for topic labels | "13px, fontWeight 600" | "bodySm (14px), 600 weight" | Uses `bodySm.copyWith(fontWeight: w600)` = 14px |
| Splash stagger timing | "300ms stagger" | "200ms stagger (0-300, 200-600, 400-800ms)" | Code has no stagger — just floating orb 3s + delay 2s |
| Color token naming | `tealClay`, `purpleClay`, `goldClay` | Same | Code: `teal`, `purple`, `gold` (no "Clay" suffix) |
| Typography count | "13 styles" | 13 styles listed | 17 styles in code (4 extra: sentence, sentenceVi, sentenceLabel, logo) |
| Shimmer for CloudImage | "Add shimmer" (as fix needed) | "Built-in shimmer" (as spec) | Neither — still CircularProgressIndicator |
| `app_spacing.dart` | Not mentioned | Listed in Section 2.3 | File exists but never referenced in file tree (Section 1.2) |

---

## PRIORITIZED ACTION PLAN

### P0 — CRITICAL (Blocking consistency)

1. **Adopt AppSpacing everywhere** — Replace all hardcoded spacing with tokens. Add missing values (6, 10, 14, 18, 20, 28, 48) or round to nearest token.
2. **Add missing radius tokens** — `AppRadius.xs = 4`, `AppRadius.xxs = 2` for badges and progress bars.
3. **Add missing animation token** — `AppAnimations.durationMedium = 200ms`.
4. **Tokenize dark gold color** — Add `AppColors.goldDark = Color(0xFF9A7B3D)`.
5. **Add `AppColors.white`** — Replace all bare `Colors.white` references.
6. **Remove/use orphan tokens** — Either wire up `AppShadows.clayHover`, `AppAnimations.easeBackOut`, `AppColors.neutralTone`, `AppTypography.logo`, `AppTypography.bodyLg` — or remove them.

### P1 — HIGH (Required for design system integrity)

7. **Eliminate hardcoded TextStyles** — Replace all inline `GoogleFonts.*()` and `.copyWith(fontFamily: 'Nunito')` with AppTypography tokens.
8. **Eliminate hardcoded shadows** — Replace inline BoxShadow with AppShadows. Add `AppShadows.colored(Color c)` factory for dynamic clay shadows.
9. **Eliminate hardcoded radius** — Replace `BorderRadius.circular(n)` with AppRadius tokens.
10. **Extract duplicate widgets** — `SelectionCheckCircle`, `ClayBadge`, `ClayChip`, `ClayDialog`.
11. **Introduce semantic color tokens** — Prepare for dark mode: `AppSemanticColors.surface`, `.onSurface`, `.primary`, etc.
12. **Set up i18n framework** — `flutter_localizations` + ARB files for Vietnamese + English.
13. **Fix Material ThemeData** — Add `ElevatedButtonTheme`, `InputDecorationTheme`, `CardTheme`, `BottomNavigationBarTheme`, `DialogTheme`.

### P2 — MEDIUM (Improve robustness)

14. **Add basic accessibility** — Semantics on interactive widgets, fix touch targets to 44x44dp minimum, fix caption contrast.
15. **Add custom page transitions** — Implement FadeTransition as documented.
16. **Implement shimmer loading** — Replace CircularProgressIndicator in CloudImage.
17. **Fix navigation** — Bottom nav tab switching, consistent `go()` vs `pop()` usage.
18. **Resolve token overlap** — `warning`/`gold`/`friendlyTone` and `error`/`casualTone` and `success`/`neutralTone` sharing hex values.
19. **Fix naming inconsistencies** — File names, enum suffixes, nav labels.

### P3 — LOW (Nice to have)

20. **Document brand foundation** — Purpose, design principles, tone of voice.
21. **Add opacity tokens** — Centralize common opacity values (0.05, 0.1, 0.3, 0.5, 0.7).
22. **Add border thickness tokens** — Centralize 1px, 1.5px, 2px, 4px values.
23. **Add icon size tokens** — Standardize icon sizes across the app.
24. **Document platform guidelines** — iOS vs Android differences, status bar handling.
25. **Update both docs to match code** — Sync token names, add missing styles, correct stagger timings.

---

## APPENDIX: Color Token Overlap Map

```
#E8C77B ──┬── AppColors.gold (accent)
          ├── AppColors.warning (semantic)
          └── AppColors.friendlyTone (tone)

#D98A8A ──┬── AppColors.error (semantic)
          └── AppColors.casualTone (tone)

#7BC6A0 ──┬── AppColors.success (semantic)
          └── AppColors.neutralTone (tone)

#7ECEC5 ──┬── AppColors.teal (accent)
          └── info (documented, not in code as separate token)
```

**Risk:** If tone colors ever need to diverge from semantic colors (e.g., "casual" tone should NOT look like "error"), this coupling will break.

**Recommendation:** Keep separate tokens but add comments documenting the intentional overlap. If they diverge in the future, only the token values need to change.

---

*End of Gap Analysis — Generated 2026-04-17*
