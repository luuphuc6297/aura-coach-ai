import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../models/assessment.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';
import 'score_circle.dart';
import 'radar_score.dart';

class AssessmentCard extends StatefulWidget {
  final AssessmentResult assessment;

  /// Difficulty-shift callbacks. Returning a [Future] lets the card show a
  /// per-button loading spinner + lock the other two while the new scenario
  /// is being generated. Null hides the button row entirely (used by replay
  /// mode where the Branch panel below the chat handles the action instead).
  final Future<void> Function()? onEasier;
  final Future<void> Function()? onSameDifficulty;
  final Future<void> Function()? onHarder;
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

/// Identifies which difficulty-shift button is currently in-flight.
/// `null` = no button active; any value disables the other two buttons
/// and replaces the active one's content with a spinner.
enum _DifficultyAction { easier, same, harder }

class _AssessmentCardState extends State<AssessmentCard> {
  bool _showCorrectionExpanded = false;
  bool _showBetterWayExpanded = false;
  _DifficultyAction? _processingAction;

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

  Color _getToneColor(BuildContext context, String tone) {
    final lower = tone.toLowerCase();
    if (lower.contains('formal')) return AppColors.formalTone;
    if (lower.contains('friendly')) return AppColors.friendlyTone;
    if (lower.contains('casual') || lower.contains('informal')) {
      return AppColors.casualTone;
    }
    if (lower.contains('conversational')) return AppColors.teal;
    return context.clay.textMuted;
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
            border: Border.all(color: context.clay.border, width: 2),
            boxShadow: AppShadows.card(context),
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
                  color: context.clay.surface,
                  border: Border.all(color: context.clay.border, width: 2),
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: AppShadows.lifted(context),
                ),
                child: Column(
                  children: [
                    _buildHeaderSection(
                        context, scoreColor, gradeText, displayScore),
                    _divider(context),
                    _buildRadarSection(context),
                    _divider(context),
                    _buildToneVariationsSection(context),
                    if (widget.assessment.keyVocabulary.isNotEmpty) ...[
                      _divider(context),
                      _buildKeyVocabularySection(context),
                    ],
                    _divider(context),
                    _buildFooterSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, Color scoreColor,
      String gradeText, int displayScore) {
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
                        _gradeBadge(context, gradeText, scoreColor),
                        _badge(
                          widget.assessment.userTone,
                          _getToneColor(context, widget.assessment.userTone),
                          bgColor: context.clay.surfaceAlt,
                          borderColor: context.clay.border,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.assessment.feedback,
                      style: AppTypography.bodySm.copyWith(
                        color: context.clay.textMuted,
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
            _buildCorrectionSection(context),
          ],
          if (widget.assessment.betterAlternative != null) ...[
            const SizedBox(height: 10),
            _buildBetterAlternativeSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrectionSection(BuildContext context) {
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
              color: context.clay.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetterAlternativeSection(BuildContext context) {
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
                      color: context.clay.text,
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

  Widget _buildRadarSection(BuildContext context) {
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
              color: context.clay.textMuted,
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
          _buildAnalysisBlock(context, AppIcons.grammar, 'Grammar',
              widget.assessment.grammarAnalysis),
          if (widget.assessment.grammarBreakdown != null) ...[
            const SizedBox(height: 10),
            _buildGrammarBreakdownBlock(context),
          ],
          const SizedBox(height: 10),
          _buildAnalysisBlock(context, AppIcons.vocabulary, 'Vocabulary',
              widget.assessment.vocabularyAnalysis),
          if (widget.assessment.improvements.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildImprovementsBlock(context),
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

  Widget _buildAnalysisBlock(
      BuildContext context, String icon, String title, String content) {
    final contentStyle = AppTypography.bodySm.copyWith(
      color: context.clay.text,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt.withValues(alpha: 0.6),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(iconId: icon, size: 18, color: context.clay.text),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.clay.text,
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

  // ---------- Grammar Breakdown ----------

  /// Maps a component role label (English, AI output) to a palette color so
  /// each role keeps a consistent visual identity across both variant cards.
  /// Subject = teal, Main Verb = coral, Auxiliary = gold, Object = purple,
  /// Adverbial = purple-deep, everything else = muted.
  Color _roleColor(BuildContext context, String role) {
    final r = role.toLowerCase();
    if (r.contains('subject') && !r.contains('complement')) {
      return AppColors.tealDeep;
    }
    if (r.contains('main verb') || r == 'verb' || r.contains('predicate')) {
      return AppColors.coral;
    }
    if (r.contains('auxiliary') || r.contains('modal')) {
      return AppColors.goldDeep;
    }
    if (r.contains('object')) return AppColors.purpleDeep;
    if (r.contains('complement')) return AppColors.goldDeep;
    if (r.contains('adverbial') || r.contains('adverb')) {
      return AppColors.purple;
    }
    if (r.contains('preposition')) return AppColors.purple;
    if (r.contains('conjunction')) return AppColors.coral;
    return context.clay.textMuted;
  }

  Widget _buildGrammarBreakdownBlock(BuildContext context) {
    final breakdown = widget.assessment.grammarBreakdown;
    if (breakdown == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                  iconId: AppIcons.grammar,
                  size: 18,
                  color: AppColors.tealDeep),
              const SizedBox(width: 8),
              Text(
                context.loc.assessmentGrammarBreakdownHeader,
                style: AppTypography.sentenceLabel.copyWith(
                  color: AppColors.tealDeep,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBreakdownVariantCard(
            context,
            breakdown.userVersion,
            isUserVersion: true,
            isUserCorrect: breakdown.correctVersion == null,
          ),
          if (breakdown.correctVersion != null) ...[
            const SizedBox(height: 10),
            _buildBreakdownVariantCard(
              context,
              breakdown.correctVersion!,
              isUserVersion: false,
              isUserCorrect: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownVariantCard(
    BuildContext context,
    GrammarBreakdownVariant variant, {
    required bool isUserVersion,
    required bool isUserCorrect,
  }) {
    // When the user input is already correct, the user-version card itself
    // is the "correct" card — use the success accent so the learner gets a
    // positive signal without showing a redundant second variant.
    final useSuccessAccent = isUserVersion ? isUserCorrect : true;
    final accent = isUserVersion && !useSuccessAccent
        ? AppColors.coral
        : AppColors.success;
    final loc = context.loc;
    final label = isUserVersion
        ? (isUserCorrect
            ? loc.assessmentGrammarBreakdownYourSentenceCorrect
            : loc.assessmentGrammarBreakdownYourSentence)
        : loc.assessmentGrammarBreakdownCorrectSentence;
    final icon = useSuccessAccent ? AppIcons.check : AppIcons.bookmark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.smBorder,
        border: Border.all(
            color: accent.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(iconId: icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.sentenceLabel.copyWith(
                  color: accent,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${variant.sentence}"',
            style: AppTypography.bodyMd.copyWith(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: context.clay.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          _buildTensePill(context, variant.tense, variant.tenseVi),
          if (variant.tenseExplanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              variant.tenseExplanation,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                color: context.clay.textMuted,
                height: 1.45,
              ),
            ),
          ],
          if (variant.components.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSubLabel(
                context, loc.assessmentGrammarBreakdownComponents),
            const SizedBox(height: 6),
            ...variant.components.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildComponentRow(context, c),
              ),
            ),
          ],
          if (variant.auxiliaries.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildSubLabel(
                context, loc.assessmentGrammarBreakdownAuxiliaries),
            const SizedBox(height: 6),
            ...variant.auxiliaries.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildAuxiliaryRow(context, a),
              ),
            ),
          ],
          if (variant.structureNote != null) ...[
            const SizedBox(height: 8),
            _buildStructureNote(context, variant.structureNote!),
          ],
        ],
      ),
    );
  }

  Widget _buildTensePill(BuildContext context, String tense, String tenseVi) {
    final hasVi = tenseVi.isNotEmpty && tenseVi != tense;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: AppRadius.smBorder,
        border: Border.all(
            color: AppColors.goldDeep.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(
              iconId: AppIcons.clock, size: 13, color: AppColors.goldDark),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              hasVi ? '$tense · $tenseVi' : tense,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.goldDark,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTypography.sentenceLabel.copyWith(
        fontSize: 10,
        letterSpacing: 0.9,
        color: context.clay.textMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildComponentRow(BuildContext context, GrammarComponent c) {
    final color = _roleColor(context, c.role);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            c.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.roleVi.isNotEmpty ? c.roleVi : c.role,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.clay.text,
                ),
              ),
              if (c.explanation != null && c.explanation!.isNotEmpty)
                Text(
                  c.explanation!,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: context.clay.textMuted,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuxiliaryRow(BuildContext context, GrammarAuxiliary a) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.goldDeep.withValues(alpha: 0.14),
            borderRadius: AppRadius.smBorder,
            border: Border.all(
                color: AppColors.goldDeep.withValues(alpha: 0.4), width: 1),
          ),
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            a.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.goldDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.type,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.clay.text,
                ),
              ),
              if (a.function.isNotEmpty)
                Text(
                  a.function,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: context.clay.textMuted,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStructureNote(BuildContext context, String note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt.withValues(alpha: 0.8),
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: context.clay.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
              iconId: AppIcons.sparkle, size: 13, color: context.clay.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${context.loc.assessmentGrammarBreakdownPatternPrefix}: $note',
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: context.clay.text,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsBlock(BuildContext context) {
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
                    color: context.clay.surface,
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
                              context: context,
                              label: 'Original',
                              value: imp.original,
                              color: AppColors.error,
                              italic: true,
                            ),
                            const SizedBox(height: 4),
                            _improvementLine(
                              context: context,
                              label: 'Better',
                              value: imp.correction,
                              color: AppColors.success,
                              bold: true,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              imp.explanation,
                              style: AppTypography.bodySm.copyWith(
                                color: context.clay.textMuted,
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
    required BuildContext context,
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
              color: context.clay.text,
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

  Widget _buildToneVariationsSection(BuildContext context) {
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
              color: context.clay.textMuted,
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
                              color: context.clay.text,
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
                                color: context.clay.surface,
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
                                color: context.clay.surface,
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

  Widget _buildKeyVocabularySection(BuildContext context) {
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
                  color: context.clay.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                '${vocab.length} ${vocab.length == 1 ? 'word' : 'words'}',
                style: AppTypography.caption.copyWith(
                  color: context.clay.textFaint,
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
              color: context.clay.textFaint,
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

  Widget _buildFooterSection(BuildContext context) {
    final hasCallbacks = widget.onEasier != null ||
        widget.onSameDifficulty != null ||
        widget.onHarder != null;

    if (!hasCallbacks) {
      return const SizedBox.shrink();
    }

    final loc = context.loc;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.assessmentDifficultyTitle,
            style: AppTypography.sentenceLabel.copyWith(
              color: context.clay.textMuted,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _difficultyButton(
                  context: context,
                  action: _DifficultyAction.easier,
                  label: loc.assessmentDifficultyEasier,
                  icon: Icons.trending_down_rounded,
                  callback: widget.onEasier,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _difficultyButton(
                  context: context,
                  action: _DifficultyAction.same,
                  label: loc.assessmentDifficultySame,
                  icon: Icons.refresh_rounded,
                  callback: widget.onSameDifficulty,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _difficultyButton(
                  context: context,
                  action: _DifficultyAction.harder,
                  label: loc.assessmentDifficultyHarder,
                  icon: Icons.trending_up_rounded,
                  callback: widget.onHarder,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Difficulty-shift button with three visual states:
  /// - **idle**: tinted background + colored border + icon + label
  /// - **pressed**: scale-down 0.92 + bumped color saturation
  /// - **loading**: spinner replaces icon + label morphs to "Generating…"
  ///   while the parent's [callback] is in-flight; other two buttons in the
  ///   row are dimmed and disabled so the user can't double-tap.
  Widget _difficultyButton({
    required BuildContext context,
    required _DifficultyAction action,
    required String label,
    required IconData icon,
    required Future<void> Function()? callback,
    required Color color,
  }) {
    final isProcessing = _processingAction == action;
    final isOtherProcessing =
        _processingAction != null && _processingAction != action;
    final isDisabled = callback == null || isOtherProcessing;
    final loc = context.loc;

    Future<void> handleTap() async {
      if (callback == null || _processingAction != null) return;
      setState(() => _processingAction = action);
      try {
        await callback();
      } finally {
        if (mounted) setState(() => _processingAction = null);
      }
    }

    return ClayPressable(
      onTap: isDisabled ? null : handleTap,
      scaleDown: 0.92,
      builder: (context, isPressed) {
        final fillAlpha = isProcessing
            ? 0.30
            : (isPressed ? 0.28 : 0.15);
        final borderAlpha = isProcessing ? 0.85 : (isPressed ? 0.75 : 0.5);
        final dim = isOtherProcessing ? 0.35 : 1.0;

        return Opacity(
          opacity: dim,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: fillAlpha),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: color.withValues(alpha: borderAlpha),
                width: isProcessing ? 2 : 1.5,
              ),
            ),
            child: isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          loc.assessmentDifficultyLoading,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: context.clay.text,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.clay.text,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _gradeBadge(BuildContext context, String text, Color color) {
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
          color: context.clay.text,
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

  Widget _divider(BuildContext context) {
    return Container(
      height: 2,
      color: context.clay.border,
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
        color: context.clay.surface,
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
                          color: context.clay.text,
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
                      color: context.clay.textMuted,
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
                      color: context.clay.textFaint,
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
