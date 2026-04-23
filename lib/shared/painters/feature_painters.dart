import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerFeaturePainters(Map<String, IconPainterFn> registry) {
  registry['feat_masks'] = _paintMasks;
  registry['feat_barChart'] = _paintBarChart;
  registry['feat_target'] = _paintTarget;
  registry['feat_save'] = _paintSave;
  registry['feat_openBook'] = _paintOpenBook;
  registry['feat_ribbonBookmark'] = _paintRibbonBookmark;
  registry['feat_magnifier'] = _paintMagnifier;
  registry['feat_brain'] = _paintBrain;
  registry['feat_cards'] = _paintCards;
  registry['feat_stack'] = _paintStack;
  registry['feat_chartUp'] = _paintChartUp;
  registry['feat_notepad'] = _paintNotepad;
}

// Theater masks — happy (teal) overlapping sad (purple). Subtle z-order toggle.
void _paintMasks(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final swap = math.sin(t * 2 * math.pi);

  // Sad mask (drawn first when swap > 0, second when swap <= 0)
  void drawSad(double alpha) {
    final sadPaint = Paint()
      ..color = AppColors.purple.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final sadPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(s * 0.56, s * 0.54),
        width: s * 0.52,
        height: s * 0.52,
      ));
    canvas.drawPath(sadPath, sadPaint);

    // Sad frown
    final frownPaint = Paint()
      ..color = AppColors.white.withValues(alpha: alpha * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s * 0.56, s * 0.64),
        width: s * 0.22,
        height: s * 0.14,
      ),
      0,
      -math.pi,
      false,
      frownPaint,
    );

    // Sad eye
    final eyePaint = Paint()
      ..color = AppColors.white.withValues(alpha: alpha * 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s * 0.48, s * 0.48), s * 0.035, eyePaint);
    canvas.drawCircle(Offset(s * 0.64, s * 0.48), s * 0.035, eyePaint);
  }

  // Happy mask (teal)
  void drawHappy(double alpha) {
    final happyPaint = Paint()
      ..color = (color ?? AppColors.teal).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final happyPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(s * 0.44, s * 0.46),
        width: s * 0.52,
        height: s * 0.52,
      ));
    canvas.drawPath(happyPath, happyPaint);

    // Happy smile
    final smilePaint = Paint()
      ..color = AppColors.white.withValues(alpha: alpha * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s * 0.44, s * 0.50),
        width: s * 0.22,
        height: s * 0.14,
      ),
      0,
      math.pi,
      false,
      smilePaint,
    );

    // Happy eye
    final eyePaint = Paint()
      ..color = AppColors.white.withValues(alpha: alpha * 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s * 0.36, s * 0.40), s * 0.035, eyePaint);
    canvas.drawCircle(Offset(s * 0.52, s * 0.40), s * 0.035, eyePaint);
  }

  if (swap > 0) {
    drawSad(0.82);
    drawHappy(1.0);
  } else {
    drawHappy(0.82);
    drawSad(1.0);
  }
}

// 3 bars (teal varying opacity). Bars grow with staggered t.
void _paintBarChart(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;

  final barWidth = s * 0.18;
  final baseY = s * 0.82;
  final maxH = s * 0.58;

  final heights = [0.55, 0.85, 0.70];
  final delays = [0.0, 0.15, 0.30];
  final xPositions = [s * 0.16, s * 0.40, s * 0.64];

  for (int i = 0; i < 3; i++) {
    final progress = ((t - delays[i]) % 1.0).clamp(0.0, 1.0);
    final easedProgress = progress < 0.5
        ? 2 * progress * progress
        : 1 - 2 * (1 - progress) * (1 - progress);
    final h = maxH * heights[i] * (0.70 + 0.30 * easedProgress);
    final alpha = 0.55 + i * 0.20;

    final barPaint = Paint()
      ..color = primaryColor.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(xPositions[i], baseY - h, barWidth, h),
      Radius.circular(s * 0.03),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  // Baseline
  final axisP = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.35)
    ..strokeWidth = s * 0.03
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(Offset(s * 0.10, baseY), Offset(s * 0.88, baseY), axisP);
}

