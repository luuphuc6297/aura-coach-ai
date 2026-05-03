import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../my_library/models/saved_item.dart';

/// Top-5 at-risk vocabulary items. Each row deep-links to the library so the
/// learner can jump straight into a review rather than re-navigating the
/// bottom nav. Empty state offers a "Save your first word" hint.
class WeakWordsCard extends StatelessWidget {
  final List<SavedItem> items;

  const WeakWordsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Words to review', style: AppTypography.sectionTitle),
              const Spacer(),
              ClayPressable(
                onTap: () => context.push('/my-library'),
                scaleDown: 0.95,
                builder: (context, _) => Text(
                  'See all →',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.tealDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            _EmptyState(onTap: () => context.push('/my-library'))
          else
            ...items.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == items.length - 1 || index == 4
                        ? 0
                        : AppSpacing.sm),
                child: _WeakWordRow(item: item),
              );
            }),
        ],
      ),
    );
  }
}

class _WeakWordRow extends StatelessWidget {
  final SavedItem item;

  const _WeakWordRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final mastery = item.masteryScore.clamp(0, 100).toInt();
    return ClayPressable(
      onTap: () => context.push('/my-library'),
      scaleDown: 0.97,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: context.clay.background,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: context.clay.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.correction.isNotEmpty
                        ? item.correction
                        : item.original,
                    style: AppTypography.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitleFor(item),
                    style: AppTypography.caption.copyWith(
                      color: context.clay.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _MasteryPill(value: mastery, isDue: item.isDueForReview),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(SavedItem item) {
    if (item.isDueForReview) {
      return 'Due for review';
    }
    if (item.partOfSpeech != null && item.partOfSpeech!.isNotEmpty) {
      return item.partOfSpeech!;
    }
    return item.type == 'grammar' ? 'Grammar' : 'Vocabulary';
  }
}

class _MasteryPill extends StatelessWidget {
  final int value;
  final bool isDue;

  const _MasteryPill({required this.value, required this.isDue});

  @override
  Widget build(BuildContext context) {
    final color = isDue
        ? AppColors.coral
        : value < 40
            ? AppColors.gold
            : AppColors.tealDeep;
    final label = isDue ? 'Review' : '$value%';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: context.clay.background,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: context.clay.border, width: 1),
        ),
        child: Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No saved words yet',
                    style: AppTypography.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save words from your chats to build your review list.',
                    style: AppTypography.caption.copyWith(
                      color: context.clay.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
