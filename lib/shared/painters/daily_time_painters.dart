import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerDailyTimePainters(Map<String, IconPainterFn> registry) {
  registry['time_seedling'] = _paintSeedling;
  registry['time_fire'] = _paintFire;
  registry['time_bolt'] = _paintBolt;
  registry['time_rocket'] = _paintRocket;
}

// Seedling — curved stem (success green) + 2 leaves. Gentle sway via sin(t).
void _paintSeedling(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.success;
  final sway = math.sin(t * 2 * math.pi) * 0.07;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.72);
  canvas.rotate(sway);
  canvas.translate(-s * 0.50, -s * 0.72);

  // Stem
  final stemPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  final stemPath = Path()
    ..moveTo(s * 0.50, s * 0.82)
    ..cubicTo(s * 0.50, s * 0.65, s * 0.46, s * 0.52, s * 0.50, s * 0.38);
  canvas.drawPath(stemPath, stemPaint);

  // Left leaf
  final leafPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final leftLeaf = Path()
    ..moveTo(s * 0.50, s * 0.54)
    ..cubicTo(s * 0.40, s * 0.42, s * 0.22, s * 0.44, s * 0.26, s * 0.58)
    ..cubicTo(s * 0.30, s * 0.66, s * 0.44, s * 0.62, s * 0.50, s * 0.54);
  canvas.drawPath(leftLeaf, leafPaint);

  // Right leaf
  final rightLeaf = Path()
    ..moveTo(s * 0.50, s * 0.44)
    ..cubicTo(s * 0.60, s * 0.32, s * 0.78, s * 0.34, s * 0.74, s * 0.48)
    ..cubicTo(s * 0.70, s * 0.56, s * 0.56, s * 0.52, s * 0.50, s * 0.44);
  canvas.drawPath(rightLeaf, leafPaint);

  // Tiny sprout tip
  final tipPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.75)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.04
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
    Offset(s * 0.50, s * 0.38),
    Offset(s * 0.50, s * 0.26),
    tipPaint,
  );

  canvas.restore();

  // Soil mound at base
  final soilPaint = Paint()
    ..color = AppColors.warmMuted.withValues(alpha: 0.30)
    ..style = PaintingStyle.fill;

  final soilPath = Path()
    ..moveTo(s * 0.30, s * 0.84)
    ..cubicTo(s * 0.30, s * 0.78, s * 0.70, s * 0.78, s * 0.70, s * 0.84)
    ..close();
  canvas.drawPath(soilPath, soilPaint);
}

// Fire — teardrop flame (coral outer, gold inner). Tips flicker at different frequencies.
void _paintFire(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final flicker1 = math.sin(t * 2 * math.pi) * s * 0.025;
  final flicker2 = math.sin(t * 2 * math.pi * 1.7 + 1.0) * s * 0.020;

  // Outer flame (coral)
  final outerPaint = Paint()
    ..color = color ?? AppColors.coral
    ..style = PaintingStyle.fill;

  final outerFlame = Path()
    ..moveTo(s * 0.50, s * 0.14 + flicker1)
    ..cubicTo(
      s * 0.30,
      s * 0.32,
      s * 0.16,
      s * 0.52,
      s * 0.24,
      s * 0.68,
    )
    ..cubicTo(
      s * 0.28,
      s * 0.82,
      s * 0.72,
      s * 0.82,
      s * 0.76,
      s * 0.68,
    )
    ..cubicTo(
      s * 0.84,
      s * 0.52,
      s * 0.70,
      s * 0.32,
      s * 0.50,
      s * 0.14 + flicker1,
    )
    ..close();
  canvas.drawPath(outerFlame, outerPaint);

  // Inner flame (gold)
  final innerPaint = Paint()
    ..color = AppColors.gold
    ..style = PaintingStyle.fill;

  final innerFlame = Path()
    ..moveTo(s * 0.50, s * 0.30 + flicker2)
    ..cubicTo(
      s * 0.38,
      s * 0.44,
      s * 0.30,
      s * 0.56,
      s * 0.36,
      s * 0.68,
    )
    ..cubicTo(
      s * 0.40,
      s * 0.78,
      s * 0.60,
      s * 0.78,
      s * 0.64,
      s * 0.68,
    )
    ..cubicTo(
      s * 0.70,
      s * 0.56,
      s * 0.62,
      s * 0.44,
      s * 0.50,
      s * 0.30 + flicker2,
    )
    ..close();
  canvas.drawPath(innerFlame, innerPaint);

  // Bright core highlight
  final corePaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.30)
    ..style = PaintingStyle.fill;
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(s * 0.48, s * 0.60),
      width: s * 0.16,
      height: s * 0.20,
    ),
    corePaint,
  );
}

