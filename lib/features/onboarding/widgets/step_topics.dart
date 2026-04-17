import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/topic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepTopics extends StatelessWidget {
  const StepTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your interests',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll tailor scenarios to what matters to you",
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.smd,
            runSpacing: AppSpacing.smd,
            children: topicOptions.map((topic) {
              final isSelected = provider.selectedTopics.contains(topic.id);
              return GestureDetector(
                onTap: () => provider.toggleTopic(topic.id),
                child: AnimatedContainer(
                  duration: AppAnimations.durationMedium,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.smd,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.teal.withValues(alpha: 0.1) : AppColors.clayWhite,
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: isSelected ? AppColors.teal : AppColors.clayBorder,
                      width: 2,
                    ),
                    boxShadow: isSelected ? AppShadows.clay : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CloudImage(url: topic.emojiUrl, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        topic.label,
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 13,
                          color: isSelected ? AppColors.teal : AppColors.warmDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.mdd),
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.smd),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lgg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.clayBeige,
              borderRadius: AppRadius.fullBorder,
              border: Border.all(color: AppColors.clayBorder, width: 2),
            ),
            child: Row(
              children: [
                const Text(
                  '\u{2728}',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Add your own topic...',
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 14,
                      color: AppColors.warmLight,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Selected: ',
                style: AppTypography.caption,
                children: [
                  TextSpan(
                    text: '${provider.selectedTopics.length} topics',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
