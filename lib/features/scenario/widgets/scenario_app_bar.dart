import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

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
              GestureDetector(
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Text(
                      '\u{2039}',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _actionIcon('\u{1F4CB}', onHistory),
              _actionIcon('\u{1F4DA}', onMyLearning),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.massive),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$emoji $category \u{00B7} $level \u{00B7} Scenario #$scenarioIndex',
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

  Widget _actionIcon(String emoji, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
