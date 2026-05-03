import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_loc_context.dart';
import 'sm2.dart';

/// Three-button rating footer for the flashcard player. Each button previews
/// the interval that will result from that rating, so the learner can make an
/// informed choice.
class RatingBar extends StatelessWidget {
  final ValueChanged<Sm2Rating> onRate;
  final int currentInterval;
  final double currentEase;
  final int reviewCount;

  const RatingBar({
    super.key,
    required this.onRate,
    required this.currentInterval,
    required this.currentEase,
    required this.reviewCount,
  });

  Sm2Outcome _preview(Sm2Rating rating) => Sm2.next(
        rating: rating,
        interval: currentInterval,
        easeFactor: currentEase,
        reviewCount: reviewCount,
      );

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight forces the Row to know its tallest child's height
    // before layout, which lets each Expanded button match heights without
    // the assertion that fires when crossAxisAlignment.stretch is paired
    // with an unbounded vertical constraint from the parent Column.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _RatingButton(
              label: context.loc.vocabFlashcardsRatingHard,
              intervalDays: _preview(Sm2Rating.hard).interval,
              color: AppColors.coral,
              onTap: () => onRate(Sm2Rating.hard),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RatingButton(
              label: context.loc.vocabFlashcardsRatingGood,
              intervalDays: _preview(Sm2Rating.good).interval,
              color: AppColors.teal,
              onTap: () => onRate(Sm2Rating.good),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RatingButton(
              label: context.loc.vocabFlashcardsRatingEasy,
              intervalDays: _preview(Sm2Rating.easy).interval,
              color: AppColors.purple,
              onTap: () => onRate(Sm2Rating.easy),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final int intervalDays;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.intervalDays,
    required this.color,
    required this.onTap,
  });

  String _formatInterval(int days) {
    if (days < 1) return '<1d';
    if (days == 1) return '1 day';
    return '$days days';
  }

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.sectionTitle.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatInterval(intervalDays),
                  style: AppTypography.caption.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      );
}
