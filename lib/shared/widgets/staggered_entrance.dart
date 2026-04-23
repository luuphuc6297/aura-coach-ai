import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';

/// Wraps a list of children with staggered fade + slide-up entrance animation.
///
/// Each child fades in and slides up from [slideOffset] pixels, staggered
/// by [staggerDelay] fraction of the total [duration]. Respects reduced motion.
class StaggeredEntrance extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final double staggerDelay;
  final double slideOffset;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredEntrance({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 600),
    this.staggerDelay = 0.12,
    this.slideOffset = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
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

  Animation<double> _fadeFor(int index) {
    final start = (index * widget.staggerDelay).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final start = (index * widget.staggerDelay).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppAnimations.shouldReduceMotion(context);

    if (reduceMotion) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: List.generate(widget.children.length, (i) {
            return Opacity(
              opacity: _fadeFor(i).value,
              child: Transform.translate(
                offset: _slideFor(i).value,
                child: widget.children[i],
              ),
            );
          }),
        );
      },
    );
  }
}
