import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerStatusPainters(Map<String, IconPainterFn> registry) {
  registry['check'] = _paintCheck;
  registry['error'] = _paintError;
  registry['warning'] = _paintWarning;
  registry['signOut'] = _paintSignOut;
}

// -----------------------------------------------------------------------------
// Check — Checkmark in circle with opacity pulse
// -----------------------------------------------------------------------------
void _paintCheck(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.success;
  final center = Offset(s * 0.50, s * 0.50);
  final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;

  // Circle outline
  final circlePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055;
  canvas.drawCircle(center, s * 0.36, circlePaint);

  // Checkmark stroke
  final checkPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.55 + pulse * 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final checkPath = Path()
    ..moveTo(s * 0.26, s * 0.50)
    ..lineTo(s * 0.43, s * 0.66)
    ..lineTo(s * 0.72, s * 0.36);
  canvas.drawPath(checkPath, checkPaint);
}

// -----------------------------------------------------------------------------
// Error — X mark in circle with horizontal shake
// -----------------------------------------------------------------------------
void _paintError(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.error;
  final shake = math.sin(t * 2 * math.pi) * s * 0.022;
  final center = Offset(s * 0.50, s * 0.50);

  canvas.save();
  canvas.translate(shake, 0);

  // Circle outline
  final circlePaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055;
  canvas.drawCircle(center, s * 0.36, circlePaint);

  // X strokes
  final xPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.34, s * 0.34),
    Offset(s * 0.66, s * 0.66),
    xPaint,
  );
  canvas.drawLine(
    Offset(s * 0.66, s * 0.34),
    Offset(s * 0.34, s * 0.66),
    xPaint,
  );

  canvas.restore();
}

// -----------------------------------------------------------------------------
// Warning — Triangle with exclamation mark and pulsing color
// -----------------------------------------------------------------------------
void _paintWarning(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final baseColor = color ?? AppColors.gold;
  final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;

  // Pulse between base color and a slightly brighter tint
  const brighterGold = Color(0xFFF5D98A);
  final pulseColor = Color.lerp(baseColor, brighterGold, pulse * 0.55)!;

  // Triangle outline
  final trianglePaint = Paint()
    ..color = pulseColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final trianglePath = Path()
    ..moveTo(s * 0.50, s * 0.16)
    ..lineTo(s * 0.88, s * 0.82)
    ..lineTo(s * 0.12, s * 0.82)
    ..close();
  canvas.drawPath(trianglePath, trianglePaint);

  // Exclamation line
  final exclamPaint = Paint()
    ..color = pulseColor
    ..strokeWidth = s * 0.065
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.50, s * 0.38),
    Offset(s * 0.50, s * 0.62),
    exclamPaint,
  );

  // Exclamation dot
  final dotPaint = Paint()..color = pulseColor;
  canvas.drawCircle(Offset(s * 0.50, s * 0.72), s * 0.046, dotPaint);
}

// -----------------------------------------------------------------------------
// Sign Out — Door with rightward-sliding arrow
// -----------------------------------------------------------------------------
void _paintSignOut(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmDark;
  final arrowSlide = math.sin(t * 2 * math.pi) * s * 0.030;

  // Door body
  final doorPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeJoin = StrokeJoin.round;
  final doorPath = Path()
    ..moveTo(s * 0.22, s * 0.18)
    ..lineTo(s * 0.22, s * 0.82)
    ..lineTo(s * 0.60, s * 0.82)
    ..lineTo(s * 0.60, s * 0.18)
    ..close();
  canvas.drawPath(doorPath, doorPaint);

  // Door panel (inner rect)
  final panelPaint = Paint()
    ..color = primaryColor.withValues(alpha: 0.22)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.03;
  canvas.drawRect(
    Rect.fromLTWH(s * 0.29, s * 0.28, s * 0.22, s * 0.30),
    panelPaint,
  );

  // Door knob
  final knobPaint = Paint()..color = primaryColor.withValues(alpha: 0.60);
  canvas.drawCircle(Offset(s * 0.54, s * 0.50), s * 0.040, knobPaint);

  // Arrow line (exits rightward from door gap)
  final arrowX = s * 0.60 + arrowSlide;
  final arrowPaint = Paint()
    ..color = primaryColor
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(arrowX, s * 0.50),
    Offset(arrowX + s * 0.22, s * 0.50),
    arrowPaint,
  );

  // Arrow head
  final headPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final headPath = Path()
    ..moveTo(arrowX + s * 0.10, s * 0.38)
    ..lineTo(arrowX + s * 0.22, s * 0.50)
    ..lineTo(arrowX + s * 0.10, s * 0.62);
  canvas.drawPath(headPath, headPaint);
}
