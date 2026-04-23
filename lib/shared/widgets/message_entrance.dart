import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';

/// Slide-up + fade entrance animation for chat messages.
///
/// Wraps a child with a one-shot animation that plays on first build.
/// Uses [AppAnimations.durationNormal] and [AppAnimations.easeClay].
class MessageEntrance extends StatefulWidget {
  final Widget child;
  final double slideOffset;

  const MessageEntrance({
    super.key,
    required this.child,
    this.slideOffset = 20.0,
  });

  @override
  State<MessageEntrance> createState() => _MessageEntranceState();
}

class _MessageEntranceState extends State<MessageEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.durationNormal,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeClay,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(curved);

    _controller.forward();
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
