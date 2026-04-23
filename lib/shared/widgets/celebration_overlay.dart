import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_colors.dart';

/// Lightweight confetti-style particle overlay for celebration moments.
///
/// Spawns [particleCount] particles that float down with random drift.
/// Auto-disposes after animation completes. Respects reduced motion.
class CelebrationOverlay extends StatefulWidget {
  final int particleCount;
  final Duration duration;

  const CelebrationOverlay({
    super.key,
    this.particleCount = 40,
    this.duration = AppAnimations.durationCelebration,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  static const _colors = [
    AppColors.teal,
    AppColors.purple,
    AppColors.gold,
    AppColors.coral,
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: rng.nextDouble(),
        startY: -0.1 - rng.nextDouble() * 0.3,
        endY: 1.1 + rng.nextDouble() * 0.2,
        drift: (rng.nextDouble() - 0.5) * 0.3,
        size: 4.0 + rng.nextDouble() * 6.0,
        color: _colors[rng.nextInt(_colors.length)],
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextDouble() - 0.5) * 4,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppAnimations.shouldReduceMotion(context)) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double startY;
  final double endY;
  final double drift;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;

  const _Particle({
    required this.x,
    required this.startY,
    required this.endY,
    required this.drift,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = progress < 0.7 ? 1.0 : (1.0 - progress) / 0.3;

    for (final p in particles) {
      final t = Curves.easeOut.transform(progress);
      final x = (p.x + p.drift * t) * size.width;
      final y = (p.startY + (p.endY - p.startY) * t) * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(1.5),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
