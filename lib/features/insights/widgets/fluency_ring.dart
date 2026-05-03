import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';

/// Circular fluency gauge used on the Profile preview card and planned for
/// the full Insights dashboard. Renders a two-tone arc: background ring in
/// clay-beige, foreground arc in teal (or a user-supplied accent) filling
/// clockwise from 12 o'clock.
class FluencyRing extends StatelessWidget {
  /// 0..100. Values outside the range are clamped.
  final double score;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  /// Optional override for the unfilled track. Falls back to
  /// `context.clay.surfaceAlt` so the ring stays readable in both light and
  /// dark themes.
  final Color? backgroundColor;
  final Widget? centerLabel;

  const FluencyRing({
    super.key,
    required this.score,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor = AppColors.tealDeep,
    this.backgroundColor,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100).toDouble();
    final resolvedBackground = backgroundColor ?? context.clay.surfaceAlt;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FluencyRingPainter(
          progress: clamped / 100,
          progressColor: progressColor,
          backgroundColor: resolvedBackground,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: centerLabel ??
              Text(
                clamped == 0 ? '—' : clamped.round().toString(),
                style: AppTypography.h2.copyWith(
                  color: context.clay.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
        ),
      ),
    );
  }
}

class _FluencyRingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _FluencyRingPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FluencyRingPainter old) {
    return old.progress != progress ||
        old.progressColor != progressColor ||
        old.backgroundColor != backgroundColor ||
        old.strokeWidth != strokeWidth;
  }
}
