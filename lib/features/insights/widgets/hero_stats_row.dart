import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_card.dart';

/// Three-up stats row: streak / practice minutes / sessions. Each tile uses
/// an accent color from the Clay palette so the numbers pop against the cream
/// background. Values are pre-formatted by the caller — this widget is purely
/// presentational.
class HeroStatsRow extends StatelessWidget {
  final int streakDays;
  final int practiceMinutes;
  final int sessions;

  const HeroStatsRow({
    super.key,
    required this.streakDays,
    required this.practiceMinutes,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so all three tiles share the tallest tile's height
    // without needing a bounded parent. Plain CrossAxisAlignment.stretch
    // crashes inside a ListView because the Row inherits unbounded height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              value: streakDays.toString(),
              label: 'Day streak',
              emoji: '🔥',
              accent: AppColors.coral,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatTile(
              value: _formatMinutes(practiceMinutes),
              label: 'Practiced',
              emoji: '⏱',
              accent: AppColors.teal,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatTile(
              value: sessions.toString(),
              label: sessions == 1 ? 'Session' : 'Sessions',
              emoji: '💬',
              accent: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    if (rem == 0) return '${hours}h';
    return '${hours}h ${rem}m';
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final Color accent;

  const _StatTile({
    required this.value,
    required this.label,
    required this.emoji,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppRadius.smBorder,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.warmMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
