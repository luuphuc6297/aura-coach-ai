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