// Lightning bolt — zigzag shape (gold). Opacity oscillates between 0.7 and 1.0.
void _paintBolt(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final opacity = 0.70 + math.sin(t * 2 * math.pi) * 0.15;
  final primaryColor = (color ?? AppColors.gold).withValues(alpha: opacity);

  final boltPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bolt = Path()
    ..moveTo(s * 0.58, s * 0.12)
    ..lineTo(s * 0.30, s * 0.52)
    ..lineTo(s * 0.48, s * 0.52)
    ..lineTo(s * 0.38, s * 0.88)
    ..lineTo(s * 0.70, s * 0.46)
    ..lineTo(s * 0.52, s * 0.46)
    ..lineTo(s * 0.58, s * 0.12)
    ..close();
  canvas.drawPath(bolt, boltPaint);

  // Subtle glow halo
  final glowPaint = Paint()
    ..color = (color ?? AppColors.gold).withValues(alpha: opacity * 0.25)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  canvas.drawPath(bolt, glowPaint);
}

// Rocket — pointed body (teal), fins, window. Thrust flame (coral/gold) flickers. Vertical bob.
void _paintRocket(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final bob = math.sin(t * 2 * math.pi) * s * 0.022;
  final flicker = math.sin(t * 2 * math.pi * 2.3 + 0.5) * s * 0.018;

  canvas.save();
  canvas.translate(0, bob);

  // Rocket body
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final body = Path()
    ..moveTo(s * 0.50, s * 0.12)
    ..cubicTo(s * 0.38, s * 0.22, s * 0.34, s * 0.38, s * 0.34, s * 0.58)
    ..lineTo(s * 0.66, s * 0.58)
    ..cubicTo(s * 0.66, s * 0.38, s * 0.62, s * 0.22, s * 0.50, s * 0.12)
    ..close();
  canvas.drawPath(body, bodyPaint);

  // Left fin
  final finPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.80)
    ..style = PaintingStyle.fill;

  final leftFin = Path()
    ..moveTo(s * 0.34, s * 0.50)
    ..lineTo(s * 0.18, s * 0.68)
    ..lineTo(s * 0.34, s * 0.64)
    ..close();
  canvas.drawPath(leftFin, finPaint);

  // Right fin
  final rightFin = Path()
    ..moveTo(s * 0.66, s * 0.50)
    ..lineTo(s * 0.82, s * 0.68)
    ..lineTo(s * 0.66, s * 0.64)
    ..close();
  canvas.drawPath(rightFin, finPaint);

  // Rocket base cap
  final capPaint = Paint()
    ..color = AppColors.warmDark.withValues(alpha: 0.30)
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTWH(s * 0.34, s * 0.58, s * 0.32, s * 0.08), capPaint);

  // Circular window
  final windowPaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.88)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.50, s * 0.38), s * 0.09, windowPaint);

  final windowRimPaint = Paint()
    ..color = AppColors.warmDark.withValues(alpha: 0.25)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.025;
  canvas.drawCircle(Offset(s * 0.50, s * 0.38), s * 0.09, windowRimPaint);

  canvas.restore();

  // Thrust flame at bottom (not bobbing — anchored below rocket nozzle)
  final flameCoral = Paint()
    ..color = AppColors.coral.withValues(alpha: 0.90)
    ..style = PaintingStyle.fill;

  final thrustOuter = Path()
    ..moveTo(s * 0.36, s * 0.66 + bob)
    ..lineTo(s * 0.44, s * 0.86 + flicker + bob)
    ..lineTo(s * 0.50, s * 0.76 + bob)
    ..lineTo(s * 0.56, s * 0.86 + flicker + bob)
    ..lineTo(s * 0.64, s * 0.66 + bob)
    ..close();
  canvas.drawPath(thrustOuter, flameCoral);

  final flameGold = Paint()
    ..color = AppColors.gold.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;

  final thrustInner = Path()
    ..moveTo(s * 0.42, s * 0.66 + bob)
    ..lineTo(s * 0.48, s * 0.78 + flicker * 0.5 + bob)
    ..lineTo(s * 0.50, s * 0.72 + bob)
    ..lineTo(s * 0.52, s * 0.78 + flicker * 0.5 + bob)
    ..lineTo(s * 0.58, s * 0.66 + bob)
    ..close();
  canvas.drawPath(thrustInner, flameGold);
}
