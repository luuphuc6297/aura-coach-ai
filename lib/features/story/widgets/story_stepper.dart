import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Three-dot step indicator for the custom story flow
/// (Topic → Character → Context). Active step is filled purple; completed
/// steps get a check glyph; upcoming steps are muted.
class StoryStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const StoryStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.labels = const ['Topic', 'Character', 'Context'],
  }) : assert(totalSteps > 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        final label = i < labels.length ? labels[i] : '';
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
            child: _StepDot(
              index: i + 1,
              label: label,
              isActive: isActive,
              isDone: isDone,
            ),
          ),
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color text;
    if (isActive) {
      fill = AppColors.purpleDeep;
      text = Colors.white;
    } else if (isDone) {
      fill = AppColors.purple.withValues(alpha: 0.4);
      text = Colors.white;
    } else {
      fill = AppColors.clayBeige;
      text = AppColors.warmMuted;
    }

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.purpleDeep : AppColors.clayBorder,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  '$index',
                  style: AppTypography.labelSm.copyWith(
                    color: text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isActive ? AppColors.purpleDeep : AppColors.warmMuted,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Dashed separator used between [StoryStepper] dots when they're arranged
/// horizontally without expanded spacing. Optional — the expanded layout in
/// [StoryStepper] handles spacing on its own.
class StoryStepperDivider extends StatelessWidget {
  final bool isActive;

  const StoryStepperDivider({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 2,
      decoration: BoxDecoration(
        color: isActive ? AppColors.purpleDeep : AppColors.clayBorder,
        borderRadius: AppRadius.fullBorder,
      ),
    );
  }
}
