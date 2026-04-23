# CustomPainter Icon System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all FluentIcon (CDN-loaded emoji), Material Icons, and inline emoji text with a unified CustomPainter animated icon system, consistent with the existing GoalIcon/LevelIcon style. CloudImage icons (Cloudinary app branding assets) are excluded.

**Architecture:** A single `AppIcon` StatefulWidget reads an icon ID string, creates a 2400ms repeating AnimationController, and delegates painting to a registry of `AppIconPainter` functions organized by category. Each painter receives `(Canvas, Size, double t)` and draws the icon with subtle looping animation. All icons respect `AppAnimations.shouldReduceMotion`.

**Tech Stack:** Flutter CustomPainter, dart:math, AppColors for consistent palette

---

## File Structure

**New files (painters by category):**
- `lib/shared/painters/icon_registry.dart` — master registry mapping icon ID → painter function
- `lib/shared/painters/action_painters.dart` — send, mic, listen, hint, toggle, search, bookmark, delete (8 icons)
- `lib/shared/painters/nav_painters.dart` — history, myLearning, profile, back (4 icons)
- `lib/shared/painters/mode_painters.dart` — scenario, story, tone, vocabHub (4 icons)
- `lib/shared/painters/learning_painters.dart` — grammar, vocabulary, brain, practice, sparkle (5 icons)
- `lib/shared/painters/status_painters.dart` — check, error, warning, signOut (4 icons)
- `lib/shared/painters/profile_painters.dart` — goal, clock, level, crown, topic (5 icons)
- `lib/shared/painters/topic_painters.dart` — travel, business, social, dailyLife, technology, education, food, healthcare, shopping, entertainment, sports, nature, finance, relationships, law, realEstate (16 icons)
- `lib/shared/painters/daily_time_painters.dart` — seedling, fire, bolt, rocket (4 icons)
- `lib/shared/painters/tone_painters.dart` — formalHat, neutralScale, friendlySmile, casualPeace, speaker (5 icons)
- `lib/shared/painters/feature_painters.dart` — masks, barChart, target, save, openBook, ribbonBookmark, magnifier, cards, stack, chartUp, notepad (11 icons)

**New widget:**
- `lib/shared/widgets/app_icon.dart` — unified animated icon widget (replaces FluentIcon)

**Modified files:**
- `lib/core/constants/icon_constants.dart` — convert URLs to string ID constants
- `lib/core/constants/topic_constants.dart` — replace emojiUrl with iconId
- `lib/core/constants/onboarding_constants.dart` — replace DailyTimeOption.emojiUrl with iconId, LearningGoal.emoji with iconId
- `lib/features/home/models/mode_deep_dive_data.dart` — replace emoji strings with iconId in DeepDiveFeature and TonePreview
- Every file importing `fluent_icon.dart` — swap FluentIcon → AppIcon
- Files with inline emoji Text widgets — swap to AppIcon
- `lib/features/onboarding/widgets/step_level.dart` — fix animation to only apply on selected level

**Files to delete after migration:**
- `lib/shared/widgets/fluent_icon.dart` — no longer needed

---

### Task 1: Create AppIcon widget + icon registry scaffold

**Files:**
- Create: `lib/shared/widgets/app_icon.dart`
- Create: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create the AppIcon widget**

```dart
// lib/shared/widgets/app_icon.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';
import '../painters/icon_registry.dart';

class AppIcon extends StatefulWidget {
  final String iconId;
  final double size;
  final Color? color;

  const AppIcon(this.iconId, {super.key, this.size = 20, this.color});

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = iconRegistry[widget.iconId];
    if (painter == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    final reduceMotion = AppAnimations.shouldReduceMotion(context);
    if (reduceMotion) {
      return CustomPaint(
        size: Size.square(widget.size),
        painter: _AppIconPainter(painter: painter, t: 0, color: widget.color),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _AppIconPainter(
            painter: painter,
            t: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _AppIconPainter extends CustomPainter {
  final IconPainterFn painter;
  final double t;
  final Color? color;

  _AppIconPainter({required this.painter, required this.t, this.color});

  @override
  void paint(Canvas canvas, Size size) => painter(canvas, size, t, color);

  @override
  bool shouldRepaint(_AppIconPainter old) => old.t != t || old.color != color;
}
```

- [ ] **Step 2: Create icon registry scaffold**

