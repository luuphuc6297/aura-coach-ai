import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerProfilePainters(Map<String, IconPainterFn> registry) {
  registry['goal'] = _paintGoal;
  registry['clock'] = _paintClock;
  registry['level'] = _paintLevel;
  registry['crown'] = _paintCrown;
  registry['topic'] = _paintTopic;
}

// Trophy cup with orbiting star sparkle.
void _paintGoal(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.gold;

  final fillPaint = Paint()
    ..color = primary
    ..style = PaintingStyle.fill;

  final basePaint = Paint()
    ..color = AppColors.goldDark
    ..style = PaintingStyle.fill;

  // Cup body — rounded trapezoid via path
  final cupPath = Path();
  cupPath.moveTo(s * 0.28, s * 0.20);
  cupPath.lineTo(s * 0.72, s * 0.20);
  cupPath.lineTo(s * 0.65, s * 0.60);
  cupPath.quadraticBezierTo(s * 0.50, s * 0.70, s * 0.35, s * 0.60);
  cupPath.close();
  canvas.drawPath(cupPath, fillPaint);

  // Left handle
  final leftHandle = Path();
  leftHandle.moveTo(s * 0.28, s * 0.28);
  leftHandle.cubicTo(
    s * 0.10,
    s * 0.28,
    s * 0.10,
    s * 0.50,
    s * 0.30,
    s * 0.50,
  );
  leftHandle.lineTo(s * 0.32, s * 0.44);
  leftHandle.cubicTo(
    s * 0.19,
    s * 0.44,
    s * 0.19,
    s * 0.32,
    s * 0.30,
    s * 0.32,
  );
  leftHandle.close();
  canvas.drawPath(leftHandle, fillPaint);

  // Right handle
  final rightHandle = Path();
  rightHandle.moveTo(s * 0.72, s * 0.28);
  rightHandle.cubicTo(
    s * 0.90,
    s * 0.28,
    s * 0.90,
    s * 0.50,
    s * 0.70,
    s * 0.50,
  );
  rightHandle.lineTo(s * 0.68, s * 0.44);
  rightHandle.cubicTo(
    s * 0.81,
    s * 0.44,
    s * 0.81,
    s * 0.32,
    s * 0.70,
    s * 0.32,
  );
  rightHandle.close();
  canvas.drawPath(rightHandle, fillPaint);

  // Stem
  final stemRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.44, s * 0.62, s * 0.12, s * 0.12),
    Radius.circular(s * 0.02),
  );
  canvas.drawRRect(stemRect, basePaint);

  // Base pedestal
  final baseRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.30, s * 0.73, s * 0.40, s * 0.08),
    Radius.circular(s * 0.03),
  );
  canvas.drawRRect(baseRect, basePaint);

  // Orbiting star sparkle — circles the top of the cup
  final angle = t * 2 * math.pi;
  final orbitX = s * 0.50 + math.cos(angle) * s * 0.26;
  final orbitY = s * 0.18 + math.sin(angle) * s * 0.10;

  _drawStar(canvas, Offset(orbitX, orbitY), s * 0.06,
      AppColors.warmDark.withOpacity(0.85));
}

// 4-point star helper
void _drawStar(Canvas canvas, Offset center, double r, Color color) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  final path = Path();
  for (int i = 0; i < 8; i++) {
    final radius = (i % 2 == 0) ? r : r * 0.45;
    final a = i * math.pi / 4 - math.pi / 8;
    final point = Offset(
        center.dx + math.cos(a) * radius, center.dy + math.sin(a) * radius);
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  canvas.drawPath(path, paint);
}

