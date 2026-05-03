import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../../my_library/models/saved_item.dart';
import '../../my_library/providers/library_provider.dart';
import '../widgets/word_analysis_card.dart';

/// Word Analysis deep-dive tab. Accepts a word, calls
/// [GeminiService.generateWordAnalysis], and renders the morphological +
/// contextual breakdown via [WordAnalysisCard].
class WordAnalysisTab extends StatefulWidget {
  const WordAnalysisTab({super.key});

  @override
  State<WordAnalysisTab> createState() => _WordAnalysisTabState();
}

class _WordAnalysisTabState extends State<WordAnalysisTab> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  WordAnalysis? _result;
  String? _savedWord;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _savedWord = null;
    });
    try {
      final gemini = context.read<GeminiService>();
      // Bumped from 30s → 60s to clear the underlying 45s server-side
      // timeout + the 1s retry backoff. The previous 30s racing against
      // 45s caused spurious "Analysis failed" errors on cold-start
      // requests where Gemini took 25-35s to respond.
      final result = await gemini
          .generateWordAnalysis(word: word)
          .timeout(const Duration(seconds: 60));
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      // Surface the real error so we don't lie to the user. Truncate
      // long stack traces — the developer can still see the full thing
      // in `flutter logs`.
      final raw = e.toString();
      final concise =
          raw.length > 140 ? '${raw.substring(0, 140)}…' : raw;
      setState(() => _error = 'Analysis failed: $concise');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final result = _result;
    if (result == null || result.word.isEmpty) return;
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final word = result.word;

    final examples = <Map<String, String>>[
      {
        'en': result.contextualEmbedding.positiveExample.en,
        'vn': result.contextualEmbedding.positiveExample.vn,
      },
      {
        'en': result.contextualEmbedding.neutralExample.en,
        'vn': result.contextualEmbedding.neutralExample.vn,
      },
      {
        'en': result.contextualEmbedding.negativeExample.en,
        'vn': result.contextualEmbedding.negativeExample.vn,
      },
    ].where((e) => (e['en'] ?? '').isNotEmpty).toList();

    final tomorrow = DateTime.now()
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch
        .toDouble();
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = SavedItem(
      id: 'wa-${word.toLowerCase()}-$now',
      original: word,
      correction: word,
      type: 'vocabulary',
      context: result.definition,
      timestamp: now,
      explanation: result.translation,
      examples: examples.isEmpty ? null : examples,
      partOfSpeech: result.partOfSpeech,
      pronunciation: result.phonetic,
      synonyms: result.synonyms.isEmpty ? null : result.synonyms,
      nextReviewDate: tomorrow,
      interval: 1,
      sourceTag: 'vocab-hub:analysis',
    );

    await library.addItem(item);
    if (!mounted) return;
    setState(() => _savedWord = word);
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.loc.vocabWordSavedSnack(word)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMindMap() {
    final result = _result;
    final word = result?.word.trim();
    if (word == null || word.isEmpty) {
      context.push('/vocab-hub/mind-map');
      return;
    }
    final encoded = Uri.encodeQueryComponent(word);
    context.push('/vocab-hub/mind-map?seed=$encoded');
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final isSaved = result != null && _savedWord == result.word;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClayTextInput(
                  controller: _controller,
                  hintText: context.loc.vocabWordAnalysisHint,
                  prefixIcon: Icons.search_rounded,
                  accentColor: AppColors.coral,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _analyze(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ClayButton(
                text: context.loc.vocabWordAnalyzeCta,
                variant: ClayButtonVariant.accentCoral,
                isLoading: _loading,
                isFullWidth: false,
                onTap: _loading ? null : _analyze,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null)
            Text(
              _error!,
              style: AppTypography.bodySm.copyWith(color: AppColors.coral),
            ),
          if (result != null) ...[
            WordAnalysisCard(analysis: result),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ClayButton(
                    text: context.loc.vocabMindMapMindMapCta,
                    variant: ClayButtonVariant.secondary,
                    onTap: _openMindMap,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClayButton(
                    text: isSaved ? '✓ Saved' : '💾 Save',
                    variant: ClayButtonVariant.accentCoral,
                    onTap: isSaved ? null : _save,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
