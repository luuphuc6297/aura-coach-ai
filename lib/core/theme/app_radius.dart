import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;

  static final xxsBorder = BorderRadius.circular(xxs);
  static final xsBorder = BorderRadius.circular(xs);
  static final smBorder = BorderRadius.circular(sm);
  static final mdBorder = BorderRadius.circular(md);
  static final lgBorder = BorderRadius.circular(lg);
  static final xlBorder = BorderRadius.circular(xl);
  static final fullBorder = BorderRadius.circular(full);
}
