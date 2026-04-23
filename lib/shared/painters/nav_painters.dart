import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerNavPainters(Map<String, IconPainterFn> registry) {
  registry['history'] = _paintHistory;
  registry['myLearning'] = _paintMyLearning;
  registry['profile'] = _paintProfile;
  registry['back'] = _paintBack;
}

void _paintHistory(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.warmDark;
  final paint = Paint()
    ..color = primary
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.07
    ..strokeCap = StrokeCap.round;

  // Subtle paper flutter: slight rotation via sin(t)
  final angle = math.sin(t * 2 * math.pi) * 0.04;
  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(angle);
  canvas.translate(-s * 0.5, -s * 0.5);

  // Clipboard rounded rect outline
  final clipRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.18, s * 0.15, s * 0.64, s * 0.72),
    Radius.circular(s * 0.1),
  );
  canvas.drawRRect(clipRect, paint);

  // Clip tab at top
  final tabPaint = Paint()
    ..color = primary
    ..style = PaintingStyle.fill;
  final tabRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.36, s * 0.08, s * 0.28, s * 0.14),
    Radius.circular(s * 0.05),
  );
  canvas.drawRRect(tabRect, tabPaint);

  // List item lines inside clipboard
  final linePaint = Paint()
    ..color = primary.withOpacity(0.55)
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  for (int i = 0; i < 3; i++) {
    final y = s * (0.37 + i * 0.15);
    canvas.drawLine(Offset(s * 0.30, y), Offset(s * 0.70, y), linePaint);
  }

  canvas.restore();
}

void _paintMyLearning(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;

  // Bottom book — teal
  final bottomPaint = Paint()
    ..color = AppColors.teal
    ..style = PaintingStyle.fill;

  final bottomBook = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.12, s * 0.48, s * 0.76, s * 0.38),
    Radius.circular(s * 0.06),
  );
  canvas.drawRRect(bottomBook, bottomPaint);

  // Bottom book spine line
  final spineBottom = Paint()
    ..color = AppColors.teal.withOpacity(0.5)
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.24, s * 0.48),
    Offset(s * 0.24, s * 0.86),
    spineBottom,
  );

  // Gentle vertical bob on top book
  final bob = math.sin(t * 2 * math.pi) * s * 0.025;

  // Top book — purple, slightly offset
  final topPaint = Paint()
    ..color = color ?? AppColors.purple
    ..style = PaintingStyle.fill;

  final topBook = RRect.fromRectAndRadius(
    Rect.fromLTWH(s * 0.18, s * 0.14 + bob, s * 0.70, s * 0.36),
    Radius.circular(s * 0.06),
  );
  canvas.drawRRect(topBook, topPaint);

  // Top book spine line
  final spineTop = Paint()
    ..color = (color ?? AppColors.purple).withOpacity(0.5)
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.30, s * 0.14 + bob),
    Offset(s * 0.30, s * 0.50 + bob),
    spineTop,
  );
}

void _paintProfile(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.teal;

  // Subtle breathing scale pulse 1.0 → 1.03
  final scale = 1.0 + math.sin(t * 2 * math.pi) * 0.015;
  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.scale(scale);
  canvas.translate(-s * 0.5, -s * 0.5);

  final fillPaint = Paint()
    ..color = primary
    ..style = PaintingStyle.fill;

  // Circle head
  canvas.drawCircle(Offset(s * 0.5, s * 0.32), s * 0.18, fillPaint);

  // Shoulders arc — clip to canvas so it doesn't overflow
  final shoulderPath = Path();
  shoulderPath.moveTo(s * 0.08, s * 0.92);
  shoulderPath.quadraticBezierTo(
    s * 0.08,
    s * 0.58,
    s * 0.5,
    s * 0.58,
  );
  shoulderPath.quadraticBezierTo(
    s * 0.92,
    s * 0.58,
    s * 0.92,
    s * 0.92,
  );
  shoulderPath.close();
  canvas.drawPath(shoulderPath, fillPaint);

  canvas.restore();
}

void _paintBack(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primary = color ?? AppColors.warmDark;

  // Gentle horizontal bob ±1.5px via sin(t)
  final bob = math.sin(t * 2 * math.pi) * s * 0.06;

  final paint = Paint()
    ..color = primary
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // Left-pointing chevron <
  final path = Path();
  path.moveTo(s * 0.62 + bob, s * 0.22);
  path.lineTo(s * 0.30 + bob, s * 0.50);
  path.lineTo(s * 0.62 + bob, s * 0.78);

  canvas.drawPath(path, paint);
}