// Alarm clock: round face, two bells, two feet, animated second hand.
void _paintClock(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;

  final faceFill = Paint()
    ..color = AppColors.cream
    ..style = PaintingStyle.fill;

  final outline = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;

  final bellPaint = Paint()
    ..color = color ?? AppColors.coral
    ..style = PaintingStyle.fill;

  final handPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  final secondHandPaint = Paint()
    ..color = AppColors.coral
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.035
    ..strokeCap = StrokeCap.round;

  // Clock face
  final center = Offset(s * 0.50, s * 0.54);
  final radius = s * 0.34;
  canvas.drawCircle(center, radius, faceFill);
  canvas.drawCircle(center, radius, outline);

  // Left bell
  final leftBellPath = Path();
  leftBellPath.moveTo(s * 0.22, s * 0.28);
  leftBellPath.arcToPoint(
    Offset(s * 0.36, s * 0.22),
    radius: Radius.circular(s * 0.14),
    clockwise: false,
  );
  leftBellPath.lineTo(s * 0.28, s * 0.34);
  leftBellPath.close();
  canvas.drawPath(leftBellPath, bellPaint);

  // Right bell
  final rightBellPath = Path();
  rightBellPath.moveTo(s * 0.78, s * 0.28);
  rightBellPath.arcToPoint(
    Offset(s * 0.64, s * 0.22),
    radius: Radius.circular(s * 0.14),
    clockwise: true,
  );
  rightBellPath.lineTo(s * 0.72, s * 0.34);
  rightBellPath.close();
  canvas.drawPath(rightBellPath, bellPaint);

  // Left foot
  canvas.drawLine(
    Offset(s * 0.28, s * 0.85),
    Offset(s * 0.18, s * 0.92),
    outline,
  );

  // Right foot
  canvas.drawLine(
    Offset(s * 0.72, s * 0.85),
    Offset(s * 0.82, s * 0.92),
    outline,
  );

  // Hour hand — fixed at ~10 o'clock position
  final hourAngle = -math.pi * 0.5 + (-math.pi * 0.4);
  canvas.drawLine(
    center,
    Offset(center.dx + math.cos(hourAngle) * s * 0.17,
        center.dy + math.sin(hourAngle) * s * 0.17),
    handPaint,
  );

  // Minute hand — fixed at ~12 o'clock position
  final minuteAngle = -math.pi * 0.5;
  canvas.drawLine(
    center,
    Offset(center.dx + math.cos(minuteAngle) * s * 0.24,
        center.dy + math.sin(minuteAngle) * s * 0.24),
    handPaint,
  );

  // Animated second hand — completes full rotation per animation cycle
  final secondAngle = t * 2 * math.pi - math.pi * 0.5;
  canvas.drawLine(
    center,
    Offset(center.dx + math.cos(secondAngle) * s * 0.26,
        center.dy + math.sin(secondAngle) * s * 0.26),
    secondHandPaint,
  );

  // Center dot
  canvas.drawCircle(center, s * 0.035, Paint()..color = AppColors.warmDark);
}

// Bar chart: 3 bars with staggered growth animation.
void _paintLevel(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.teal;

  final baselineY = s * 0.82;
  final maxHeights = [s * 0.30, s * 0.46, s * 0.60];
  final opacities = [0.4, 0.7, 1.0];
  final phaseOffsets = [0.0, 0.15, 0.30];
  final barWidth = s * 0.18;
  final xPositions = [s * 0.16, s * 0.41, s * 0.66];

  for (int i = 0; i < 3; i++) {
    // Staggered animation: each bar starts growing slightly later
    final phase = ((t + 1.0 - phaseOffsets[i]) % 1.0);
    // Ease-in-out: use sin-based easing from 0 → 1 → 0 mapped to grow
    final growFactor = math.sin(phase * math.pi).clamp(0.0, 1.0);
    final barHeight = maxHeights[i] * (0.5 + growFactor * 0.5);

    final paint = Paint()
      ..color = primary.withOpacity(opacities[i])
      ..style = PaintingStyle.fill;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        xPositions[i],
        baselineY - barHeight,
        barWidth,
        barHeight,
      ),
      Radius.circular(s * 0.04),
    );
    canvas.drawRRect(barRect, paint);
  }

  // Baseline
  final baselinePaint = Paint()
    ..color = AppColors.warmMuted.withOpacity(0.4)
    ..strokeWidth = s * 0.04
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.10, baselineY), Offset(s * 0.90, baselineY), baselinePaint);
}

