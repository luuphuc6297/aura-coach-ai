// lib/features/scenario/screens/session_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/celebration_overlay.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../providers/scenario_provider.dart';
import '../widgets/score_circle.dart';
import '../widgets/radar_score.dart';
import '../models/assessment.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScenarioProvider>();
      final summary = provider.getSessionSummary();
      final avgScore = summary['averageScore'] as double;
      if (avgScore >= 6) {
        setState(() => _showCelebration = true);
      }
    });
  }

  Color _getScoreColor(double score) {
    if (score < 5) return AppColors.error;
    if (score < 8) return AppColors.gold;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ScenarioProvider>();
    final summary = provider.getSessionSummary();
    final avgScore = (summary['averageScore'] as double);
    final assessments = summary['assessments'] as List<AssessmentResult>;
    final scoreColor = _getScoreColor(avgScore);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildScoreHeader(summary, avgScore, scoreColor),
                      const SizedBox(height: 16),
                      _buildStatsRow(summary),
                      const SizedBox(height: 16),
                      if (assessments.isNotEmpty)
                        _buildAverageRadar(assessments),
                      const SizedBox(height: 24),
                      _buildActionButtons(context, provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCelebration)
            const Positioned.fill(
              child: IgnorePointer(
                child: CelebrationOverlay(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          ClayPressable(
            onTap: () => context.go('/home'),
            scaleDown: 0.90,
            builder: (context, isPressed) {
              return Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child:
                    Text('✕', style: AppTypography.h2.copyWith(fontSize: 18)),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Session Summary',
            style: AppTypography.title.copyWith(color: AppColors.teal),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(
      Map<String, dynamic> summary, double avgScore, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.lifted,
      ),
      child: Column(
        children: [
          ScoreCircle(
            score: avgScore.round(),
            size: 80,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            avgScore >= 8
                ? 'Excellent Session!'
                : avgScore >= 6
                    ? 'Good Progress!'
                    : 'Keep Practicing!',
            style: AppTypography.title.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary['topic']} · ${summary['difficulty']}',
            style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> summary) {
    return Row(
      children: [
        _statCard('⏱️', '${summary['duration']}m', 'Duration'),
        const SizedBox(width: 10),
        _statCard('💬', '${summary['totalTurns']}', 'Turns'),
        const SizedBox(width: 10),
        _statCard('📊', '#${summary['scenarioIndex']}', 'Scenario'),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: AppColors.clayBorder, width: 1.5),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.h2.copyWith(fontSize: 18),
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.warmMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageRadar(List<AssessmentResult> assessments) {
    final avgAccuracy =
        assessments.map((a) => a.accuracyScore).reduce((a, b) => a + b) /
            assessments.length;
    final avgNaturalness =
        assessments.map((a) => a.naturalnessScore).reduce((a, b) => a + b) /
            assessments.length;
    final avgComplexity =
        assessments.map((a) => a.complexityScore).reduce((a, b) => a + b) /
            assessments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.soft,
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
              accuracyScore: avgAccuracy.round(),
              naturalnessScore: avgNaturalness.round(),
              complexityScore: avgComplexity.round(),
              size: 160,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ScenarioProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ClayPressable(
            onTap: () {
              provider.endSession();
              context.go('/home');
            },
            builder: (context, isPressed) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: AppColors.clayBorder, width: 2),
                ),
                child: Text(
                  'Back to Home',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmDark,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClayPressable(
            onTap: () async {
              await provider.startNewScenario();
              if (context.mounted) {
                context.go('/scenario');
              }
            },
            builder: (context, isPressed) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: AppRadius.mdBorder,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Text(
                  'New Scenario',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmDark,
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
