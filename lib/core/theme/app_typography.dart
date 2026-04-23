import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography roles follow the Clay design system mockups:
/// - Fredoka — headings, titles, section labels (playful identity)
/// - Nunito — buttons, labels, chips, badges, card titles (utility UI text)
/// - Inter  — body copy, input text, long-form prompts
abstract final class AppTypography {
  static TextStyle get displayLg => GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get displayMd => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get h1 => GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  static TextStyle get h2 => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  static TextStyle get h3 => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w700,
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

  static TextStyle get labelLg => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.4,
      );

  static TextStyle get labelMd => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.warmMuted,
        height: 1.4,
      );

  static TextStyle get labelSm => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
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

  // 22/800 — Hero sentence prompt (English)
  static TextStyle get sentence => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.warmDark,
        height: 1.12,
      );

  // 22/800 — Hero sentence prompt (Vietnamese)
  static TextStyle get sentenceVi => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.warmDark,
        height: 1.12,
      );

  // 15/700 — Section title within sentence card
  static TextStyle get sectionTitle => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.4,
      );

  // 13/700 — Card title / story title
  static TextStyle get cardBody => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.5,
      );

  // 11/700 — Small label / badge / pill
  static TextStyle get sentenceLabel => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.warmMuted,
        height: 1.3,
        letterSpacing: 0.8,
      );

  // 9/700 — Micro label / level badge
  static TextStyle get micro => GoogleFonts.nunito(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.warmLight,
        height: 1.4,
        letterSpacing: 0.3,
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.2,
      );

  static TextStyle get logo => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      );

  // 20/700 Fredoka — Screen / question title
  static TextStyle get title => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.warmDark,
        height: 1.3,
      );

  // 18/500 Fredoka — Text field input + placeholder
  static TextStyle get input => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.warmDark,
        height: 1.3,
      );
}
