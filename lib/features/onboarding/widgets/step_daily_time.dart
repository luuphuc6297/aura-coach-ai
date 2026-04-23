import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/selection_check_circle.dart';
import '../../../shared/widgets/staggered_entrance.dart';

class StepDailyTime extends StatelessWidget {
  const StepDailyTime({super.key});

  static const _bgColors = [
    Color(0x267BC6A0),
    Color(0x267ECEC5),
    Color(0x26E8C77B),
    Color(0x26A78BCA),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: StaggeredEntrance(
        children: [
          Center(
            child: AppIcon(iconId: 'clock', size: 80),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'How much time daily?',
              style: AppTypography.displayMd,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              "We'll build the right plan for you",
              style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ...List.generate(dailyTimeOptions.length, (i) {
            final option = dailyTimeOptions[i];
            final isSelected = provider.dailyMinutes == option.minutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ClayCard(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lgg,
                ),
                onTap: () => provider.setDailyMinutes(option.minutes),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _bgColors[i],
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: Center(
                        child: AppIcon(iconId: option.iconId, size: 32),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.mdd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: AppTypography.title
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            option.description,
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.warmMuted),
                          ),
                        ],
                      ),
                    ),
                    SelectionCheckCircle(isSelected: isSelected, size: 28),
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
