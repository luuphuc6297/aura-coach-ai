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
    onPrimary: AppColors.warmDark,
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
