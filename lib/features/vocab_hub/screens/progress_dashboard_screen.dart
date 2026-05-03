import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../my_library/models/saved_item.dart';
import '../../my_library/providers/library_provider.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Progress Dashboard sub-screen. Surfaces three core stats — total saved,
/// due for review today, and mastered — plus a drill-down row per part of
/// speech so the learner can see where their vocabulary is growing.
class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  // SM-2 graduation threshold: seen 3+ times AND the scheduler pushed the
  // next review at least 3 weeks out. Items meeting both are considered
  // "mastered" for dashboard purposes.
  static const _masteredMinReviews = 3;
  static const _masteredMinInterval = 21;

  @override
  Widget build(BuildContext context) {
    return VocabHubScaffold(
      title: context.loc.vocabProgressTitle,
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          final all = library.allItems;
          final vocabItems =
              all.where((i) => i.type == 'vocabulary').toList();
          final total = all.length;
          final due = all.where((i) => i.isDueForReview).length;
          final mastered = all
              .where((i) =>
                  i.reviewCount >= _masteredMinReviews &&
                  i.interval >= _masteredMinInterval)
              .length;
          final learning = all
              .where((i) =>
                  i.reviewCount >= 1 &&
                  !(i.reviewCount >= _masteredMinReviews &&
                      i.interval >= _masteredMinInterval))
              .length;
          final fresh = (total - mastered - learning).clamp(0, total);

          final posBreakdown = _countByPartOfSpeech(vocabItems);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: total.toString(),
                      label: context.loc.vocabProgressSaved,
                      accent: AppColors.coral,
                      icon: Icons.bookmark_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      value: due.toString(),
                      label: context.loc.vocabProgressDueToday,
                      accent: AppColors.gold,
                      icon: Icons.schedule_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      value: mastered.toString(),
                      label: context.loc.vocabProgressMastered,
                      accent: AppColors.teal,
                      icon: Icons.workspace_premium_rounded,
                    ),
                  ),
                ],
              ),
              if (total > 0) ...[
                const SizedBox(height: AppSpacing.lg),
                _MasteryBar(
                  mastered: mastered,
                  learning: learning,
                  fresh: fresh,
                  total: total,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (total == 0)
                _EmptyState(
                  onBrowse: () => context.push('/vocab-hub/analysis'),
                )
              else ...[
                _SectionTitle(text: context.loc.vocabProgressByPos),
                const SizedBox(height: AppSpacing.sm),
                if (posBreakdown.isEmpty)
                  _MutedHint(
                    text:
                        'No part-of-speech data yet — analyze a word to start populating this breakdown.',
                  )
                else
                  ClayCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < posBreakdown.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: context.clay.border,
                            ),
                          _PosRow(
                            label: posBreakdown[i].key,
                            count: posBreakdown[i].value,
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(text: context.loc.vocabProgressKeepGoing),
                const SizedBox(height: AppSpacing.sm),
                _CallToAction(
                  title: due > 0
                      ? '$due card${due == 1 ? '' : 's'} ready for review'
                      : 'No cards due today',
                  description: due > 0
                      ? 'Clear your SM-2 queue before it grows.'
                      : 'Practice 10 random words to stay warm.',
                  ctaLabel:
                      due > 0 ? 'Review now' : 'Practice 10 cards',
                  onTap: () => context.push('/vocab-hub/flashcards'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<MapEntry<String, int>> _countByPartOfSpeech(List<SavedItem> items) {
    final map = <String, int>{};
    for (final item in items) {
      final pos = item.partOfSpeech?.trim();
      if (pos == null || pos.isEmpty) continue;
      final key = _titleCase(pos);
      map[key] = (map[key] ?? 0) + 1;
    }
    final entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final IconData icon;

  const _StatTile({
    required this.value,
    required this.label,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.clay.border, width: 2),
        boxShadow: AppShadows.clay(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: context.clay.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.sectionTitle.copyWith(
          color: context.clay.text,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _PosRow extends StatelessWidget {
  final String label;
  final int count;
  const _PosRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: context.clay.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _MutedHint extends StatelessWidget {
  final String text;
  const _MutedHint({required this.text});

  @override
  Widget build(BuildContext context) => ClayCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          text,
          style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
        ),
      );
}

class _CallToAction extends StatelessWidget {
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onTap;

  const _CallToAction({
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ClayCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(
              description,
              style:
                  AppTypography.bodySm.copyWith(color: context.clay.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            ClayButton(
              text: ctaLabel,
              variant: ClayButtonVariant.accentCoral,
              onTap: onTap,
            ),
          ],
        ),
      );
}

/// Horizontal segmented bar tying the three stat tiles together. Shows
/// mastered (teal) / learning (gold) / fresh (warmLight) proportions plus
/// a headline "X% mastered" blurb that anchors the learner's progress.
class _MasteryBar extends StatelessWidget {
  final int mastered;
  final int learning;
  final int fresh;
  final int total;

  const _MasteryBar({
    required this.mastered,
    required this.learning,
    required this.fresh,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1 : total;
    final masteredPct = (mastered / safeTotal * 100).round();

    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$masteredPct% mastered',
                  style: AppTypography.h3.copyWith(
                    color: context.clay.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$mastered / $total',
                style: AppTypography.caption.copyWith(
                  color: context.clay.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Row(
              children: [
                if (mastered > 0)
                  Expanded(
                    flex: mastered,
                    child: Container(height: 10, color: AppColors.teal),
                  ),
                if (learning > 0)
                  Expanded(
                    flex: learning,
                    child: Container(height: 10, color: AppColors.gold),
                  ),
                if (fresh > 0)
                  Expanded(
                    flex: fresh,
                    child: Container(height: 10, color: context.clay.textFaint),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendDot(color: AppColors.teal, label: context.loc.vocabProgressLegendMastered(mastered)),
              _LegendDot(color: AppColors.gold, label: context.loc.vocabProgressLegendLearning(learning)),
              _LegendDot(color: context.clay.textFaint, label: context.loc.vocabProgressLegendNew(fresh)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyState({required this.onBrowse});

  @override
  Widget build(BuildContext context) => ClayCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.insights_rounded,
              size: 40,
              color: context.clay.textFaint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.loc.vocabProgressEmptyTitle, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Analyze a word or describe one in Vietnamese to start your collection.',
              style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 220,
              child: ClayButton(
                text: context.loc.vocabProgressEmptyAnalyze,
                variant: ClayButtonVariant.accentCoral,
                onTap: onBrowse,
              ),
            ),
          ],
        ),
      );
}
