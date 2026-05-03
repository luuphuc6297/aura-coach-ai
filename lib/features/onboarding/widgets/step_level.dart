import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/selection_check_circle.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import 'level_animation_wrapper.dart';

class StepLevel extends StatelessWidget {
  const StepLevel({super.key});

  String _iconUrl(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return CloudinaryAssets.levelBeginner;
      case ProficiencyLevel.intermediate:
        return CloudinaryAssets.levelIntermediate;
      case ProficiencyLevel.advanced:
        return CloudinaryAssets.levelAdvanced;
    }
  }

  Color _cefrColor(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return AppColors.success;
      case ProficiencyLevel.intermediate:
        return AppColors.gold;
      case ProficiencyLevel.advanced:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: StaggeredEntrance(
        children: [
          Text(
            context.loc.onboardingLevelTitle,
            style: AppTypography.displayMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.loc.onboardingLevelSubtitle,
            style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ...ProficiencyLevel.values.map((level) {
            final isSelected = provider.proficiencyLevel == level.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.all(AppSpacing.lgg),
                onTap: () => provider.setProficiencyLevel(level.id),
                child: Row(
                  children: [
                    isSelected
                        ? LevelAnimationWrapper(
                            levelId: level.id,
                            child: CloudImage(url: _iconUrl(level), size: 72),
                          )
                        : CloudImage(url: _iconUrl(level), size: 72),
                    const SizedBox(width: AppSpacing.mdd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(level.label, style: AppTypography.title),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            level.cefr,
                            style: AppTypography.sentenceLabel.copyWith(
                              color: _cefrColor(level),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            level.description,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 13,
                              color: context.clay.textMuted,
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
