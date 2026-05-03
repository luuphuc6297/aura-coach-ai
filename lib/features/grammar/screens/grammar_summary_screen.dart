import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../my_library/models/saved_item.dart';
import '../../my_library/providers/library_provider.dart';
import '../data/grammar_catalog.dart';
import '../models/grammar_exercise.dart';
import '../models/grammar_session.dart';
import '../models/grammar_topic.dart';
import '../providers/grammar_provider.dart';

/// Grammar Coach session summary. Reads the just-closed
/// [GrammarProvider.activeSession] + cached [GrammarProvider.sessionAttempts]
/// to render: headline, four stat tiles (attempts / accuracy / duration /
/// mastery delta), recent-mistakes list, and three CTAs (Practice again,
/// Back to topic, Back to all topics).
///
/// Edge cases:
/// - If the user lands here directly via deep link with no active session
///   (cold-restart scenario), we show an empty state pointing back to Hub
///   so the screen never crashes from a null session.
/// - Save-mistakes saves each wrong attempt as a `grammar` SavedItem so
///   they show up under the Library "Grammar" filter chip.
class GrammarSummaryScreen extends StatelessWidget {
  final String topicId;

  const GrammarSummaryScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    final grammar = context.watch<GrammarProvider>();
    final topic = GrammarCatalog.maybeById(topicId);
    final session = grammar.activeSession;
    final loc = context.loc;

    if (topic == null || session == null) {
      return _MissingSessionState(topicId: topicId);
    }

    final mistakes = grammar.sessionMistakes;

    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
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
              loc.grammarSummaryTitle,
              style: AppTypography.title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              topic.title,
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
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            _Headline(session: session),
            const SizedBox(height: AppSpacing.lg),
            _StatGrid(session: session),
            const SizedBox(height: AppSpacing.lg),
            _MistakesSection(
              mistakes: mistakes,
              onSaveAll: mistakes.isEmpty
                  ? null
                  : () => _onSaveAllMistakes(context, topic, mistakes),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CtaColumn(topic: topic, session: session),
          ],
        ),
      ),
    );
  }

  Future<void> _onSaveAllMistakes(
    BuildContext context,
    GrammarTopic topic,
    List<GrammarPracticeAttempt> mistakes,
  ) async {
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final loc = context.loc;
    const uuid = Uuid();

    for (final attempt in mistakes) {
      await library.addItem(SavedItem(
        id: uuid.v4(),
        original: attempt.userAnswer,
        correction: attempt.correctAnswer,
        type: 'grammar',
        context: '${topic.title} · ${attempt.prompt}',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        explanation: attempt.feedback,
        sourceTag: 'grammar:${topic.id}',
      ));
    }

    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(loc.grammarSummarySaveAllSnack(mistakes.length)),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.gold,
      ),
    );
  }
}

