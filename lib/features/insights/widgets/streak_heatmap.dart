import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_card.dart';

/// GitHub-style 13-week contribution grid. `grid` is 13 (weeks) × 7 (days).
/// Cell shade increases with session count at that day — empty days render
/// in clay-beige so the grid always has a readable silhouette.
class StreakHeatmap extends StatelessWidget {
  final List<List<int>> grid;
  final int currentStreak;
  final int bestStreak;

  const StreakHeatmap({
    super.key,
    required this.grid,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Practice heatmap',
                style: AppTypography.sectionTitle,
              ),
              const Spacer(),
              _StreakChip(
                label: 'Current',
                value: currentStreak,
                color: AppColors.coral,
              ),
              const SizedBox(width: AppSpacing.xs),
              _StreakChip(
                label: 'Best',
                value: bestStreak,
                color: AppColors.tealDeep,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 4.0;
              final totalWidth = constraints.maxWidth;
              final cellSize = (totalWidth - spacing * 12) / 13;
              return SizedBox(
                height: cellSize * 7 + spacing * 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(grid.length, (w) {
                    final week = grid[w];
                    return Padding(
                      padding: EdgeInsets.only(
                          right: w == grid.length - 1 ? 0 : spacing),
                      child: Column(
                        children: List.generate(7, (d) {
                          final count = d < week.length ? week[d] : 0;
                          return Padding(
                            padding:
                                EdgeInsets.only(bottom: d == 6 ? 0 : spacing),
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: _shadeFor(context, count),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.smd),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: AppTypography.micro.copyWith(color: context.clay.textFaint),
              ),
              const SizedBox(width: AppSpacing.xs),
              ...[0, 1, 2, 3, 4].map((level) {
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _shadeFor(context, level),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 2),
              Text(
                'More',
                style: AppTypography.micro.copyWith(color: context.clay.textFaint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _shadeFor(BuildContext context, int count) {
    if (count <= 0) return context.clay.surfaceAlt;
    if (count == 1) return AppColors.teal.withValues(alpha: 0.35);
    if (count == 2) return AppColors.teal.withValues(alpha: 0.6);
    if (count == 3) return AppColors.teal.withValues(alpha: 0.8);
    return AppColors.tealDeep;
  }
}

class _StreakChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StreakChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: AppTypography.labelMd.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
