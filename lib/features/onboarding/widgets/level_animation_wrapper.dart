import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';

/// Wraps a child widget with a per-level motion animation.
///
/// - beginner: gentle wobble (rotation oscillation)
/// - intermediate: slow vertical float
/// - advanced: subtle scale pulse with glow
class LevelAnimationWrapper extends StatefulWidget {
  final String levelId;
  final Widget child;

  const LevelAnimationWrapper({
    super.key,
    required this.levelId,
    required this.child,
  });

  @override
  State<LevelAnimationWrapper> createState() => _LevelAnimationWrapperState();
}

class _LevelAnimationWrapperState extends State<LevelAnimationWrapper>
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
    if (AppAnimations.shouldReduceMotion(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.levelId) {
          case 'beginner':
            return _buildWobble(child!);
          case 'intermediate':
            return _buildFloat(child!);
          case 'advanced':
            return _buildGlowPulse(child!);
          default:
            return child!;
        }
      },
      child: widget.child,
    );
  }

  /// Gentle rocking rotation: +/- 6 degrees
  Widget _buildWobble(Widget child) {
    final angle = math.sin(_controller.value * 2 * math.pi) * 0.10;
    return Transform.rotate(angle: angle, child: child);
  }

  /// Slow vertical drift: +/- 4px
  Widget _buildFloat(Widget child) {
    final dy = math.sin(_controller.value * 2 * math.pi) * 4.0;
    return Transform.translate(offset: Offset(0, dy), child: child);
  }

  /// Subtle scale pulse: 1.0 → 1.06 with a soft glow shadow
  Widget _buildGlowPulse(Widget child) {
    final t = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
    final scale = 1.0 + t * 0.06;
    final glowOpacity = 0.10 + t * 0.18;
    return Transform.scale(
      scale: scale,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8C77B).withValues(alpha: glowOpacity),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
