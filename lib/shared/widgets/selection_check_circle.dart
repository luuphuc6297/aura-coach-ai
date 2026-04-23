import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_animations.dart';

class SelectionCheckCircle extends StatelessWidget {
  final bool isSelected;
  final double size;

  const SelectionCheckCircle({
    super.key,
    required this.isSelected,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: AnimatedContainer(
          duration: AppAnimations.durationMedium,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.teal : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.teal : AppColors.clayBorder,
              width: 2,
            ),
          ),
          child: isSelected
              ? Icon(Icons.check, size: size * 0.5, color: AppColors.warmDark)
              : null,
        ),
      ),
    );
  }
}
