import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerTonePainters(Map<String, IconPainterFn> registry) {
  registry['tone_formal'] = _paintFormal;
  registry['tone_neutral'] = _paintNeutral;
  registry['tone_friendly'] = _paintFriendly;
  registry['tone_casual'] = _paintCasual;
  registry['tone_speaker'] = _paintSpeaker;
}

// Top hat — tall body with brim. Subtle tilt via sin(t).
void _paintFormal(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.formalTone;
  final tilt = math.sin(t * 2 * math.pi) * 0.06;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.60);
  canvas.rotate(tilt);
  canvas.translate(-s * 0.50, -s * 0.60);

  // Hat body
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bodyRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.30, s * 0.18, s * 0.40, s * 0.52),
    Radius.circular(s * 0.04),
  );
  canvas.drawRRect(bodyRect, bodyPaint);

  // Brim
  final brimPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.90)
    ..style = PaintingStyle.fill;

  final brimRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.16, s * 0.68, s * 0.68, s * 0.10),
    Radius.circular(s * 0.03),
  );
  canvas.drawRRect(brimRect, brimPaint);

  // Hat band
  final bandPaint = Paint()
    ..color = AppColors.warmDark.withValues(alpha: 0.22)
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTWH(s * 0.30, s * 0.62, s * 0.40, s * 0.08), bandPaint);

  // Shine glint on hat body
  final glintPaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.18)
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.34, s * 0.22, s * 0.10, s * 0.28),
      Radius.circular(s * 0.05),
    ),
    glintPaint,
  );

  canvas.restore();
}

// Balance scale — vertical post + horizontal beam + 2 hanging pans. Beam tilts gently.
void _paintNeutral(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.neutralTone;
  final tilt = math.sin(t * 2 * math.pi) * 0.12;

  // Vertical post
  final postPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.50, s * 0.22), Offset(s * 0.50, s * 0.82), postPaint);

  // Base
  final basePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.32, s * 0.82), Offset(s * 0.68, s * 0.82), basePaint);

  // Rotating beam around post top
  canvas.save();
  canvas.translate(s * 0.50, s * 0.28);
  canvas.rotate(tilt);

  final beamPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.045
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(Offset(-s * 0.30, 0), Offset(s * 0.30, 0), beamPaint);

  // Left pan strings + pan
  final stringPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.70)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.025
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
      Offset(-s * 0.28, 0), Offset(-s * 0.28, s * 0.26), stringPaint);
  canvas.drawLine(
      Offset(-s * 0.32, 0), Offset(-s * 0.28, s * 0.26), stringPaint);
  canvas.drawLine(
      Offset(-s * 0.24, 0), Offset(-s * 0.28, s * 0.26), stringPaint);

  // Left pan dish
  final panPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.05
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(-s * 0.28, s * 0.26), width: s * 0.24, height: s * 0.12),
    0,
    math.pi,
    false,
    panPaint,
  );

  // Right pan strings + pan
  canvas.drawLine(Offset(s * 0.28, 0), Offset(s * 0.28, s * 0.26), stringPaint);
  canvas.drawLine(Offset(s * 0.32, 0), Offset(s * 0.28, s * 0.26), stringPaint);
  canvas.drawLine(Offset(s * 0.24, 0), Offset(s * 0.28, s * 0.26), stringPaint);

  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(s * 0.28, s * 0.26), width: s * 0.24, height: s * 0.12),
    0,
    math.pi,
    false,
    panPaint,
  );

  canvas.restore();

  // Top pivot knob
  final knobPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.50, s * 0.22), s * 0.045, knobPaint);
}

