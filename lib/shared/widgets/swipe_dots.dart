import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/clay_palette.dart';

class SwipeDots extends StatelessWidget {
  final int total;
  final int current;
  final Color activeColor;
  final double activeLength;
  final double dotSize;
  final double spacing;
  final Axis axis;

  const SwipeDots({
    super.key,
    required this.total,
    required this.current,
    this.activeColor = AppColors.teal,
    this.activeLength = 20,
    this.dotSize = 8,
    this.spacing = 3,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final isVertical = axis == Axis.vertical;

    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: AppAnimations.durationNormal,
          curve: AppAnimations.easeClay,
          width: isVertical ? dotSize : (isActive ? activeLength : dotSize),
          height: isVertical ? (isActive ? activeLength : dotSize) : dotSize,
          margin: EdgeInsets.symmetric(
            horizontal: isVertical ? 0 : spacing,
            vertical: isVertical ? spacing : 0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dotSize / 2),
            color: isActive ? activeColor : context.clay.border,
          ),
        );
      }),
    );
  }
}
