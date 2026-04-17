# Design System Consistency Fixes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all P0, P1, and P2 design system inconsistencies identified in the gap analysis, making the codebase the single source of truth before updating documentation.

**Architecture:** Token-first approach — update/add design tokens first, then extract shared widgets, then refactor all feature files to consume tokens exclusively. Finally, add infrastructure (a11y, i18n, transitions, shimmer).

**Tech Stack:** Flutter 3.x / Dart ≥3.2, Google Fonts, cached_network_image, shimmer, GoRouter, flutter_localizations

---

## File Structure

### Token files (modify):
- `lib/core/theme/app_colors.dart` — add `white`, `goldDark`; add comments for overlapping tokens
- `lib/core/theme/app_spacing.dart` — add missing scale values
- `lib/core/theme/app_radius.dart` — add `xs`, `xxs` and their BorderRadius helpers
- `lib/core/theme/app_animations.dart` — add `durationMedium`; remove `easeBackOut`
- `lib/core/theme/app_shadows.dart` — add `colored()` factory; remove `clayHover`
- `lib/core/theme/app_typography.dart` — keep all 17 styles (they're used or planned); fix AuraLogo to use `logo`
- `lib/core/theme/app_theme.dart` — add component themes
- `lib/core/theme/app_semantic_colors.dart` — NEW: semantic color tokens for dark mode prep

### Shared widgets (create/modify):
- `lib/shared/widgets/selection_check_circle.dart` — NEW: extracted from 3 duplicate implementations
- `lib/shared/widgets/clay_badge.dart` — NEW: reusable badge/chip/pill
- `lib/shared/widgets/shimmer_placeholder.dart` — NEW: shimmer loading widget
- `lib/shared/widgets/cloud_image.dart` — modify to use shimmer
- `lib/shared/widgets/aura_logo.dart` — modify to use AppTypography.logo
- `lib/shared/widgets/error_banner.dart` — tokenize spacing
- `lib/shared/widgets/progress_dots.dart` — tokenize radius

### Feature files (modify for token adoption):
- `lib/features/auth/screens/auth_screen.dart`
- `lib/features/auth/widgets/auth_button.dart`
- `lib/features/home/screens/home_screen.dart`
- `lib/features/home/widgets/bottom_nav_bar.dart`
- `lib/features/home/widgets/mode_card.dart`
- `lib/features/splash/screens/splash_screen.dart`
- `lib/features/onboarding/widgets/step_daily_time.dart`
- `lib/features/onboarding/widgets/step_name_avatar.dart`
- `lib/features/onboarding/widgets/step_level.dart`
- `lib/features/onboarding/widgets/step_goals.dart`
- `lib/features/onboarding/widgets/step_topics.dart`
- `lib/features/scenario/widgets/scenario_app_bar.dart`

### Infrastructure (create/modify):
- `lib/core/theme/page_transitions.dart` — NEW: custom FadeTransition
- `lib/core/router/app_router.dart` — modify for page transitions
- `lib/l10n/app_en.arb` — NEW: English strings
- `lib/l10n/app_vi.arb` — NEW: Vietnamese strings
- `pubspec.yaml` — add shimmer, flutter_localizations dependencies

---

## Task 1: Update AppColors — Add Missing Tokens + Document Overlaps

**Files:**
- Modify: `lib/core/theme/app_colors.dart`

- [ ] **Step 1: Update app_colors.dart with new tokens and overlap documentation**

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Surface
  static const cream = Color(0xFFFFF8F0);
  static const clayWhite = Color(0xFFFEFCF9);
  static const clayBeige = Color(0xFFF5EDE3);
  static const clayBorder = Color(0xFFE8DFD3);
  static const clayShadow = Color(0xFFD4C9BB);
  static const white = Color(0xFFFFFFFF);

  // Text
  static const warmDark = Color(0xFF2D3047);
  static const warmMuted = Color(0xFF6B6D7B);
  static const warmLight = Color(0xFF9B9DAB);

  // Accent
  static const teal = Color(0xFF7ECEC5);
  static const purple = Color(0xFFA78BCA);
  static const gold = Color(0xFFE8C77B);
  static const goldDark = Color(0xFF9A7B3D);
  static const coral = Color(0xFFE8927C);

  // Semantic — intentionally shares hex with accent/tone where applicable.
  // If tone colors need to diverge from semantic, update only the tone value.
  static const success = Color(0xFF7BC6A0); // same as neutralTone
  static const warning = Color(0xFFE8C77B); // same as gold, friendlyTone
  static const error = Color(0xFFD98A8A); // same as casualTone

  // Tone Colors — used for conversation tone indicators.
  // Intentionally overlap with semantic colors for visual coherence.
  static const formalTone = Color(0xFF6366F1);
  static const neutralTone = Color(0xFF7BC6A0); // same as success
  static const friendlyTone = Color(0xFFE8C77B); // same as gold, warning
  static const casualTone = Color(0xFFD98A8A); // same as error
}
```

- [ ] **Step 2: Verify no compilation errors**

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && grep -rn "Colors\.white" lib/ | head -20`
Expected: List of files that will need updating in later tasks.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_colors.dart
git commit -m "feat(tokens): add AppColors.white, goldDark; document color overlaps"
```

---

## Task 2: Update AppSpacing — Add Missing Scale Values

**Files:**
- Modify: `lib/core/theme/app_spacing.dart`

- [ ] **Step 1: Update app_spacing.dart with full scale**

The existing scale is 4, 8, 12, 16, 24, 32, 40. Hardcoded values found in codebase: 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 48. Add tokens to cover these.

```dart
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 10;
  static const double md = 12;
  static const double mdd = 14;
  static const double lg = 16;
  static const double lgg = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double huge = 32;
  static const double massive = 40;
  static const double giant = 48;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/app_spacing.dart
