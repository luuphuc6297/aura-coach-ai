import 'package:flutter/material.dart';

abstract final class AppAnimations {
  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 200);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);

  static const easeClay = Curves.easeInOut;
}