// Bullseye target — 3 circles. Center pulses.
void _paintTarget(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;
  final center = Offset(s * 0.50, s * 0.50);

  final outerPaint = Paint()
    ..color = AppColors.warmLight
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05;
  canvas.drawCircle(center, s * 0.36, outerPaint);

  final midPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05;
  canvas.drawCircle(center, s * 0.23, midPaint);

  final innerFillPaint = Paint()..color = primaryColor.withValues(alpha: 0.20);
  canvas.drawCircle(center, s * 0.14, innerFillPaint);

  final innerRingPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.04;
  canvas.drawCircle(center, s * 0.14, innerRingPaint);

  final dotRadius = s * 0.055 + pulse * s * 0.020;
  final dotPaint = Paint()..color = primaryColor;
  canvas.drawCircle(center, dotRadius, dotPaint);
}

// Floppy disk — square body with notch (warmDark), label area (teal). Gentle pulse.
void _paintSave(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final pulse = 1.0 + math.sin(t * 2 * math.pi) * 0.03;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.50);
  canvas.scale(pulse, pulse);
  canvas.translate(-s * 0.50, -s * 0.50);

  // Disk body
  final bodyPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;

  final bodyRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.16, s * 0.16, s * 0.68, s * 0.68),
    Radius.circular(s * 0.06),
  );
  canvas.drawRRect(bodyRect, bodyPaint);

  // Top-right notch cutout
  final notchPaint = Paint()
    ..color = AppColors.cream
    ..style = PaintingStyle.fill;
  final notchPath = Path()
    ..moveTo(s * 0.62, s * 0.16)
    ..lineTo(s * 0.84, s * 0.16)
    ..lineTo(s * 0.84, s * 0.38)
    ..lineTo(s * 0.62, s * 0.16)
    ..close();
  canvas.drawPath(notchPath, notchPaint);

  // Label area (teal rectangle in lower portion)
  final labelPaint = Paint()
    ..color = color ?? AppColors.teal
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.26, s * 0.52, s * 0.48, s * 0.24),
      Radius.circular(s * 0.03),
    ),
    labelPaint,
  );

  // Shutter slot (top center)
  final shutterPaint = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.50)
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.28, s * 0.20, s * 0.28, s * 0.22),
      Radius.circular(s * 0.025),
    ),
    shutterPaint,
  );

  // Label lines
  final linePaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.40)
    ..strokeWidth = s * 0.025
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.32, s * 0.60), Offset(s * 0.68, s * 0.60), linePaint);
  canvas.drawLine(
      Offset(s * 0.32, s * 0.68), Offset(s * 0.58, s * 0.68), linePaint);

  canvas.restore();
}

// Open book — same style as vocabulary. Page flutter.
void _paintOpenBook(Canvas canvas, Size size, double t, Color? color) {
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

  // Spine
  final spinePaint = Paint()
    ..color = primaryColor
    ..strokeWidth = s * 0.035
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.50, s * 0.22), Offset(s * 0.50, s * 0.74), spinePaint);

  // Text lines
  final linePaint = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.35)
    ..strokeWidth = s * 0.02
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 3; i++) {
    final y = s * 0.40 + i * s * 0.10;
    canvas.drawLine(Offset(s * 0.20, y), Offset(s * 0.44, y), linePaint);
    canvas.drawLine(Offset(s * 0.56, y), Offset(s * 0.80, y), linePaint);
  }
}

// Ribbon bookmark — V-notch at bottom, coral fill, side wave.
void _paintRibbonBookmark(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.coral;
  final wave = math.sin(t * 2 * math.pi) * s * 0.018;

  final bookmarkPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final path = Path()
    ..moveTo(s * 0.28, s * 0.12)
    ..lineTo(s * 0.72, s * 0.12)
    ..lineTo(s * 0.72 + wave, s * 0.88)
    ..lineTo(s * 0.50, s * 0.72)
    ..lineTo(s * 0.28 - wave, s * 0.88)
    ..close();
  canvas.drawPath(path, bookmarkPaint);

  // Inner shine stripe
  final shinePaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.18)
    ..style = PaintingStyle.fill;

  final shinePath = Path()
    ..moveTo(s * 0.34, s * 0.12)
    ..lineTo(s * 0.44, s * 0.12)
    ..lineTo(s * 0.44, s * 0.68)
    ..lineTo(s * 0.37, s * 0.62)
    ..lineTo(s * 0.34, s * 0.65)
    ..close();
  canvas.drawPath(shinePath, shinePaint);
}

