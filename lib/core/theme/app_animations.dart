import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

abstract final class AppAnimations {
  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 200);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);

  /// Duration for press-down scale (instant feel, no spring).
  static const durationPress = Duration(milliseconds: 80);

  /// Duration for staggered entrance sequences (auth, onboarding).
  static const durationStagger = Duration(milliseconds: 800);

  /// Duration for score circle sweep + count-up reveal.
  static const durationScore = Duration(milliseconds: 900);

  /// Duration for typing indicator sine-wave cycle.
  static const durationTypingWave = Duration(milliseconds: 1200);

  /// Duration for celebration confetti overlay.
  static const durationCelebration = Duration(milliseconds: 2000);

  /// Duration for pulsing glow (splash screen).
  static const durationPulse = Duration(milliseconds: 2200);

  /// Duration for floating icon drift (mode card, splash).
  static const durationFloat = Duration(milliseconds: 2800);

  static const easeClay = Curves.easeInOut;

  /// Spring for tap release — fast, slight overshoot, quick settle.
  static const springTap = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 15,
  );

  /// Spring for gentle transitions — smooth, no overshoot.
  static const springGentle = SpringDescription(
    mass: 1,
    stiffness: 200,
    damping: 20,
  );

  /// Whether animations should be reduced for accessibility.
  ///
  /// Returns true when the platform reports [disableAnimations] or
  /// [reduceMotion]. Widgets should skip scale/slide/spring animations
  /// and use instant transitions instead.
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}
