import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_semantic_colors.dart';
import 'clay_palette.dart';

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
          onPrimary: AppColors.warmDark,
          onSurface: AppColors.warmDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.warmDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle:
              AppTypography.title.copyWith(color: AppColors.warmDark),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        // AppTypography styles intentionally have no color — Material's
        // DefaultTextStyle (derived from textTheme + colorScheme.onSurface)
        // provides the right one per theme. Body styles get warmDark/muted
        // here; dark mode mirrors the same shape with palette.text/textMuted.
        textTheme: TextTheme(
          displayLarge:
              AppTypography.displayLg.copyWith(color: AppColors.warmDark),
          displayMedium:
              AppTypography.displayMd.copyWith(color: AppColors.warmDark),
          headlineLarge: AppTypography.h1.copyWith(color: AppColors.warmDark),
          headlineMedium: AppTypography.h2.copyWith(color: AppColors.warmDark),
          headlineSmall: AppTypography.h3.copyWith(color: AppColors.warmDark),
          bodyLarge: AppTypography.bodyLg.copyWith(color: AppColors.warmDark),
          bodyMedium: AppTypography.bodyMd.copyWith(color: AppColors.warmDark),
          bodySmall: AppTypography.bodySm.copyWith(color: AppColors.warmDark),
          labelLarge: AppTypography.labelLg.copyWith(color: AppColors.warmDark),
          labelMedium:
              AppTypography.labelMd.copyWith(color: AppColors.warmMuted),
          labelSmall:
              AppTypography.labelSm.copyWith(color: AppColors.warmMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: AppColors.warmDark,
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
          hintStyle: AppTypography.input.copyWith(color: AppColors.warmLight),
          labelStyle: AppTypography.input.copyWith(color: AppColors.warmMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        cardTheme: CardThemeData(
          color: AppColors.clayWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          titleTextStyle: AppTypography.title,
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
          ClayPalette.light,
        ],
      );

  /// Dark variant — built on the same warm clay hue family as light mode.
  /// Surface = AppColors.warmDark (the light-mode TEXT color); text = cream
  /// (the light-mode BACKGROUND). Only luminosity is inverted; we never
  /// drift to neutral gray.
  ///
  /// Widgets that read `context.clay.<token>` re-resolve automatically via
  /// the registered [ClayPalette.dark] extension. Hardcoded `AppColors.X`
  /// references in feature screens are migrated in subsequent tasks
  /// (see docs/superpowers/plans/2026-04-26-dark-mode.md).
  static ThemeData get dark {
    const palette = ClayPalette.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.purple,
        tertiary: AppColors.gold,
        surface: palette.surface,
        error: AppColors.error,
        onPrimary: AppColors.warmDark,
        onSurface: palette.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title.copyWith(color: palette.text),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLg.copyWith(color: palette.text),
        displayMedium: AppTypography.displayMd.copyWith(color: palette.text),
        headlineLarge: AppTypography.h1.copyWith(color: palette.text),
        headlineMedium: AppTypography.h2.copyWith(color: palette.text),
        headlineSmall: AppTypography.h3.copyWith(color: palette.text),
        bodyLarge: AppTypography.bodyLg.copyWith(color: palette.text),
        bodyMedium: AppTypography.bodyMd.copyWith(color: palette.text),
        bodySmall: AppTypography.bodySm.copyWith(color: palette.text),
        labelLarge: AppTypography.labelLg.copyWith(color: palette.text),
        labelMedium: AppTypography.labelMd.copyWith(color: palette.text),
        labelSmall: AppTypography.labelSm.copyWith(color: palette.text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.warmDark,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),
      // Match the light theme's input shell — fillColor/border/padding so
      // any TextField that DOES rely on the global theme (rare now that
      // ClayTextInput strips Material chrome) renders consistently.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAlt,
        hintStyle: AppTypography.input.copyWith(color: palette.textFaint),
        labelStyle: AppTypography.input.copyWith(color: palette.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: palette.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: palette.border, width: 2),
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
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.background,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        titleTextStyle: AppTypography.title.copyWith(color: palette.text),
        contentTextStyle: AppTypography.bodyMd.copyWith(color: palette.text),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: palette.textFaint,
        elevation: 0,
      ),
      extensions: const [
        AppSemanticColors.light,
        ClayPalette.dark,
      ],
    );
  }
}