```dart
// lib/shared/painters/icon_registry.dart
typedef IconPainterFn = void Function(Canvas canvas, Size size, double t, Color? color);

// Populated by painter category files via registerXxxPainters()
final Map<String, IconPainterFn> iconRegistry = {};

void initIconRegistry() {
  // Called once at app startup — each category registers its painters
  // Imports and calls will be added as painter files are created
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/app_icon.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add AppIcon widget + icon registry scaffold"
```

---

### Task 2: Action painters (send, mic, listen, hint, toggle, search, bookmark, delete)

**Files:**
- Create: `lib/shared/painters/action_painters.dart`
- Modify: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create action_painters.dart with all 8 icon painters**

Each painter draws a vector icon with subtle animation at `t` (0→1 repeating).
Animation style: gentle bob, pulse, or rotation per icon.

Icons:
- `send`: paper airplane tilting, trail dashes
- `mic`: microphone body + bobbing sound waves
- `listen`: speaker cone + animated sound arcs
- `hint`: lightbulb with pulsing glow rays
- `toggle`: two curved arrows with rotation
- `search`: magnifying glass with subtle tilt
- `bookmark`: ribbon bookmark with gentle wave
- `delete`: wastebasket with wobble on lid

- [ ] **Step 2: Register in icon_registry.dart**

