import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class RadarScore extends StatelessWidget {
  final int accuracyScore;
  final int naturalnessScore;
  final int complexityScore;
  final double size;

  const RadarScore({
    super.key,
    required this.accuracyScore,
    required this.naturalnessScore,
    required this.complexityScore,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          accuracyScore: accuracyScore,
          naturalnessScore: naturalnessScore,
          complexityScore: complexityScore,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final int accuracyScore;
  final int naturalnessScore;
  final int complexityScore;

  static const int maxScore = 10;
  static const int gridLevels = 4;
  static const List<String> axisLabels = ['Accuracy', 'Naturalness', 'Complexity'];
  static const double gridOpacity = 0.15;
  static const double fillOpacity = 0.4;

  _RadarChartPainter({
    required this.accuracyScore,
    required this.naturalnessScore,
    required this.complexityScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    _drawGrid(canvas, center, radius);
    _drawAxes(canvas, center, radius);
    _drawDataPolygon(canvas, center, radius);
    _drawLabels(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = AppColors.clayBorder.withValues(alpha: gridOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= gridLevels; i++) {
      final gridRadius = (radius / gridLevels) * i;
      final points = _getAxisPoints(center, gridRadius, 3);

      final path = Path();
      for (int j = 0; j < points.length; j++) {
        if (j == 0) {
          path.moveTo(points[j].dx, points[j].dy);
        } else {
          path.lineTo(points[j].dx, points[j].dy);
        }
      }
      path.close();

      canvas.drawPath(path, gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final axisPaint = Paint()
      ..color = AppColors.clayBorder.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final axisPoints = _getAxisPoints(center, radius, 3);
    for (final point in axisPoints) {
      canvas.drawLine(center, point, axisPaint);
    }
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius) {
    final scores = [
      accuracyScore.toDouble(),
      naturalnessScore.toDouble(),
      complexityScore.toDouble(),
    ];

    final normalizedRadius = radius / maxScore;
    final dataPoints = <Offset>[];

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * 3.14159 / 3) - (3.14159 / 2);
      final distance = scores[i] * normalizedRadius;
      final point = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );
      dataPoints.add(point);
    }

    final fillPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: fillOpacity)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      if (i == 0) {
        path.moveTo(dataPoints[i].dx, dataPoints[i].dy);
      } else {
        path.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final labelRadius = radius * 1.25;
    final axisPoints = _getAxisPoints(center, labelRadius, 3);
    final scores = [accuracyScore, naturalnessScore, complexityScore];

    for (int i = 0; i < 3; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${axisLabels[i]}\n${scores[i]}',
          style: AppTypography.caption.copyWith(
            color: AppColors.warmDark,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      final offset = Offset(
        axisPoints[i].dx - textPainter.width / 2,
        axisPoints[i].dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  List<Offset> _getAxisPoints(Offset center, double radius, int axes) {
    final points = <Offset>[];
    for (int i = 0; i < axes; i++) {
      final angle = (i * 2 * 3.14159 / axes) - (3.14159 / 2);
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      points.add(point);
    }
    return points;
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.accuracyScore != accuracyScore ||
        oldDelegate.naturalnessScore != naturalnessScore ||
        oldDelegate.complexityScore != complexityScore;
  }
}
