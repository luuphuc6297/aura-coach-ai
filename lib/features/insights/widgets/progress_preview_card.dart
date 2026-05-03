import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../my_library/models/saved_item.dart';
import 'fluency_ring.dart';

/// Compact "Your progress" card embedded on the Profile screen. Acts as a
/// teaser for the full Insights tab — taps anywhere on the card invoke
/// [onOpenInsights]. Layout:
///
///   [Fluency ring]   [streak chip]
///                    [sessions chip]
///                    [Top weak word pill]
///   ────────────────────────────────────
///   View full →
class ProgressPreviewCard extends StatelessWidget {
  final double fluencyScore;
  final int streakDays;
  final int sessionsThisPeriod;
  final SavedItem? topWeakWord;
  final VoidCallback onOpenInsights;

  const ProgressPreviewCard({
    super.key,
    required this.fluencyScore,
    required this.streakDays,
    required this.sessionsThisPeriod,
    required this.topWeakWord,
    required this.onOpenInsights,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onOpenInsights,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your progress', style: AppTypography.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Text(
                  'This week',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.tealDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              FluencyRing(
                score: fluencyScore,
                size: 76,
                strokeWidth: 8,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MetricChip(
                      icon: '🔥',
                      label: streakDays == 1
                          ? '1 day streak'
                          : '$streakDays day streak',
                      accent: AppColors.coral,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _MetricChip(
                      icon: '💬',
                      label: sessionsThisPeriod == 1
                          ? '1 session'
                          : '$sessionsThisPeriod sessions',
                      accent: AppColors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (topWeakWord != null)
            _WeakWordHint(item: topWeakWord!)
          else
            _EmptyWeakWordHint(),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: context.clay.border),
          const SizedBox(height: AppSpacing.smd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'See full insights',
                style: AppTypography.labelMd.copyWith(
                  color: context.clay.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ClayPressable(
                onTap: onOpenInsights,
                scaleDown: 0.95,
                builder: (context, _) => Text(
                  'View full →',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.tealDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color accent;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: AppRadius.smBorder,
          ),
          child:
              Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: context.clay.text,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _WeakWordHint extends StatelessWidget {
  final SavedItem item;

  const _WeakWordHint({required this.item});

  @override
  Widget build(BuildContext context) {
    final word = item.correction.isNotEmpty ? item.correction : item.original;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTypography.labelMd.copyWith(
                  color: context.clay.text,
                ),
                children: [
                  const TextSpan(text: 'Top word to revisit: '),
                  TextSpan(
                    text: word,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w800,
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

class _EmptyWeakWordHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1),
      ),
      child: Text(
        'Save your first word to start tracking review progress.',
        style: AppTypography.labelMd.copyWith(
          color: context.clay.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