// ── headline ───────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  final GrammarSession session;
  const _Headline({required this.session});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final accuracy = session.accuracy;
    final attempts = session.attemptCount;

    final String headline;
    final Color accent;
    final IconData icon;
    if (attempts == 0) {
      headline = loc.grammarSummaryHeadlineEmpty;
      accent = context.clay.textMuted;
      icon = Icons.info_outline_rounded;
    } else if (accuracy >= 0.8) {
      headline = loc.grammarSummaryHeadlineMastered;
      accent = AppColors.success;
      icon = Icons.emoji_events_rounded;
    } else if (accuracy >= 0.5) {
      headline = loc.grammarSummaryHeadlineProgress;
      accent = AppColors.goldDark;
      icon = Icons.trending_up_rounded;
    } else {
      headline = loc.grammarSummaryHeadlineRough;
      accent = AppColors.error;
      icon = Icons.fitness_center_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.warmDark, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.warmDark, offset: Offset(3, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              headline,
              style: AppTypography.title.copyWith(
                color: context.clay.text,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── stats grid ─────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  final GrammarSession session;
  const _StatGrid({required this.session});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final accuracyPct = session.attemptCount == 0
        ? 0
        : (session.accuracy * 100).round();
    final delta = session.masteryDelta ?? 0.0;
    final deltaPct = (delta * 100).round();
    final deltaSign = deltaPct > 0 ? '+' : (deltaPct < 0 ? '−' : '±');
    final deltaAbs = deltaPct.abs().toString();
    final Color deltaColor = deltaPct > 0
        ? AppColors.success
        : (deltaPct < 0 ? AppColors.error : context.clay.textMuted);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: loc.grammarSummaryStatAttempts,
                value: '${session.attemptCount}',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: loc.grammarSummaryStatAccuracy,
                value: '$accuracyPct%',
                valueColor: accuracyPct >= 70
                    ? AppColors.success
                    : (accuracyPct >= 40
                        ? AppColors.goldDark
                        : AppColors.error),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: loc.grammarSummaryStatDuration,
                value: _formatDuration(context, session.duration),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: loc.grammarSummaryStatMastery,
                value: loc.grammarSummaryMasteryDelta(deltaSign, deltaAbs),
                valueColor: deltaColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(BuildContext context, Duration d) {
    final loc = context.loc;
    final totalSeconds = d.inSeconds.clamp(0, 3600 * 24);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) return loc.grammarSummaryDurationSeconds(seconds);
    return loc.grammarSummaryDurationMinutes(minutes, seconds);
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: valueColor ?? context.clay.text,
              fontSize: 22,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── mistakes section ───────────────────────────────────────────────────

class _MistakesSection extends StatelessWidget {
  final List<GrammarPracticeAttempt> mistakes;
  final Future<void> Function()? onSaveAll;

  const _MistakesSection({required this.mistakes, this.onSaveAll});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loc.grammarSummaryMistakesTitle,
                style: AppTypography.title.copyWith(
                  color: context.clay.text,
                  fontSize: 14,
                ),
              ),
            ),
            if (onSaveAll != null)
              TextButton.icon(
                onPressed: onSaveAll,
                icon: const Icon(
                  Icons.bookmark_add_rounded,
                  size: 18,
                  color: AppColors.goldDark,
                ),
                label: Text(
                  loc.grammarSummarySaveAllMistakes,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (mistakes.isEmpty)
          _EmptyMistakesPanel()
        else
          for (final m in mistakes) _MistakeRow(attempt: m),
      ],
    );
  }
}

class _EmptyMistakesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded,
              color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.loc.grammarSummaryMistakesEmpty,
              style: AppTypography.bodySm.copyWith(
                color: context.clay.text,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeRow extends StatelessWidget {
  final GrammarPracticeAttempt attempt;
  const _MistakeRow({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attempt.prompt,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _AnswerRow(
            label: loc.grammarSummaryMistakeYou,
            value: attempt.userAnswer,
            color: AppColors.error,
          ),
          const SizedBox(height: 4),
          _AnswerRow(
            label: loc.grammarSummaryMistakeCorrect,
            value: attempt.correctAnswer,
            color: AppColors.success,
          ),
          if (attempt.feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              attempt.feedback,
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

class _AnswerRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnswerRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ── CTAs ───────────────────────────────────────────────────────────────

class _CtaColumn extends StatelessWidget {
  final GrammarTopic topic;
  final GrammarSession session;

  const _CtaColumn({required this.topic, required this.session});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClayButton(
          text: loc.grammarSummaryPracticeAgain,
          variant: ClayButtonVariant.accentGold,
          onTap: () {
            // Clear the closed session so /practice mounts a fresh one,
            // then push (replacing summary) to the practice route with
            // the same mode the user just finished.
            context.read<GrammarProvider>().clearSession();
            context.pushReplacement(
              '/grammar/${topic.id}/practice?mode=${session.mode.id}',
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        ClayButton(
          text: loc.grammarSummaryBackToTopic,
          variant: ClayButtonVariant.secondary,
          onTap: () {
            context.read<GrammarProvider>().clearSession();
            context.go('/grammar/${topic.id}');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () {
            context.read<GrammarProvider>().clearSession();
            context.go('/grammar');
          },
          child: Text(
            loc.grammarSummaryBackToHub,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ── empty / cold-start fallback ────────────────────────────────────────

class _MissingSessionState extends StatelessWidget {
  final String topicId;
  const _MissingSessionState({required this.topicId});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
        title: Text(
          loc.grammarSummaryTitle,
          style: AppTypography.title.copyWith(fontSize: 18),
        ),
        titleSpacing: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 56,
                color: context.clay.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                loc.grammarSummaryHeadlineEmpty,
                style: AppTypography.title.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ClayButton(
                text: loc.grammarSummaryBackToTopic,
                variant: ClayButtonVariant.accentGold,
                onTap: () => context.go('/grammar/$topicId'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
