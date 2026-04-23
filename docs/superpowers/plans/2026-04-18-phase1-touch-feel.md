# Phase 1: Core Touch Feel — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add spring-based press feedback (scale + haptic), consistent bounce scroll, and cross-fade loading transitions to every interactive element in the app.

**Architecture:** Create a `ClayPressable` builder widget that wraps any child with spring-physics scale animation + haptic feedback. Integrate it into all tappable widgets. Add `BouncingScrollBehavior` globally via `ScrollConfiguration`. Add `AnimatedSwitcher` for loading state transitions.

**Tech Stack:** Flutter `physics.dart` (SpringSimulation, SpringDescription), `services.dart` (HapticFeedback). No new dependencies.

---

## File Structure

**Create:**
- `lib/shared/widgets/clay_pressable.dart` — Core press feedback widget
- `lib/shared/widgets/bouncing_scroll_behavior.dart` — Custom ScrollBehavior

**Modify:**
- `lib/core/theme/app_animations.dart` — Add spring constants
- `lib/shared/widgets/clay_button.dart` — Use ClayPressable, add AnimatedSwitcher
- `lib/shared/widgets/clay_card.dart` — Use ClayPressable
- `lib/features/auth/widgets/auth_button.dart` — Use ClayPressable, add AnimatedSwitcher
- `lib/features/home/widgets/mode_card.dart` — CTA wrap ClayPressable, add AnimatedSwitcher
- `lib/features/home/widgets/mode_deep_dive_card.dart` — CTA wrap ClayPressable
- `lib/features/scenario/widgets/lesson_card.dart` — Listen button wrap ClayPressable
- `lib/features/scenario/widgets/assessment_card.dart` — Bookmark, listen, difficulty buttons wrap ClayPressable
- `lib/features/scenario/widgets/chat_bubble_user.dart` — Listen button wrap ClayPressable
- `lib/features/scenario/widgets/scenario_app_bar.dart` — Back + action icons wrap ClayPressable
- `lib/features/home/screens/home_screen.dart` — History button wrap ClayPressable
- `lib/features/onboarding/widgets/step_topics.dart` — Topic chips wrap ClayPressable
- `lib/app.dart` — Add ScrollConfiguration with BouncingScrollBehavior

---

### Task 1: Add spring constants to AppAnimations

**Files:**
- Modify: `lib/core/theme/app_animations.dart`

- [ ] **Step 1: Add spring constants and press duration**

Replace the entire file content with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

abstract final class AppAnimations {
  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 200);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);

  /// Duration for press-down scale (instant feel, no spring).
  static const durationPress = Duration(milliseconds: 80);

  static const easeClay = Curves.easeInOut;

  /// Spring for tap release — fast, slight overshoot, quick settle.
  static const springTap = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 15,
  );

  /// Spring for gentle transitions — smooth, no overshoot.
  static const springGentle = SpringDescription(
    mass: 1,
    stiffness: 200,
    damping: 20,
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/app_animations.dart
git commit -m "feat(tokens): add spring constants and press duration to AppAnimations"
```

---

### Task 2: Create ClayPressable widget

**Files:**
- Create: `lib/shared/widgets/clay_pressable.dart`

- [ ] **Step 1: Create the ClayPressable widget**

Create `lib/shared/widgets/clay_pressable.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_animations.dart';

enum ClayHapticType { light, medium }

class ClayPressable extends StatefulWidget {
  final Widget Function(BuildContext context, bool isPressed) builder;
  final VoidCallback? onTap;
  final bool enabled;
  final double scaleDown;
  final bool enableHaptic;
  final ClayHapticType hapticType;

  const ClayPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.enabled = true,
    this.scaleDown = 0.97,
    this.enableHaptic = true,
    this.hapticType = ClayHapticType.light,
  });

  @override
  State<ClayPressable> createState() => _ClayPressableState();
}

