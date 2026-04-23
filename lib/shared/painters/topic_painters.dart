import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerTopicPainters(Map<String, IconPainterFn> registry) {
  registry['topic_travel'] = _paintTravel;
  registry['topic_business'] = _paintBusiness;
  registry['topic_social'] = _paintSocial;
  registry['topic_dailyLife'] = _paintDailyLife;
  registry['topic_technology'] = _paintTechnology;
  registry['topic_education'] = _paintEducation;
  registry['topic_food'] = _paintFood;
  registry['topic_healthcare'] = _paintHealthcare;
  registry['topic_shopping'] = _paintShopping;
  registry['topic_entertainment'] = _paintEntertainment;
  registry['topic_sports'] = _paintSports;
  registry['topic_nature'] = _paintNature;
  registry['topic_finance'] = _paintFinance;
  registry['topic_relationships'] = _paintRelationships;
  registry['topic_law'] = _paintLaw;
  registry['topic_realEstate'] = _paintRealEstate;
}

// Airplane silhouette with gentle banking tilt
void _paintTravel(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.teal;
  final angle = math.sin(t * 2 * math.pi) * 0.1;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(angle);
  canvas.translate(-s * 0.5, -s * 0.5);

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Fuselage
  final fuselage = Path()
    ..moveTo(s * 0.50, s * 0.18)
    ..lineTo(s * 0.58, s * 0.54)
    ..lineTo(s * 0.50, s * 0.50)
    ..lineTo(s * 0.42, s * 0.54)
    ..close();
  canvas.drawPath(fuselage, paint);

  // Wings
  final wings = Path()
    ..moveTo(s * 0.50, s * 0.36)
    ..lineTo(s * 0.82, s * 0.56)
    ..lineTo(s * 0.50, s * 0.50)
    ..lineTo(s * 0.18, s * 0.56)
    ..close();
  canvas.drawPath(wings, paint);

  // Tail fins
  final tail = Path()
    ..moveTo(s * 0.50, s * 0.50)
    ..lineTo(s * 0.66, s * 0.72)
    ..lineTo(s * 0.50, s * 0.68)
    ..lineTo(s * 0.34, s * 0.72)
    ..close();
  canvas.drawPath(tail, paint);

  canvas.restore();
}

// Briefcase with bouncing clasp
void _paintBusiness(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.coral;
  final claspBob = math.sin(t * 2 * math.pi) * s * 0.015;

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Body
  final body = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.12, s * 0.36, s * 0.76, s * 0.50),
    Radius.circular(s * 0.06),
  );
  canvas.drawRRect(body, paint);

  // Handle arc
  final handlePaint = Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.08
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(
    Rect.fromLTWH(s * 0.30, s * 0.16, s * 0.40, s * 0.28),
    math.pi,
    math.pi,
    false,
    handlePaint,
  );

  // Clasp (center divider line + small rect)
  final claspPaint = Paint()
    ..color = AppColors.white.withOpacity(0.8)
    ..style = PaintingStyle.fill;
  final claspRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.42, s * 0.56 + claspBob, s * 0.16, s * 0.10),
    Radius.circular(s * 0.02),
  );
  canvas.drawRRect(claspRect, claspPaint);
}

// Two overlapping circles tapping together
void _paintSocial(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final offset = math.sin(t * 2 * math.pi) * s * 0.04;

  final tealPaint = Paint()
    ..color = AppColors.teal.withOpacity(0.85)
    ..style = PaintingStyle.fill;
  final purplePaint = Paint()
    ..color = AppColors.purple.withOpacity(0.85)
    ..style = PaintingStyle.fill;

  // Left circle moves right on tap
  canvas.drawCircle(
    Offset(s * 0.34 + offset, s * 0.50),
    s * 0.24,
    tealPaint,
  );
  // Right circle moves left on tap
  canvas.drawCircle(
    Offset(s * 0.66 - offset, s * 0.50),
    s * 0.24,
    purplePaint,
  );
}

// House with chimney and drifting smoke
void _paintDailyLife(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final smokeRise = math.sin(t * 2 * math.pi) * s * 0.04;

  // House body
  final bodyPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;
  canvas.drawRect(
    Rect.fromLTWH(s * 0.18, s * 0.50, s * 0.64, s * 0.40),
    bodyPaint,
  );

  // Roof triangle
  final roofPaint = Paint()
    ..color = color ?? AppColors.coral
    ..style = PaintingStyle.fill;
  final roof = Path()
    ..moveTo(s * 0.10, s * 0.52)
    ..lineTo(s * 0.50, s * 0.18)
    ..lineTo(s * 0.90, s * 0.52)
    ..close();
  canvas.drawPath(roof, roofPaint);

  // Chimney
  canvas.drawRect(
    Rect.fromLTWH(s * 0.62, s * 0.24, s * 0.10, s * 0.20),
    bodyPaint,
  );

  // Smoke circles drifting up
  final smokePaint = Paint()
    ..color = AppColors.warmLight.withOpacity(0.6)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(
      Offset(s * 0.67, s * 0.18 - smokeRise), s * 0.04, smokePaint);
  canvas.drawCircle(
      Offset(s * 0.70, s * 0.10 - smokeRise), s * 0.03, smokePaint);
}

