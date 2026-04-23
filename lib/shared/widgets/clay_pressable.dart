import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_animations.dart';

enum ClayHapticType { light, medium }

class ClayPressable extends StatefulWidget {
  final Widget Function(BuildContext context, bool isPressed) builder;
  final VoidCallback? onTap;
  final bool enabled;
  final double scaleDown;
  final bool enableHaptic;
  final ClayHapticType hapticType;

  const ClayPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.enabled = true,
    this.scaleDown = 0.97,
    this.enableHaptic = true,
    this.hapticType = ClayHapticType.light,
  });

  @override
  State<ClayPressable> createState() => _ClayPressableState();
}

class _ClayPressableState extends State<ClayPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isActive => widget.enabled && widget.onTap != null;

  void _onTapDown(TapDownDetails details) {
    if (!_isActive) return;
    setState(() => _isPressed = true);
    final reduceMotion = AppAnimations.shouldReduceMotion(context);
    if (!reduceMotion) {
      _controller.animateTo(
        widget.scaleDown,
        duration: AppAnimations.durationPress,
        curve: Curves.easeOut,
      );
    }
    if (widget.enableHaptic) {
      switch (widget.hapticType) {
        case ClayHapticType.light:
          HapticFeedback.lightImpact();
        case ClayHapticType.medium:
          HapticFeedback.mediumImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isActive) return;
    setState(() => _isPressed = false);
    _springBack();
  }

  void _onTapCancel() {
    if (!_isActive) return;
    setState(() => _isPressed = false);
    _springBack();
  }

  void _springBack() {
    if (AppAnimations.shouldReduceMotion(context)) {
      _controller.value = 1.0;
      return;
    }
    final simulation = SpringSimulation(
      AppAnimations.springTap,
      _controller.value,
      1.0,
      0.0,
    );
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _isActive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: widget.builder(context, _isPressed),
          );
        },
      ),
    );
  }
}
