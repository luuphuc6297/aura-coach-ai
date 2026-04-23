import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';
import '../painters/icon_registry.dart';

class AppIcon extends StatefulWidget {
  final String iconId;
  final double size;
  final Color? color;

  const AppIcon({
    super.key,
    required this.iconId,
    this.size = 20,
    this.color,
  });

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> with SingleTickerProviderStateMixin {
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
    final painter = iconRegistry[widget.iconId];

    if (painter == null) {
      return SizedBox.square(dimension: widget.size);
    }

    final reduceMotion = AppAnimations.shouldReduceMotion(context);

    if (reduceMotion) {
      return CustomPaint(
        size: Size.square(widget.size),
        painter: _AppIconPainter(
          painterFn: painter,
          t: 0,
          color: widget.color,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _AppIconPainter(
            painterFn: painter,
            t: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _AppIconPainter extends CustomPainter {
  final IconPainterFn painterFn;
  final double t;
  final Color? color;

  _AppIconPainter({
    required this.painterFn,
    required this.t,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    painterFn(canvas, size, t, color);
  }

  @override
  bool shouldRepaint(_AppIconPainter old) {
    return old.t != t || old.color != color;
  }
}
