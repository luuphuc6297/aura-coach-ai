import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../models/assessment.dart';
import 'score_circle.dart';
import 'radar_score.dart';

class AssessmentCard extends StatefulWidget {
  final AssessmentResult assessment;
  final VoidCallback? onEasier;
  final VoidCallback? onSameDifficulty;
  final VoidCallback? onHarder;
  final ValueChanged<String>? onListen;
  final void Function(Improvement improvement)? onSaveImprovement;

  const AssessmentCard({
    super.key,
    required this.assessment,
    this.onEasier,
    this.onSameDifficulty,
    this.onHarder,
    this.onListen,
    this.onSaveImprovement,
  });

  @override
  State<AssessmentCard> createState() => _AssessmentCardState();
}

class _AssessmentCardState extends State<AssessmentCard> {
  bool _showCorrectionExpanded = false;
  bool _showBetterWayExpanded = false;

  Color _getScoreColor(int score) {
    if (score < 5) return AppColors.error;
    if (score < 8) return AppColors.gold;
    return AppColors.success;
  }

  String _getGradeText(int score) {
    if (score >= 9) return 'Excellent!';
    if (score >= 8) return 'Great!';
    if (score >= 7) return 'Good!';
    if (score >= 6) return 'Nice Try!';
    if (score >= 5) return 'Keep Going!';
    return 'Keep Practicing!';
  }

  Color _getToneColor(String tone) {
    final lower = tone.toLowerCase();
    if (lower.contains('formal')) return AppColors.formalTone;
    if (lower.contains('friendly')) return AppColors.friendlyTone;
    if (lower.contains('casual') || lower.contains('informal')) {
      return AppColors.casualTone;
    }
    if (lower.contains('conversational')) return AppColors.teal;
    return AppColors.warmMuted;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.assessment.score);
    final gradeText = _getGradeText(widget.assessment.score);
    final displayScore = (widget.assessment.score * 10).clamp(0, 100);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: ClipOval(
            child: CloudImage(url: CloudinaryAssets.chatbot, size: 32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aura Coach',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  border: Border.all(color: AppColors.clayBorder, width: 2),
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: AppShadows.lifted,
                ),
                child: Column(
                  children: [
                    _buildHeaderSection(scoreColor, gradeText, displayScore),
                    _divider(),
                    _buildRadarSection(),
                    _divider(),
                    _buildToneVariationsSection(),
                    _divider(),
                    _buildFooterSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(Color scoreColor, String gradeText, int displayScore) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScoreCircle(score: widget.assessment.score, color: scoreColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _badge(gradeText, scoreColor),
                        _badge(
                          widget.assessment.userTone,
                          _getToneColor(widget.assessment.userTone),
                          bgColor: AppColors.clayBeige,
                          borderColor: AppColors.clayBorder,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.assessment.feedback,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.assessment.correction != null) ...[
            const SizedBox(height: 12),
            _buildCorrectionSection(),
          ],
          if (widget.assessment.betterAlternative != null) ...[
            const SizedBox(height: 12),
            _buildBetterAlternativeSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrectionSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✏️', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                'Correction',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A7B3D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.assessment.correction!,
            style: AppTypography.caption.copyWith(
              color: AppColors.warmDark,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetterAlternativeSection() {
    return GestureDetector(
      onTap: () => setState(() => _showBetterWayExpanded = !_showBetterWayExpanded),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      'Better Way to Say It',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _showBetterWayExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.teal,
                ),
              ],
            ),
            if (_showBetterWayExpanded) ...[
              const SizedBox(height: 8),
              Text(
                widget.assessment.betterAlternative!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmDark,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: RadarScore(
              accuracyScore: widget.assessment.accuracyScore,
              naturalnessScore: widget.assessment.naturalnessScore,
              complexityScore: widget.assessment.complexityScore,
              size: 140,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisBlock('✏️', 'Grammar', widget.assessment.grammarAnalysis),
          const SizedBox(height: 10),
          _buildAnalysisBlock('📖', 'Vocabulary', widget.assessment.vocabularyAnalysis),
          if (widget.assessment.improvements.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildImprovementsBlock(),
          ],
        ],
      ),
    );
  }

  List<InlineSpan> _parseEmphasis(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    var lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }

    return spans;
  }

  Widget _buildAnalysisBlock(String icon, String title, String content) {
    final contentStyle = AppTypography.caption.copyWith(
      color: AppColors.warmDark,
      fontSize: 11,
      height: 1.4,
      letterSpacing: 0.2,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.clayBeige.withValues(alpha: 0.5),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.clayBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: _parseEmphasis(content, contentStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsBlock() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.purple,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            widget.assessment.improvements.length,
            (i) {
              final imp = widget.assessment.improvements[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < widget.assessment.improvements.length - 1 ? 8 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _ImprovementTypeBadge(type: imp.type),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Original: ${imp.original}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.error,
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Better: ${imp.correction}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                imp.explanation,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.warmMuted,
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => widget.onSaveImprovement?.call(imp),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text('\u{1F516}', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToneVariationsSection() {
    final tones = [
      ('Formal', widget.assessment.alternativeTones.formal),
      ('Friendly', widget.assessment.alternativeTones.friendly),
      ('Informal', widget.assessment.alternativeTones.informal),
      ('Conversational', widget.assessment.alternativeTones.conversational),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alternative Tones',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.warmDark,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(tones.length, (i) {
            final toneName = tones[i].$1;
            final toneVar = tones[i].$2;
            final toneColor = toneVar.color;

            return Padding(
              padding: EdgeInsets.only(bottom: i < tones.length - 1 ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: toneColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toneName,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: toneColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            toneVar.text,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warmDark,
                              fontSize: 11,
                              height: 1.3,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => widget.onListen?.call(toneVar.text),
                          child: Text('🔊', style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {},
                          child: Text('🔖', style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    final hasCallbacks = widget.onEasier != null ||
        widget.onSameDifficulty != null ||
        widget.onHarder != null;

    if (!hasCallbacks) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Roleplay Difficulty',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.warmDark,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _difficultyButton(
                  'Easier',
                  widget.onEasier,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _difficultyButton(
                  'Same',
                  widget.onSameDifficulty,
                  AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _difficultyButton(
                  'Harder',
                  widget.onHarder,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _difficultyButton(String label, VoidCallback? onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _badge(
    String text,
    Color color, {
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(
          color: borderColor ?? color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 2,
      color: AppColors.clayBorder,
    );
  }
}

class _ImprovementTypeBadge extends StatelessWidget {
  final ImprovementType type;
  const _ImprovementTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isGrammar = type == ImprovementType.grammar;
    final color = isGrammar ? AppColors.error : AppColors.formalTone;
    final label = isGrammar ? 'GRAMMAR' : 'VOCAB';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
