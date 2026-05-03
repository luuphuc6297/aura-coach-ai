import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../providers/compare_words_provider.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Compare Words sub-screen. The learner enters two words and gets a
/// side-by-side nuance breakdown from Gemini — register, connotation,
/// definition, collocations, example, plus a shared "key difference"
/// paragraph and per-word "when to use" guidance. Available on all tiers.
class CompareWordsScreen extends StatefulWidget {
  const CompareWordsScreen({super.key});

  @override
  State<CompareWordsScreen> createState() => _CompareWordsScreenState();
}

class _CompareWordsScreenState extends State<CompareWordsScreen> {
  final TextEditingController _wordA = TextEditingController();
  final TextEditingController _wordB = TextEditingController();

  @override
  void dispose() {
    _wordA.dispose();
    _wordB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VocabHubScaffold(
      title: context.loc.vocabCompareTitle,
      body: _CompareBody(wordA: _wordA, wordB: _wordB),
    );
  }
}

class _CompareBody extends StatelessWidget {
  final TextEditingController wordA;
  final TextEditingController wordB;

  const _CompareBody({required this.wordA, required this.wordB});

  void _onCompare(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<CompareWordsProvider>().compare(
          wordA: wordA.text,
          wordB: wordB.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompareWordsProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pick two words to compare',
            style: AppTypography.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: context.clay.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _WordField(
                  controller: wordA,
                  hint: 'Word A',
                  onSubmitted: () => _onCompare(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  color: AppColors.coral,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _WordField(
                  controller: wordB,
                  hint: 'Word B',
                  onSubmitted: () => _onCompare(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClayButton(
            text: provider.loading ? 'Comparing…' : 'Compare',
            variant: ClayButtonVariant.accentCoral,
            isLoading: provider.loading,
            onTap: provider.loading ? null : () => _onCompare(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (provider.error != null)
            Text(
              provider.error!,
              style: AppTypography.bodySm.copyWith(color: AppColors.coral),
            ),
          if (provider.result != null) _ResultBlock(result: provider.result!),
          if (provider.result == null &&
              provider.error == null &&
              !provider.loading)
            _EmptyHint(),
        ],
      ),
    );
  }
}

class _WordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmitted;

  const _WordField({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ClayTextInput(
      controller: controller,
      hintText: hint,
      accentColor: AppColors.coral,
      textStyle: AppTypography.bodyMd,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.loc.vocabCompareTryAPair, style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            'affect / effect · big / huge · tell / say · remember / remind',
            style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  final WordComparison result;
  const _ResultBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // IntrinsicHeight is required: the parent SingleChildScrollView gives
        // unbounded vertical constraints, and Row.crossAxisAlignment.stretch
        // would otherwise pass `h=Infinity` down to each ClayCard column,
        // tripping the "BoxConstraints forces an infinite height" assertion.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ComparisonColumn(
                  entry: result.wordA,
                  headerColor: AppColors.teal,
                  label: context.loc.vocabCompareWordA,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ComparisonColumn(
                  entry: result.wordB,
                  headerColor: AppColors.purple,
                  label: context.loc.vocabCompareWordB,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _KeyDifferenceCard(
          keyDifference: result.keyDifference,
          whenToUseA: result.whenToUseA,
          whenToUseB: result.whenToUseB,
          wordA: result.wordA.word,
          wordB: result.wordB.word,
        ),
      ],
    );
  }
}

class _ComparisonColumn extends StatelessWidget {
  final ComparisonEntry entry;
  final Color headerColor;
  final String label;

  const _ComparisonColumn({
    required this.entry,
    required this.headerColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ColumnHeader(
            word: entry.word,
            label: label,
            color: headerColor,
          ),
          if (entry.phonetic.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              entry.phonetic,
              style: AppTypography.caption.copyWith(
                color: context.clay.textFaint,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          if (entry.translation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              entry.translation,
              style: AppTypography.bodySm.copyWith(color: context.clay.text),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _MiniTag(
                label: entry.partOfSpeech,
                color: context.clay.textMuted,
              ),
              _MiniTag(
                label: entry.register,
                color: _registerColor(context, entry.register),
              ),
              _MiniTag(
                label: entry.connotation,
                color: _connotationColor(entry.connotation),
              ),
            ],
          ),
          const Divider(height: 20),
          _SectionLabel(text: context.loc.vocabCompareSectionDefinition),
          const SizedBox(height: 2),
          Text(
            entry.definition,
            style: AppTypography.bodySm.copyWith(color: context.clay.text),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionLabel(text: context.loc.vocabCompareSectionExample),
          const SizedBox(height: 4),
          _ExampleTile(example: entry.example, color: headerColor),
          if (entry.collocations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _SectionLabel(text: context.loc.vocabCompareSectionCollocations),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: entry.collocations
                  .map((c) => _CollocationChip(label: c))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  static Color _registerColor(BuildContext context, String register) {
    switch (register.toLowerCase()) {
      case 'formal':
        return AppColors.purple;
      case 'casual':
        return AppColors.coral;
      case 'neutral':
      default:
        return context.clay.textMuted;
    }
  }

  static Color _connotationColor(String connotation) {
    switch (connotation.toLowerCase()) {
      case 'positive':
        return AppColors.success;
      case 'negative':
        return AppColors.error;
      case 'neutral':
      default:
        return AppColors.gold;
    }
  }
}

class _ColumnHeader extends StatelessWidget {
  final String word;
  final String label;
  final Color color;

  const _ColumnHeader({
    required this.word,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                word,
                style: AppTypography.h3.copyWith(color: context.clay.text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _ListenIconButton(text: word, color: color),
          ],
        ),
      ],
    );
  }
}

class _ListenIconButton extends StatelessWidget {
  final String text;
  final Color color;
  const _ListenIconButton({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Semantics(
      button: true,
      label: 'Listen to $text',
      child: InkWell(
        onTap: () => TtsService().speakEnglish(text),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.volume_up_rounded, size: 18, color: color),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.caption.copyWith(
          color: context.clay.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      );
}

class _ExampleTile extends StatelessWidget {
  final EnVnExample example;
  final Color color;

  const _ExampleTile({required this.example, required this.color});

  @override
  Widget build(BuildContext context) {
    if (example.en.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  example.en,
                  style: AppTypography.bodySm.copyWith(
                    color: context.clay.text,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              _ListenIconButton(text: example.en, color: color),
            ],
          ),
          if (example.vn.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              example.vn,
              style: AppTypography.caption.copyWith(color: context.clay.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _CollocationChip extends StatelessWidget {
  final String label;
  const _CollocationChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.clay.border, width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: context.clay.text,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _KeyDifferenceCard extends StatelessWidget {
  final String keyDifference;
  final String whenToUseA;
  final String whenToUseB;
  final String wordA;
  final String wordB;

  const _KeyDifferenceCard({
    required this.keyDifference,
    required this.whenToUseA,
    required this.whenToUseB,
    required this.wordA,
    required this.wordB,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: AppColors.coral,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(context.loc.vocabCompareKeyDifference, style: AppTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            keyDifference,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.text,
              height: 1.5,
            ),
          ),
          const Divider(height: 24),
          _UsageLine(
            label: context.loc.vocabCompareWhenToUse(wordA),
            sentence: whenToUseA,
            color: AppColors.teal,
          ),
          const SizedBox(height: 8),
          _UsageLine(
            label: context.loc.vocabCompareWhenToUse(wordB),
            sentence: whenToUseB,
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class _UsageLine extends StatelessWidget {
  final String label;
  final String sentence;
  final Color color;

  const _UsageLine({
    required this.label,
    required this.sentence,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (sentence.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySm.copyWith(color: context.clay.text),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: sentence),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
