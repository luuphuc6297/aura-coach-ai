import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';

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
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: size,
          child: CustomPaint(
            painter: _RadarChartPainter(
              accuracyScore: accuracyScore,
              naturalnessScore: naturalnessScore,
              complexityScore: complexityScore,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _scorePill('Accuracy', accuracyScore, AppColors.teal),
            _scorePill('Naturalness', naturalnessScore, AppColors.purple),
            _scorePill('Complexity', complexityScore, AppColors.gold),
          ],
        ),
      ],
    );
  }

  Widget _scorePill(String label, int score, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.fullBorder,
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$score',
              style: AppTypography.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final int accuracyScore;
  final int naturalnessScore;
  final int complexityScore;

  static const int _maxScore = 10;
  static const int _gridLevels = 4;
  static const List<String> _labels = ['Accuracy', 'Naturalness', 'Complexity'];

  _RadarChartPainter({
    required this.accuracyScore,
    required this.naturalnessScore,
    required this.complexityScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.72;

    _drawGridPolygons(canvas, center, radius);
    _drawAxes(canvas, center, radius);
    _drawDataArea(canvas, center, radius);
    _drawDataDots(canvas, center, radius);
    _drawLabels(canvas, center, radius, size);
  }

  void _drawGridPolygons(Canvas canvas, Offset center, double radius) {
    for (int level = 1; level <= _gridLevels; level++) {
      final r = (radius / _gridLevels) * level;
      final isOuter = level == _gridLevels;

      final paint = Paint()
        ..color = AppColors.clayBorder.withValues(alpha: isOuter ? 0.4 : 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isOuter ? 1.5 : 0.8;

      canvas.drawPath(_polygonPath(center, r, 3), paint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.clayBorder.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final point in _axisPoints(center, radius, 3)) {
      canvas.drawLine(center, point, paint);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius) {
    final dataPath = _dataPath(center, radius);

    // Gradient fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.teal.withValues(alpha: 0.5),
          AppColors.teal.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(dataPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(dataPath, strokePaint);
  }

  void _drawDataDots(Canvas canvas, Offset center, double radius) {
    final scores = [
      accuracyScore.toDouble(),
      naturalnessScore.toDouble(),
      complexityScore.toDouble(),
    ];

    final unit = radius / _maxScore;

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * pi / 3) - (pi / 2);
      final d = scores[i] * unit;
      final point = Offset(
        center.dx + d * cos(angle),
        center.dy + d * sin(angle),
      );

      // Outer glow
      canvas.drawCircle(
        point,
        6,
        Paint()..color = AppColors.teal.withValues(alpha: 0.2),
      );

      // White ring
      canvas.drawCircle(
        point,
        4.5,
        Paint()
          ..color = AppColors.clayWhite
          ..style = PaintingStyle.fill,
      );

      // Teal dot
      canvas.drawCircle(
        point,
        3.5,
        Paint()
          ..color = AppColors.teal
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawLabels(
      Canvas canvas, Offset center, double radius, Size canvasSize) {
    final labelRadius = radius + 22;
    final points = _axisPoints(center, labelRadius, 3);

    for (int i = 0; i < 3; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: _labels[i],
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.warmDark,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();

      final offset = Offset(
        points[i].dx - tp.width / 2,
        points[i].dy - tp.height / 2,
      );
      tp.paint(canvas, offset);
    }
  }

  Path _dataPath(Offset center, double radius) {
    final scores = [
      accuracyScore.toDouble(),
      naturalnessScore.toDouble(),
      complexityScore.toDouble(),
    ];
    final unit = radius / _maxScore;
    final path = Path();

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * pi / 3) - (pi / 2);
      final d = scores[i] * unit;
      final point = Offset(
        center.dx + d * cos(angle),
        center.dy + d * sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  Path _polygonPath(Offset center, double radius, int sides) {
    final path = Path();
    final points = _axisPoints(center, radius, sides);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    path.close();
    return path;
  }

  List<Offset> _axisPoints(Offset center, double radius, int axes) {
    return List.generate(axes, (i) {
      final angle = (i * 2 * pi / axes) - (pi / 2);
      return Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    });
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.accuracyScore != accuracyScore ||
        oldDelegate.naturalnessScore != naturalnessScore ||
        oldDelegate.complexityScore != complexityScore;
  }
}
