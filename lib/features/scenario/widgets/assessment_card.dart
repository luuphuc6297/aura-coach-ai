import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../models/assessment.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';
import 'score_circle.dart';
import 'radar_score.dart';

class AssessmentCard extends StatefulWidget {
  final AssessmentResult assessment;
  final VoidCallback? onEasier;
  final VoidCallback? onSameDifficulty;
  final VoidCallback? onHarder;
  final ValueChanged<String>? onListen;
  final void Function(Improvement improvement)? onSaveImprovement;
  final void Function(KeyVocabulary vocab)? onSaveVocabulary;
  final bool Function(KeyVocabulary vocab)? isVocabularySaved;

  const AssessmentCard({
    super.key,
    required this.assessment,
    this.onEasier,
    this.onSameDifficulty,
    this.onHarder,
    this.onListen,
    this.onSaveImprovement,
    this.onSaveVocabulary,
    this.isVocabularySaved,
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
                    if (widget.assessment.keyVocabulary.isNotEmpty) ...[
                      _divider(),
                      _buildKeyVocabularySection(),
                    ],
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

  Widget _buildHeaderSection(
      Color scoreColor, String gradeText, int displayScore) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScoreCircle(score: widget.assessment.score, color: scoreColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _gradeBadge(gradeText, scoreColor),
                        _badge(
                          widget.assessment.userTone,
                          _getToneColor(widget.assessment.userTone),
                          bgColor: AppColors.clayBeige,
                          borderColor: AppColors.clayBorder,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.assessment.feedback,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.warmMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.assessment.correction != null) ...[
            const SizedBox(height: 14),
            _buildCorrectionSection(),
          ],
          if (widget.assessment.betterAlternative != null) ...[
            const SizedBox(height: 10),
            _buildBetterAlternativeSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrectionSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                  iconId: AppIcons.grammar,
                  size: 16,
                  color: AppColors.goldDeep),
              const SizedBox(width: 8),
              Text(
                'CORRECTION',
                style: AppTypography.sentenceLabel.copyWith(
                  color: AppColors.goldDeep,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.assessment.correction!,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.warmDark,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetterAlternativeSection() {
    return ClayPressable(
      onTap: () =>
          setState(() => _showBetterWayExpanded = !_showBetterWayExpanded),
      scaleDown: 0.98,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: AppColors.teal.withValues(alpha: 0.35),
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
                      const AppIcon(
                          iconId: AppIcons.hint,
                          size: 16,
                          color: AppColors.tealDeep),
                      const SizedBox(width: 8),
                      Text(
                        'BETTER WAY TO SAY IT',
                        style: AppTypography.sentenceLabel.copyWith(
                          color: AppColors.tealDeep,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _showBetterWayExpanded ? 0.5 : 0.0,
                    duration: AppAnimations.durationMedium,
                    child: const Icon(
                      Icons.expand_more,
                      size: 20,
                      color: AppColors.tealDeep,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.assessment.betterAlternative!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.warmDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _showBetterWayExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: AppAnimations.durationMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE BREAKDOWN',
            style: AppTypography.sentenceLabel.copyWith(
              fontSize: 11,
              letterSpacing: 1.0,
              color: AppColors.warmMuted,
            ),
          ),
          const SizedBox(height: 14),
          RadarScore(
            accuracyScore: widget.assessment.accuracyScore,
            naturalnessScore: widget.assessment.naturalnessScore,
            complexityScore: widget.assessment.complexityScore,
            size: 200,
          ),
          const SizedBox(height: 18),
          _buildAnalysisBlock(
              AppIcons.grammar, 'Grammar', widget.assessment.grammarAnalysis),
          const SizedBox(height: 10),
          _buildAnalysisBlock(AppIcons.vocabulary, 'Vocabulary',
              widget.assessment.vocabularyAnalysis),
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
    final contentStyle = AppTypography.bodySm.copyWith(
      color: AppColors.warmDark,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.clayBeige.withValues(alpha: 0.6),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.clayBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(iconId: icon, size: 18, color: AppColors.warmDark),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
            color: AppColors.purple.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                  iconId: AppIcons.hint, size: 18, color: AppColors.purpleDeep),
              const SizedBox(width: 8),
              Text(
                'SUGGESTIONS',
                style: AppTypography.sentenceLabel.copyWith(
                  color: AppColors.purpleDeep,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(
            widget.assessment.improvements.length,
            (i) {
              final imp = widget.assessment.improvements[i];
              final isLast = i == widget.assessment.improvements.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.clayWhite,
                    borderRadius: AppRadius.smBorder,
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ImprovementTypeBadge(type: imp.type),
                            const SizedBox(height: 6),
                            _improvementLine(
                              label: 'Original',
                              value: imp.original,
                              color: AppColors.error,
                              italic: true,
                            ),
                            const SizedBox(height: 4),
                            _improvementLine(
                              label: 'Better',
                              value: imp.correction,
                              color: AppColors.success,
                              bold: true,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              imp.explanation,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.warmMuted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClayPressable(
                        onTap: () => widget.onSaveImprovement?.call(imp),
                        scaleDown: 0.85,
                        builder: (context, isPressed) {
                          return Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: AppIcon(
                                iconId: AppIcons.bookmark,
                                size: 16,
                                color: AppColors.purpleDeep,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _improvementLine({
    required String label,
    required String value,
    required Color color,
    bool italic = false,
    bool bold = false,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: AppTypography.labelSm.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: value,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.warmDark,
              fontSize: 12,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              height: 1.4,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALTERNATIVE TONES',
            style: AppTypography.sentenceLabel.copyWith(
              color: AppColors.warmMuted,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(tones.length, (i) {
            final toneName = tones[i].$1;
            final toneVar = tones[i].$2;
            final toneColor = toneVar.color;
            final isLast = i == tones.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                      color: toneColor.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toneName.toUpperCase(),
                            style: AppTypography.sentenceLabel.copyWith(
                              color: toneColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            toneVar.text,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.warmDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        ClayPressable(
                          onTap: () => widget.onListen?.call(toneVar.text),
                          scaleDown: 0.85,
                          builder: (context, isPressed) {
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.clayWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: toneColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: AppIcon(
                                  iconId: AppIcons.listen,
                                  size: 16,
                                  color: toneColor,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        ClayPressable(
                          onTap: () {},
                          scaleDown: 0.85,
                          builder: (context, isPressed) {
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.clayWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: toneColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: AppIcon(
                                  iconId: AppIcons.bookmark,
                                  size: 16,
                                  color: toneColor,
                                ),
                              ),
                            );
                          },
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

  Widget _buildKeyVocabularySection() {
    final vocab = widget.assessment.keyVocabulary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                iconId: AppIcons.vocabulary,
                size: 16,
                color: AppColors.purpleDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'KEY VOCABULARY',
                style: AppTypography.sentenceLabel.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                '${vocab.length} ${vocab.length == 1 ? 'word' : 'words'}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tap bookmark to save to your dictionary',
            style: AppTypography.caption.copyWith(
              color: AppColors.warmLight,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(vocab.length, (i) {
            final item = vocab[i];
            final saved = widget.isVocabularySaved?.call(item) ?? false;
            final isLast = i == vocab.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: _KeyVocabularyTile(
                item: item,
                saved: saved,
                onSave:
                    saved ? null : () => widget.onSaveVocabulary?.call(item),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROLEPLAY DIFFICULTY',
            style: AppTypography.sentenceLabel.copyWith(
              color: AppColors.warmMuted,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
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
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.warmDark,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _gradeBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.warmDark,
          fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.15),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(
          color: borderColor ?? color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 12,
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

class _KeyVocabularyTile extends StatelessWidget {
  final KeyVocabulary item;
  final bool saved;
  final VoidCallback? onSave;

  const _KeyVocabularyTile({
    required this.item,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        item.word,
                        style: AppTypography.sectionTitle.copyWith(
                          color: AppColors.warmDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.partOfSpeech.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.partOfSpeech,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.purpleDeep,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.meaning.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.meaning,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.warmMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
                if (item.example.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.example,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.warmLight,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClayPressable(
            onTap: onSave,
            scaleDown: 0.85,
            builder: (context, isPressed) {
              return Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: saved
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: saved
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.purple.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: AppIcon(
                    iconId: saved ? AppIcons.check : AppIcons.bookmark,
                    size: 16,
                    color: saved ? AppColors.success : AppColors.purpleDeep,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
