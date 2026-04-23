import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';

class ScoreCircle extends StatefulWidget {
  final int score;
  final int maxScore;
  final double size;
  final Color color;

  const ScoreCircle({
    super.key,
    required this.score,
    this.maxScore = 10,
    this.size = 64,
    this.color = AppColors.success,
  });

  @override
  State<ScoreCircle> createState() => _ScoreCircleState();
}

class _ScoreCircleState extends State<ScoreCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweepAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.durationScore,
      vsync: this,
    );

    _sweepAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _countAnim = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppAnimations.shouldReduceMotion(context);
    final strokeWidth = widget.size > 70 ? 4.0 : 3.0;

    if (reduceMotion) {
      return _buildStatic(strokeWidth);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.12),
                  ),
                ),
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SweepPainter(
                    color: widget.color,
                    progress: _sweepAnim.value,
                    strokeWidth: strokeWidth,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_countAnim.value}',
                      style: GoogleFonts.fredoka(
                        fontSize: widget.size * 0.375,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/${widget.maxScore}',
                      style: GoogleFonts.fredoka(
                        fontSize: widget.size * 0.14,
                        fontWeight: FontWeight.w600,
                        color: widget.color.withValues(alpha: 0.7),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatic(double strokeWidth) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: 0.12),
        border: Border.all(color: widget.color, width: strokeWidth),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.score}',
            style: GoogleFonts.fredoka(
              fontSize: widget.size * 0.375,
              fontWeight: FontWeight.w800,
              color: widget.color,
              height: 1,
            ),
          ),
          Text(
            '/${widget.maxScore}',
            style: GoogleFonts.fredoka(
              fontSize: widget.size * 0.14,
              fontWeight: FontWeight.w600,
              color: widget.color.withValues(alpha: 0.7),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double strokeWidth;

  _SweepPainter({
    required this.color,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawOval(rect, bgPaint);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(_SweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