// Magnifying glass — circle lens (teal stroke) + angled handle, subtle tilt.
void _paintMagnifier(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final tilt = math.sin(t * 2 * math.pi) * 0.08;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(tilt);
  canvas.translate(-s * 0.5, -s * 0.5);

  final lensPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10;
  canvas.drawCircle(Offset(s * 0.42, s * 0.40), s * 0.22, lensPaint);

  final handlePaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.58, s * 0.58), Offset(s * 0.80, s * 0.80), handlePaint);

  canvas.restore();
}

// Brain — two hemispheres with pulsing highlight.
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

  // Fold lines
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

  // Pulsing glow
  final glowPaint = Paint()
    ..color = primaryColor.withValues(alpha: pulse * 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  canvas.drawCircle(Offset(s * 0.50, s * 0.50), s * 0.22, glowPaint);
}

// Playing cards — 2-3 overlapping rounded rects fanning out (teal/purple/gold). Fan animation.
void _paintCards(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final fanSpread = math.sin(t * 2 * math.pi) * 0.04;

  final cardColors = [
    AppColors.gold,
    AppColors.purple,
    color ?? AppColors.teal
  ];
  final baseAngles = [-0.32, 0.0, 0.32];
  final cardRect = Rect.fromLTWH(-s * 0.18, -s * 0.28, s * 0.36, s * 0.52);
  final cardRadius = Radius.circular(s * 0.06);

  canvas.save();
  canvas.translate(s * 0.50, s * 0.54);

  for (int i = 0; i < 3; i++) {
    final angle = baseAngles[i] + (i - 1) * fanSpread;
    canvas.save();
    canvas.rotate(angle);

    final cardPaint = Paint()
      ..color = cardColors[i]
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect, cardRadius), cardPaint);

    // Card suit symbol (simple cross dots)
    final suitPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -s * 0.06), s * 0.055, suitPaint);

    // Card border
    final borderPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025;
    canvas.drawRRect(
        RRect.fromRectAndRadius(cardRect, cardRadius), borderPaint);

    canvas.restore();
  }

  canvas.restore();
}

// Book stack — 3 horizontal rects stacked. Subtle bob.
void _paintStack(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final bob = math.sin(t * 2 * math.pi) * s * 0.018;

  final bookColors = [
    AppColors.teal,
    color ?? AppColors.purple,
    AppColors.gold
  ];
  final bookHeights = [s * 0.14, s * 0.12, s * 0.14];
  final bookWidths = [s * 0.66, s * 0.58, s * 0.72];
  final baseY = s * 0.72;
  final bookRadius = Radius.circular(s * 0.04);

  for (int i = 0; i < 3; i++) {
    final yOffset = i == 0 ? bob : (i == 1 ? bob * 0.6 : bob * 0.3);
    final y = baseY - (i * (bookHeights[0] + s * 0.04)) + yOffset;
    final xStart = (s - bookWidths[i]) / 2;

    final bookPaint = Paint()
      ..color = bookColors[i]
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(xStart, y, bookWidths[i], bookHeights[i]),
        bookRadius,
      ),
      bookPaint,
    );

    // Spine line on each book
    final spinePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.30)
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(xStart + s * 0.06, y + bookHeights[i] * 0.25),
      Offset(xStart + s * 0.06, y + bookHeights[i] * 0.75),
      spinePaint,
    );
  }
}