// Smiley face — circle (friendlyTone), two dot eyes, curved smile. Eye blink animation.
void _paintFriendly(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.friendlyTone;

  // Face circle
  final facePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.50, s * 0.50), s * 0.36, facePaint);

  // Blink: eyes become thin lines momentarily
  // blink triggers once per cycle near t=0.5
  final blinkProgress =
      math.max(0.0, math.sin(t * 2 * math.pi - math.pi * 0.5));
  final eyeHeight = s * 0.055 * (1.0 - blinkProgress * 0.92);

  final eyePaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;

  // Left eye
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(s * 0.38, s * 0.42),
      width: s * 0.055,
      height: eyeHeight.clamp(s * 0.005, s * 0.055),
    ),
    eyePaint,
  );

  // Right eye
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(s * 0.62, s * 0.42),
      width: s * 0.055,
      height: eyeHeight.clamp(s * 0.005, s * 0.055),
    ),
    eyePaint,
  );

  // Smile arc
  final smilePaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(
    Rect.fromCenter(
      center: Offset(s * 0.50, s * 0.50),
      width: s * 0.36,
      height: s * 0.36,
    ),
    math.pi * 0.20,
    math.pi * 0.60,
    false,
    smilePaint,
  );

  // Subtle cheek blush circles
  final blushPaint = Paint()
    ..color = AppColors.coral.withValues(alpha: 0.28)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.32, s * 0.56), s * 0.08, blushPaint);
  canvas.drawCircle(Offset(s * 0.68, s * 0.56), s * 0.08, blushPaint);
}

// Peace/victory hand — two raised fingers (casualTone). Slight wave oscillation.
void _paintCasual(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.casualTone;
  final wave = math.sin(t * 2 * math.pi) * 0.07;

  canvas.save();
  canvas.translate(s * 0.50, s * 0.55);
  canvas.rotate(wave);
  canvas.translate(-s * 0.50, -s * 0.55);

  final handPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  // Palm base
  final palm = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.30, s * 0.56, s * 0.40, s * 0.30),
    Radius.circular(s * 0.06),
  );
  canvas.drawRRect(palm, handPaint);

  // Index finger (left raised finger)
  final indexFinger = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.32, s * 0.22, s * 0.14, s * 0.40),
    Radius.circular(s * 0.07),
  );
  canvas.drawRRect(indexFinger, handPaint);

  // Middle finger (right raised finger)
  final middleFinger = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.50, s * 0.18, s * 0.14, s * 0.44),
    Radius.circular(s * 0.07),
  );
  canvas.drawRRect(middleFinger, handPaint);

  // Ring finger (partially bent / tucked)
  final ringFinger = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.68, s * 0.48, s * 0.00, s * 0.00),
    Radius.circular(s * 0.07),
  );
  canvas.drawRRect(ringFinger, handPaint);

  // Knuckle lines
  final knucklePaint = Paint()
    ..color = AppColors.white.withValues(alpha: 0.28)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.025
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.32, s * 0.58), Offset(s * 0.46, s * 0.58), knucklePaint);
  canvas.drawLine(
      Offset(s * 0.50, s * 0.58), Offset(s * 0.64, s * 0.58), knucklePaint);

  canvas.restore();
}

// Speaker cone with 2 sound arcs. Arcs pulse opacity.
void _paintSpeaker(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmDark;
  final arcOpacity = math.sin(t * 2 * math.pi) * 0.40 + 0.60;

  // Speaker body (trapezoid)
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bodyPath = Path()
    ..moveTo(s * 0.18, s * 0.38)
    ..lineTo(s * 0.40, s * 0.28)
    ..lineTo(s * 0.40, s * 0.72)
    ..lineTo(s * 0.18, s * 0.62)
    ..close();
  canvas.drawPath(bodyPath, bodyPaint);

  // Speaker grille box
  final grillPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTRB(s * 0.10, s * 0.38, s * 0.18, s * 0.62), grillPaint);

  // Outer sound arc
  final arcPaint1 = Paint()
    ..color = AppColors.teal.withValues(alpha: arcOpacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;

  canvas.drawArc(
    Rect.fromCenter(
      center: Offset(s * 0.40, s * 0.50),
      width: s * 0.30,
      height: s * 0.30,
    ),
    -math.pi * 0.42,
    math.pi * 0.84,
    false,
    arcPaint1,
  );

  // Inner sound arc (farther out, dimmer)
  final arcPaint2 = Paint()
    ..color = AppColors.teal.withValues(alpha: arcOpacity * 0.50)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  canvas.drawArc(
    Rect.fromCenter(
      center: Offset(s * 0.40, s * 0.50),
      width: s * 0.52,
      height: s * 0.52,
    ),
    -math.pi * 0.42,
    math.pi * 0.84,
    false,
    arcPaint2,
  );
}
