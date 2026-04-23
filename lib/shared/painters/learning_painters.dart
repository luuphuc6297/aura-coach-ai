import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerLearningPainters(Map<String, IconPainterFn> registry) {
  registry['grammar'] = _paintGrammar;
  registry['vocabulary'] = _paintVocabulary;
  registry['brain'] = _paintBrain;
  registry['practice'] = _paintPractice;
  registry['sparkle'] = _paintSparkle;
}

// -----------------------------------------------------------------------------
// Grammar — Angled pencil with animated squiggle tip trace
// -----------------------------------------------------------------------------
void _paintGrammar(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.gold;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.50);
  canvas.rotate(-math.pi / 4);
  canvas.translate(-s * 0.50, -s * 0.50);

  // Pencil body
  final bodyPaint = Paint()..color = primaryColor;
  canvas.drawRect(
    Rect.fromLTWH(s * 0.36, s * 0.18, s * 0.28, s * 0.52),
    bodyPaint,
  );

  // Eraser (coral top)
  final eraserPaint = Paint()..color = AppColors.coral;
  canvas.drawRect(
    Rect.fromLTWH(s * 0.36, s * 0.14, s * 0.28, s * 0.10),
    eraserPaint,
  );

  // Eraser band
  final bandPaint = Paint()..color = AppColors.warmDark.withValues(alpha: 0.30);
  canvas.drawRect(
    Rect.fromLTWH(s * 0.36, s * 0.23, s * 0.28, s * 0.04),
    bandPaint,
  );

  // Wood section
  final woodPaint = Paint()..color = AppColors.gold.withValues(alpha: 0.55);
  canvas.drawRect(
    Rect.fromLTWH(s * 0.36, s * 0.70, s * 0.28, s * 0.10),
    woodPaint,
  );

  // Tip (triangle)
  final tipPaint = Paint()..color = AppColors.warmDark;
  final tipPath = Path()
    ..moveTo(s * 0.36, s * 0.80)
    ..lineTo(s * 0.64, s * 0.80)
    ..lineTo(s * 0.50, s * 0.90)
    ..close();
  canvas.drawPath(tipPath, tipPaint);

  canvas.restore();

  // Animated squiggle at the tip area
  final squigglePhase = t * 2 * math.pi;
  final squigglePaint = Paint()
    ..color = AppColors.warmDark.withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.025
    ..strokeCap = StrokeCap.round;
  final squigglePath = Path();
  squigglePath.moveTo(s * 0.72, s * 0.72);
  for (var i = 0; i <= 6; i++) {
    final x = s * 0.72 + i * s * 0.03;
    final y = s * 0.72 + math.sin(squigglePhase + i * 1.2) * s * 0.025;
    squigglePath.lineTo(x, y);
  }
  canvas.drawPath(squigglePath, squigglePaint);
}

// -----------------------------------------------------------------------------
// Vocabulary — Open book with animated page flutter
// -----------------------------------------------------------------------------
void _paintVocabulary(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmDark;
  final flutter = math.sin(t * 2 * math.pi) * s * 0.03;

  // Left page
  final leftPagePaint = Paint()..color = AppColors.cream;
  final leftOutlinePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.03;

  final leftPagePath = Path()
    ..moveTo(s * 0.50, s * 0.24)
    ..lineTo(s * 0.14, s * 0.30)
    ..lineTo(s * 0.14, s * 0.76)
    ..lineTo(s * 0.50, s * 0.72)
    ..close();
  canvas.drawPath(leftPagePath, leftPagePaint);
  canvas.drawPath(leftPagePath, leftOutlinePaint);

  // Right page with top-edge flutter
  final rightPagePaint = Paint()..color = AppColors.white;
  final rightOutlinePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.03;

  final rightPagePath = Path()
    ..moveTo(s * 0.50, s * 0.24)
    ..lineTo(s * 0.86, s * 0.30 - flutter)
    ..lineTo(s * 0.86, s * 0.76)
    ..lineTo(s * 0.50, s * 0.72)
    ..close();
  canvas.drawPath(rightPagePath, rightPagePaint);
  canvas.drawPath(rightPagePath, rightOutlinePaint);

  // Spine center line
  final spinePaint = Paint()
    ..color = primaryColor
    ..strokeWidth = s * 0.035
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.50, s * 0.22),
    Offset(s * 0.50, s * 0.74),
    spinePaint,
  );

  // Text lines on left page
  final linePaint = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.35)
    ..strokeWidth = s * 0.02
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 3; i++) {
    final y = s * 0.40 + i * s * 0.10;
    canvas.drawLine(Offset(s * 0.20, y), Offset(s * 0.44, y), linePaint);
  }

  // Text lines on right page
  for (var i = 0; i < 3; i++) {
    final y = s * 0.40 + i * s * 0.10;
    canvas.drawLine(Offset(s * 0.56, y), Offset(s * 0.80, y), linePaint);
  }
}