// Laptop with blinking cursor
void _paintTechnology(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.warmDark;
  // Cursor blinks: opacity oscillates 0→1
  final cursorOpacity = (math.sin(t * 2 * math.pi) + 1) / 2;

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Screen trapezoid
  final screen = Path()
    ..moveTo(s * 0.14, s * 0.22)
    ..lineTo(s * 0.86, s * 0.22)
    ..lineTo(s * 0.80, s * 0.64)
    ..lineTo(s * 0.20, s * 0.64)
    ..close();
  canvas.drawPath(screen, paint);

  // Screen interior (lighter)
  final screenInner = Paint()
    ..color = AppColors.warmMuted
    ..style = PaintingStyle.fill;
  final innerScreen = Path()
    ..moveTo(s * 0.20, s * 0.28)
    ..lineTo(s * 0.80, s * 0.28)
    ..lineTo(s * 0.75, s * 0.58)
    ..lineTo(s * 0.25, s * 0.58)
    ..close();
  canvas.drawPath(innerScreen, screenInner);

  // Base
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.06, s * 0.64, s * 0.88, s * 0.10),
      Radius.circular(s * 0.03),
    ),
    paint,
  );

  // Blinking cursor line on screen
  final cursorPaint = Paint()
    ..color = AppColors.white.withOpacity(cursorOpacity)
    ..strokeWidth = s * 0.05
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.32, s * 0.38),
    Offset(s * 0.32, s * 0.50),
    cursorPaint,
  );
}

// Graduation cap with swinging tassel
void _paintEducation(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.warmDark;
  final tasselSwing = math.sin(t * 2 * math.pi) * 0.18;

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Cap board (diamond / rotated rect)
  canvas.save();
  canvas.translate(s * 0.50, s * 0.36);
  canvas.rotate(math.pi / 4);
  canvas.drawRect(
    Rect.fromCenter(center: Offset.zero, width: s * 0.40, height: s * 0.40),
    paint,
  );
  canvas.restore();

  // Cap base cylinder
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.30, s * 0.46, s * 0.40, s * 0.16),
      Radius.circular(s * 0.04),
    ),
    paint,
  );

  // Tassel cord
  canvas.save();
  canvas.translate(s * 0.72, s * 0.36);
  canvas.rotate(tasselSwing);

  final tasselPaint = Paint()
    ..color = AppColors.gold
    ..strokeWidth = s * 0.05
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(Offset.zero, Offset(0, s * 0.30), tasselPaint);

  // Tassel tip
  canvas.drawCircle(
      Offset(0, s * 0.30), s * 0.05, Paint()..color = AppColors.gold);
  canvas.restore();
}

// Bowl with rising steam
void _paintFood(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.teal;
  final steamRise = math.sin(t * 2 * math.pi) * s * 0.03;

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Bowl semicircle
  canvas.drawArc(
    Rect.fromLTWH(s * 0.12, s * 0.40, s * 0.76, s * 0.46),
    0,
    math.pi,
    true,
    paint,
  );

  // Bowl rim
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.10, s * 0.40, s * 0.80, s * 0.08),
      Radius.circular(s * 0.04),
    ),
    paint,
  );

  // Steam curves
  final steamPaint = Paint()
    ..color = AppColors.warmLight
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;

  for (int i = 0; i < 3; i++) {
    final xBase = s * (0.28 + i * 0.22);
    final path = Path()
      ..moveTo(xBase, s * 0.38 - steamRise)
      ..quadraticBezierTo(
        xBase + s * 0.06,
        s * 0.26 - steamRise,
        xBase,
        s * 0.16 - steamRise,
      );
    canvas.drawPath(path, steamPaint);
  }
}

// Cross inside circle — pulsing scale
void _paintHealthcare(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.error;
  final pulse = 1.0 + math.sin(t * 2 * math.pi) * 0.06;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.scale(pulse);
  canvas.translate(-s * 0.5, -s * 0.5);

  // Circle outline
  final circlePaint = Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.08;
  canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.38, circlePaint);

  // Cross fill
  final crossPaint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTWH(s * 0.44, s * 0.24, s * 0.12, s * 0.52), crossPaint);
  canvas.drawRect(
      Rect.fromLTWH(s * 0.24, s * 0.44, s * 0.52, s * 0.12), crossPaint);

  canvas.restore();
}