// Line chart trending up — axes + ascending line (teal) with dot at end. Line draws with t.
void _paintChartUp(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;

  // Axes
  final axisPaint = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.035
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
      Offset(s * 0.16, s * 0.20), Offset(s * 0.16, s * 0.80), axisPaint);
  canvas.drawLine(
      Offset(s * 0.16, s * 0.80), Offset(s * 0.86, s * 0.80), axisPaint);

  // Ascending line points
  final points = [
    Offset(s * 0.16, s * 0.72),
    Offset(s * 0.34, s * 0.60),
    Offset(s * 0.52, s * 0.50),
    Offset(s * 0.70, s * 0.36),
    Offset(s * 0.86, s * 0.26),
  ];

  // Animate line draw progress using t (0→1 loop)
  final drawProgress = (t % 1.0);
  final totalSegments = points.length - 1;

  final linePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final linePath = Path();
  linePath.moveTo(points[0].dx, points[0].dy);

  Offset lastDrawn = points[0];

  for (int i = 0; i < totalSegments; i++) {
    final segStart = i / totalSegments;
    final segEnd = (i + 1) / totalSegments;

    if (drawProgress <= segStart) break;

    if (drawProgress >= segEnd) {
      linePath.lineTo(points[i + 1].dx, points[i + 1].dy);
      lastDrawn = points[i + 1];
    } else {
      final segProgress = (drawProgress - segStart) / (segEnd - segStart);
      final interpX =
          points[i].dx + (points[i + 1].dx - points[i].dx) * segProgress;
      final interpY =
          points[i].dy + (points[i + 1].dy - points[i].dy) * segProgress;
      linePath.lineTo(interpX, interpY);
      lastDrawn = Offset(interpX, interpY);
      break;
    }
  }

  canvas.drawPath(linePath, linePaint);

  // Dot at end of drawn line
  final dotPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;
  canvas.drawCircle(lastDrawn, s * 0.055, dotPaint);

  final dotRimPaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.70)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(lastDrawn, s * 0.028, dotRimPaint);
}

// Notepad — rect with lines + small pencil on right. Pencil writes.
void _paintNotepad(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmDark;

  // Notepad body
  final padPaint = Paint()
    ..color = AppColors.cream
    ..style = PaintingStyle.fill;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.10, s * 0.14, s * 0.60, s * 0.72),
      Radius.circular(s * 0.05),
    ),
    padPaint,
  );

  // Notepad border
  final borderPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.03;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.10, s * 0.14, s * 0.60, s * 0.72),
      Radius.circular(s * 0.05),
    ),
    borderPaint,
  );

  // Top binding strip
  final bindingPaint = Paint()
    ..color = AppColors.teal.withValues(alpha: 0.75)
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.10, s * 0.14, s * 0.60, s * 0.10),
      Radius.circular(s * 0.05),
    ),
    bindingPaint,
  );

  // Horizontal text lines
  final linePaint = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.30)
    ..strokeWidth = s * 0.025
    ..strokeCap = StrokeCap.round;
  for (int i = 0; i < 4; i++) {
    final y = s * 0.34 + i * s * 0.12;
    canvas.drawLine(Offset(s * 0.18, y), Offset(s * 0.62, y), linePaint);
  }

  // Pencil on the right side — tilted with writing animation
  final pencilAngle = -math.pi / 4 + math.sin(t * 2 * math.pi) * 0.10;
  final pencilX = s * 0.80;
  final pencilY = s * 0.50;

  canvas.save();
  canvas.translate(pencilX, pencilY);
  canvas.rotate(pencilAngle);

  // Pencil body
  final pencilBodyPaint = Paint()
    ..color = AppColors.gold
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTWH(-s * 0.06, -s * 0.24, s * 0.12, s * 0.38), pencilBodyPaint);

  // Pencil eraser
  final eraserPaint = Paint()
    ..color = AppColors.coral
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTWH(-s * 0.06, -s * 0.30, s * 0.12, s * 0.08), eraserPaint);

  // Pencil tip (triangle)
  final tipPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;
  final tip = Path()
    ..moveTo(-s * 0.06, s * 0.14)
    ..lineTo(s * 0.06, s * 0.14)
    ..lineTo(0, s * 0.26)
    ..close();
  canvas.drawPath(tip, tipPaint);

  canvas.restore();
}