git commit -m "feat(tokens): expand AppSpacing scale to cover all used values"
```

---

## Task 3: Update AppRadius — Add xs and xxs

**Files:**
- Modify: `lib/core/theme/app_radius.dart`

- [ ] **Step 1: Update app_radius.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;

  static final xxsBorder = BorderRadius.circular(xxs);
  static final xsBorder = BorderRadius.circular(xs);
  static final smBorder = BorderRadius.circular(sm);
  static final mdBorder = BorderRadius.circular(md);
  static final lgBorder = BorderRadius.circular(lg);
  static final xlBorder = BorderRadius.circular(xl);
  static final fullBorder = BorderRadius.circular(full);
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/app_radius.dart
git commit -m "feat(tokens): add AppRadius.xxs and xs with BorderRadius helpers"
```

---

## Task 4: Update AppAnimations — Add durationMedium, Remove easeBackOut

**Files:**
- Modify: `lib/core/theme/app_animations.dart`

- [ ] **Step 1: Update app_animations.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppAnimations {
  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 200);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);

  static const easeClay = Curves.easeInOut;
}
```

- [ ] **Step 2: Verify easeBackOut is not used anywhere**

Run: `grep -rn "easeBackOut" lib/`
Expected: Only the definition in app_animations.dart (which we just removed). If found elsewhere, keep it.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_animations.dart
git commit -m "feat(tokens): add durationMedium (200ms); remove unused easeBackOut"
```

---

## Task 5: Update AppShadows — Add colored() Factory, Remove clayHover

**Files:**
- Modify: `lib/core/theme/app_shadows.dart`

