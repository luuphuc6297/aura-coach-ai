import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/hero_stats_row.dart';
import '../widgets/period_picker.dart';
import '../widgets/skill_bars.dart';
import '../widgets/streak_heatmap.dart';
import '../widgets/weak_words_card.dart';

/// Lite v1 of the Insights tab. Layout top-to-bottom:
///   • Header title
///   • Period picker (Today/Week/Month/All)
///   • Hero stats row (streak, practice time, sessions)
///   • Streak heatmap (13 weeks)
///   • Skill breakdown bars
///   • Weak words list
///
/// Heavier future widgets (radar, tone donut, trend line, AI read-out) plug
/// into this same scroll column as they're built — no restructure needed.
class InsightsScreen extends StatefulWidget {
  /// When `true`, omit the in-screen "Insights" header — the parent
  /// [InsightsHubScreen] already provides the page title via its AppBar.
  final bool embedded;

  const InsightsScreen({super.key, this.embedded = false});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<AnalyticsProvider>().init(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, _) {
        return RefreshIndicator(
          color: AppColors.teal,
          backgroundColor: context.clay.surface,
          onRefresh: analytics.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.huge,
            ),
            children: [
              if (!widget.embedded) ...[
                const _Header(),
                const SizedBox(height: AppSpacing.lg),
              ],
              PeriodPicker(
                value: analytics.period,
                onChanged: analytics.setPeriod,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (analytics.isLoading && !analytics.hasAnyData)
                const _LoadingPlaceholder()
              else ...[
                HeroStatsRow(
                  streakDays: analytics.currentStreak,
                  practiceMinutes: analytics.practiceMinutesInPeriod,
                  sessions: analytics.sessionsInPeriod,
                ),
                const SizedBox(height: AppSpacing.lg),
                StreakHeatmap(
                  grid: analytics.heatmap,
                  currentStreak: analytics.currentStreak,
                  bestStreak: analytics.bestStreak,
                ),
                const SizedBox(height: AppSpacing.lg),
                SkillBars(
                  fluency: analytics.skillAverages['fluency'] ?? 0,
                  accuracy: analytics.skillAverages['accuracy'] ?? 0,
                  naturalness: analytics.skillAverages['naturalness'] ?? 0,
                  complexity: analytics.skillAverages['complexity'] ?? 0,
                ),
                const SizedBox(height: AppSpacing.lg),
                WeakWordsCard(items: analytics.weakWords()),
                if (analytics.error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    analytics.error!,
                    style:
                        AppTypography.caption.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your insights', style: AppTypography.h1),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'See how your practice is paying off.',
          style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.giant),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.teal,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Crunching your practice data...',
              style: AppTypography.caption.copyWith(color: context.clay.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