Add import + registration in `initIconRegistry()`.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/painters/action_painters.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add action painters — send, mic, listen, hint, toggle, search, bookmark, delete"
```

---

### Task 3: Navigation + Mode painters (8 icons)

**Files:**
- Create: `lib/shared/painters/nav_painters.dart`
- Create: `lib/shared/painters/mode_painters.dart`
- Modify: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create nav_painters.dart**

Icons:
- `history`: clipboard with small list lines, subtle paper flutter
- `myLearning`: two stacked books, gentle bobbing
- `profile`: person silhouette bust, subtle breathing scale
- `back`: left-pointing chevron arrow, gentle horizontal bob

- [ ] **Step 2: Create mode_painters.dart**

Icons:
- `scenario`: speaking head with sound waves emanating
- `story`: scroll with gentle unrolling wave
- `tone`: artist palette with orbiting color dots
- `vocabHub`: card index dividers with fanning animation

- [ ] **Step 3: Register both in icon_registry.dart**

- [ ] **Step 4: Commit**

```bash
git add lib/shared/painters/nav_painters.dart lib/shared/painters/mode_painters.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add navigation + mode painters"
```

---

### Task 4: Learning + Status painters (9 icons)

**Files:**
- Create: `lib/shared/painters/learning_painters.dart`
- Create: `lib/shared/painters/status_painters.dart`
- Modify: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create learning_painters.dart**

Icons:
- `grammar`: pencil with writing motion, subtle drawing line trail
- `vocabulary`: open book with page flutter
- `brain`: two hemispheres with pulsing highlight (reuse style from goal_icon.dart brain)
- `practice`: bullseye target with pulsing center
- `sparkle`: 4-point star with rotating secondary sparkles

- [ ] **Step 2: Create status_painters.dart**

Icons:
- `check`: checkmark in circle with stroke-draw animation
- `error`: X mark in circle with subtle shake
- `warning`: triangle with exclamation, pulsing color
- `signOut`: door with arrow exiting, gentle slide

- [ ] **Step 3: Register both in icon_registry.dart**

- [ ] **Step 4: Commit**

```bash
git add lib/shared/painters/learning_painters.dart lib/shared/painters/status_painters.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add learning + status painters"
```

---

### Task 5: Profile painters (5 icons)

**Files:**
- Create: `lib/shared/painters/profile_painters.dart`
- Modify: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create profile_painters.dart**

Icons:
- `goal`: trophy cup with sparkle orbit (gold body, handles, star)
- `clock`: alarm clock face with ticking second hand
- `level`: bar chart with bars growing animation
- `crown`: crown with jewels + subtle sparkles (reuse style from original level_icon advanced)
- `topic`: label/tag with gentle swing

- [ ] **Step 2: Register in icon_registry.dart**

- [ ] **Step 3: Commit**

```bash
git add lib/shared/painters/profile_painters.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add profile painters — goal, clock, level, crown, topic"
```

---

### Task 6: Topic painters (16 icons)

**Files:**
- Create: `lib/shared/painters/topic_painters.dart`
- Modify: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create topic_painters.dart**

Each topic gets a simple, recognizable vector icon with gentle animation:
- `topic_travel`: airplane with banking tilt (reuse travel style from goal_icon)
- `topic_business`: briefcase (reuse career style from goal_icon)
- `topic_social`: two clinking glasses with subtle tap
- `topic_dailyLife`: house with chimney smoke drift
- `topic_technology`: laptop screen with blinking cursor
- `topic_education`: graduation cap (reuse exam style from goal_icon)
- `topic_food`: steaming bowl with rising steam
- `topic_healthcare`: hospital cross with pulsing glow
- `topic_shopping`: shopping bag with gentle swing
- `topic_entertainment`: clapperboard with clap animation
- `topic_sports`: soccer ball with subtle spin
- `topic_nature`: herb/leaf with gentle sway
- `topic_finance`: money bag with coin bounce
- `topic_relationships`: heart with pulse beat
- `topic_law`: balance scale with gentle tilt
- `topic_realEstate`: key with slight rotation

- [ ] **Step 2: Register in icon_registry.dart**

- [ ] **Step 3: Commit**

```bash
git add lib/shared/painters/topic_painters.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add 16 topic painters"
```

---

### Task 7: Daily time + Tone + Feature painters (20 icons)

**Files:**
- Create: `lib/shared/painters/daily_time_painters.dart`
- Create: `lib/shared/painters/tone_painters.dart`
- Create: `lib/shared/painters/feature_painters.dart`
- Modify: `lib/shared/painters/icon_registry.dart`

- [ ] **Step 1: Create daily_time_painters.dart**

Icons:
- `time_seedling`: small sprout with growing leaf, gentle sway
- `time_fire`: flame with flickering tips
- `time_bolt`: lightning bolt with flash pulse
- `time_rocket`: rocket with thrust flame flicker

- [ ] **Step 2: Create tone_painters.dart**

Icons:
- `tone_formal`: top hat with subtle tilt
- `tone_neutral`: balance scale with gentle rock (reuse law style)
- `tone_friendly`: smiley face with eye blink
- `tone_casual`: peace/victory hand with slight wave
- `tone_speaker`: speaker cone with sound arcs (reuse listen style)

- [ ] **Step 3: Create feature_painters.dart**

Icons for ModeDeepDiveCard features:
- `feat_masks`: theater masks with subtle toggle
- `feat_barChart`: bar chart with bar growth (reuse level style)
- `feat_target`: bullseye (reuse practice style)
- `feat_save`: floppy disk with gentle pulse
- `feat_openBook`: open book (reuse vocabulary style)
- `feat_ribbonBookmark`: ribbon bookmark (reuse bookmark style)
- `feat_magnifier`: magnifying glass (reuse search style)
- `feat_brain`: brain (reuse brain style)
- `feat_cards`: playing cards with fan
- `feat_stack`: book stack (reuse myLearning style)
- `feat_chartUp`: chart trending up, line drawing animation
- `feat_notepad`: notepad with pencil, writing line

- [ ] **Step 4: Register all three in icon_registry.dart**

- [ ] **Step 5: Commit**

```bash
git add lib/shared/painters/daily_time_painters.dart lib/shared/painters/tone_painters.dart lib/shared/painters/feature_painters.dart lib/shared/painters/icon_registry.dart
git commit -m "feat(icons): add daily time, tone, and feature painters"
```

---

### Task 8: Update constants to use icon IDs

**Files:**
- Modify: `lib/core/constants/icon_constants.dart`
- Modify: `lib/core/constants/topic_constants.dart`
- Modify: `lib/core/constants/onboarding_constants.dart`
- Modify: `lib/features/home/models/mode_deep_dive_data.dart`

- [ ] **Step 1: Convert icon_constants.dart from URLs to string IDs**

Replace all Fluent Emoji URL strings with plain icon ID strings matching the registry keys.

```dart
abstract final class AppIcons {
  // Actions
  static const send = 'send';
  static const mic = 'mic';
  static const search = 'search';
  static const listen = 'listen';
  static const hint = 'hint';
  static const toggle = 'toggle';
  // ... all icons converted to ID strings
}
```

- [ ] **Step 2: Update topic_constants.dart**

Replace `emojiUrl` field with `iconId` field, change values from Fluent URLs to `topic_xxx` icon IDs.

```dart
class TopicOption {
  final String id;
  final String label;
  final String iconId;
  const TopicOption({required this.id, required this.label, required this.iconId});
}

