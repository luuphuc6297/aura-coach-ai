import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get displayLg => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get displayMd => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.warmDark,
        height: 1.4,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.warmDark,
        height: 1.5,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.warmDark,
        height: 1.5,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.warmDark,
        height: 1.5,
        letterSpacing: 0.2,
      );

  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.4,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.warmMuted,
        height: 1.4,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.warmMuted,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.warmMuted,
        height: 1.4,
        letterSpacing: 0.3,
      );

  // Primary sentence prompt — hero content in learning cards
  static TextStyle get sentence => GoogleFonts.nunito(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.55,
      );

  // Vietnamese sentence prompt — extra height for diacritic stacking
  static TextStyle get sentenceVi => GoogleFonts.nunito(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.65,
      );

  // Small direction label above sentence ("Translate to English")
  static TextStyle get sentenceLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.warmMuted,
        height: 1.3,
        letterSpacing: 0.8,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get logo => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      );
}
