import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';

class ProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isDone = index < currentStep;
          return AnimatedContainer(
            duration: AppAnimations.durationNormal,
            curve: AppAnimations.easeClay,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: isActive ? AppSpacing.xxl : AppSpacing.sm,
            height: AppSpacing.sm,
            decoration: BoxDecoration(
              color:
                  (isActive || isDone) ? AppColors.teal : AppColors.clayBorder,
              borderRadius: AppRadius.xsBorder,
            ),
          );
        }),
      ),
    );
  }
}
