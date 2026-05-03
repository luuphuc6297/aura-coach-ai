import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme-aware surface tokens. Accent colors (teal, coral, gold, purple,
/// success, error) live on [AppColors] and stay constant across modes —
/// only surfaces, text, borders, and shadow flip.
///
/// Light mode uses the established clay tokens directly. Dark mode stays
/// inside the same warm purple-blue hue family — the surface color is
/// literally [AppColors.warmDark] (the light-mode text color), and the
/// text color is [AppColors.cream] (the light-mode background). This
/// preserves the clay aesthetic across both modes; we never drift to
/// neutral gray.
///
/// Access via the [BuildContext.clay] extension below — widgets that read
/// `context.clay.surface` will rebuild automatically when the user toggles
/// theme mode in Settings.
@immutable
class ClayPalette extends ThemeExtension<ClayPalette> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  /// Sharp offset clay drop — no blur. Used by `AppShadows.clay`/`clayPressed`.
  /// Light = warm beige (`clayShadow`); dark = 45% black so the offset stays
  /// visible against the dark surface.
  final Color shadow;
  /// Stronger emphasis drop, used by `AppShadows.clayBold`/`clayBoldPressed`
  /// (primary buttons, emphasized clay surfaces). Light = warmDark; dark =
  /// near-black so the shadow stays visible.
  final Color shadowBold;

  const ClayPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.shadow,
    required this.shadowBold,
  });

  static const light = ClayPalette(
    background: AppColors.cream,
    surface: AppColors.clayWhite,
    surfaceAlt: AppColors.clayBeige,
    border: AppColors.clayBorder,
    text: AppColors.warmDark,
    textMuted: AppColors.warmMuted,
    textFaint: AppColors.warmLight,
    shadow: AppColors.clayShadow,
    shadowBold: AppColors.warmDark,
  );

  static const dark = ClayPalette(
    background: Color(0xFF1A1C2E),
    surface: Color(0xFF2D3047),
    surfaceAlt: Color(0xFF3A3D55),
    border: Color(0xFF4A4D62),
    text: Color(0xFFFFF8F0),
    textMuted: Color(0xFFB8B6CC),
    textFaint: Color(0xFF82849A),
    shadow: Color(0x73000000),
    shadowBold: Color(0xCC000000),
  );

  @override
  ClayPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? text,
    Color? textMuted,
    Color? textFaint,
    Color? shadow,
    Color? shadowBold,
  }) {
    return ClayPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      shadow: shadow ?? this.shadow,
      shadowBold: shadowBold ?? this.shadowBold,
    );
  }

  @override
  ClayPalette lerp(ThemeExtension<ClayPalette>? other, double t) {
    if (other is! ClayPalette) return this;
    return ClayPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shadowBold: Color.lerp(shadowBold, other.shadowBold, t)!,
    );
  }
}

/// Ergonomic accessor: `context.clay.surface` instead of
/// `Theme.of(context).extension<ClayPalette>()!.surface`. Always returns
/// non-null — falls back to the light variant if no extension is registered
/// (defensive against a stale theme during hot-reload).
extension ClayPaletteContext on BuildContext {
  ClayPalette get clay =>
      Theme.of(this).extension<ClayPalette>() ?? ClayPalette.light;
}
