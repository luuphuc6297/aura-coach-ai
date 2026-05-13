import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

/// Compact header indicator surfacing the active practice session: scenario
/// count + running average score. Tap opens the Session Panel where the
/// learner can review or branch from any past scenario in the session.
///
/// Hidden by the parent when there is no active session — this widget is
/// purely presentational and assumes the data is non-null.
class SessionChip extends StatelessWidget {
  /// Number of completed scenarios in the current session.
  final int scenarioCount;

  /// Running average score across all scenarios in the session (0-10).
  /// Displayed with one decimal; rendered as "—" when count is 0.
  final double avgScore;

  /// Tap handler — typically opens the Session Panel bottom sheet.
  final VoidCallback onTap;

  const SessionChip({
    super.key,
    required this.scenarioCount,
    required this.avgScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasScores = scenarioCount > 0;
    final avgLabel = hasScores ? avgScore.toStringAsFixed(1) : '—';

    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.12),
            borderRadius: AppRadius.smBorder,
            border: Border.all(
              color: AppColors.teal.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                iconId: AppIcons.history,
                size: 14,
                color: AppColors.tealDeep,
              ),
              const SizedBox(width: 6),
              Text(
                '$scenarioCount',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tealDeep,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 12,
                color: AppColors.tealDeep.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.star_rounded,
                size: 14,
                color: hasScores
                    ? AppColors.goldDeep
                    : context.clay.textMuted,
              ),
              const SizedBox(width: 3),
              Text(
                avgLabel,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: hasScores
                      ? AppColors.tealDeep
                      : context.clay.textMuted,
                  height: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
