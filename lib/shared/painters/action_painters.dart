import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_registry.dart';

void registerActionPainters(Map<String, IconPainterFn> registry) {
  registry['send'] = _paintSend;
  registry['mic'] = _paintMic;
  registry['listen'] = _paintListen;
  registry['hint'] = _paintHint;
  registry['toggle'] = _paintToggle;
  registry['search'] = _paintSearch;
  registry['bookmark'] = _paintBookmark;
  registry['delete'] = _paintDelete;
}

// 1. Send — paper airplane pointing right-up with tilt oscillation and trail dashes.
void _paintSend(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final tilt = math.sin(t * 2 * math.pi) * 0.08;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(tilt);
  canvas.translate(-s * 0.5, -s * 0.5);

  // Airplane body path
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bodyPath = Path();
  // Tip points right-up; body forms a triangle
  bodyPath.moveTo(s * 0.82, s * 0.22); // nose tip
  bodyPath.lineTo(s * 0.12, s * 0.42); // bottom-left tail
  bodyPath.lineTo(s * 0.28, s * 0.55); // inner fold
  bodyPath.lineTo(s * 0.52, s * 0.72); // tail bottom
  bodyPath.close();
  canvas.drawPath(bodyPath, bodyPaint);

  // Wing fold line
  final wingPaint = Paint()
    ..color = AppColors.warmDark.withOpacity(0.25)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.03
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
    Offset(s * 0.28, s * 0.55),
    Offset(s * 0.82, s * 0.22),
    wingPaint,
  );

  canvas.restore();

  // Trail dashes behind the airplane
  final dashPaint = Paint()
    ..color = primaryColor.withOpacity(0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.035
    ..strokeCap = StrokeCap.round;

  final trailOpacity = (math.sin(t * 2 * math.pi) * 0.5 + 0.5);
  dashPaint.color = primaryColor.withOpacity(0.15 + trailOpacity * 0.25);

  canvas.drawLine(
      Offset(s * 0.08, s * 0.55), Offset(s * 0.20, s * 0.55), dashPaint);
  canvas.drawLine(
      Offset(s * 0.12, s * 0.64), Offset(s * 0.22, s * 0.64), dashPaint);
}

// 2. Mic — rounded rect body, mesh dots, stand and base, with vertical bob.
void _paintMic(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmDark;
  final bob = math.sin(t * 2 * math.pi) * s * 0.02;

  canvas.save();
  canvas.translate(0, bob);

  // Mic body
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bodyRect = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(s * 0.5, s * 0.36),
      width: s * 0.32,
      height: s * 0.46,
    ),
    Radius.circular(s * 0.16),
  );
  canvas.drawRRect(bodyRect, bodyPaint);

  // Mesh dots near top of mic
  final dotPaint = Paint()
    ..color = AppColors.white.withOpacity(0.45)
    ..style = PaintingStyle.fill;

  final dotOffsets = <List<double>>[
    [0.42, 0.20],
    [0.50, 0.20],
    [0.58, 0.20],
    [0.42, 0.27],
    [0.50, 0.27],
    [0.58, 0.27],
    [0.42, 0.34],
    [0.50, 0.34],
    [0.58, 0.34],
  ];
  for (final d in dotOffsets) {
    canvas.drawCircle(Offset(s * d[0], s * d[1]), s * 0.025, dotPaint);
  }

  canvas.restore();

  // Stand arc (outside of bob so it stays fixed)
  final standPaint = Paint()
    ..color = AppColors.warmMuted
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  final standPath = Path();
  standPath.moveTo(s * 0.5, s * 0.59 + bob);
  standPath.arcTo(
    Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.59 + bob),
        width: s * 0.44,
        height: s * 0.28),
    0,
    math.pi,
    false,
  );
  canvas.drawPath(standPath, standPaint);

  // Vertical stem
  final stemPaint = Paint()
    ..color = AppColors.warmMuted
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.5, s * 0.73 + bob), Offset(s * 0.5, s * 0.82), stemPaint);

  // Base
  final basePaint = Paint()
    ..color = AppColors.warmMuted
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
      Offset(s * 0.32, s * 0.82), Offset(s * 0.68, s * 0.82), basePaint);
}

