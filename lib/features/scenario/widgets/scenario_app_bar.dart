import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_pressable.dart';

class ScenarioAppBar extends StatelessWidget {
  final String title;
  final String emoji;
  final String category;
  final String level;
  final int scenarioIndex;
  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onHistory;
  final VoidCallback? onMyLearning;

  const ScenarioAppBar({
    super.key,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
    required this.scenarioIndex,
    required this.progress,
    this.onBack,
    this.onHistory,
    this.onMyLearning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      color: AppColors.cream,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClayBackButton(onTap: onBack),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                ),
              ),
              _actionButton(AppIcons.history, 18, onHistory),
              _actionButton(AppIcons.myLearning, 18, onMyLearning),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.massive),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$emoji $category · $level · Scenario #$scenarioIndex',
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadius.xxsBorder,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.clayBeige,
              valueColor: AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _actionButton(String iconUrl, double iconSize, VoidCallback? onTap) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.90,
      builder: (context, isPressed) {
        return SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AppIcon(iconId: iconUrl, size: iconSize),
          ),
        );
      },
    );
  }
}
