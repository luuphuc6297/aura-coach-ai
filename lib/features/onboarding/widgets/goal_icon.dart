import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';

/// Animated CustomPainter icon for each learning goal.
///
/// Each goal has a unique vector illustration with subtle looping animation:
/// - career: briefcase with bouncing clasp
/// - travel: airplane with banking tilt
/// - exam: graduation cap with swaying tassel
/// - daily: globe with rotating longitude line
/// - self: brain with pulsing highlight
class GoalIcon extends StatefulWidget {
  final String goalId;
  final double size;

  const GoalIcon({
    super.key,
    required this.goalId,
    this.size = 40,
  });

  @override
  State<GoalIcon> createState() => _GoalIconState();
}

class _GoalIconState extends State<GoalIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppAnimations.shouldReduceMotion(context);
    final strokeColor = context.clay.text;
    final trailColor = context.clay.textFaint;

    if (reduceMotion) {
      return CustomPaint(
        size: Size.square(widget.size),
        painter: _GoalPainter(
          goalId: widget.goalId,
          t: 0,
          strokeColor: strokeColor,
          trailColor: trailColor,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _GoalPainter(
            goalId: widget.goalId,
            t: _controller.value,
            strokeColor: strokeColor,
            trailColor: trailColor,
          ),
        );
      },
    );
  }
}

class _GoalPainter extends CustomPainter {
  final String goalId;
  final double t;
  final Color strokeColor;
  final Color trailColor;

  _GoalPainter({
    required this.goalId,
    required this.t,
    required this.strokeColor,
    required this.trailColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (goalId) {
      case 'career':
        _paintBriefcase(canvas, size);
      case 'travel':
        _paintAirplane(canvas, size);
      case 'exam':
        _paintGradCap(canvas, size);
      case 'daily':
        _paintGlobe(canvas, size);
      case 'self':
        _paintBrain(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_GoalPainter old) =>
      old.t != t ||
      old.goalId != goalId ||
      old.strokeColor != strokeColor ||
      old.trailColor != trailColor;

  // ---------------------------------------------------------------------------
  // Career — Briefcase with bouncing clasp
  // ---------------------------------------------------------------------------
  void _paintBriefcase(Canvas canvas, Size size) {
    final s = size.width;
    final bounce = math.sin(t * 2 * math.pi) * s * 0.02;

    // Body
    final bodyPaint = Paint()..color = AppColors.coral;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.12, s * 0.32, s * 0.76, s * 0.52),
      Radius.circular(s * 0.08),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Handle
    final handlePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round;
    final handlePath = Path()
      ..moveTo(s * 0.34, s * 0.32)
      ..quadraticBezierTo(s * 0.34, s * 0.16, s * 0.50, s * 0.16)
      ..quadraticBezierTo(s * 0.66, s * 0.16, s * 0.66, s * 0.32);
    canvas.drawPath(handlePath, handlePaint);

    // Clasp (animated bounce)
    final claspPaint = Paint()..color = AppColors.gold;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(s * 0.50, s * 0.54 + bounce),
          width: s * 0.14,
          height: s * 0.10,
        ),
        Radius.circular(s * 0.03),
      ),
      claspPaint,
    );

