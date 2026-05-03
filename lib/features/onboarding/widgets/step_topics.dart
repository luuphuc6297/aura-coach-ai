import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/topic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shared/widgets/topic_chip.dart';

class StepTopics extends StatelessWidget {
  const StepTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: StaggeredEntrance(
        children: [
          Text(
            context.loc.onboardingTopicsTitle,
            style: AppTypography.displayMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.loc.onboardingTopicsSubtitle,
            style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.smd,
            runSpacing: AppSpacing.smd,
            children: topicOptions.map((topic) {
              return TopicChip(
                topic: topic,
                isSelected: provider.selectedTopics.contains(topic.id),
                onTap: () => provider.toggleTopic(topic.id),
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
              color: context.clay.surfaceAlt,
              borderRadius: AppRadius.fullBorder,
              border: Border.all(color: context.clay.border, width: 2),
            ),
            child: Row(
              children: [
                const AppIcon(iconId: 'sparkle', size: 16),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    context.loc.addYourOwnTopic,
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 14,
                      color: context.clay.textFaint,
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
