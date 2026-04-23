import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerModePainters(Map<String, IconPainterFn> registry) {
  registry['scenario'] = _paintScenario;
  registry['story'] = _paintStory;
  registry['tone'] = _paintTone;
  registry['vocabHub'] = _paintVocabHub;
}

void _paintScenario(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.warmDark;

  // Side-profile head silhouette
  final headPaint = Paint()
    ..color = primary
    ..style = PaintingStyle.fill;

  final headPath = Path();
  // Simple profile: circle-ish head facing right
  headPath.addOval(Rect.fromCenter(
    center: Offset(s * 0.34, s * 0.36),
    width: s * 0.36,
    height: s * 0.40,
  ));

  // Neck + partial shoulder
  headPath.addRect(Rect.fromLTWH(s * 0.22, s * 0.54, s * 0.24, s * 0.18));

  canvas.drawPath(headPath, headPaint);

  // Mouth area indicator — small dot at the "mouth" position
  final mouthX = s * 0.44;
  final mouthY = s * 0.42;

  // Sound wave lines emanating from mouth, pulsing opacity
  final wavePhase = t * 2 * math.pi;
  final wavePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  final waveData = [
    (s * 0.10, 1.0),
    (s * 0.16, 0.65),
    (s * 0.22, 0.35),
  ];

  for (int i = 0; i < waveData.length; i++) {
    final (radius, baseOpacity) = waveData[i];
    final opacity =
        baseOpacity * (0.5 + 0.5 * math.sin(wavePhase - i * math.pi * 0.5));
    wavePaint.color = AppColors.teal.withOpacity(opacity.clamp(0.1, 1.0));

    // Arc spanning roughly 90° around the mouth
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(mouthX, mouthY),
        width: radius * 2,
        height: radius * 2,
      ),
      -math.pi * 0.35,
      math.pi * 0.70,
      false,
      wavePaint,
    );
  }
}

void _paintStory(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.gold;

  final fillPaint = Paint()
    ..color = primary
    ..style = PaintingStyle.fill;

  // Unrolled section of scroll — flat parchment body
  final bodyRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.18, s * 0.28, s * 0.64, s * 0.50),
    Radius.circular(s * 0.04),
  );
  canvas.drawRRect(bodyRect, fillPaint);

  // Top rolled edge — oval cylinder cap
  final topRollPaint = Paint()
    ..color = primary.withOpacity(0.75)
    ..style = PaintingStyle.fill;
  canvas.drawOval(
    Rect.fromLTWH(s * 0.18, s * 0.20, s * 0.64, s * 0.16),
    topRollPaint,
  );

  // Bottom rolled edge
  canvas.drawOval(
    Rect.fromLTWH(s * 0.18, s * 0.70, s * 0.64, s * 0.16),
    topRollPaint,
  );

  // Gentle unrolling wave: faint text lines with subtle vertical shift
  final waveOffset = math.sin(t * 2 * math.pi) * s * 0.015;
  final linePaint = Paint()
    ..color = AppColors.warmDark.withOpacity(0.30)
    ..strokeWidth = s * 0.045
    ..strokeCap = StrokeCap.round;

  for (int i = 0; i < 3; i++) {
    final y = s * (0.38 + i * 0.12) + waveOffset;
    final xEnd = i == 2 ? s * 0.60 : s * 0.72;
    canvas.drawLine(Offset(s * 0.28, y), Offset(xEnd, y), linePaint);
  }
}

void _paintTone(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;

  // Artist palette — oval background
  final palettePaint = Paint()
    ..color = color ?? AppColors.warmLight
    ..style = PaintingStyle.fill;

  final palettePath = Path();
  palettePath.addOval(Rect.fromCenter(
    center: Offset(s * 0.50, s * 0.52),
    width: s * 0.78,
    height: s * 0.68,
  ));

  // Thumb hole cutout
  palettePath.addOval(Rect.fromCenter(
    center: Offset(s * 0.68, s * 0.34),
    width: s * 0.18,
    height: s * 0.18,
  ));

  canvas.drawPath(palettePath, palettePaint);

  // 4 color dots orbiting slightly
  final dotColors = [
    AppColors.teal,
    AppColors.purple,
    AppColors.gold,
    AppColors.coral,
  ];

  // Base positions for dots on the palette
  final baseDots = [
    Offset(s * 0.28, s * 0.38),
    Offset(s * 0.44, s * 0.30),
    Offset(s * 0.34, s * 0.60),
    Offset(s * 0.56, s * 0.62),
  ];

  final dotPaint = Paint()..style = PaintingStyle.fill;
  final phase = t * 2 * math.pi;

  for (int i = 0; i < 4; i++) {
    // Subtle orbital shift — each dot offset by phase + quadrant
    final angle = phase + i * math.pi * 0.5;
    final orbit = s * 0.025;
    final dx = math.cos(angle) * orbit;
    final dy = math.sin(angle) * orbit;

    dotPaint.color = dotColors[i];
    canvas.drawCircle(
      Offset(baseDots[i].dx + dx, baseDots[i].dy + dy),
      s * 0.075,
      dotPaint,
    );
  }
}

void _paintVocabHub(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;

  // 3 overlapping rounded rect cards fanning out
  // Subtle fanning animation: cards spread slightly with sin(t)
  final fanOffset = math.sin(t * 2 * math.pi) * s * 0.025;

  final cardColors = [
    AppColors.gold,
    AppColors.purple,
    color ?? AppColors.teal,
  ];

  // Draw back-to-front; back card most offset
  final cardAngles = [
    -0.28 - fanOffset * 0.04,
    0.0,
    0.28 + fanOffset * 0.04,
  ];

  final cardRect = Rect.fromLTWH(-s * 0.22, -s * 0.30, s * 0.44, s * 0.56);
  final cardRadius = Radius.circular(s * 0.08);

  canvas.save();
  canvas.translate(s * 0.5, s * 0.52);

  // Draw in order: back (gold) → middle (purple) → front (teal)
  for (int i = 0; i < 3; i++) {
    canvas.save();
    canvas.rotate(cardAngles[i]);

    final cardPaint = Paint()
      ..color = cardColors[i]
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, cardRadius),
      cardPaint,
    );

    // Faint lines on each card to suggest text/vocab
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round;

    for (int j = 0; j < 2; j++) {
      final ly = -s * 0.06 + j * s * 0.14;
      canvas.drawLine(
        Offset(-s * 0.12, ly),
        Offset(s * 0.12, ly),
        linePaint,
      );
    }

    canvas.restore();
  }

  canvas.restore();
}
