import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ScenarioAppBar extends StatelessWidget {
  final String title;
  final String emoji;
  final String category;
  final String level;
  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onHint;
  final VoidCallback? onMore;

  const ScenarioAppBar({
    super.key,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
    required this.progress,
    this.onBack,
    this.onHint,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      color: AppColors.cream,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '‹',
                    style: AppTypography.h1.copyWith(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      '$emoji $category · $level',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              _actionIcon('💡', onHint),
              _actionIcon('🔊', null),
              _actionIcon('⋯', onMore),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.clayBeige,
              valueColor: AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _actionIcon(String emoji, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