const List<TopicOption> topicOptions = [
  TopicOption(id: 'travel', label: 'Travel', iconId: 'topic_travel'),
  // ... all 16 topics
];
```

- [ ] **Step 3: Update onboarding_constants.dart**

- Change `DailyTimeOption.emojiUrl` → `iconId` with `time_xxx` IDs
- Change `LearningGoal.emoji` → `iconId` (already handled by GoalIcon, keep as-is if GoalIcon works independently)

- [ ] **Step 4: Update mode_deep_dive_data.dart**

- Change `DeepDiveFeature.emoji` → `iconId` with `feat_xxx` IDs
- Change `TonePreview.emoji` → `iconId` with `tone_xxx` IDs

- [ ] **Step 5: Commit**

```bash
git add lib/core/constants/icon_constants.dart lib/core/constants/topic_constants.dart lib/core/constants/onboarding_constants.dart lib/features/home/models/mode_deep_dive_data.dart
git commit -m "refactor(constants): convert icon URLs/emojis to icon ID strings"
```

---

### Task 9: Wire AppIcon into all screens — Batch 1 (onboarding + home)

**Files:**
- Modify: `lib/features/onboarding/widgets/step_topics.dart` — CloudImage(topic.emojiUrl) → AppIcon(topic.iconId)
- Modify: `lib/features/onboarding/widgets/step_daily_time.dart` — CloudImage(emojiUrl) → AppIcon(iconId), header CloudImage → AppIcon
- Modify: `lib/features/onboarding/widgets/step_level.dart` — fix animation only on selected
- Modify: `lib/features/home/widgets/bottom_nav_bar.dart` — FluentIcon → AppIcon for profile tab
- Modify: `lib/features/home/screens/home_screen.dart` — FluentIcon(AppIcons.history) → AppIcon(AppIcons.history)
- Modify: `lib/features/home/widgets/mode_deep_dive_card.dart` — emoji Text → AppIcon for features and tones

- [ ] **Step 1: Update step_topics.dart**

Replace `CloudImage(url: topic.emojiUrl, size: 24)` with `AppIcon(topic.iconId, size: 24)`.
Replace `Text('\u{2728}')` sparkle with `AppIcon('sparkle', size: 16)`.
Update import: remove `cloud_image.dart`, add `app_icon.dart`.

- [ ] **Step 2: Update step_daily_time.dart**

Replace header `CloudImage(url: '...Alarm%20Clock.png', size: 80)` with `AppIcon('clock', size: 80)`.
Replace `CloudImage(url: option.emojiUrl, size: 32)` with `AppIcon(option.iconId, size: 32)`.
Update import.

- [ ] **Step 3: Update bottom_nav_bar.dart**

In `_buildIcon()`: replace `FluentIcon(fluentIconUrl!, size: 28)` with `AppIcon(fluentIconUrl!, size: 28)`.
Update import: `fluent_icon.dart` → `app_icon.dart`.

- [ ] **Step 4: Update home_screen.dart**

Replace `FluentIcon(AppIcons.history, size: 22)` with `AppIcon(AppIcons.history, size: 22)`.
Update import.

- [ ] **Step 5: Update mode_deep_dive_card.dart**

In `_buildFeatures()`: replace `Text(feature.emoji, style: TextStyle(fontSize: 22))` with `AppIcon(feature.iconId, size: 22)`.
In `_buildTonePreviews()`: replace `Text(tone.emoji, style: TextStyle(fontSize: 16))` with `AppIcon(tone.iconId, size: 16)`.
Replace `Text('🔊')` with `AppIcon('tone_speaker', size: 14)`.

- [ ] **Step 6: Commit**

```bash
git add lib/features/onboarding/widgets/step_topics.dart lib/features/onboarding/widgets/step_daily_time.dart lib/features/home/widgets/bottom_nav_bar.dart lib/features/home/screens/home_screen.dart lib/features/home/widgets/mode_deep_dive_card.dart lib/features/onboarding/widgets/step_level.dart
git commit -m "refactor(icons): wire AppIcon into onboarding + home screens"
```

---

### Task 10: Wire AppIcon into all screens — Batch 2 (scenario + chat)

**Files:**
- Modify: `lib/features/scenario/widgets/chat_input_bar.dart`
- Modify: `lib/features/scenario/widgets/chat_bubble_user.dart`
- Modify: `lib/features/scenario/widgets/assessment_card.dart`
- Modify: `lib/features/scenario/widgets/context_panel.dart`
- Modify: `lib/features/scenario/widgets/lesson_card.dart`
- Modify: `lib/features/scenario/widgets/scenario_app_bar.dart`
- Modify: `lib/features/scenario/screens/conversation_history_screen.dart`
- Modify: `lib/features/scenario/screens/scenario_chat_screen.dart`

- [ ] **Step 1: Update each file**

In every file: replace `FluentIcon(AppIcons.xxx, size: N)` with `AppIcon(AppIcons.xxx, size: N)`.
Replace emoji Text widgets (e.g. `Text('🎯')`) with `AppIcon('practice', size: 14)`.
In scenario_chat_screen.dart: replace topic emoji mapping to use AppIcon with `topic_xxx` IDs.
Update imports: `fluent_icon.dart` → `app_icon.dart`.

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/widgets/ lib/features/scenario/screens/
git commit -m "refactor(icons): wire AppIcon into scenario + chat screens"
```

