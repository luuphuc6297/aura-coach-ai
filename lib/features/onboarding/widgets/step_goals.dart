import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/selection_check_circle.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import 'goal_icon.dart';

class StepGoals extends StatelessWidget {
  const StepGoals({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: StaggeredEntrance(
        children: [
          Text(
            'What are your goals?',
            style: AppTypography.displayMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select all that apply',
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ...learningGoals.map((goal) {
            final isSelected = provider.selectedGoals.contains(goal.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.smd),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.mdd,
                ),
                onTap: () => provider.toggleGoal(goal.id),
                child: Row(
                  children: [
                    GoalIcon(goalId: goal.id, size: 40),
                    const SizedBox(width: AppSpacing.mdd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.label,
                            style: AppTypography.title
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            goal.description,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 13,
                              color: AppColors.warmMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SelectionCheckCircle(isSelected: isSelected),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
