import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/session.dart';
import '../providers/scenario_provider.dart';

/// Bottom sheet that lists every scenario in the active practice session
/// with score filtering and an End-session footer. Tap a completed row →
/// [onTapRow] (typically pushes the replay route in P5). Tap End session →
/// [onEndSession] (typically shows confirmation + calls
/// [ScenarioProvider.endPracticeSession]).
///
/// Render via [showModalBottomSheet] with `isScrollControlled: true` and a
/// transparent background so the rounded top corners are visible.
class SessionPanelSheet extends StatefulWidget {
  /// Called when the learner taps a completed scenario row. Null disables
  /// row taps entirely — used during P3/P4 while the replay screen is not
  /// yet built.
  final void Function(SessionScenarioMeta meta)? onTapRow;

  /// Called when the learner taps "End session" after confirming the
  /// destructive dialog. The sheet pops itself before invoking; callers
  /// typically navigate away from the chat screen.
  final VoidCallback? onEndSession;

  const SessionPanelSheet({
    super.key,
    this.onTapRow,
    this.onEndSession,
  });

  @override
  State<SessionPanelSheet> createState() => _SessionPanelSheetState();
}

class _SessionPanelSheetState extends State<SessionPanelSheet> {
  SessionScoreFilter _filter = SessionScoreFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScenarioProvider>();
    final loc = context.loc;
    final mediaQuery = MediaQuery.of(context);
    final sheetMaxHeight = mediaQuery.size.height * 0.85;