// Shopping bag with gentle swing
void _paintShopping(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.purple;
  final swing = math.sin(t * 2 * math.pi) * 0.06;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.20);
  canvas.rotate(swing);
  canvas.translate(-s * 0.50, -s * 0.20);

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Bag body (trapezoid)
  final bag = Path()
    ..moveTo(s * 0.18, s * 0.36)
    ..lineTo(s * 0.82, s * 0.36)
    ..lineTo(s * 0.74, s * 0.86)
    ..lineTo(s * 0.26, s * 0.86)
    ..close();
  canvas.drawPath(bag, paint);

  // Handles
  final handlePaint = Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(
    Rect.fromLTWH(s * 0.26, s * 0.14, s * 0.20, s * 0.26),
    math.pi,
    math.pi,
    false,
    handlePaint,
  );
  canvas.drawArc(
    Rect.fromLTWH(s * 0.54, s * 0.14, s * 0.20, s * 0.26),
    math.pi,
    math.pi,
    false,
    handlePaint,
  );

  canvas.restore();
}

// Clapperboard with clapping top piece
void _paintEntertainment(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.warmDark;
  final clapAngle = math.sin(t * 2 * math.pi).abs() * 0.30;

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Board body
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.10, s * 0.34, s * 0.80, s * 0.54),
      Radius.circular(s * 0.06),
    ),
    paint,
  );

  // Stripe lines on body
  final stripePaint = Paint()
    ..color = AppColors.white.withOpacity(0.3)
    ..strokeWidth = s * 0.06;
  for (int i = 0; i < 3; i++) {
    final x = s * (0.22 + i * 0.22);
    canvas.drawLine(Offset(x, s * 0.34), Offset(x, s * 0.88), stripePaint);
  }

  // Hinged top piece (rotates open)
  canvas.save();
  canvas.translate(s * 0.10, s * 0.34);
  canvas.rotate(-clapAngle);

  final topPaint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, -s * 0.18, s * 0.80, s * 0.18),
      Radius.circular(s * 0.04),
    ),
    topPaint,
  );

  // Diagonal stripe on top piece
  final topStripePaint = Paint()
    ..color = AppColors.white.withOpacity(0.5)
    ..strokeWidth = s * 0.06;
  for (int i = 0; i < 3; i++) {
    final x = s * (0.12 + i * 0.22);
    canvas.drawLine(
        Offset(x, 0), Offset(x + s * 0.12, -s * 0.18), topStripePaint);
  }

  canvas.restore();
}

// Soccer ball with subtle spin
void _paintSports(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final spinAngle = t * 2 * math.pi;

  // Ball base
  final whitePaint = Paint()
    ..color = AppColors.white
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.40, whitePaint);

  // Outline
  final outlinePaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.06;
  canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.40, outlinePaint);

  // Rotating center pentagon patch
  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(spinAngle);

  final patchPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;

  final pentagon = Path();
  for (int i = 0; i < 5; i++) {
    final angle = (i * 2 * math.pi / 5) - math.pi / 2;
    final px = math.cos(angle) * s * 0.14;
    final py = math.sin(angle) * s * 0.14;
    if (i == 0)
      pentagon.moveTo(px, py);
    else
      pentagon.lineTo(px, py);
  }
  pentagon.close();
  canvas.drawPath(pentagon, patchPaint);

  canvas.restore();
}

// Leaf shape with gentle sway
void _paintNature(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.success;
  final sway = math.sin(t * 2 * math.pi) * 0.12;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.72);
  canvas.rotate(sway);
  canvas.translate(-s * 0.50, -s * 0.72);

  // Stem
  final stemPaint = Paint()
    ..color = c
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.50, s * 0.86), Offset(s * 0.50, s * 0.50), stemPaint);

  // Leaf shape
  final leafPaint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;
  final leaf = Path()
    ..moveTo(s * 0.50, s * 0.16)
    ..cubicTo(s * 0.80, s * 0.20, s * 0.82, s * 0.54, s * 0.50, s * 0.52)
    ..cubicTo(s * 0.18, s * 0.54, s * 0.20, s * 0.20, s * 0.50, s * 0.16)
    ..close();
  canvas.drawPath(leaf, leafPaint);

  // Midrib line
  final ribPaint = Paint()
    ..color = AppColors.white.withOpacity(0.5)
    ..strokeWidth = s * 0.04
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.50, s * 0.18), Offset(s * 0.50, s * 0.50), ribPaint);

  canvas.restore();
}