    // Belt line
    final beltPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.25)
      ..strokeWidth = s * 0.03;
    canvas.drawLine(
      Offset(s * 0.12, s * 0.56),
      Offset(s * 0.88, s * 0.56),
      beltPaint,
    );
  }

  // ---------------------------------------------------------------------------
  // Travel — Paper airplane with banking tilt
  // ---------------------------------------------------------------------------
  void _paintAirplane(Canvas canvas, Size size) {
    final s = size.width;
    final tiltAngle = math.sin(t * 2 * math.pi) * 0.12;
    final dy = math.sin(t * 2 * math.pi) * s * 0.03;

    canvas.save();
    canvas.translate(s * 0.5, s * 0.5 + dy);
    canvas.rotate(tiltAngle);
    canvas.translate(-s * 0.5, -s * 0.5);

    // Main wing
    final wingPaint = Paint()..color = AppColors.teal;
    final wingPath = Path()
      ..moveTo(s * 0.14, s * 0.56)
      ..lineTo(s * 0.86, s * 0.38)
      ..lineTo(s * 0.50, s * 0.50)
      ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Body
    final bodyPaint = Paint()..color = AppColors.teal.withValues(alpha: 0.75);
    final bodyPath = Path()
      ..moveTo(s * 0.14, s * 0.56)
      ..lineTo(s * 0.86, s * 0.38)
      ..lineTo(s * 0.50, s * 0.68)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Tail fin
    final tailPaint = Paint()..color = AppColors.purple.withValues(alpha: 0.6);
    final tailPath = Path()
      ..moveTo(s * 0.50, s * 0.50)
      ..lineTo(s * 0.50, s * 0.68)
      ..lineTo(s * 0.38, s * 0.60)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Trail dashes
    final trailPaint = Paint()
      ..color = trailColor.withValues(alpha: 0.45)
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final offset = (t + i * 0.12) % 1.0;
      final x = s * 0.14 - s * 0.08 * (i + 1);
      final y = s * 0.56 + s * 0.04 * (i + 1);
      final alpha = (1.0 - offset) * 0.4;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - s * 0.06, y + s * 0.02),
        trailPaint..color = trailColor.withValues(alpha: alpha),
      );
    }

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // Exam — Graduation cap with swaying tassel
  // ---------------------------------------------------------------------------
  void _paintGradCap(Canvas canvas, Size size) {
    final s = size.width;
    final tasselSwing = math.sin(t * 2 * math.pi) * s * 0.06;

    // Board (diamond)
    final boardPaint = Paint()..color = strokeColor;
    final boardPath = Path()
      ..moveTo(s * 0.50, s * 0.22)
      ..lineTo(s * 0.88, s * 0.42)
      ..lineTo(s * 0.50, s * 0.54)
      ..lineTo(s * 0.12, s * 0.42)
      ..close();
    canvas.drawPath(boardPath, boardPaint);

    // Top surface highlight
    final topPaint = Paint()..color = strokeColor.withValues(alpha: 0.7);
    final topPath = Path()
      ..moveTo(s * 0.50, s * 0.26)
      ..lineTo(s * 0.80, s * 0.42)
      ..lineTo(s * 0.50, s * 0.50)
      ..lineTo(s * 0.20, s * 0.42)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Crown base
    final crownPaint = Paint()..color = AppColors.gold;
    final crownPath = Path()
      ..moveTo(s * 0.30, s * 0.46)
      ..lineTo(s * 0.70, s * 0.46)
      ..lineTo(s * 0.66, s * 0.68)
      ..quadraticBezierTo(s * 0.50, s * 0.74, s * 0.34, s * 0.68)
      ..close();
    canvas.drawPath(crownPath, crownPaint);

    // Tassel string + bob (animated swing)
    final tasselStringPaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    final tasselStart = Offset(s * 0.50, s * 0.42);
    final tasselEnd = Offset(s * 0.50 + tasselSwing, s * 0.72);
    canvas.drawLine(tasselStart, tasselEnd, tasselStringPaint);

    final bobPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(tasselEnd, s * 0.04, bobPaint);
  }

  // ---------------------------------------------------------------------------
  // Daily — Globe with rotating meridian
  // ---------------------------------------------------------------------------
  void _paintGlobe(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s * 0.50, s * 0.50);
    final radius = s * 0.36;

    // Globe fill
    final globePaint = Paint()..color = AppColors.teal.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius, globePaint);

    // Globe outline
    final outlinePaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035;
    canvas.drawCircle(center, radius, outlinePaint);

    // Equator
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      outlinePaint..strokeWidth = s * 0.02,
    );

    // Animated meridian (rotating ellipse)
    final meridianOffset = math.cos(t * 2 * math.pi) * radius * 0.8;
    final meridianPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.02;
    final meridianRect = Rect.fromCenter(
      center: Offset(center.dx + meridianOffset * 0.1, center.dy),
      width: (radius * 0.5 + meridianOffset.abs() * 0.3)
          .clamp(s * 0.06, radius * 1.2),
      height: radius * 2,
    );
    canvas.save();
    canvas.clipRect(Rect.fromCircle(center: center, radius: radius));
    canvas.drawOval(meridianRect, meridianPaint);
    canvas.restore();

    // Latitude lines
    final latPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.015;
    for (final frac in [0.3, 0.7]) {
      final ly = center.dy - radius + radius * 2 * frac;
      final lHalf =
          math.sqrt(radius * radius - (ly - center.dy) * (ly - center.dy));
      canvas.drawLine(
        Offset(center.dx - lHalf, ly),
        Offset(center.dx + lHalf, ly),
        latPaint,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Self — Brain with pulsing highlight
  // ---------------------------------------------------------------------------
  void _paintBrain(Canvas canvas, Size size) {
    final s = size.width;
    final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;

    // Left hemisphere
    final leftPaint = Paint()..color = AppColors.purple;
    final leftPath = Path()
      ..moveTo(s * 0.48, s * 0.24)
      ..cubicTo(s * 0.28, s * 0.18, s * 0.12, s * 0.34, s * 0.16, s * 0.52)
      ..cubicTo(s * 0.14, s * 0.64, s * 0.22, s * 0.76, s * 0.36, s * 0.80)
      ..cubicTo(s * 0.42, s * 0.82, s * 0.48, s * 0.76, s * 0.48, s * 0.68)
      ..lineTo(s * 0.48, s * 0.24);
    canvas.drawPath(leftPath, leftPaint);

    // Right hemisphere
    final rightPaint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.78);
    final rightPath = Path()
      ..moveTo(s * 0.52, s * 0.24)
      ..cubicTo(s * 0.72, s * 0.18, s * 0.88, s * 0.34, s * 0.84, s * 0.52)
      ..cubicTo(s * 0.86, s * 0.64, s * 0.78, s * 0.76, s * 0.64, s * 0.80)
      ..cubicTo(s * 0.58, s * 0.82, s * 0.52, s * 0.76, s * 0.52, s * 0.68)
      ..lineTo(s * 0.52, s * 0.24);
    canvas.drawPath(rightPath, rightPaint);

    // Fold lines — left
    final foldPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.18)
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
      ..color = strokeColor.withValues(alpha: 0.2)
      ..strokeWidth = s * 0.02;
    canvas.drawLine(
        Offset(s * 0.50, s * 0.26), Offset(s * 0.50, s * 0.78), dividerPaint);

    // Pulsing highlight glow
    final glowPaint = Paint()
      ..color = AppColors.purple.withValues(alpha: pulse * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(s * 0.50, s * 0.50), s * 0.22, glowPaint);
  }
}
