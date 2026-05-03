import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/clay_palette.dart';
import '../../l10n/app_loc_context.dart';
import 'clay_pressable.dart';

/// Snapshot of session stats + quota state that a mode hands to
/// [showEndSessionDialog]. Keeping this a plain data class lets Story and
/// Scenario compute their own field-by-field so the dialog stays mode
/// agnostic.
class EndSessionStats {
  /// Number of user turns so far.
  final int turns;

  /// Average user-turn score. Null when no assessed turn exists.
  final double? averageScore;

  /// Active session wall time. Null to hide the duration tile.
  final Duration? duration;

  /// Optional best-line highlight e.g. `Best line: "I was just ..."`. Null
  /// hides the line entirely.
  final String? highlight;

  /// Daily quota label e.g. `"2/3 sessions left today"`. Null hides the
  /// reminder.
  final String? quotaReminder;

  const EndSessionStats({
    required this.turns,
    this.averageScore,
    this.duration,
    this.highlight,
    this.quotaReminder,
  });
}

/// Show the shared end-session confirmation sheet. Returns `true` when the
/// learner chose "End & review", `false` when they chose "Keep going", and
/// `null` when they dismissed by tapping outside the sheet.
Future<bool?> showEndSessionDialog({
  required BuildContext context,
  required Color accentColor,
  required EndSessionStats stats,
  String? title,
  String? continueLabel,
  String? endLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EndSessionSheet(
      accentColor: accentColor,
      title: title,
      stats: stats,
      continueLabel: continueLabel,
      endLabel: endLabel,
    ),
  );
}

class _EndSessionSheet extends StatelessWidget {
  final Color accentColor;
  final String? title;
  final EndSessionStats stats;
  final String? continueLabel;
  final String? endLabel;

  const _EndSessionSheet({
    required this.accentColor,
    required this.title,
    required this.stats,
    required this.continueLabel,
    required this.endLabel,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final resolvedTitle = title ?? loc.endSessionDefaultTitle;
    final resolvedContinue = continueLabel ?? loc.endSessionContinueLabel;
    final resolvedEnd = endLabel ?? loc.endSessionEndReviewLabel;
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.clay.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(resolvedTitle,
                style: AppTypography.title.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            _StatsStrip(stats: stats, accentColor: accentColor),
            if (stats.highlight != null) ...[
              const SizedBox(height: 10),
              _HighlightLine(text: stats.highlight!, accentColor: accentColor),
            ],
            if (stats.quotaReminder != null) ...[
              const SizedBox(height: 8),
              Text(
                stats.quotaReminder!,
                style: AppTypography.caption.copyWith(
                  color: context.clay.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ClayPressable(
                    onTap: () => Navigator.of(context).pop(false),
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: context.clay.surfaceAlt,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                          color: context.clay.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        resolvedContinue,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: context.clay.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClayPressable(
                    onTap: () => Navigator.of(context).pop(true),
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: AppRadius.mdBorder,
                        boxShadow: AppShadows.colored(accentColor, alpha: 0.35),
                      ),
                      child: Text(
                        resolvedEnd,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final EndSessionStats stats;
  final Color accentColor;

  const _StatsStrip({required this.stats, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final tiles = <_StatTile>[
      _StatTile(
        label: loc.endSessionStatTurns,
        value: '${stats.turns}',
        accentColor: accentColor,
      ),
    ];
    if (stats.averageScore != null) {
      tiles.add(_StatTile(
        label: loc.endSessionStatAvgScore,
        value: stats.averageScore!.toStringAsFixed(1),
        accentColor: accentColor,
      ));
    }
    if (stats.duration != null) {
      tiles.add(_StatTile(
        label: loc.endSessionStatDuration,
        value: _formatDuration(stats.duration!),
        accentColor: accentColor,
      ));
    }
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return '$h:${m.toString().padLeft(2, '0')}';
    }
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightLine extends StatelessWidget {
  final String text;
  final Color accentColor;

  const _HighlightLine({required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 14, color: accentColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: context.clay.text,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