class _ClayPressableState extends State<ClayPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isActive => widget.enabled && widget.onTap != null;

  void _onTapDown(TapDownDetails details) {
    if (!_isActive) return;
    setState(() => _isPressed = true);
    _controller.animateTo(
      widget.scaleDown,
      duration: AppAnimations.durationPress,
      curve: Curves.easeOut,
    );
    if (widget.enableHaptic) {
      switch (widget.hapticType) {
        case ClayHapticType.light:
          HapticFeedback.lightImpact();
        case ClayHapticType.medium:
          HapticFeedback.mediumImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isActive) return;
    setState(() => _isPressed = false);
    _springBack();
  }

  void _onTapCancel() {
    if (!_isActive) return;
    setState(() => _isPressed = false);
    _springBack();
  }

  void _springBack() {
    final simulation = SpringSimulation(
      AppAnimations.springTap,
      _controller.value,
      1.0,
      0.0,
    );
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _isActive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.builder(context, _isPressed),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/clay_pressable.dart
git commit -m "feat(widgets): create ClayPressable with spring scale + haptic feedback"
```

---

### Task 3: Create BouncingScrollBehavior and wire into app

**Files:**
- Create: `lib/shared/widgets/bouncing_scroll_behavior.dart`
- Modify: `lib/app.dart:130-136`

- [ ] **Step 1: Create BouncingScrollBehavior**

Create `lib/shared/widgets/bouncing_scroll_behavior.dart` with:

```dart
import 'package:flutter/material.dart';

class BouncingScrollBehavior extends ScrollBehavior {
  const BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
```

- [ ] **Step 2: Wrap MaterialApp.router with ScrollConfiguration**

In `lib/app.dart`, add the import at the top (after line 10):

```dart
import 'shared/widgets/bouncing_scroll_behavior.dart';
```

Then change the `MaterialApp.router` block (lines 130-135) from:

```dart
      child: MaterialApp.router(
        title: 'Aura Coach AI',
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
```

to:

```dart
      child: ScrollConfiguration(
        behavior: const BouncingScrollBehavior(),
        child: MaterialApp.router(
          title: 'Aura Coach AI',
          theme: AppTheme.light,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/bouncing_scroll_behavior.dart lib/app.dart
git commit -m "feat(scroll): add global BouncingScrollPhysics via ScrollConfiguration"
```

---

### Task 4: Refactor ClayButton to use ClayPressable + AnimatedSwitcher

**Files:**
- Modify: `lib/shared/widgets/clay_button.dart`

- [ ] **Step 1: Rewrite ClayButton**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_animations.dart';
import 'clay_pressable.dart';

enum ClayButtonVariant { primary, secondary, danger, ghost, pill }

class ClayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final ClayButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const ClayButton({
    super.key,
    required this.text,
    this.onTap,
    this.variant = ClayButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  Color get _bg {
    if (onTap == null) return AppColors.clayBeige;
    switch (variant) {
      case ClayButtonVariant.primary:
        return AppColors.teal;
      case ClayButtonVariant.secondary:
        return AppColors.clayWhite;
      case ClayButtonVariant.danger:
        return AppColors.error;
      case ClayButtonVariant.ghost:
        return Colors.transparent;
      case ClayButtonVariant.pill:
        return AppColors.teal;
    }
  }

  Color get _fg {
    if (onTap == null) return AppColors.warmLight;
    switch (variant) {
      case ClayButtonVariant.primary:
      case ClayButtonVariant.danger:
      case ClayButtonVariant.pill:
        return AppColors.white;
      case ClayButtonVariant.secondary:
        return AppColors.warmDark;
      case ClayButtonVariant.ghost:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow> _shadow(bool isPressed) {
    if (onTap == null || variant == ClayButtonVariant.ghost) {
      return [];
    }
    if (isPressed) return AppShadows.clayPressed;
    return AppShadows.clay;
  }

  Border? get _border {
    if (variant == ClayButtonVariant.secondary) {
      return Border.all(color: AppColors.clayBorder, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
      child: ClayPressable(
        onTap: isLoading ? null : onTap,
        enabled: onTap != null,
        builder: (context, isPressed) {
          return AnimatedContainer(
            duration: AppAnimations.durationFast,
            curve: AppAnimations.easeClay,
            width: isFullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: variant == ClayButtonVariant.pill ? 24 : 20,
              vertical: variant == ClayButtonVariant.pill ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: variant == ClayButtonVariant.pill
                  ? AppRadius.fullBorder
                  : AppRadius.lgBorder,
              border: _border,
              boxShadow: _shadow(isPressed),
            ),
            child: AnimatedOpacity(
              duration: AppAnimations.durationFast,
              opacity: onTap == null ? 0.5 : 1.0,
              child: Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: AppAnimations.durationFast,
                    child: isLoading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(_fg),
                            ),
                          )
                        : Row(
                            key: const ValueKey('content'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                icon!,
                                const SizedBox(width: 10),
                              ],
                              Text(
                                text,
                                style: AppTypography.button.copyWith(color: _fg),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

Key changes: `StatefulWidget` → `StatelessWidget` (press state now in ClayPressable). Shadow uses `isPressed` from builder. AnimatedSwitcher for loading ↔ content. No more duplicate `_isPressed` / `GestureDetector`.

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/clay_button.dart
git commit -m "refactor(clay-button): use ClayPressable for spring press + AnimatedSwitcher for loading"
```

---

### Task 5: Refactor ClayCard to use ClayPressable

**Files:**
- Modify: `lib/shared/widgets/clay_card.dart`

- [ ] **Step 1: Rewrite ClayCard**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_animations.dart';
import 'clay_pressable.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final Color selectedBorderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final String? semanticLabel;

  const ClayCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.selectedBorderColor = AppColors.teal,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.boxShadow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = AnimatedContainer(
      duration: AppAnimations.durationFast,
      curve: AppAnimations.easeClay,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: isSelected ? selectedBorderColor : AppColors.clayBorder,
          width: 2,
        ),
        boxShadow: boxShadow ?? (isSelected ? AppShadows.clay : AppShadows.card),
      ),
      child: child,
    );

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: onTap != null
          ? ClayPressable(
              onTap: onTap,
              builder: (context, isPressed) => cardContent,
            )
          : cardContent,
    );
  }
}
```

Key change: When `onTap` is non-null, wraps with `ClayPressable` for scale + haptic. When null (display-only card), no wrapper.

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/clay_card.dart
git commit -m "refactor(clay-card): use ClayPressable for spring press feedback"
```

---

### Task 6: Refactor AuthButton to use ClayPressable + AnimatedSwitcher

**Files:**
- Modify: `lib/features/auth/widgets/auth_button.dart`

- [ ] **Step 1: Rewrite AuthButton**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';

enum AuthButtonVariant {
  google,
  apple,
  guest,
}

class AuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final AuthButtonVariant style;
  final VoidCallback? onTap;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.style,
    this.onTap,
    this.isLoading = false,
  });

  Color get _bg {
    switch (style) {
      case AuthButtonVariant.google:
        return AppColors.teal;
      case AuthButtonVariant.apple:
        return AppColors.warmDark;
      case AuthButtonVariant.guest:
        return Colors.transparent;
    }
  }

  Color get _fg {
    switch (style) {
      case AuthButtonVariant.google:
      case AuthButtonVariant.apple:
        return AppColors.white;
      case AuthButtonVariant.guest:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow>? get _shadow {
    switch (style) {
      case AuthButtonVariant.google:
        return AppShadows.clay;
      case AuthButtonVariant.apple:
        return AppShadows.colored(AppColors.warmDark, alpha: 0.3);
      case AuthButtonVariant.guest:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: isLoading ? null : onTap,
      enabled: onTap != null,
      builder: (context, isPressed) {
        return AnimatedOpacity(
          duration: AppAnimations.durationFast,
          opacity: onTap == null ? 0.5 : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: AppRadius.lgBorder,
              border: style == AuthButtonVariant.guest
                  ? Border.all(color: AppColors.clayBorder, width: 2)
                  : null,
              boxShadow: _shadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppAnimations.durationFast,
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(_fg),
                          ),
                        )
                      : Row(
                          key: const ValueKey('content'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            icon,
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              text,
                              style: AppTypography.button.copyWith(color: _fg),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

Key change: `GestureDetector` → `ClayPressable`. `AnimatedSwitcher` for loading ↔ content cross-fade.

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/widgets/auth_button.dart
git commit -m "refactor(auth-button): use ClayPressable + AnimatedSwitcher for loading"
```

---

### Task 7: Add ClayPressable to ModeCard CTA + AnimatedSwitcher

**Files:**
- Modify: `lib/features/home/widgets/mode_card.dart:98-126`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/home/widgets/mode_card.dart` after the last import:

```dart
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace CTA GestureDetector block**

Replace lines 98-126 (the `GestureDetector` wrapping the CTA button) with:

```dart
          ClayPressable(
            onTap: isLoading ? null : onTap,
            builder: (context, isPressed) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.giant,
                  vertical: AppSpacing.mdd,
                ),
                decoration: BoxDecoration(
                  color: isLoading
                      ? accentColor.withValues(alpha: 0.6)
                      : accentColor,
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: AppShadows.colored(accentColor),
                ),
                child: AnimatedSwitcher(
                  duration: AppAnimations.durationFast,
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Text(
                          key: const ValueKey('text'),
                          '$ctaText \u{2192}',
                          style: AppTypography.button,
                        ),
                ),
              );
            },
          ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/widgets/mode_card.dart
git commit -m "refactor(mode-card): CTA use ClayPressable + AnimatedSwitcher"
```

---

### Task 8: Add ClayPressable to ModeDeepDiveCard CTA

**Files:**
- Modify: `lib/features/home/widgets/mode_deep_dive_card.dart:331-355`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/home/widgets/mode_deep_dive_card.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace _buildCta GestureDetector**

Replace the GestureDetector block inside `_buildCta()` (lines 331-355) with:

```dart
          ClayPressable(
            onTap: onTap,
            builder: (context, isPressed) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withValues(alpha: 0.4),
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${data.ctaText} →',
                  textAlign: TextAlign.center,
                  style: AppTypography.button.copyWith(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/widgets/mode_deep_dive_card.dart
git commit -m "refactor(deep-dive-card): CTA use ClayPressable for press feedback"
```

---

### Task 9: Add ClayPressable to LessonCard listen button

**Files:**
- Modify: `lib/features/scenario/widgets/lesson_card.dart:87-101`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/scenario/widgets/lesson_card.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace listen button GestureDetector**

Replace the GestureDetector wrapping the listen button (lines 89-101) with:

```dart
              ClayPressable(
                onTap: () =>
                    widget.onListen?.call(widget.vietnameseSentence),
                scaleDown: 0.90,
                builder: (context, isPressed) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const FluentIcon(AppIcons.listen, size: 20),
                  );
                },
              ),
```

Note: `scaleDown: 0.90` for small icon buttons — smaller elements need more pronounced scale to be perceptible.

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenario/widgets/lesson_card.dart
git commit -m "refactor(lesson-card): listen button use ClayPressable"
```

---

### Task 10: Add ClayPressable to AssessmentCard buttons

**Files:**
- Modify: `lib/features/scenario/widgets/assessment_card.dart`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/scenario/widgets/assessment_card.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace listen button GestureDetector (line ~547-549)**

Replace:

```dart
                        GestureDetector(
                          onTap: () => widget.onListen?.call(toneVar.text),
                          child: const FluentIcon(AppIcons.listen, size: 18),
                        ),
```

with:

```dart
                        ClayPressable(
                          onTap: () => widget.onListen?.call(toneVar.text),
                          scaleDown: 0.85,
                          builder: (context, isPressed) {
                            return const FluentIcon(AppIcons.listen, size: 18);
                          },
                        ),
```

- [ ] **Step 3: Replace bookmark button GestureDetector (line ~552-554)**

Replace:

```dart
                        GestureDetector(
                          onTap: () {},
                          child: const FluentIcon(AppIcons.bookmark, size: 18),
                        ),
```

with:

```dart
                        ClayPressable(
                          onTap: () {},
                          scaleDown: 0.85,
                          builder: (context, isPressed) {
                            return const FluentIcon(AppIcons.bookmark, size: 18);
                          },
                        ),
```

- [ ] **Step 4: Replace _difficultyButton method (lines 623-643)**

Replace the entire `_difficultyButton` method with:

```dart
  Widget _difficultyButton(String label, VoidCallback? onTap, Color color) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 11,
            ),
          ),
        );
      },
    );
  }
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/scenario/widgets/assessment_card.dart
git commit -m "refactor(assessment-card): listen, bookmark, difficulty buttons use ClayPressable"
```

---

### Task 11: Add ClayPressable to ChatBubbleUser listen button

**Files:**
- Modify: `lib/features/scenario/widgets/chat_bubble_user.dart:63-87`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/scenario/widgets/chat_bubble_user.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace listen button GestureDetector**

Replace the GestureDetector block (lines 63-87) with:

```dart
                ClayPressable(
                  onTap: onListen,
                  scaleDown: 0.90,
                  builder: (context, isPressed) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.clayBeige,
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FluentIcon(AppIcons.listen, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            'Listen',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warmMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/scenario/widgets/chat_bubble_user.dart
git commit -m "refactor(chat-bubble-user): listen button use ClayPressable"
```

---

### Task 12: Add ClayPressable to ScenarioAppBar buttons

**Files:**
- Modify: `lib/features/scenario/widgets/scenario_app_bar.dart:48-61, 108-119`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/scenario/widgets/scenario_app_bar.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace back button GestureDetector (lines 48-61)**

Replace:

```dart
              GestureDetector(
                onTap: onBack,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: AppColors.warmDark,
                    ),
                  ),
                ),
              ),
```

with:

```dart
              ClayPressable(
                onTap: onBack,
                scaleDown: 0.90,
                builder: (context, isPressed) {
                  return SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20,
                        color: AppColors.warmDark,
                      ),
                    ),
                  );
                },
              ),
```

- [ ] **Step 3: Replace _actionButton method (lines 108-119)**

Replace the entire `_actionButton` method with:

```dart
  Widget _actionButton(String iconUrl, double iconSize, VoidCallback? onTap) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.90,
      builder: (context, isPressed) {
        return SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: FluentIcon(iconUrl, size: iconSize),
          ),
        );
      },
    );
  }
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/scenario/widgets/scenario_app_bar.dart
git commit -m "refactor(scenario-app-bar): back + action buttons use ClayPressable"
```

---

### Task 13: Add ClayPressable to HomeScreen history button

**Files:**
- Modify: `lib/features/home/screens/home_screen.dart:291-300`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/home/screens/home_screen.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace history button GestureDetector**

Replace lines 291-300:

```dart
          GestureDetector(
            onTap: () => context.push('/history'),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: FluentIcon(AppIcons.history, size: 22),
              ),
            ),
          ),
```

with:

```dart
          ClayPressable(
            onTap: () => context.push('/history'),
            scaleDown: 0.90,
            builder: (context, isPressed) {
              return const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: FluentIcon(AppIcons.history, size: 22),
                ),
              );
            },
          ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/screens/home_screen.dart
git commit -m "refactor(home): history button use ClayPressable"
```

---

### Task 14: Add ClayPressable to StepTopics chips

**Files:**
- Modify: `lib/features/onboarding/widgets/step_topics.dart:40-74`

- [ ] **Step 1: Add import**

Add at the top of `lib/features/onboarding/widgets/step_topics.dart` after the last import:

```dart
import '../../../shared/widgets/clay_pressable.dart';
```

- [ ] **Step 2: Replace topic chip GestureDetector**

Replace the `GestureDetector` wrapping each topic chip (lines 40-74) with:

```dart
              return ClayPressable(
                onTap: () => provider.toggleTopic(topic.id),
                builder: (context, isPressed) {
                  return AnimatedContainer(
                    duration: AppAnimations.durationMedium,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.smd,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.teal.withValues(alpha: 0.1) : AppColors.clayWhite,
                      borderRadius: AppRadius.fullBorder,
                      border: Border.all(
                        color: isSelected ? AppColors.teal : AppColors.clayBorder,
                        width: 2,
                      ),
                      boxShadow: isSelected ? AppShadows.clay : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CloudImage(url: topic.emojiUrl, size: 24),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          topic.label,
                          style: AppTypography.labelMd.copyWith(
                            fontSize: 13,
                            color: isSelected ? AppColors.teal : AppColors.warmDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/widgets/step_topics.dart
git commit -m "refactor(step-topics): topic chips use ClayPressable"
```

---

### Task 15: Final verification

**Files:** All modified files

- [ ] **Step 1: Verify no remaining bare GestureDetector on tappable elements in modified files**

Run:

```bash
grep -n "GestureDetector" lib/shared/widgets/clay_button.dart lib/shared/widgets/clay_card.dart lib/features/auth/widgets/auth_button.dart lib/features/home/widgets/mode_card.dart lib/features/scenario/widgets/scenario_app_bar.dart lib/features/home/screens/home_screen.dart lib/features/onboarding/widgets/step_topics.dart
```

Expected: Zero results in these files (all GestureDetector replaced by ClayPressable). Note: `clay_pressable.dart` itself uses GestureDetector internally — that is correct.

- [ ] **Step 2: Verify ClayPressable adoption count**

Run:

```bash
grep -r "ClayPressable" lib/ --include="*.dart" -l
```

Expected: 13+ files importing or using ClayPressable.

- [ ] **Step 3: Verify no import errors**

Run:

```bash
grep -rn "import.*clay_pressable" lib/ --include="*.dart"
```

Expected: Imports present in all 11 modified feature/widget files.

- [ ] **Step 4: Verify AnimatedSwitcher adoption**

Run:

```bash
grep -rn "AnimatedSwitcher" lib/ --include="*.dart"
```

Expected: Present in `clay_button.dart`, `auth_button.dart`, `mode_card.dart`.

- [ ] **Step 5: Verify BouncingScrollBehavior wired**

Run:

```bash
grep -n "BouncingScrollBehavior\|ScrollConfiguration" lib/app.dart
```

Expected: Both present.
