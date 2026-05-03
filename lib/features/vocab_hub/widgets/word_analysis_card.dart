import 'package:flutter/material.dart';

import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../data/gemini/types.dart';
import '../../../shared/widgets/clay_card.dart';
import 'morphology_diagram.dart';

/// Composite card that surfaces every segment of a [WordAnalysis] payload —
/// headword with a Listen pill, phonetics, morphology, three contextual
/// examples (positive / neutral / negative), word-family derivatives,
/// collocations, and green synonym / red antonym chips.
class WordAnalysisCard extends StatelessWidget {
  final WordAnalysis analysis;
  const WordAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            word: analysis.word,
            phonetic: analysis.phonetic,
            partOfSpeech: analysis.partOfSpeech,
          ),
          if (analysis.definition.isNotEmpty) ...[
            const SizedBox(height: 14),
            const _WaLabel('Definition'),
            const SizedBox(height: 4),
            _WaDefinition(text: analysis.definition),
          ],
          if (analysis.translation.isNotEmpty) ...[
            const SizedBox(height: 14),
            const _WaLabel('Nghĩa tiếng Việt'),
            const SizedBox(height: 4),
            _WaDefinition(text: analysis.translation),
          ],
          const Divider(height: 24),
          MorphologyDiagram(morphology: analysis.morphology),
          const Divider(height: 24),
          _ExampleSection(embedding: analysis.contextualEmbedding),
          const Divider(height: 24),
          _DerivativesSection(derivatives: analysis.derivatives),
          if (analysis.synonyms.isNotEmpty ||
              analysis.antonyms.isNotEmpty) ...[
            const Divider(height: 24),
            _SynAntSection(
              synonyms: analysis.synonyms,
              antonyms: analysis.antonyms,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String word;
  final String phonetic;
  final String partOfSpeech;

  const _HeaderRow({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                word,
                style: AppTypography.h2.copyWith(color: context.clay.text),
              ),
            ),
            if (word.isNotEmpty) _ListenPill(text: word, label: 'Listen'),
          ],
        ),
        if (phonetic.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            phonetic,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.coral,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
        if (partOfSpeech.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PosPill(label: partOfSpeech.toLowerCase()),
        ],
      ],
    );
  }
}

/// Uppercase caption above a detail block (Definition, Nghĩa tiếng Việt,
/// Examples, ...). Matches the `.wa-label` style in the Vocab Hub deep-dive
/// mockup — 11px, bold, letter-spacing 0.5, warmMuted.
class _WaLabel extends StatelessWidget {
  final String text;
  const _WaLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.labelSm.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.clay.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _WaDefinition extends StatelessWidget {
  final String text;
  const _WaDefinition({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodyMd.copyWith(
        fontSize: 13,
        color: context.clay.text,
        height: 1.5,
      ),
    );
  }
}

/// Coral POS pill shown below the phonetic on the Word Analysis card.
class _PosPill extends StatelessWidget {
  final String label;
  const _PosPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.labelSm.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ListenPill extends StatelessWidget {
  final String text;
  final String label;

  const _ListenPill({required this.text, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Listen to $text',
      child: InkWell(
        onTap: () => TtsService().speakEnglish(text),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.coral.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.volume_up_rounded,
                size: 16,
                color: AppColors.coral,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  final ContextualEmbedding embedding;
  const _ExampleSection({required this.embedding});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Examples', style: AppTypography.sectionTitle),
          const SizedBox(height: 8),
          _ExampleTile(
            label: 'Positive',
            example: embedding.positiveExample,
            color: AppColors.teal,
          ),
          const SizedBox(height: 8),
          _ExampleTile(
            label: 'Neutral',
            example: embedding.neutralExample,
            color: AppColors.gold,
          ),
          const SizedBox(height: 8),
          _ExampleTile(
            label: 'Negative',
            example: embedding.negativeExample,
            color: AppColors.coral,
          ),
          if (embedding.collocations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Collocations', style: AppTypography.sectionTitle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: embedding.collocations
                  .map((c) => _OutlinedChip(
                        label: c,
                        color: context.clay.textMuted,
                      ))
                  .toList(),
            ),
          ],
        ],
      );
}

class _ExampleTile extends StatelessWidget {
  final String label;
  final EnVnExample example;
  final Color color;

  const _ExampleTile({
    required this.label,
    required this.example,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (example.en.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _TileListenButton(text: example.en, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            example.en,
            style: AppTypography.bodyMd.copyWith(color: context.clay.text),
          ),
          if (example.vn.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              example.vn,
              style: AppTypography.bodySm.copyWith(color: context.clay.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _TileListenButton extends StatelessWidget {
  final String text;
  final Color color;

  const _TileListenButton({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Listen to example',
      child: InkWell(
        onTap: () => TtsService().speakEnglish(text),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.volume_up_rounded,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _DerivativesSection extends StatelessWidget {
  final Derivatives derivatives;
  const _DerivativesSection({required this.derivatives});

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String?)>[
      ('Noun', derivatives.noun),
      ('Verb', derivatives.verb),
      ('Adjective', derivatives.adjective),
      ('Adverb', derivatives.adverb),
    ].where((e) => e.$2 != null && e.$2!.isNotEmpty).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Word family', style: AppTypography.sectionTitle),
        const SizedBox(height: 8),
        ...entries.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(
                  color: context.clay.text,
                ),
                children: [
                  TextSpan(
                    text: '${e.$1}: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: e.$2!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SynAntSection extends StatelessWidget {
  final List<String> synonyms;
  final List<String> antonyms;
  const _SynAntSection({required this.synonyms, required this.antonyms});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (synonyms.isNotEmpty)
            _ChipListBlock(
              title: 'Synonyms',
              items: synonyms,
              // Green = success = synonym (matches "close in meaning").
              color: AppColors.success,
              dotSymbol: '≈',
            ),
          if (synonyms.isNotEmpty && antonyms.isNotEmpty)
            const SizedBox(height: 12),
          if (antonyms.isNotEmpty)
            _ChipListBlock(
              title: 'Antonyms',
              items: antonyms,
              // Red = error = antonym (matches "opposite in meaning").
              color: AppColors.error,
              dotSymbol: '≠',
            ),
        ],
      );
}

class _ChipListBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final String dotSymbol;

  const _ChipListBlock({
    required this.title,
    required this.items,
    required this.color,
    required this.dotSymbol,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.sectionTitle.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map((s) => _FilledChip(
                      label: s,
                      prefix: dotSymbol,
                      color: color,
                    ))
                .toList(),
          ),
        ],
      );
}

class _FilledChip extends StatelessWidget {
  final String label;
  final String prefix;
  final Color color;

  const _FilledChip({
    required this.label,
    required this.prefix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prefix,
            style: AppTypography.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: context.clay.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedChip extends StatelessWidget {
  final String label;
  final Color color;

  const _OutlinedChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.clay.border, width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(color: color),
      ),
    );
  }
}