    final metas = provider.sessionMetas.reversed.toList();
    final filtered =
        metas.where((m) => _filter.accepts(m.totalScore)).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: sheetMaxHeight),
      decoration: BoxDecoration(
        color: context.clay.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          _Header(
            count: provider.sessionScenarioCount,
            avgScore: provider.sessionAvgScore,
            onClose: () => Navigator.of(context).pop(),
          ),
          _FilterRow(
            current: _filter,
            counts: _countByBucket(metas),
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _buildBody(context, loc, metas, filtered),
          ),
          if (widget.onEndSession != null)
            _Footer(
              onEndSession: () => _confirmEndSession(context, loc),
              bottomInset: mediaQuery.padding.bottom,
            )
          else
            SizedBox(height: mediaQuery.padding.bottom + 12),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic loc,
    List<SessionScenarioMeta> all,
    List<SessionScenarioMeta> filtered,
  ) {
    if (all.isEmpty) {
      return _EmptyState(
        title: loc.sessionPanelEmptyTitle,
        body: loc.sessionPanelEmptyBody,
      );
    }
    if (filtered.isEmpty) {
      return _EmptyState(
        title: loc.sessionPanelFilterEmpty,
        body: '',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final meta = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ScenarioRow(
            meta: meta,
            onTap: meta.isCompleted && widget.onTapRow != null
                ? () => widget.onTapRow!(meta)
                : null,
          ),
        );
      },
    );
  }

  Map<SessionScoreFilter, int> _countByBucket(
      List<SessionScenarioMeta> metas) {
    final counts = <SessionScoreFilter, int>{
      SessionScoreFilter.all: metas.length,
      SessionScoreFilter.excellent: 0,
      SessionScoreFilter.good: 0,
      SessionScoreFilter.needsWork: 0,
    };
    for (final m in metas) {
      for (final f in SessionScoreFilter.values) {
        if (f == SessionScoreFilter.all) continue;
        if (f.accepts(m.totalScore)) counts[f] = (counts[f] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<void> _confirmEndSession(BuildContext context, dynamic loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: context.clay.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: Text(
          loc.sessionPanelEndConfirmTitle,
          style: AppTypography.sectionTitle.copyWith(fontSize: 18),
        ),
        content: Text(
          loc.sessionPanelEndConfirmBody,
          style: AppTypography.bodyMd
              .copyWith(color: context.clay.textMuted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(loc.sessionPanelEndConfirmCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.coral,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(loc.sessionPanelEndConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.of(context).pop();
    widget.onEndSession?.call();
  }
}

// ---------- internal layout pieces ----------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.clay.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final double avgScore;
  final VoidCallback onClose;

  const _Header({
    required this.count,
    required this.avgScore,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final hasScores = count > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.sessionPanelTitle,
                  style: AppTypography.sentenceLabel.copyWith(
                    color: AppColors.tealDeep,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      loc.sessionPanelCount(count),
                      style: AppTypography.sectionTitle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (hasScores) ...[
                      const SizedBox(width: 8),
                      Text(
                        '·',
                        style: AppTypography.bodyMd
                            .copyWith(color: context.clay.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.sessionPanelAvg(avgScore.toStringAsFixed(1)),
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            iconSize: 22,
            color: context.clay.textMuted,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final SessionScoreFilter current;
  final Map<SessionScoreFilter, int> counts;
  final ValueChanged<SessionScoreFilter> onChanged;

  const _FilterRow({
    required this.current,
    required this.counts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final entries = [
      (SessionScoreFilter.all, loc.sessionPanelFilterAll),
      (SessionScoreFilter.excellent, loc.sessionPanelFilterExcellent),
      (SessionScoreFilter.good, loc.sessionPanelFilterGood),
      (SessionScoreFilter.needsWork, loc.sessionPanelFilterNeedsWork),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = entries[index];
          final isActive = filter == current;
          final count = counts[filter] ?? 0;
          return _FilterChip(
            label: count > 0 ? '$label ($count)' : label,
            isActive: isActive,
            isEmpty: count == 0 && filter != SessionScoreFilter.all,
            onTap: () => onChanged(filter),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isEmpty;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.isEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.tealDeep;
    final inactiveColor =
        isEmpty ? context.clay.textMuted : context.clay.text;
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.teal.withValues(alpha: 0.18)
                : context.clay.surfaceAlt,
            borderRadius: AppRadius.smBorder,
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.5)
                  : context.clay.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        );
      },
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  final SessionScenarioMeta meta;
  final VoidCallback? onTap;

  const _ScenarioRow({required this.meta, this.onTap});

  Color _scoreColor(int score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6) return AppColors.goldDeep;
    return AppColors.coral;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = !meta.isCompleted;
    final scoreColor = _scoreColor(meta.totalScore);
    final loc = context.loc;
    final timeLabel = _formatTimeAgo(loc, meta.doneAt);
    final disabled = onTap == null;

    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.98,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.clay.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: isActive
                  ? AppColors.teal.withValues(alpha: 0.6)
                  : context.clay.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderBadge(order: meta.orderInSession),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isActive)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _ActiveBadge(
                                label: loc.sessionPanelActiveLabel),
                          ),
                        Expanded(
                          child: Text(
                            meta.sourcePhrase.isNotEmpty
                                ? meta.sourcePhrase
                                : meta.situation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: disabled
                                  ? context.clay.textMuted
                                  : context.clay.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (meta.tenseDetected != null &&
                            meta.tenseDetected!.isNotEmpty) ...[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                meta.tenseDetected!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 11,
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          timeLabel,
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 11,
                            color: context.clay.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (meta.isCompleted)
                _ScoreBadge(score: meta.totalScore, color: scoreColor),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(dynamic loc, DateTime doneAt) {
    final now = DateTime.now();
    final delta = now.difference(doneAt);
    if (delta.inMinutes < 1) return loc.sessionPanelTimeNow;
    if (delta.inMinutes < 60) {
      return loc.sessionPanelTimeMinutes(delta.inMinutes);
    }
    if (delta.inHours < 24) {
      return loc.sessionPanelTimeHours(delta.inHours);
    }
    if (delta.inDays == 1) return loc.sessionPanelTimeYesterday;
    return loc.sessionPanelTimeOlder(delta.inDays);
  }
}

class _OrderBadge extends StatelessWidget {
  final int order;
  const _OrderBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        '#$order',
        style: AppTypography.bodySm.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.tealDeep,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, size: 14, color: color),
          Text(
            '$score',
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final String label;
  const _ActiveBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.tealDeep,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyState({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.sectionTitle.copyWith(
                fontSize: 15,
                color: context.clay.text,
              ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                body,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm
                    .copyWith(color: context.clay.textMuted, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onEndSession;
  final double bottomInset;

  const _Footer({
    required this.onEndSession,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, 10, AppSpacing.md, bottomInset + 14),
      child: Row(
        children: [
          Expanded(
            child: ClayPressable(
              onTap: onEndSession,
              scaleDown: 0.97,
              builder: (context, isPressed) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.14),
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(
                      color: AppColors.coral.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    loc.sessionPanelEndSessionCta,
                    style: AppTypography.sectionTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coral,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