// Crown with 3 peaks, jewels, and orbiting sparkles.
void _paintCrown(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.gold;

  final crownPaint = Paint()
    ..color = primary
    ..style = PaintingStyle.fill;

  final bandPaint = Paint()
    ..color = AppColors.goldDark
    ..style = PaintingStyle.fill;

  // Crown body path — 3 peaked tips
  final crownPath = Path();
  crownPath.moveTo(s * 0.10, s * 0.75); // bottom-left
  crownPath.lineTo(s * 0.10, s * 0.45); // left side up
  crownPath.lineTo(s * 0.28, s * 0.62); // left inner valley
  crownPath.lineTo(s * 0.50, s * 0.24); // center peak (tallest)
  crownPath.lineTo(s * 0.72, s * 0.62); // right inner valley
  crownPath.lineTo(s * 0.90, s * 0.45); // right side up
  crownPath.lineTo(s * 0.90, s * 0.75); // bottom-right
  crownPath.close();
  canvas.drawPath(crownPath, crownPaint);

  // Band at base — darker gold stripe
  final bandPath = Path();
  bandPath.moveTo(s * 0.10, s * 0.65);
  bandPath.lineTo(s * 0.90, s * 0.65);
  bandPath.lineTo(s * 0.90, s * 0.75);
  bandPath.lineTo(s * 0.10, s * 0.75);
  bandPath.close();
  canvas.drawPath(bandPath, bandPaint);

  // Jewels at the three peaks
  final jewelsData = [
    (Offset(s * 0.10, s * 0.45), AppColors.coral),
    (Offset(s * 0.50, s * 0.24), AppColors.teal),
    (Offset(s * 0.90, s * 0.45), AppColors.purple),
  ];

  for (final (pos, jewColor) in jewelsData) {
    canvas.drawCircle(
        pos,
        s * 0.055,
        Paint()
          ..color = jewColor
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
      pos,
      s * 0.055,
      Paint()
        ..color = AppColors.warmDark.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02,
    );
  }

  // Orbiting sparkles — two small sparkles rotating around the crown center
  final orbitCenter = Offset(s * 0.50, s * 0.52);
  for (int i = 0; i < 2; i++) {
    final angle = t * 2 * math.pi + i * math.pi;
    final ox = orbitCenter.dx + math.cos(angle) * s * 0.36;
    final oy = orbitCenter.dy + math.sin(angle) * s * 0.18;
    // Only draw if above the crown baseline (don't clip into band)
    if (oy < s * 0.70) {
      _drawStar(
          canvas, Offset(ox, oy), s * 0.045, AppColors.gold.withOpacity(0.80));
    }
  }
}

// Price tag with swing animation.
void _paintTopic(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.purple;

  // Swing: rotate the tag around its top-left string attachment point
  final swingAngle = math.sin(t * 2 * math.pi) * 0.12;

  // Pivot at top-center-left where string attaches
  final pivotX = s * 0.28;
  final pivotY = s * 0.18;

  canvas.save();
  canvas.translate(pivotX, pivotY);
  canvas.rotate(swingAngle);
  canvas.translate(-pivotX, -pivotY);

  // String line from top attachment to tag hole
  final stringPaint = Paint()
    ..color = AppColors.warmMuted
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.03
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(pivotX, pivotY), Offset(s * 0.32, s * 0.38), stringPaint);

  // Tag body — rounded rectangle
  final tagRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.20, s * 0.36, s * 0.60, s * 0.40),
    Radius.circular(s * 0.08),
  );
  canvas.drawRRect(
      tagRect,
      Paint()
        ..color = primary
        ..style = PaintingStyle.fill);

  // Hole circle cutout on left side
  final holePaint = Paint()
    ..color = AppColors.cream
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.32, s * 0.56), s * 0.055, holePaint);

  // Hole outline
  canvas.drawCircle(
    Offset(s * 0.32, s * 0.56),
    s * 0.055,
    Paint()
      ..color = primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025,
  );

  // Two text lines on the tag for visual detail
  final linePaint = Paint()
    ..color = AppColors.white.withOpacity(0.55)
    ..strokeWidth = s * 0.045
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.42, s * 0.50), Offset(s * 0.72, s * 0.50), linePaint);
  canvas.drawLine(
      Offset(s * 0.42, s * 0.62), Offset(s * 0.64, s * 0.62), linePaint);

  canvas.restore();
}