- [ ] **Step 1: Update app_shadows.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppShadows {
  static const clay = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(3, 3)),
  ];

  static const clayPressed = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(1, 1)),
  ];

  static const soft = [
    BoxShadow(
      color: Color(0x0F2D3047),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0A2D3047),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const lifted = [
    BoxShadow(
      color: Color(0x1A2D3047),
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
    BoxShadow(color: AppColors.clayShadow, offset: Offset(3, 3)),
  ];

  /// Clay shadow using a custom accent color.
  /// Replaces inline `BoxShadow(color: accentColor.withValues(alpha: 0.4), offset: Offset(3, 3))`.
  static List<BoxShadow> colored(Color accentColor, {double alpha = 0.4}) {
    return [
      BoxShadow(
        color: accentColor.withValues(alpha: alpha),
        offset: const Offset(3, 3),
      ),
    ];
  }
}
```

- [ ] **Step 2: Verify clayHover is not used**

Run: `grep -rn "clayHover" lib/`
Expected: Only the old definition. If used elsewhere, keep it.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_shadows.dart
git commit -m "feat(tokens): add AppShadows.colored() factory; remove unused clayHover"
```

---

## Task 6: Create AppSemanticColors for Dark Mode Prep

**Files:**
- Create: `lib/core/theme/app_semantic_colors.dart`

- [ ] **Step 1: Create semantic color tokens**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic color tokens that map to different values per theme.
/// Usage: `AppSemanticColors.of(context).surface`
/// For now, only light theme values are defined. Dark values will be added
/// after analytics confirms dark mode demand.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceLight;
  final Color primary;
  final Color onPrimary;
  final Color cardBackground;
  final Color divider;
  final Color shadow;

  const AppSemanticColors({
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceLight,
    required this.primary,
    required this.onPrimary,
    required this.cardBackground,
    required this.divider,
    required this.shadow,
  });

  static const light = AppSemanticColors(
    surface: AppColors.cream,
    surfaceVariant: AppColors.clayWhite,
    onSurface: AppColors.warmDark,
    onSurfaceMuted: AppColors.warmMuted,
    onSurfaceLight: AppColors.warmLight,
    primary: AppColors.teal,
    onPrimary: AppColors.white,
    cardBackground: AppColors.clayBeige,
    divider: AppColors.clayBorder,
    shadow: AppColors.clayShadow,
  );

  static AppSemanticColors of(BuildContext context) {
    return Theme.of(context).extension<AppSemanticColors>() ?? light;
  }

  @override
  AppSemanticColors copyWith({
    Color? surface,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? onSurfaceLight,
    Color? primary,
    Color? onPrimary,
    Color? cardBackground,
    Color? divider,
    Color? shadow,
  }) {
    return AppSemanticColors(
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      onSurfaceLight: onSurfaceLight ?? this.onSurfaceLight,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      cardBackground: cardBackground ?? this.cardBackground,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      onSurfaceLight: Color.lerp(onSurfaceLight, other.onSurfaceLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/app_semantic_colors.dart
git commit -m "feat(tokens): add AppSemanticColors ThemeExtension for dark mode prep"
```

---

## Task 7: Update AppTheme — Add Component Themes + Semantic Extension

**Files:**
- Modify: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Update app_theme.dart with component themes**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_semantic_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: const ColorScheme.light(
          primary: AppColors.teal,
          secondary: AppColors.purple,
          tertiary: AppColors.gold,
          surface: AppColors.cream,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSurface: AppColors.warmDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.warmDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.h3,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLg,
          displayMedium: AppTypography.displayMd,
          headlineLarge: AppTypography.h1,
          headlineMedium: AppTypography.h2,
          headlineSmall: AppTypography.h3,
          bodyLarge: AppTypography.bodyLg,
          bodyMedium: AppTypography.bodyMd,
          bodySmall: AppTypography.bodySm,
          labelLarge: AppTypography.labelLg,
          labelMedium: AppTypography.labelMd,
          labelSmall: AppTypography.labelSm,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: AppColors.white,
            textStyle: AppTypography.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgBorder,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.clayBeige,
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.warmLight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.lgBorder,
            borderSide: const BorderSide(color: AppColors.clayBorder, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgBorder,
            borderSide: const BorderSide(color: AppColors.clayBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgBorder,
            borderSide: const BorderSide(color: AppColors.teal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgBorder,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.clayWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          titleTextStyle: AppTypography.h2,
          contentTextStyle: AppTypography.bodyMd,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.clayWhite,
          selectedItemColor: AppColors.teal,
          unselectedItemColor: AppColors.warmLight,
          elevation: 0,
        ),
        extensions: const [
          AppSemanticColors.light,
        ],
      );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat(theme): add component themes + AppSemanticColors extension"
```

---

## Task 8: Extract SelectionCheckCircle Shared Widget

**Files:**
- Create: `lib/shared/widgets/selection_check_circle.dart`

- [ ] **Step 1: Create the shared widget**

This replaces 3 duplicate implementations: `step_level.dart` _CheckCircle (24x24), `step_goals.dart` inline check (24x24), `step_daily_time.dart` inline check (28x28). All will use 44x44 touch target.

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_animations.dart';

class SelectionCheckCircle extends StatelessWidget {
  final bool isSelected;
  final double size;

  const SelectionCheckCircle({
    super.key,
    required this.isSelected,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: AnimatedContainer(
          duration: AppAnimations.durationMedium,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.teal : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.teal : AppColors.clayBorder,
              width: 2,
            ),
          ),
          child: isSelected
              ? Icon(Icons.check, size: size * 0.5, color: AppColors.white)
              : null,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/selection_check_circle.dart
git commit -m "feat(widgets): extract SelectionCheckCircle from 3 duplicate implementations"
```

---

## Task 9: Create ClayBadge Shared Widget

**Files:**
- Create: `lib/shared/widgets/clay_badge.dart`

- [ ] **Step 1: Create the shared badge/chip widget**

Consolidates badge/chip/pill patterns found in mode_card.dart, step_topics.dart, and multiple other files.

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class ClayBadge extends StatelessWidget {
  final String text;
  final Color accentColor;
  final bool isOutlined;

  const ClayBadge({
    super.key,
    required this.text,
    this.accentColor = AppColors.teal,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : accentColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
        border: isOutlined
            ? Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/clay_badge.dart
git commit -m "feat(widgets): extract ClayBadge for reusable badge/chip/pill pattern"
```

---

## Task 10: Create ShimmerPlaceholder + Update CloudImage

**Files:**
- Create: `lib/shared/widgets/shimmer_placeholder.dart`
- Modify: `lib/shared/widgets/cloud_image.dart`

- [ ] **Step 1: Add shimmer dependency**

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && grep "shimmer:" pubspec.yaml`
Expected: Not found. Need to add it.

Add to `pubspec.yaml` under dependencies:
```yaml
  shimmer: ^3.0.0
```

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && flutter pub get`

- [ ] **Step 2: Create shimmer_placeholder.dart**

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.clayBeige,
      highlightColor: AppColors.clayWhite,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.clayBeige,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Update cloud_image.dart to use shimmer**

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import 'shimmer_placeholder.dart';

class CloudImage extends StatelessWidget {
  final String url;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CloudImage({
    super.key,
    required this.url,
    this.size = 64,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: fit,
      placeholder: (_, __) => ShimmerPlaceholder(
        width: size,
        height: size,
        borderRadius: borderRadius,
      ),
      errorWidget: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.broken_image, color: AppColors.warmLight),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml lib/shared/widgets/shimmer_placeholder.dart lib/shared/widgets/cloud_image.dart
git commit -m "feat(widgets): add shimmer loading for CloudImage, replace CircularProgressIndicator"
```

---

## Task 11: Fix AuraLogo to Use AppTypography.logo

**Files:**
- Modify: `lib/shared/widgets/aura_logo.dart`

- [ ] **Step 1: Update aura_logo.dart to use AppTypography.logo**

Replace the inline `GoogleFonts.fredoka()` call with `AppTypography.logo`. The `logo` token already uses `GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2)`. The widget uses variable fontSize, so we use `copyWith`.

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/cloudinary_assets.dart';
import 'cloud_image.dart';

class AuraLogo extends StatelessWidget {
  final double fontSize;
  final bool compact;
  final Color? color;

  const AuraLogo({super.key, this.fontSize = 28, this.compact = false, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.teal;
    final orbSize = fontSize * 2.0;
    final style = AppTypography.logo.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: fontSize * 0.04,
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('AURA C', style: style.copyWith(color: effectiveColor)),
          SizedBox(
            width: orbSize - AppSpacing.lg,
            height: orbSize,
            child: CloudImage(url: CloudinaryAssets.auraOrbLarge, size: orbSize),
          ),
          Text('ACH', style: style.copyWith(color: effectiveColor)),
          Text('.AI', style: style.copyWith(color: AppColors.warmDark, letterSpacing: 0)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('AURA', style: style.copyWith(color: effectiveColor)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('C', style: style.copyWith(color: effectiveColor)),
            SizedBox(
              width: orbSize - AppSpacing.giant,
              height: orbSize,
              child: CloudImage(url: CloudinaryAssets.auraOrbLarge, size: orbSize),
            ),
            Text('ACH', style: style.copyWith(color: effectiveColor)),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text('.AI', style: style.copyWith(color: AppColors.warmDark, letterSpacing: 0)),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/aura_logo.dart
git commit -m "refactor(widgets): use AppTypography.logo in AuraLogo instead of inline GoogleFonts"
```

---

## Task 12: Tokenize Shared Widgets (ErrorBanner, ProgressDots)

**Files:**
- Modify: `lib/shared/widgets/error_banner.dart`
- Modify: `lib/shared/widgets/progress_dots.dart`

- [ ] **Step 1: Update error_banner.dart — tokenize spacing**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(color: AppColors.error),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(Icons.close, color: AppColors.error, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update progress_dots.dart — tokenize radius**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';

class ProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isDone = index < currentStep;
          return AnimatedContainer(
            duration: AppAnimations.durationNormal,
            curve: AppAnimations.easeClay,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: isActive ? AppSpacing.xxl : AppSpacing.sm,
            height: AppSpacing.sm,
            decoration: BoxDecoration(
              color: (isActive || isDone) ? AppColors.teal : AppColors.clayBorder,
              borderRadius: AppRadius.xsBorder,
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/error_banner.dart lib/shared/widgets/progress_dots.dart
git commit -m "refactor(widgets): tokenize spacing and radius in ErrorBanner, ProgressDots"
```

---

## Task 13: Refactor AuthScreen — Replace Hardcoded Styles

**Files:**
- Modify: `lib/features/auth/screens/auth_screen.dart`

- [ ] **Step 1: Update auth_screen.dart**

Replace `GoogleFonts.inter()` calls with AppTypography tokens. Replace hardcoded spacing with AppSpacing tokens.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AuraLogo(fontSize: 64),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Your personal AI English coach.\nLearn naturally, speak confidently.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.warmMuted,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xxl,
                    right: AppSpacing.xxl,
                    bottom: AppSpacing.sm,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AuthButton(
                          text: 'Continue with Google',
                          icon: const _GoogleIcon(),
                          style: AuthButtonStyle.google,
                          isLoading: auth.isMethodLoading(AuthMethod.google),
                          onTap: auth.isAnyLoading
                              ? null
                              : () => auth.signInWithGoogle(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthButton(
                          text: 'Continue with Apple',
                          icon: Icon(
                            Icons.apple,
                            size: 20,
                            color: AppColors.white,
                          ),
                          style: AuthButtonStyle.apple,
                          isLoading: auth.isMethodLoading(AuthMethod.apple),
                          onTap: auth.isAnyLoading
                              ? null
                              : () => auth.signInWithApple(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthButton(
                          text: 'Try as Guest',
                          icon: const Text(
                            '\u{1F464}',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: AuthButtonStyle.guest,
                          isLoading: auth.isMethodLoading(AuthMethod.guest),
                          onTap: auth.isAnyLoading
                              ? null
                              : () => auth.continueAsGuest(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'By continuing you agree to our\nTerms of Service and Privacy Policy',
                          style: AppTypography.caption,
                          textAlign: TextAlign.center,
                        ),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          ErrorBanner(
                            message: auth.errorMessage!,
                            onDismiss: auth.clearError,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(w * 0.94, h * 0.51)
      ..cubicTo(w * 0.94, h * 0.48, w * 0.937, h * 0.44, w * 0.932, h * 0.417)
      ..lineTo(w * 0.5, h * 0.417)
      ..lineTo(w * 0.5, h * 0.594)
      ..lineTo(w * 0.747, h * 0.594)
      ..cubicTo(w * 0.735, h * 0.665, w * 0.697, h * 0.725, w * 0.655, h * 0.763)
      ..lineTo(w * 0.804, h * 0.878)
      ..cubicTo(w * 0.89, h * 0.798, w * 0.94, h * 0.68, w * 0.94, h * 0.51);
    canvas.drawPath(bluePath, bluePaint);

    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(w * 0.5, h * 0.958)
      ..cubicTo(w * 0.624, h * 0.958, w * 0.727, h * 0.917, w * 0.804, h * 0.847)
      ..lineTo(w * 0.655, h * 0.732)
      ..cubicTo(w * 0.614, h * 0.76, w * 0.562, h * 0.776, w * 0.5, h * 0.776)
      ..cubicTo(w * 0.381, h * 0.776, w * 0.28, h * 0.695, w * 0.243, h * 0.587)
      ..lineTo(w * 0.091, h * 0.705)
      ..cubicTo(w * 0.166, h * 0.855, w * 0.321, h * 0.958, w * 0.5, h * 0.958);
    canvas.drawPath(greenPath, greenPaint);

    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(w * 0.243, h * 0.587)
      ..cubicTo(w * 0.234, h * 0.56, w * 0.228, h * 0.53, w * 0.228, h * 0.5)
      ..cubicTo(w * 0.228, h * 0.47, w * 0.234, h * 0.44, w * 0.243, h * 0.413)
      ..lineTo(w * 0.091, h * 0.295)
      ..cubicTo(w * 0.042, h * 0.39, w * 0.042, h * 0.5, w * 0.042, h * 0.5)
      ..cubicTo(w * 0.042, h * 0.574, w * 0.059, h * 0.644, w * 0.091, h * 0.705)
      ..lineTo(w * 0.243, h * 0.587);
    canvas.drawPath(yellowPath, yellowPaint);

    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(w * 0.5, h * 0.224)
      ..cubicTo(w * 0.567, h * 0.224, w * 0.627, h * 0.247, w * 0.675, h * 0.292)
      ..lineTo(w * 0.806, h * 0.161)
      ..cubicTo(w * 0.727, h * 0.087, w * 0.624, h * 0.042, w * 0.5, h * 0.042)
      ..cubicTo(w * 0.321, h * 0.042, w * 0.166, h * 0.145, w * 0.091, h * 0.295)
      ..lineTo(w * 0.243, h * 0.413)
      ..cubicTo(w * 0.28, h * 0.305, w * 0.381, h * 0.224, w * 0.5, h * 0.224);
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/screens/auth_screen.dart
git commit -m "refactor(auth): replace hardcoded styles with AppTypography/AppSpacing tokens"
```

---

## Task 14: Refactor AuthButton — Replace Hardcoded Styles

**Files:**
- Modify: `lib/features/auth/widgets/auth_button.dart`

- [ ] **Step 1: Update auth_button.dart**

Replace `GoogleFonts.inter()`, `Color(0xFFD4C9BB)` duplicate, `Colors.white`, and hardcoded spacing.

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';

enum AuthButtonStyle {
  google,
  apple,
  guest,
}

class AuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final AuthButtonStyle style;
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
      case AuthButtonStyle.google:
        return AppColors.teal;
      case AuthButtonStyle.apple:
        return AppColors.warmDark;
      case AuthButtonStyle.guest:
        return Colors.transparent;
    }
  }

  Color get _fg {
    switch (style) {
      case AuthButtonStyle.google:
      case AuthButtonStyle.apple:
        return AppColors.white;
      case AuthButtonStyle.guest:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow>? get _shadow {
    switch (style) {
      case AuthButtonStyle.google:
        return AppShadows.clay;
      case AuthButtonStyle.apple:
        return AppShadows.colored(AppColors.warmDark, alpha: 0.3);
      case AuthButtonStyle.guest:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
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
            border: style == AuthButtonStyle.guest
                ? Border.all(color: AppColors.clayBorder, width: 2)
                : null,
            boxShadow: _shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(_fg),
                  ),
                )
              else ...[
                icon,
                const SizedBox(width: AppSpacing.md),
                Text(
                  text,
                  style: AppTypography.button.copyWith(color: _fg),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/widgets/auth_button.dart
git commit -m "refactor(auth): tokenize AuthButton colors, shadows, spacing, typography"
```

---

## Task 15: Refactor SplashScreen — Replace Hardcoded Colors

**Files:**
- Modify: `lib/features/splash/screens/splash_screen.dart`

- [ ] **Step 1: Update splash_screen.dart**

Replace `Color(0xFF7ECEC5)` with `AppColors.teal`.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _initAndRedirect();
  }

  Future<void> _initAndRedirect() async {
    final auth = context.read<AuthProvider>();
    await auth.initialize();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (auth.status == AuthStatus.unauthenticated) {
      context.go('/auth');
    } else if (!auth.hasCompletedOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.teal.withValues(alpha: 0.15),
                    AppColors.teal.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.7],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: child,
                );
              },
              child: SizedBox(
                width: 180,
                height: 180,
                child: Center(
                  child: CloudImage(
                    url: CloudinaryAssets.auraOrbLarge,
                    size: 160,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/splash/screens/splash_screen.dart
git commit -m "refactor(splash): replace hardcoded Color(0xFF7ECEC5) with AppColors.teal"
```

---

## Task 16: Refactor HomeScreen — Tokenize TopBar

**Files:**
- Modify: `lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Update home_screen.dart**

Fix `_TopBar`: replace `fontFamily: 'Nunito'` bypass, inline BoxShadow, hardcoded spacing. Fix touch target on history button to 44x44.

In `_TopBar`, replace lines 278-327 with:

```dart
class _TopBar extends StatelessWidget {
  final Color accentColor;

  const _TopBar({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final profile = homeProvider.userProfile;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AuraLogo(fontSize: 16, compact: true, color: accentColor),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/history'),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text('\u{1F4CB}', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (profile != null) ...[
            Text(
              'Hi, ${profile.name}',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warmDark,
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
                boxShadow: AppShadows.clay,
              ),
              child: ClipOval(
                child: CloudImage(url: profile.avatarUrl, size: 32),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

Also add imports at the top of the file:
```dart
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/home/screens/home_screen.dart
git commit -m "refactor(home): tokenize TopBar spacing, shadows, typography; fix touch targets"
```

---

## Task 17: Refactor BottomNavBar — Tokenize Animations + Fix Touch Targets

**Files:**
- Modify: `lib/features/home/widgets/bottom_nav_bar.dart`

- [ ] **Step 1: Update bottom_nav_bar.dart**

Replace `Duration(milliseconds: 200)` with `AppAnimations.durationMedium`, `Curves.easeOut` with `AppAnimations.easeClay`. Fix touch target padding.

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../core/constants/cloudinary_assets.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.clayWhite,
          border: Border(top: BorderSide(color: AppColors.clayBorder, width: 2)),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              imageUrl: CloudinaryAssets.navHome,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              emoji: '\u{1F464}',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              imageUrl: CloudinaryAssets.navSettings,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String? emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.imageUrl,
    this.icon,
    this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 44,
        child: Center(
          child: AnimatedScale(
            scale: isActive ? 1.15 : 1.0,
            duration: AppAnimations.durationMedium,
            curve: AppAnimations.easeClay,
            child: Opacity(
              opacity: isActive ? 1.0 : 0.45,
              child: _buildIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (imageUrl != null) {
      return CloudImage(url: imageUrl!, size: 32);
    } else if (emoji != null) {
      return Text(
        emoji!,
        style: const TextStyle(fontSize: 28),
      );
    } else {
      return Icon(
        icon,
        size: 32,
        color: isActive ? AppColors.teal : AppColors.warmLight,
      );
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/home/widgets/bottom_nav_bar.dart
git commit -m "refactor(nav): tokenize BottomNavBar animations/spacing; fix touch targets to 44dp"
```

---

## Task 18: Refactor ModeCard — Tokenize Shadows, Radius, Typography

**Files:**
- Modify: `lib/features/home/widgets/mode_card.dart`

- [ ] **Step 1: Update mode_card.dart**

Replace `BorderRadius.circular(40)`, inline BoxShadow, `fontFamily: 'Nunito'` bypass, `Colors.white`, hardcoded spacing.

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/clay_badge.dart';

class ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconUrl;
  final Color accentColor;
  final String badgeText;
  final String ctaText;
  final String quotaText;
  final List<String> tags;
  final VoidCallback? onTap;
  final bool isLoading;

  const ModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.accentColor,
    required this.badgeText,
    required this.ctaText,
    required this.quotaText,
    required this.tags,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cream, accentColor.withValues(alpha: 0.08)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.fullBorder,
            ),
            child: Text(
              badgeText,
              style: AppTypography.caption.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.xlBorder,
              border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 2),
            ),
            child: Center(child: CloudImage(url: iconUrl, size: 100)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: AppTypography.h1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: tags.map((tag) {
              return ClayBadge(text: tag, accentColor: accentColor);
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Container(
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
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(
                      '$ctaText \u{2192}',
                      style: AppTypography.button,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(quotaText, style: AppTypography.caption),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/home/widgets/mode_card.dart
git commit -m "refactor(home): tokenize ModeCard shadows, radius, spacing, typography; use ClayBadge"
```

---

## Task 19: Refactor Onboarding Step Widgets

**Files:**
- Modify: `lib/features/onboarding/widgets/step_daily_time.dart`
- Modify: `lib/features/onboarding/widgets/step_level.dart`
- Modify: `lib/features/onboarding/widgets/step_goals.dart`
- Modify: `lib/features/onboarding/widgets/step_name_avatar.dart`
- Modify: `lib/features/onboarding/widgets/step_topics.dart`

- [ ] **Step 1: Update step_daily_time.dart — use SelectionCheckCircle + tokens**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/selection_check_circle.dart';

class StepDailyTime extends StatelessWidget {
  const StepDailyTime({super.key});

  static const _bgColors = [
    Color(0x267BC6A0),
    Color(0x267ECEC5),
    Color(0x26E8C77B),
    Color(0x26A78BCA),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CloudImage(
              url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Alarm%20Clock.png',
              size: 80,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'How much time daily?',
              style: AppTypography.displayMd.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              "We'll build the right plan for you",
              style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ...List.generate(dailyTimeOptions.length, (i) {
            final option = dailyTimeOptions[i];
            final isSelected = provider.dailyMinutes == option.minutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lgg,
                ),
                onTap: () => provider.setDailyMinutes(option.minutes),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _bgColors[i],
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: Center(
                        child: CloudImage(url: option.emojiUrl, size: 32),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.mdd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.label, style: AppTypography.labelLg.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            option.description,
                            style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
                          ),
                        ],
                      ),
                    ),
                    SelectionCheckCircle(isSelected: isSelected, size: 28),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update step_level.dart — use SelectionCheckCircle + tokens**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/selection_check_circle.dart';

class StepLevel extends StatelessWidget {
  const StepLevel({super.key});

  String _iconUrl(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return CloudinaryAssets.levelBeginner;
      case ProficiencyLevel.intermediate:
        return CloudinaryAssets.levelIntermediate;
      case ProficiencyLevel.advanced:
        return CloudinaryAssets.levelAdvanced;
    }
  }

  Color _cefrColor(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return AppColors.success;
      case ProficiencyLevel.intermediate:
        return AppColors.gold;
      case ProficiencyLevel.advanced:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your English level?",
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll personalize lessons just for you",
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ...ProficiencyLevel.values.map((level) {
            final isSelected = provider.proficiencyLevel == level.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.all(AppSpacing.lgg),
                onTap: () => provider.setProficiencyLevel(level.id),
                child: Row(
                  children: [
                    CloudImage(url: _iconUrl(level), size: 72),
                    const SizedBox(width: AppSpacing.mdd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(level.label, style: AppTypography.labelLg.copyWith(fontSize: 17)),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            level.cefr,
                            style: AppTypography.labelSm.copyWith(
                              color: _cefrColor(level),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            level.description,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 13,
                              color: AppColors.warmMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SelectionCheckCircle(isSelected: isSelected),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Update step_goals.dart — use SelectionCheckCircle + tokens**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/selection_check_circle.dart';

class StepGoals extends StatelessWidget {
  const StepGoals({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your goals?',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select all that apply',
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ...learningGoals.map((goal) {
            final isSelected = provider.selectedGoals.contains(goal.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.smd),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.mdd,
                ),
                onTap: () => provider.toggleGoal(goal.id),
                child: Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: AppSpacing.mdd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.label, style: AppTypography.labelLg.copyWith(fontSize: 16)),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            goal.description,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 13,
                              color: AppColors.warmMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SelectionCheckCircle(isSelected: isSelected),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Update step_name_avatar.dart — tokenize spacing, shadows**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepNameAvatar extends StatelessWidget {
  const StepNameAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CloudImage(
              url: CloudinaryAssets.auraOrbLarge,
              size: 100,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'What should we call you?',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick a name and choose your avatar',
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.clayBeige,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: AppColors.teal, width: 2),
            ),
            child: TextField(
              onChanged: provider.setName,
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.warmLight),
                border: InputBorder.none,
                icon: const Icon(Icons.edit, size: 18, color: AppColors.warmMuted),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'CHOOSE YOUR BUDDY',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.warmLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: avatarOptions.map((avatar) {
              final isSelected = provider.selectedAvatarId == avatar.id;
              return GestureDetector(
                onTap: () => provider.selectAvatar(avatar.id, avatar.url),
                child: Transform.scale(
                  scale: isSelected ? 1.15 : 1.0,
                  child: AnimatedContainer(
                    duration: AppAnimations.durationMedium,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.teal : AppColors.clayBorder,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.teal.withValues(alpha: 0.25),
                                blurRadius: 0,
                                spreadRadius: 3,
                              ),
                              ...AppShadows.clay,
                            ]
                          : AppShadows.card,
                    ),
                    child: ClipOval(
                      child: CloudImage(url: avatar.url, size: 60),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Update step_topics.dart — tokenize spacing, radius, animations**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/topic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepTopics extends StatelessWidget {
  const StepTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your interests',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll tailor scenarios to what matters to you",
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.smd,
            runSpacing: AppSpacing.smd,
            children: topicOptions.map((topic) {
              final isSelected = provider.selectedTopics.contains(topic.id);
              return GestureDetector(
                onTap: () => provider.toggleTopic(topic.id),
                child: AnimatedContainer(
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
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.mdd),
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.smd),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lgg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.clayBeige,
              borderRadius: AppRadius.fullBorder,
              border: Border.all(color: AppColors.clayBorder, width: 2),
            ),
            child: Row(
              children: [
                const Text(
                  '\u{2728}',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Add your own topic...',
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 14,
                      color: AppColors.warmLight,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Selected: ',
                style: AppTypography.caption,
                children: [
                  TextSpan(
                    text: '${provider.selectedTopics.length} topics',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/onboarding/widgets/step_daily_time.dart lib/features/onboarding/widgets/step_level.dart lib/features/onboarding/widgets/step_goals.dart lib/features/onboarding/widgets/step_name_avatar.dart lib/features/onboarding/widgets/step_topics.dart
git commit -m "refactor(onboarding): tokenize all steps; use SelectionCheckCircle, AppSpacing, AppAnimations"
```

---

## Task 20: Refactor ScenarioAppBar — Tokenize + Fix Touch Targets

**Files:**
- Modify: `lib/features/scenario/widgets/scenario_app_bar.dart`

- [ ] **Step 1: Update scenario_app_bar.dart**

Replace `fontFamily: 'Nunito'` bypass, `BorderRadius.circular(2)`, hardcoded spacing, fix touch targets to 44x44.

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ScenarioAppBar extends StatelessWidget {
  final String title;
  final String emoji;
  final String category;
  final String level;
  final int scenarioIndex;
  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onHistory;
  final VoidCallback? onMyLearning;

  const ScenarioAppBar({
    super.key,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
    required this.scenarioIndex,
    required this.progress,
    this.onBack,
    this.onHistory,
    this.onMyLearning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      color: AppColors.cream,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Text(
                      '\u{2039}',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _actionIcon('\u{1F4CB}', onHistory),
              _actionIcon('\u{1F4DA}', onMyLearning),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.massive),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$emoji $category \u{00B7} $level \u{00B7} Scenario #$scenarioIndex',
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadius.xxsBorder,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.clayBeige,
              valueColor: AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _actionIcon(String emoji, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/scenario/widgets/scenario_app_bar.dart
git commit -m "refactor(scenario): tokenize ScenarioAppBar; fix touch targets to 44dp minimum"
```

---

## Task 21: Create Custom Page Transitions

**Files:**
- Create: `lib/core/theme/page_transitions.dart`

- [ ] **Step 1: Create page_transitions.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_animations.dart';

/// Custom fade page transition matching design system spec.
CustomTransitionPage<T> fadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: AppAnimations.easeClay).animate(animation),
        child: child,
      );
    },
    transitionDuration: AppAnimations.durationNormal,
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/page_transitions.dart
git commit -m "feat(nav): add custom FadeTransition page transition as documented in design system"
```

---

## Task 22: Set Up i18n Framework

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_vi.arb`

- [ ] **Step 1: Add flutter_localizations to pubspec.yaml**

In `pubspec.yaml`, ensure under `dependencies`:
```yaml
  flutter_localizations:
    sdk: flutter
```

And under `flutter`:
```yaml
  generate: true
```

- [ ] **Step 2: Create l10n.yaml in project root**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

- [ ] **Step 3: Create app_en.arb with initial strings from auth and onboarding**

```json
{
  "@@locale": "en",
  "authSubtitle": "Your personal AI English coach.\nLearn naturally, speak confidently.",
  "continueWithGoogle": "Continue with Google",
  "continueWithApple": "Continue with Apple",
  "tryAsGuest": "Try as Guest",
  "termsNotice": "By continuing you agree to our\nTerms of Service and Privacy Policy",
  "onboardingNameTitle": "What should we call you?",
  "onboardingNameSubtitle": "Pick a name and choose your avatar",
  "onboardingNameHint": "Enter your name",
  "onboardingBuddyLabel": "CHOOSE YOUR BUDDY",
  "onboardingLevelTitle": "What's your English level?",
  "onboardingLevelSubtitle": "We'll personalize lessons just for you",
  "onboardingGoalsTitle": "What are your goals?",
  "onboardingGoalsSubtitle": "Select all that apply",
  "onboardingTopicsTitle": "Pick your interests",
  "onboardingTopicsSubtitle": "We'll tailor scenarios to what matters to you",
  "onboardingTimeTitle": "How much time daily?",
  "onboardingTimeSubtitle": "We'll build the right plan for you",
  "addYourOwnTopic": "Add your own topic...",
  "selectedTopicsCount": "Selected: {count} topics",
  "@selectedTopicsCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  },
  "dailyLimitReached": "Daily limit reached. Upgrade for more sessions.",
  "failedToStart": "Failed to start: {error}",
  "@failedToStart": {
    "placeholders": {
      "error": {
        "type": "String"
      }
    }
  }
}
```

- [ ] **Step 4: Create app_vi.arb with Vietnamese translations**

```json
{
  "@@locale": "vi",
  "authSubtitle": "Huấn luyện viên tiếng Anh AI của bạn.\nHọc tự nhiên, nói tự tin.",
  "continueWithGoogle": "Tiếp tục với Google",
  "continueWithApple": "Tiếp tục với Apple",
  "tryAsGuest": "Dùng thử",
  "termsNotice": "Khi tiếp tục, bạn đồng ý với\nĐiều khoản dịch vụ và Chính sách bảo mật",
  "onboardingNameTitle": "Bạn muốn được gọi là gì?",
  "onboardingNameSubtitle": "Chọn tên và avatar của bạn",
  "onboardingNameHint": "Nhập tên của bạn",
  "onboardingBuddyLabel": "CHỌN BẠN ĐỒNG HÀNH",
  "onboardingLevelTitle": "Trình độ tiếng Anh của bạn?",
  "onboardingLevelSubtitle": "Chúng tôi sẽ cá nhân hóa bài học cho bạn",
  "onboardingGoalsTitle": "Mục tiêu của bạn là gì?",
  "onboardingGoalsSubtitle": "Chọn tất cả phù hợp",
  "onboardingTopicsTitle": "Chọn sở thích của bạn",
  "onboardingTopicsSubtitle": "Chúng tôi sẽ điều chỉnh kịch bản theo sở thích của bạn",
  "onboardingTimeTitle": "Thời gian luyện tập mỗi ngày?",
  "onboardingTimeSubtitle": "Chúng tôi sẽ xây dựng kế hoạch phù hợp",
  "addYourOwnTopic": "Thêm chủ đề của bạn...",
  "selectedTopicsCount": "Đã chọn: {count} chủ đề",
  "dailyLimitReached": "Đã đạt giới hạn hàng ngày. Nâng cấp để có thêm phiên.",
  "failedToStart": "Không thể bắt đầu: {error}"
}
```

- [ ] **Step 5: Run flutter gen-l10n**

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && flutter gen-l10n`
Expected: Generated `lib/l10n/app_localizations.dart` and related files.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml l10n.yaml lib/l10n/
git commit -m "feat(i18n): set up flutter_localizations with English + Vietnamese ARB files"
```

---

## Task 23: Fix Naming Inconsistencies

**Files:**
- Rename: `lib/features/scenario/widgets/translate_prompt.dart` -> `lesson_card.dart`
- Rename: `lib/features/scenario/widgets/inline_assessment.dart` -> `assessment_card.dart`
- Modify: `lib/features/auth/widgets/auth_button.dart` (rename `AuthButtonStyle` -> `AuthButtonVariant`)

- [ ] **Step 1: Rename translate_prompt.dart to lesson_card.dart**

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && git mv lib/features/scenario/widgets/translate_prompt.dart lib/features/scenario/widgets/lesson_card.dart`

Then update all import references:
Run: `grep -rn "translate_prompt" lib/`
Update each file's import from `translate_prompt.dart` to `lesson_card.dart`.

- [ ] **Step 2: Rename inline_assessment.dart to assessment_card.dart**

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && git mv lib/features/scenario/widgets/inline_assessment.dart lib/features/scenario/widgets/assessment_card.dart`

Then update all import references:
Run: `grep -rn "inline_assessment" lib/`
Update each file's import from `inline_assessment.dart` to `assessment_card.dart`.

- [ ] **Step 3: Rename AuthButtonStyle to AuthButtonVariant in auth_button.dart**

In `lib/features/auth/widgets/auth_button.dart`, rename `AuthButtonStyle` to `AuthButtonVariant` globally.
Also update `lib/features/auth/screens/auth_screen.dart` which references `AuthButtonStyle.google`, `.apple`, `.guest`.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor(naming): rename translate_prompt->lesson_card, inline_assessment->assessment_card, AuthButtonStyle->AuthButtonVariant"
```

---

## Task 24: Add Basic Accessibility (Semantics + Touch Targets)

**Files:**
- Modify: `lib/shared/widgets/clay_button.dart` — add Semantics
- Modify: `lib/shared/widgets/clay_card.dart` — add Semantics
- Modify: `lib/features/home/widgets/bottom_nav_bar.dart` — add Semantics labels

- [ ] **Step 1: Add Semantics wrapper to ClayButton**

In `clay_button.dart`, wrap the GestureDetector with Semantics:

```dart
@override
Widget build(BuildContext context) {
  return Semantics(
    button: true,
    enabled: widget.onTap != null,
    label: widget.text,
    child: GestureDetector(
      // ... rest of existing build
    ),
  );
}
```

- [ ] **Step 2: Add Semantics to ClayCard**

In `clay_card.dart`, add a `semanticLabel` parameter and wrap with Semantics when tappable:

Read `clay_card.dart` first, then add:
```dart
final String? semanticLabel;
// In build():
if (onTap != null) {
  return Semantics(
    button: true,
    label: semanticLabel,
    child: GestureDetector(/* existing */),
  );
}
```

- [ ] **Step 3: Add Semantics labels to BottomNavBar items**

In `bottom_nav_bar.dart`, wrap each `_NavItem` GestureDetector with Semantics:
```dart
return Semantics(
  label: _label,
  selected: isActive,
  child: GestureDetector(/* existing */),
);
```

Add a `label` parameter to `_NavItem` and pass 'Home', 'Profile', 'Settings'.

- [ ] **Step 4: Fix caption contrast**

In `app_typography.dart`, update `caption` color from `AppColors.warmLight` (#9B9DAB) to `AppColors.warmMuted` (#6B6D7B) which achieves ~5.5:1 contrast on cream background, passing WCAG AA.

```dart
static TextStyle get caption => GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.warmMuted,
      height: 1.4,
      letterSpacing: 0.3,
    );
```

- [ ] **Step 5: Commit**

```bash
git add lib/shared/widgets/clay_button.dart lib/shared/widgets/clay_card.dart lib/features/home/widgets/bottom_nav_bar.dart lib/core/theme/app_typography.dart
git commit -m "feat(a11y): add Semantics to interactive widgets; fix caption contrast for WCAG AA"
```

---

## Task 25: Verification — Full Static Analysis

- [ ] **Step 1: Run dart analyze**

Run: `cd /sessions/compassionate-eloquent-bell/mnt/aura-coach-ai && dart analyze lib/`
Expected: No errors. Warnings acceptable.

- [ ] **Step 2: Verify no remaining hardcoded Colors.white in tokenized files**

Run: `grep -rn "Colors\.white" lib/features/ lib/shared/`
Expected: Zero matches in refactored files.

- [ ] **Step 3: Verify AppSpacing adoption**

Run: `grep -rn "AppSpacing\." lib/features/ lib/shared/ | wc -l`
Expected: Significant number of references (was zero before).

- [ ] **Step 4: Verify no remaining hardcoded Duration(milliseconds: 200)**

Run: `grep -rn "Duration(milliseconds: 200)" lib/features/ lib/shared/`
Expected: Zero matches.

- [ ] **Step 5: Verify no remaining BorderRadius.circular with raw numbers in refactored files**

Run: `grep -rn "BorderRadius.circular(" lib/features/auth/ lib/features/home/ lib/features/onboarding/ lib/features/splash/ lib/features/scenario/widgets/scenario_app_bar.dart lib/shared/widgets/error_banner.dart lib/shared/widgets/progress_dots.dart`
Expected: Zero matches in these files (SwipeDots uses dynamic radius, which is acceptable).

- [ ] **Step 6: Verify no remaining GoogleFonts calls outside app_typography.dart**

Run: `grep -rn "GoogleFonts\." lib/ --include="*.dart" | grep -v "app_typography.dart" | grep -v "pubspec"`
Expected: Only in `aura_logo.dart` (which now uses AppTypography.logo but may still need GoogleFonts import for the package). If any others remain, they need fixing.

---

*Plan covers all 19 P0/P1/P2 items from the gap analysis action plan. Documentation update will be a separate follow-up task after all code changes are verified.*
