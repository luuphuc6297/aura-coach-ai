import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/topic_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/topic_chip.dart';
import '../../home/providers/home_provider.dart';
import '../flashcards/flashcard_view.dart';
import '../flashcards/flashcards_provider.dart';
import '../flashcards/rating_bar.dart';

/// Flashcards deep-dive tab. Loads today's SM-2 due queue on mount, then
/// renders: empty state → card + rating bar → done state. A "Study 10 more"
/// action appends a practice batch for over-learners.
class FlashcardsTab extends StatefulWidget {
  const FlashcardsTab({super.key});

  @override
  State<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FlashcardsProvider>().loadDueToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardsProvider>();

    if (provider.queue.isEmpty) {
      return _EmptyState(onStartPractice: provider.addPracticeBatch);
    }
    if (!provider.hasMore) {
      return _DoneState(onStudyMore: provider.addPracticeBatch);
    }

    final card = provider.currentCard!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _ProgressBar(
            index: provider.currentIndex,
            total: provider.queue.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: Center(child: FlashcardView(item: card))),
          const SizedBox(height: AppSpacing.lg),
          RatingBar(
            onRate: provider.rate,
            currentInterval: card.interval,
            currentEase: card.easeFactor,
            reviewCount: card.reviewCount,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int index;
  final int total;
  const _ProgressBar({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    final safeTotal = total == 0 ? 1 : total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Card ${index + 1} of $total',
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (index + 1) / safeTotal,
            minHeight: 6,
            backgroundColor: context.clay.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.coral),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStartPractice;
  const _EmptyState({required this.onStartPractice});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.style_outlined,
              size: 48,
              color: context.clay.textFaint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No cards due today',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Practice 10 random saved words — or grow your deck with AI-picked cards for the topics you chose during onboarding.',
              style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 220,
              child: ClayButton(
                text: context.loc.vocabFlashcardsPracticeCta,
                variant: ClayButtonVariant.accentCoral,
                onTap: onStartPractice,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _TopicSuggestionsSection(),
          ],
        ),
      );
}

class _DoneState extends StatelessWidget {
  final VoidCallback onStudyMore;
  const _DoneState({required this.onStudyMore});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.teal,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Done for today!',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nicely done. Come back tomorrow — or extend the streak with a fresh topic pack below.',
              style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 220,
              child: ClayButton(
                text: context.loc.vocabFlashcardsStudyMoreCta,
                variant: ClayButtonVariant.accentCoral,
                onTap: onStudyMore,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _TopicSuggestionsSection(),
          ],
        ),
      );
}

/// Suggests AI-generated vocabulary packs for the topics the learner picked
/// during onboarding. Each chip triggers a Gemini call that persists 4–12
/// fresh words to the library and appends them to the practice queue, so the
/// user goes straight from "tap topic" to reviewing new cards.
class _TopicSuggestionsSection extends StatelessWidget {
  const _TopicSuggestionsSection();

  @override
  Widget build(BuildContext context) {
    final profile =
        context.select<HomeProvider, UserProfile?>((p) => p.userProfile);
    if (profile == null) return const SizedBox.shrink();

    final selectedIds = profile.selectedTopics;
    if (selectedIds.isEmpty) return const SizedBox.shrink();

    final topics = <TopicOption>[
      for (final id in selectedIds)
        topicOptions.firstWhere(
          (t) => t.id == id,
          orElse: () => TopicOption(
            id: id,
            label: _prettifyId(id),
            iconId: 'topic_dailyLife',
            color: AppColors.coral,
          ),
        ),
    ];

    final level = CefrLevel.fromProficiencyId(profile.proficiencyLevel);
    final provider = context.watch<FlashcardsProvider>();
    final activeTopicId = provider.suggestingTopicId;
    final error = provider.suggestionError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Suggested packs for you',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.clay.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tap a topic to add ${FlashcardsProvider.topicSuggestionCount} AI-picked words to your library.',
          style: AppTypography.caption.copyWith(color: context.clay.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.smd,
          runSpacing: AppSpacing.smd,
          alignment: WrapAlignment.center,
          children: [
            for (final topic in topics)
              TopicChip(
                topic: topic,
                isLoading: activeTopicId == topic.id,
                isDisabled: activeTopicId != null && activeTopicId != topic.id,
                onTap: () => _handleTap(context, topic, level),
              ),
          ],
        ),
        if (activeTopicId != null) ...[
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: context.clay.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coral),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Generating new cards… this can take a few seconds.',
            style: AppTypography.caption.copyWith(color: context.clay.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            style: AppTypography.caption.copyWith(color: AppColors.coral),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: () {
                context.read<FlashcardsProvider>().clearSuggestionError();
              },
              icon: const Icon(Icons.refresh, size: 18, color: AppColors.coral),
              label: Text(
                'Dismiss',
                style: AppTypography.labelMd.copyWith(color: AppColors.coral),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _prettifyId(String id) => id
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  Future<void> _handleTap(
    BuildContext context,
    TopicOption topic,
    CefrLevel level,
  ) async {
    final provider = context.read<FlashcardsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final added = await provider.loadTopicSuggestions(
      topicId: topic.id,
      topicLabel: topic.label,
      level: level,
    );
    if (!context.mounted) return;
    if (added > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.loc.vocabFlashcardsAddedSnack(added, topic.label)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (provider.suggestionError == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.loc.vocabFlashcardsAlreadyHaveSnack(topic.label)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

