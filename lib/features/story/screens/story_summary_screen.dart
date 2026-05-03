import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/celebration_overlay.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../scenario/models/assessment.dart';
import '../../scenario/widgets/score_circle.dart';
import '../../scenario/widgets/radar_score.dart';
import '../models/story_session.dart';
import '../models/story_turn.dart';
import '../providers/story_provider.dart';

/// Wrap-up screen for a Story session. Reads [StoryProvider.activeSession]
/// and derives the stats inline (average score, per-metric radar). Shows a
/// celebration overlay for strong performances (avg ≥ 6.0). Two primary
/// actions: new story (returns to the library), or back to Home.
class StorySummaryScreen extends StatefulWidget {
  const StorySummaryScreen({super.key});

  @override
  State<StorySummaryScreen> createState() => _StorySummaryScreenState();
}

class _StorySummaryScreenState extends State<StorySummaryScreen> {
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<StoryProvider>().activeSession;
      if (session == null) return;
      if (session.averageScore >= 6.0) {
        setState(() => _showCelebration = true);
      }
    });
  }

  Color _scoreColor(double s) {
    if (s < 5) return AppColors.error;
    if (s < 8) return AppColors.gold;
    return AppColors.success;
  }

  String _grade(double s) {
    if (s >= 9) return 'Excellent Story!';
    if (s >= 7) return 'Great Job!';
    if (s >= 5) return 'Keep Practicing!';
    return 'Finished!';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<StoryProvider>().activeSession;

    return Scaffold(
      backgroundColor: context.clay.background,
      body: Stack(
        children: [
          SafeArea(
            child: session == null
                ? _buildEmpty(context)
                : _buildSummary(context, session),
          ),
          if (_showCelebration)
            const Positioned.fill(
              child: IgnorePointer(child: CelebrationOverlay()),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text('No story to summarize', style: AppTypography.h2),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, StorySession session) {
    final avg = session.averageScore;
    final color = _scoreColor(avg);
    final assessed = session.turns
        .where((t) => t.role == StoryTurnRole.user && t.assessment != null)
        .map((t) => t.assessment!)
        .toList();

    return Column(
      children: [
        _AppBar(onClose: () => context.go('/home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ScoreHeader(
                avgScore: avg,
                color: color,
                title: session.title,
                topic: session.topic,
                grade: _grade(avg),
              ),
              const SizedBox(height: 16),
              _StatsRow(session: session),
              const SizedBox(height: 16),
              if (assessed.isNotEmpty) _RadarCard(assessments: assessed),
              const SizedBox(height: 16),
              if (assessed.isNotEmpty) _TopMomentsCard(assessments: assessed),
              const SizedBox(height: 24),
              const _Actions(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  final VoidCallback onClose;

  const _AppBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          ClayPressable(
            onTap: onClose,
            scaleDown: 0.9,
            builder: (_, __) => Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Text('✕', style: AppTypography.h2.copyWith(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Story Summary',
            style: AppTypography.title.copyWith(color: AppColors.purpleDeep),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final double avgScore;
  final Color color;
  final String title;
  final String topic;
  final String grade;

  const _ScoreHeader({
    required this.avgScore,
    required this.color,
    required this.title,
    required this.topic,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.clay.border, width: 2),
        boxShadow: AppShadows.lifted(context),
      ),
      child: Column(
        children: [
          ScoreCircle(score: avgScore.round(), size: 80, color: color),
          const SizedBox(height: 12),
          Text(grade, style: AppTypography.title.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            title.isEmpty ? topic.toUpperCase() : title,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: context.clay.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final StorySession session;

  const _StatsRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.endedAt == null
        ? 0
        : session.endedAt!.difference(session.startedAt).inMinutes;
    final turns = session.userTurnCount;
    final topic = session.topic;
    final topicDisplay =
        topic.isEmpty ? '—' : (topic[0].toUpperCase() + topic.substring(1));

    return Row(
      children: [
        _StatCard(emoji: '⏱️', value: '${duration}m', label: 'Duration'),
        const SizedBox(width: 10),
        _StatCard(emoji: '💬', value: '$turns', label: 'Turns'),
        const SizedBox(width: 10),
        _StatCard(emoji: '🎭', value: topicDisplay, label: 'Topic'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: context.clay.border, width: 1.5),
          boxShadow: AppShadows.soft(context),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.h2.copyWith(fontSize: 16)),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  final List<AssessmentResult> assessments;

  const _RadarCard({required this.assessments});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.clay.border, width: 2),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        children: [
          Text(
            'Performance Overview',
            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Center(
            child: RadarScore(
              accuracyScore: _avg((a) => a.accuracyScore),
              naturalnessScore: _avg((a) => a.naturalnessScore),
              complexityScore: _avg((a) => a.complexityScore),
              size: 160,
            ),
          ),
        ],
      ),
    );
  }

  int _avg(int Function(AssessmentResult) pick) {
    if (assessments.isEmpty) return 0;
    final total = assessments.map(pick).reduce((a, b) => a + b);
    return (total / assessments.length).round();
  }
}

class _TopMomentsCard extends StatelessWidget {
  final List<AssessmentResult> assessments;

  const _TopMomentsCard({required this.assessments});

  @override
  Widget build(BuildContext context) {
    final ranked = [...assessments]..sort((a, b) => b.score.compareTo(a.score));
    final top = ranked.take(2).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.clay.border, width: 2),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Best Moments',
                style:
                    AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final a in top) _MomentRow(assessment: a),
        ],
      ),
    );
  }
}

class _MomentRow extends StatelessWidget {
  final AssessmentResult assessment;

  const _MomentRow({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final feedback = assessment.feedback.isNotEmpty
        ? assessment.feedback
        : (assessment.analysis.isNotEmpty ? assessment.analysis : '—');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.clay.background,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: context.clay.border, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScorePill(score: assessment.score),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                feedback,
                style: AppTypography.bodySm.copyWith(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score;

  const _ScorePill({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 8
        ? AppColors.success
        : score >= 5
            ? AppColors.gold
            : AppColors.error;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        '$score',
        style: AppTypography.labelLg.copyWith(color: color, fontSize: 14),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClayPressable(
            onTap: () => context.go('/home'),
            builder: (ctx, __) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ctx.clay.surface,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: ctx.clay.border, width: 2),
                ),
                child: Text(
                  'Back to Home',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: ctx.clay.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClayPressable(
            onTap: () => context.go('/story'),
            builder: (_, __) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.purple, AppColors.purpleDeep],
                  ),
                  borderRadius: AppRadius.mdBorder,
                  boxShadow: AppShadows.colored(AppColors.purple, alpha: 0.35),
                ),
                child: Text(
                  'New Story',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
