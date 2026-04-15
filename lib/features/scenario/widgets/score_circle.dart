import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

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
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.12),
          border: Border.all(
            color: widget.color,
            width: widget.size > 70 ? 4 : 3,
          ),
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
      ),
    );
  }
}