// Money bag with bouncing coin above
void _paintFinance(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.gold;
  final coinBob = math.sin(t * 2 * math.pi) * s * 0.06;

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Bag body
  final bag = Path()
    ..moveTo(s * 0.50, s * 0.30)
    ..cubicTo(s * 0.80, s * 0.30, s * 0.86, s * 0.54, s * 0.82, s * 0.70)
    ..cubicTo(s * 0.78, s * 0.88, s * 0.22, s * 0.88, s * 0.18, s * 0.70)
    ..cubicTo(s * 0.14, s * 0.54, s * 0.20, s * 0.30, s * 0.50, s * 0.30)
    ..close();
  canvas.drawPath(bag, paint);

  // Bag neck
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.36, s * 0.18, s * 0.28, s * 0.14),
      Radius.circular(s * 0.04),
    ),
    paint,
  );

  // Dollar sign on bag
  final textPaint = Paint()
    ..color = AppColors.white.withOpacity(0.8)
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(
      Offset(s * 0.50, s * 0.48), Offset(s * 0.50, s * 0.78), textPaint);

  final sPaint = Paint()
    ..color = AppColors.white.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(
    Rect.fromLTWH(s * 0.38, s * 0.46, s * 0.24, s * 0.16),
    math.pi * 0.2,
    math.pi * 1.4,
    false,
    sPaint,
  );
  canvas.drawArc(
    Rect.fromLTWH(s * 0.38, s * 0.60, s * 0.24, s * 0.16),
    math.pi * 1.2,
    math.pi * 1.4,
    false,
    sPaint,
  );

  // Bouncing coin
  canvas.drawCircle(
    Offset(s * 0.50, s * 0.12 - coinBob),
    s * 0.10,
    Paint()..color = c,
  );
  canvas.drawCircle(
    Offset(s * 0.50, s * 0.12 - coinBob),
    s * 0.10,
    Paint()
      ..color = AppColors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03,
  );
}

// Heart with pulse scale animation
void _paintRelationships(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.coral;
  final scale = 1.0 + math.sin(t * 2 * math.pi) * 0.08;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.scale(scale);
  canvas.translate(-s * 0.5, -s * 0.5);

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  final heart = Path()
    ..moveTo(s * 0.50, s * 0.72)
    ..cubicTo(s * 0.18, s * 0.52, s * 0.10, s * 0.30, s * 0.28, s * 0.24)
    ..cubicTo(s * 0.38, s * 0.20, s * 0.46, s * 0.28, s * 0.50, s * 0.36)
    ..cubicTo(s * 0.54, s * 0.28, s * 0.62, s * 0.20, s * 0.72, s * 0.24)
    ..cubicTo(s * 0.90, s * 0.30, s * 0.82, s * 0.52, s * 0.50, s * 0.72)
    ..close();
  canvas.drawPath(heart, paint);

  canvas.restore();
}

// Balance scale with tilting beam
void _paintLaw(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.warmDark;
  final tilt = math.sin(t * 2 * math.pi) * 0.10;

  final paint = Paint()
    ..color = c
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // Vertical pole
  canvas.drawLine(
      Offset(s * 0.50, s * 0.20), Offset(s * 0.50, s * 0.82), paint);

  // Base
  canvas.drawLine(
      Offset(s * 0.22, s * 0.82), Offset(s * 0.78, s * 0.82), paint);

  // Tilting beam
  canvas.save();
  canvas.translate(s * 0.50, s * 0.28);
  canvas.rotate(tilt);
  canvas.drawLine(Offset(-s * 0.32, 0), Offset(s * 0.32, 0), paint);

  // Left pan
  final panPaint = Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(Offset(-s * 0.32, 0), Offset(-s * 0.32, s * 0.22), panPaint);
  canvas.drawArc(
    Rect.fromLTWH(-s * 0.44, s * 0.20, s * 0.24, s * 0.12),
    0,
    math.pi,
    false,
    panPaint,
  );

  // Right pan
  canvas.drawLine(Offset(s * 0.32, 0), Offset(s * 0.32, s * 0.22), panPaint);
  canvas.drawArc(
    Rect.fromLTWH(s * 0.20, s * 0.20, s * 0.24, s * 0.12),
    0,
    math.pi,
    false,
    panPaint,
  );

  canvas.restore();
}

// Key with rotation oscillation
void _paintRealEstate(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final c = color ?? AppColors.gold;
  final oscillation = math.sin(t * 2 * math.pi) * 0.12;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(oscillation);
  canvas.translate(-s * 0.5, -s * 0.5);

  final paint = Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  // Key bow (oval ring)
  final ringPaint = Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10;
  canvas.drawCircle(Offset(s * 0.34, s * 0.40), s * 0.18, ringPaint);

  // Key shaft
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.44, s * 0.46, s * 0.44, s * 0.10),
      Radius.circular(s * 0.03),
    ),
    paint,
  );

  // Key teeth
  canvas.drawRect(Rect.fromLTWH(s * 0.68, s * 0.56, s * 0.08, s * 0.10), paint);
  canvas.drawRect(Rect.fromLTWH(s * 0.78, s * 0.56, s * 0.08, s * 0.08), paint);

  canvas.restore();
}
