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
          onPrimary: AppColors.warmDark,
          onSurface: AppColors.warmDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.warmDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.title,
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
        ],
      );
}