// 3. Listen — speaker cone pointing right, 2 concentric arcs that pulse opacity.
void _paintListen(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmDark;
  final arcOpacity = math.sin(t * 2 * math.pi) * 0.4 + 0.6;

  // Speaker body (trapezoid approximated with path)
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bodyPath = Path();
  bodyPath.moveTo(s * 0.18, s * 0.38); // top-left
  bodyPath.lineTo(s * 0.40, s * 0.28); // top-right wide
  bodyPath.lineTo(s * 0.40, s * 0.72); // bottom-right wide
  bodyPath.lineTo(s * 0.18, s * 0.62); // bottom-left
  bodyPath.close();
  canvas.drawPath(bodyPath, bodyPaint);

  // Speaker grille rect connector
  final grillPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;
  canvas.drawRect(
      Rect.fromLTRB(s * 0.10, s * 0.38, s * 0.18, s * 0.62), grillPaint);

  // Sound arcs
  final arcPaint = Paint()
    ..color = AppColors.teal.withOpacity(arcOpacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.06
    ..strokeCap = StrokeCap.round;

  final arcRect1 = Rect.fromCenter(
    center: Offset(s * 0.40, s * 0.50),
    width: s * 0.30,
    height: s * 0.30,
  );
  canvas.drawArc(arcRect1, -math.pi * 0.42, math.pi * 0.84, false, arcPaint);

  final arcPaint2 = Paint()
    ..color = AppColors.teal.withOpacity(arcOpacity * 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.055
    ..strokeCap = StrokeCap.round;

  final arcRect2 = Rect.fromCenter(
    center: Offset(s * 0.40, s * 0.50),
    width: s * 0.52,
    height: s * 0.52,
  );
  canvas.drawArc(arcRect2, -math.pi * 0.42, math.pi * 0.84, false, arcPaint2);
}

// 4. Hint — light bulb with pulsing glow rays radiating from top.
void _paintHint(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.gold;
  final glowOpacity = math.sin(t * 2 * math.pi) * 0.4 + 0.6;

  // Bulb body
  final bulbPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  // Upper round part of bulb
  canvas.drawCircle(Offset(s * 0.5, s * 0.42), s * 0.24, bulbPaint);

  // Lower flat body extension
  final lowerPath = Path();
  lowerPath.moveTo(s * 0.34, s * 0.55);
  lowerPath.lineTo(s * 0.34, s * 0.64);
  lowerPath.lineTo(s * 0.66, s * 0.64);
  lowerPath.lineTo(s * 0.66, s * 0.55);
  lowerPath.close();
  canvas.drawPath(lowerPath, bulbPaint);

  // Screw base segments (warmDark)
  final basePaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;

  canvas.drawRect(
      Rect.fromLTRB(s * 0.37, s * 0.65, s * 0.63, s * 0.70), basePaint);
  canvas.drawRect(
      Rect.fromLTRB(s * 0.39, s * 0.71, s * 0.61, s * 0.76), basePaint);
  canvas.drawRect(
      Rect.fromLTRB(s * 0.41, s * 0.77, s * 0.59, s * 0.82), basePaint);

  // Shine glint
  final glintPaint = Paint()
    ..color = AppColors.white.withOpacity(0.35)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(s * 0.42, s * 0.35), s * 0.07, glintPaint);

  // Glow rays
  final rayPaint = Paint()
    ..color = primaryColor.withOpacity(glowOpacity * 0.75)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.045
    ..strokeCap = StrokeCap.round;

  final rayAngles = [-math.pi / 2, -math.pi * 5 / 8, -math.pi * 3 / 8];
  for (final angle in rayAngles) {
    final innerR = s * 0.30;
    final outerR = s * 0.42;
    canvas.drawLine(
      Offset(s * 0.5 + innerR * math.cos(angle),
          s * 0.42 + innerR * math.sin(angle)),
      Offset(s * 0.5 + outerR * math.cos(angle),
          s * 0.42 + outerR * math.sin(angle)),
      rayPaint,
    );
  }
}

// 5. Toggle — two curved arrows forming a refresh cycle, with subtle rotation.
void _paintToggle(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final rotation = math.sin(t * 2 * math.pi) * 0.10;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(rotation);
  canvas.translate(-s * 0.5, -s * 0.5);

  final arrowPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final r = s * 0.28;
  final cx = s * 0.5;
  final cy = s * 0.5;

  // Top arc (left-to-right, ~210 deg sweep)
  canvas.drawArc(
    Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
    math.pi * 0.9,
    -math.pi * 1.4,
    false,
    arrowPaint,
  );

  // Top arrowhead
  final t1Angle = math.pi * 0.9 - math.pi * 1.4;
  final arrowHead1 = _arrowHeadPath(
    cx + r * math.cos(t1Angle),
    cy + r * math.sin(t1Angle),
    t1Angle + math.pi / 2,
    s * 0.10,
  );
  canvas.drawPath(arrowHead1, arrowPaint..style = PaintingStyle.fill);

  // Bottom arc (right-to-left, ~210 deg sweep)
  final arrowPaint2 = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  canvas.drawArc(
    Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
    -math.pi * 0.1,
    -math.pi * 1.4,
    false,
    arrowPaint2,
  );

  // Bottom arrowhead
  final t2Angle = -math.pi * 0.1 - math.pi * 1.4;
  final arrowHead2 = _arrowHeadPath(
    cx + r * math.cos(t2Angle),
    cy + r * math.sin(t2Angle),
    t2Angle + math.pi / 2,
    s * 0.10,
  );
  canvas.drawPath(arrowHead2, arrowPaint2..style = PaintingStyle.fill);

  canvas.restore();
}

Path _arrowHeadPath(double tipX, double tipY, double angle, double size) {
  final path = Path();
  path.moveTo(tipX, tipY);
  path.lineTo(
    tipX + size * math.cos(angle + math.pi * 0.75),
    tipY + size * math.sin(angle + math.pi * 0.75),
  );
  path.lineTo(
    tipX + size * math.cos(angle - math.pi * 0.75),
    tipY + size * math.sin(angle - math.pi * 0.75),
  );
  path.close();
  return path;
}

// 6. Search — magnifying glass: circle lens (teal stroke) + angled handle, subtle tilt.
void _paintSearch(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.teal;
  final tilt = math.sin(t * 2 * math.pi) * 0.08;

  canvas.save();
  canvas.translate(s * 0.5, s * 0.5);
  canvas.rotate(tilt);
  canvas.translate(-s * 0.5, -s * 0.5);

  // Lens circle
  final lensPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10;
  canvas.drawCircle(Offset(s * 0.42, s * 0.40), s * 0.22, lensPaint);

  // Handle
  final handlePaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.10
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(s * 0.58, s * 0.58),
    Offset(s * 0.80, s * 0.80),
    handlePaint,
  );

  canvas.restore();
}

