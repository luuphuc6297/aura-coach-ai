import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppShadows {
  static const clay = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(3, 3)),
  ];

  static const clayPressed = [
    BoxShadow(color: AppColors.clayShadow, offset: Offset(1, 1)),
  ];

  /// Bold clay shadow — warm-dark, no blur.
  /// Used for primary buttons and emphasized clay surfaces that need
  /// a strong offset drop against the cream background.
  static const clayBold = [
    BoxShadow(color: AppColors.warmDark, offset: Offset(3, 3)),
  ];

  static const clayBoldPressed = [
    BoxShadow(color: AppColors.warmDark, offset: Offset(1, 1)),
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
