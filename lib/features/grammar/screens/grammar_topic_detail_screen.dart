import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../data/grammar_catalog.dart';
import '../models/grammar_exercise.dart';
import '../models/grammar_topic.dart';

/// Topic Detail surface for one [GrammarTopic]. Renders the formula,
/// summary EN+VI, when-to-use checklist, examples (with TTS), common
/// mistakes, related-topic chips, and a sticky "Start practice" CTA that
/// opens the practice-mode picker bottom sheet.
///
/// Loaded by id via the route `/grammar/:topicId`. The catalog is
/// hand-curated and lives in `lib/features/grammar/data/`, so loading is
/// a synchronous catalog lookup with no Firestore round-trip.
class GrammarTopicDetailScreen extends StatelessWidget {
  final String topicId;

  const GrammarTopicDetailScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    final topic = GrammarCatalog.maybeById(topicId);
    if (topic == null) return _NotFoundState(topicId: topicId);

    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: _buildAppBar(context, topic),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryCard(topic: topic),
              if (topic.useCases.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(text: context.loc.grammarTopicWhenToUseTitle),
                const SizedBox(height: AppSpacing.sm),
                _UseCasesList(topic: topic),
              ],
              if (topic.examples.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(text: context.loc.grammarTopicExamplesTitle),
                const SizedBox(height: AppSpacing.sm),
                ...topic.examples
                    .map((e) => _ExampleCard(example: e))
                    .toList(growable: false),
              ],
              if (topic.commonMistakes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(text: context.loc.grammarTopicMistakesTitle),
                const SizedBox(height: AppSpacing.sm),
                ...topic.commonMistakes
                    .map((m) => _MistakeCard(mistake: m))
                    .toList(growable: false),
              ],
              if (topic.relatedTopicIds.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(text: context.loc.grammarTopicRelatedTitle),
                const SizedBox(height: AppSpacing.sm),
                _RelatedRow(topicIds: topic.relatedTopicIds),
              ],
              if (_isContentEmpty(topic)) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.loc.grammarTopicNoContentBody,
                  style: AppTypography.bodySm.copyWith(
                    color: context.clay.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _StartPracticeBar(topic: topic),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, GrammarTopic topic) {
    return AppBar(
      backgroundColor: context.clay.background,
      surfaceTintColor: context.clay.background,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: ClayBackButton(),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            topic.title,
            style: AppTypography.title.copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${topic.level.label} · ${_categoryShort(context, topic.category)}',
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: _LevelChip(level: topic.level),
        ),
      ],
    );
  }

  bool _isContentEmpty(GrammarTopic t) =>
      t.summary.isEmpty &&
      t.useCases.isEmpty &&
      t.examples.isEmpty &&
      t.commonMistakes.isEmpty;
}

String _categoryShort(BuildContext context, GrammarCategory cat) {
  final loc = context.loc;
  return switch (cat) {
    GrammarCategory.tense => loc.grammarHubCategoryTense,
    GrammarCategory.modal => loc.grammarHubCategoryModal,
    GrammarCategory.conditional => loc.grammarHubCategoryConditional,
    GrammarCategory.passive => loc.grammarHubCategoryPassive,
    GrammarCategory.reported => loc.grammarHubCategoryReported,
    GrammarCategory.articleQuantifier =>
      loc.grammarHubCategoryArticleQuantifier,
    GrammarCategory.clause => loc.grammarHubCategoryClause,
    GrammarCategory.comparison => loc.grammarHubCategoryComparison,
    GrammarCategory.linkingInversion =>
      loc.grammarHubCategoryLinkingInversion,
    GrammarCategory.other => loc.grammarHubCategoryOther,
  };
}

// ── small chrome ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.caption.copyWith(
        color: context.clay.textMuted,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final CefrLevel level;
  const _LevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        level.label,
        style: AppTypography.labelSm.copyWith(
          color: AppColors.warmDark,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.04 * 11,
        ),
      ),
    );
  }
}