// 7. Bookmark — ribbon with V-notch at bottom, coral fill, gentle side wave.
void _paintBookmark(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.coral;
  final wave = math.sin(t * 2 * math.pi) * s * 0.018;

  final bookmarkPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final path = Path();
  path.moveTo(s * 0.28, s * 0.12); // top-left
  path.lineTo(s * 0.72, s * 0.12); // top-right
  path.lineTo(s * 0.72 + wave, s * 0.88); // bottom-right (waved)
  path.lineTo(s * 0.50, s * 0.72); // V-notch point
  path.lineTo(s * 0.28 - wave, s * 0.88); // bottom-left (waved)
  path.close();
  canvas.drawPath(path, bookmarkPaint);

  // Subtle inner shine stripe
  final shinePaint = Paint()
    ..color = AppColors.white.withOpacity(0.18)
    ..style = PaintingStyle.fill;

  final shinePath = Path();
  shinePath.moveTo(s * 0.34, s * 0.12);
  shinePath.lineTo(s * 0.44, s * 0.12);
  shinePath.lineTo(s * 0.44, s * 0.68);
  shinePath.lineTo(s * 0.37, s * 0.62);
  shinePath.lineTo(s * 0.34, s * 0.65);
  shinePath.close();
  canvas.drawPath(shinePath, shinePaint);
}

// 8. Delete — wastebasket: trapezoid body, lid on top with knob, lid wobbles.
void _paintDelete(Canvas canvas, Size size, double t, Color? color) {
  final s = size.width;
  final primaryColor = color ?? AppColors.warmMuted;
  final lidWobble = math.sin(t * 2 * math.pi) * 0.08;

  // Bin body (trapezoid)
  final bodyPaint = Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  final bodyPath = Path();
  bodyPath.moveTo(s * 0.24, s * 0.32); // top-left
  bodyPath.lineTo(s * 0.76, s * 0.32); // top-right
  bodyPath.lineTo(s * 0.68, s * 0.85); // bottom-right
  bodyPath.lineTo(s * 0.32, s * 0.85); // bottom-left
  bodyPath.close();
  canvas.drawPath(bodyPath, bodyPaint);

  // Vertical lines on body
  final linePaint = Paint()
    ..color = AppColors.white.withOpacity(0.30)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.04
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
      Offset(s * 0.40, s * 0.38), Offset(s * 0.38, s * 0.80), linePaint);
  canvas.drawLine(
      Offset(s * 0.50, s * 0.38), Offset(s * 0.50, s * 0.80), linePaint);
  canvas.drawLine(
      Offset(s * 0.60, s * 0.38), Offset(s * 0.62, s * 0.80), linePaint);

  // Lid (wobbles around its center)
  canvas.save();
  canvas.translate(s * 0.5, s * 0.28);
  canvas.rotate(lidWobble);
  canvas.translate(-s * 0.5, -s * 0.28);

  final lidPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;

  final lidPath = Path();
  lidPath.moveTo(s * 0.18, s * 0.28); // left
  lidPath.lineTo(s * 0.82, s * 0.28); // right
  lidPath.lineTo(s * 0.78, s * 0.34); // inner right
  lidPath.lineTo(s * 0.22, s * 0.34); // inner left
  lidPath.close();
  canvas.drawPath(lidPath, lidPaint);

  // Knob on lid
  final knobPaint = Paint()
    ..color = AppColors.warmDark
    ..style = PaintingStyle.fill;

  final knobPath = Path();
  knobPath.moveTo(s * 0.42, s * 0.20);
  knobPath.lineTo(s * 0.58, s * 0.20);
  knobPath.lineTo(s * 0.58, s * 0.28);
  knobPath.lineTo(s * 0.42, s * 0.28);
  knobPath.close();
  canvas.drawPath(knobPath, knobPaint);

  canvas.restore();
}