// -----------------------------------------------------------------------------
// Brain — Two hemispheres with pulsing highlight (same style as goal_icon.dart)
// -----------------------------------------------------------------------------
void _paintBrain(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.purple;
  final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;

  // Left hemisphere
  final leftPaint = Paint()..color = primaryColor;
  final leftPath = Path()
    ..moveTo(s * 0.48, s * 0.24)
    ..cubicTo(s * 0.28, s * 0.18, s * 0.12, s * 0.34, s * 0.16, s * 0.52)
    ..cubicTo(s * 0.14, s * 0.64, s * 0.22, s * 0.76, s * 0.36, s * 0.80)
    ..cubicTo(s * 0.42, s * 0.82, s * 0.48, s * 0.76, s * 0.48, s * 0.68)
    ..lineTo(s * 0.48, s * 0.24);
  canvas.drawPath(leftPath, leftPaint);

  // Right hemisphere
  final rightPaint = Paint()..color = primaryColor.withValues(alpha: 0.78);
  final rightPath = Path()
    ..moveTo(s * 0.52, s * 0.24)
    ..cubicTo(s * 0.72, s * 0.18, s * 0.88, s * 0.34, s * 0.84, s * 0.52)
    ..cubicTo(s * 0.86, s * 0.64, s * 0.78, s * 0.76, s * 0.64, s * 0.80)
    ..cubicTo(s * 0.58, s * 0.82, s * 0.52, s * 0.76, s * 0.52, s * 0.68)
    ..lineTo(s * 0.52, s * 0.24);
  canvas.drawPath(rightPath, rightPaint);

  // Fold lines — left
  final foldPaint = Paint()
    ..color = AppColors.warmDark.withValues(alpha: 0.18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.02
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.26, s * 0.42), Offset(s * 0.42, s * 0.46), foldPaint);
  canvas.drawLine(
      Offset(s * 0.22, s * 0.58), Offset(s * 0.40, s * 0.58), foldPaint);
  canvas.drawLine(
      Offset(s * 0.30, s * 0.70), Offset(s * 0.44, s * 0.66), foldPaint);

  // Fold lines — right
  canvas.drawLine(
      Offset(s * 0.74, s * 0.42), Offset(s * 0.58, s * 0.46), foldPaint);
  canvas.drawLine(
      Offset(s * 0.78, s * 0.58), Offset(s * 0.60, s * 0.58), foldPaint);
  canvas.drawLine(
      Offset(s * 0.70, s * 0.70), Offset(s * 0.56, s * 0.66), foldPaint);

  // Center divider
  final dividerPaint = Paint()
    ..color = AppColors.warmDark.withValues(alpha: 0.20)
    ..strokeWidth = s * 0.02;
  canvas.drawLine(
      Offset(s * 0.50, s * 0.26), Offset(s * 0.50, s * 0.78), dividerPaint);

  // Pulsing highlight glow
  final glowPaint = Paint()
    ..color = primaryColor.withValues(alpha: pulse * 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  canvas.drawCircle(Offset(s * 0.50, s * 0.50), s * 0.22, glowPaint);
}

// -----------------------------------------------------------------------------
// Practice — Bullseye target with pulsing center dot
// -----------------------------------------------------------------------------
void _paintPractice(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;
  final center = Offset(s * 0.50, s * 0.50);

  // Outer ring
  final outerPaint = Paint()
    ..color = AppColors.warmLight
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05;
  canvas.drawCircle(center, s * 0.36, outerPaint);

  // Middle ring
  final midPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05;
  canvas.drawCircle(center, s * 0.23, midPaint);

  // Inner ring (solid fill)
  final innerFillPaint = Paint()..color = primaryColor.withValues(alpha: 0.20);
  canvas.drawCircle(center, s * 0.14, innerFillPaint);

  final innerRingPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.04;
  canvas.drawCircle(center, s * 0.14, innerRingPaint);

  // Center dot — pulsing scale
  final dotRadius = s * 0.055 + pulse * s * 0.020;
  final dotPaint = Paint()..color = primaryColor;
  canvas.drawCircle(center, dotRadius, dotPaint);
}

// -----------------------------------------------------------------------------
// Sparkle — 4-point star with orbiting secondary sparkles
// -----------------------------------------------------------------------------
void _paintSparkle(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.gold;
  final center = Offset(s * 0.50, s * 0.50);

  // Draw 4-point star helper
  Path _star4(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final r = i.isEven ? outer : inner;
      final p = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  // Main star
  final starPaint = Paint()..color = primaryColor;
  canvas.drawPath(_star4(center, s * 0.28, s * 0.10), starPaint);

  // Secondary sparkles orbiting around the main star
  final orbitRadius = s * 0.34;
  final smallStarSize = s * 0.08;
  final offsets = [0.0, 0.33, 0.67];
  for (final basePhase in offsets) {
    final angle = (t + basePhase) * 2 * math.pi;
    final pos = Offset(
      center.dx + orbitRadius * math.cos(angle),
      center.dy + orbitRadius * math.sin(angle),
    );
    final alphaNorm = ((math.sin(angle) + 1) / 2) * 0.6 + 0.25;
    final smallPaint = Paint()
      ..color = primaryColor.withValues(alpha: alphaNorm);
    canvas.drawPath(
        _star4(pos, smallStarSize, smallStarSize * 0.36), smallPaint);
  }
}