// ── summary card ──────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final GrammarTopic topic;
  const _SummaryCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formula chip — monospace-style on the alt surface so it
          // reads as a code block. Sits on top of the regular surface
          // and stays distinct in both light + dark mode.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.clay.surfaceAlt,
              borderRadius: AppRadius.smBorder,
              border: Border.all(
                color: context.clay.shadow,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Text(
              topic.formula,
              style: AppTypography.bodySm.copyWith(
                color: context.clay.text,
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (topic.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              topic.summary,
              style: AppTypography.bodyMd.copyWith(
                color: context.clay.text,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
          if (topic.summaryVi.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              topic.summaryVi,
              style: AppTypography.bodySm.copyWith(
                color: context.clay.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── use cases ─────────────────────────────────────────────────────────

class _UseCasesList extends StatelessWidget {
  final GrammarTopic topic;
  const _UseCasesList({required this.topic});

  @override
  Widget build(BuildContext context) {
    // Pair EN + VI by index when both lists are present and same length.
    // Some topics in Phase A3 have parallel arrays; if the VI list is
    // shorter we fall back to EN-only rendering for the trailing rows.
    final viCases = topic.useCasesVi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < topic.useCases.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: AppSpacing.sm),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.goldDeep,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.useCases[i],
                        style: AppTypography.bodySm.copyWith(
                          color: context.clay.text,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      if (i < viCases.length && viCases[i].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            viCases[i],
                            style: AppTypography.caption.copyWith(
                              color: context.clay.textMuted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── examples ──────────────────────────────────────────────────────────

class _ExampleCard extends StatefulWidget {
  final GrammarExample example;
  const _ExampleCard({required this.example});

  @override
  State<_ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<_ExampleCard> {
  static final _tts = TtsService();

  Future<void> _speak() async {
    await _tts.speakEnglish(widget.example.en);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.example.en,
                  style: AppTypography.bodyMd.copyWith(
                    color: context.clay.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.example.vi,
                  style: AppTypography.caption.copyWith(
                    color: context.clay.textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                if (widget.example.gloss != null &&
                    widget.example.gloss!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.example.gloss!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ListenButton(onTap: _speak),
        ],
      ),
    );
  }
}

class _ListenButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ListenButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.88,
      builder: (context, _) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.goldDeep, width: 1.5),
        ),
        child: Tooltip(
          message: context.loc.grammarTopicListenA11y,
          child: const Icon(
            Icons.volume_up_rounded,
            size: 16,
            color: AppColors.goldDark,
          ),
        ),
      ),
    );
  }
}

// ── common mistakes ───────────────────────────────────────────────────

class _MistakeCard extends StatelessWidget {
  final GrammarMistake mistake;
  const _MistakeCard({required this.mistake});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.close_rounded, color: AppColors.error, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  mistake.wrong,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_rounded, color: AppColors.success, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  mistake.right,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (mistake.why.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              mistake.why,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── related ───────────────────────────────────────────────────────────

class _RelatedRow extends StatelessWidget {
  final List<String> topicIds;
  const _RelatedRow({required this.topicIds});

  @override
  Widget build(BuildContext context) {
    final related = topicIds
        .map(GrammarCatalog.maybeById)
        .whereType<GrammarTopic>()
        .toList(growable: false);
    if (related.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: related.map((t) => _RelatedChip(topic: t)).toList(),
    );
  }
}

class _RelatedChip extends StatelessWidget {
  final GrammarTopic topic;
  const _RelatedChip({required this.topic});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: () => context.push('/grammar/${topic.id}'),
      scaleDown: 0.95,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(color: context.clay.border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_outward_rounded,
              size: 12,
              color: AppColors.goldDeep,
            ),
            const SizedBox(width: 4),
            Text(
              topic.title,
              style: AppTypography.caption.copyWith(
                color: context.clay.text,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── start practice CTA + mode picker ──────────────────────────────────

class _StartPracticeBar extends StatelessWidget {
  final GrammarTopic topic;
  const _StartPracticeBar({required this.topic});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.smd,
      ),
      child: ClayButton(
        text: context.loc.grammarStartPracticeCta,
        variant: ClayButtonVariant.accentGold,
        onTap: () => _showModePicker(context, topic),
      ),
    );
  }
}

Future<void> _showModePicker(
  BuildContext context,
  GrammarTopic topic,
) async {
  final picked = await showModalBottomSheet<GrammarPracticeMode>(
    context: context,
    backgroundColor: context.clay.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _PracticeModePickerSheet(),
  );
  if (picked == null || !context.mounted) return;
  context.push('/grammar/${topic.id}/practice?mode=${picked.id}');
}

class _PracticeModePickerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.smd,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle.
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.clay.shadow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            loc.grammarPracticePickerTitle,
            style: AppTypography.title.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            loc.grammarPracticePickerSubtitle,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ModeCard(
            mode: GrammarPracticeMode.translate,
            icon: Icons.translate_rounded,
            label: loc.grammarPracticeModeTranslate,
            subtitle: loc.grammarPracticeModeTranslateSub,
            featured: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ModeCard(
            mode: GrammarPracticeMode.fillBlank,
            icon: Icons.edit_rounded,
            label: loc.grammarPracticeModeFillBlank,
            subtitle: loc.grammarPracticeModeFillBlankSub,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ModeCard(
            mode: GrammarPracticeMode.transform,
            icon: Icons.swap_horiz_rounded,
            label: loc.grammarPracticeModeTransform,
            subtitle: loc.grammarPracticeModeTransformSub,
          ),
          const SizedBox(height: AppSpacing.md),
          ClayButton(
            text: loc.commonCancel,
            variant: ClayButtonVariant.ghost,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final GrammarPracticeMode mode;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool featured;

  const _ModeCard({
    required this.mode,
    required this.icon,
    required this.label,
    required this.subtitle,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use clay surface for the card in both light & dark mode so body
    // text always reads cleanly. The "featured" affordance is carried
    // by the gold border + gold drop-shadow + gold-tinted icon tile —
    // we no longer wash a translucent gold tint over the entire card,
    // which previously crushed contrast on the subtitle in dark mode.
    return ClayPressable(
      onTap: () => Navigator.of(context).pop(mode),
      scaleDown: 0.97,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: featured ? AppColors.goldDeep : context.clay.border,
            width: featured ? 2 : 1.5,
          ),
          boxShadow: featured
              ? [const BoxShadow(color: AppColors.goldDeep, offset: Offset(2, 2))]
              : AppShadows.card(context),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.24),
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: AppColors.goldDeep.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 22, color: AppColors.goldDark),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLg.copyWith(
                      color: context.clay.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: context.clay.textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: context.clay.textFaint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── not-found state ───────────────────────────────────────────────────

class _NotFoundState extends StatelessWidget {
  final String topicId;
  const _NotFoundState({required this.topicId});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.find_in_page_rounded,
                size: 56,
                color: context.clay.textFaint,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                loc.grammarTopicNotFoundTitle,
                style: AppTypography.title.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                loc.grammarTopicNotFoundBody,
                style: AppTypography.bodySm.copyWith(
                  color: context.clay.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'id: $topicId',
                style: AppTypography.caption.copyWith(
                  color: context.clay.textFaint,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
