import 'package:flutter/material.dart';
import 'clay_palette.dart';

/// Theme-aware clay shadows. Each method takes a [BuildContext] so the
/// shadow color resolves through the active [ClayPalette] — light mode
/// gets warm beige / warmDark drops; dark mode gets near-black drops so
/// the clay 3D effect stays visible against the dark surface.
///
/// Migration: every call site was updated to pass `(context)`. The
/// `colored(...)` accent variant stays static because accent colors
/// (coral / teal / gold / purple) are theme-invariant by design.
abstract final class AppShadows {
  /// Sharp clay drop shadow — 3px offset, no blur.
  static List<BoxShadow> clay(BuildContext context) => [
        BoxShadow(color: context.clay.shadow, offset: const Offset(3, 3)),
      ];

  /// Same color as [clay] but tighter offset for the pressed state.
  static List<BoxShadow> clayPressed(BuildContext context) => [
        BoxShadow(color: context.clay.shadow, offset: const Offset(1, 1)),
      ];

  /// Bold drop — used by primary buttons and emphasized clay surfaces.
  /// Light = warmDark; dark = near-black. No blur.
  static List<BoxShadow> clayBold(BuildContext context) => [
        BoxShadow(color: context.clay.shadowBold, offset: const Offset(3, 3)),
      ];

  static List<BoxShadow> clayBoldPressed(BuildContext context) => [
        BoxShadow(color: context.clay.shadowBold, offset: const Offset(1, 1)),
      ];

  /// Soft blurred drop — for surfaces that float above the page (sheets,
  /// dialogs, lifted cards). Color/alpha tuned per mode so the blur stays
  /// perceivable on both cream and dark navy surfaces.
  static List<BoxShadow> soft(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? const Color(0x33000000)
            : const Color(0x0F2D3047),
        offset: const Offset(0, 4),
        blurRadius: 12,
      ),
    ];
  }

  /// Subtle card shadow — lighter than [soft], used for resting cards.
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? const Color(0x26000000)
            : const Color(0x0A2D3047),
        offset: const Offset(0, 2),
        blurRadius: 8,
      ),
    ];
  }

  /// Stack of [soft] + [clay] used for "lifted" / hover-pressed surfaces.
  static List<BoxShadow> lifted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? const Color(0x40000000)
            : const Color(0x1A2D3047),
        offset: const Offset(0, 6),
        blurRadius: 20,
      ),
      BoxShadow(color: context.clay.shadow, offset: const Offset(3, 3)),
    ];
  }

  /// Clay shadow tinted with a custom accent color. Theme-invariant —
  /// accent colors stay constant across light/dark modes per the design
  /// system. Replaces inline
  /// `BoxShadow(color: accent.withValues(alpha: 0.4), offset: Offset(3, 3))`.
  static List<BoxShadow> colored(Color accentColor, {double alpha = 0.4}) {
    return [
      BoxShadow(
        color: accentColor.withValues(alpha: alpha),
        offset: const Offset(3, 3),
      ),
    ];
  }
}