---

### Task 11: Wire AppIcon into all screens — Batch 3 (profile + library + auth)

**Files:**
- Modify: `lib/features/profile/screens/profile_screen.dart`
- Modify: `lib/features/my_library/screens/my_library_screen.dart`
- Modify: `lib/features/auth/screens/auth_screen.dart`

- [ ] **Step 1: Update each file**

Same pattern: `FluentIcon(AppIcons.xxx)` → `AppIcon(AppIcons.xxx)`.
In auth_screen.dart: keep `_GoogleLogoPainter` as-is (it's already CustomPainter), replace `FluentIcon` for guest icon.
Update imports.

- [ ] **Step 2: Commit**

```bash
git add lib/features/profile/ lib/features/my_library/ lib/features/auth/
git commit -m "refactor(icons): wire AppIcon into profile, library, and auth screens"
```

---

### Task 12: Init registry at app startup + delete FluentIcon

**Files:**
- Modify: `lib/main.dart` — call `initIconRegistry()` before `runApp`
- Delete: `lib/shared/widgets/fluent_icon.dart`
- Modify: `lib/shared/painters/icon_registry.dart` — add all imports and register calls

- [ ] **Step 1: Finalize icon_registry.dart with all imports and registrations**

```dart
import 'action_painters.dart';
import 'nav_painters.dart';
import 'mode_painters.dart';
import 'learning_painters.dart';
import 'status_painters.dart';
import 'profile_painters.dart';
import 'topic_painters.dart';
import 'daily_time_painters.dart';
import 'tone_painters.dart';
import 'feature_painters.dart';

void initIconRegistry() {
  registerActionPainters(iconRegistry);
  registerNavPainters(iconRegistry);
  registerModePainters(iconRegistry);
  registerLearningPainters(iconRegistry);
  registerStatusPainters(iconRegistry);
  registerProfilePainters(iconRegistry);
  registerTopicPainters(iconRegistry);
  registerDailyTimePainters(iconRegistry);
  registerTonePainters(iconRegistry);
  registerFeaturePainters(iconRegistry);
}
```

- [ ] **Step 2: Add initIconRegistry() call in main.dart**

Call `initIconRegistry()` inside `main()` before `runApp()`.

- [ ] **Step 3: Delete fluent_icon.dart**

Verify no remaining imports of `fluent_icon.dart` anywhere, then delete the file.

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart lib/shared/painters/icon_registry.dart
git rm lib/shared/widgets/fluent_icon.dart
git commit -m "refactor(icons): init registry at startup, remove FluentIcon"
```

---

### Task 13: Fix level animation — only animate selected level

**Files:**
- Modify: `lib/features/onboarding/widgets/step_level.dart`

- [ ] **Step 1: Conditionally wrap with LevelAnimationWrapper**

Already done in prior step — verify the ternary conditional is in place:
```dart
isSelected
    ? LevelAnimationWrapper(levelId: level.id, child: CloudImage(...))
    : CloudImage(...)
```

- [ ] **Step 2: Commit if not already committed**

---

### Task 14: Verification + cleanup

**Files:**
- All modified files

- [ ] **Step 1: Grep for remaining FluentIcon imports**

```bash
grep -rn "fluent_icon" lib/
```
Expected: zero results.

- [ ] **Step 2: Grep for remaining emoji text in non-data files**

```bash
grep -rn "TextStyle(fontSize:" lib/ | grep -v "test\|\.g\.dart"
```
Review any remaining emoji text usage.

- [ ] **Step 3: Verify no broken imports**

```bash
grep -rn "import.*fluent_icon" lib/
```
Expected: zero results.

- [ ] **Step 4: Commit any final cleanup**

```bash
git add -A
git commit -m "chore: final cleanup — remove all FluentIcon/emoji remnants"
```
