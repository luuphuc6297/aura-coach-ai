import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_dialog.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../../home/providers/home_provider.dart';
import '../../my_library/models/saved_item.dart';
import '../../my_library/providers/library_provider.dart';
import '../data/grammar_catalog.dart';
import '../models/grammar_exercise.dart';
import '../models/grammar_topic.dart';
import '../providers/grammar_provider.dart';
import '../services/grammar_gemini_service.dart' show GrammarEvaluation;

/// Practice loop screen. Reads `topicId` + `mode` from the route, kicks
/// off [GrammarProvider.startSession] on mount, and renders one of three
/// states:
///
/// 1. **Generating** — spinner + "Building your next exercise…" while
///    Gemini composes the next prompt.
/// 2. **Awaiting answer** — prompt card + input shell + Check button.
/// 3. **Showing result** — same prompt up top, result card overlaid with
///    feedback + Save / Next CTAs.
///
/// Open-ended session per spec (no auto-end after N exercises). User
/// taps "End session" to wrap up; provider closes the session and the
/// caller routes to the summary screen (Phase F).
class GrammarPracticeScreen extends StatefulWidget {
  final String topicId;
  final GrammarPracticeMode mode;

  const GrammarPracticeScreen({
    super.key,
    required this.topicId,
    required this.mode,
  });

  @override
  State<GrammarPracticeScreen> createState() => _GrammarPracticeScreenState();
}

class _GrammarPracticeScreenState extends State<GrammarPracticeScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocus = FocusNode();
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    // Defer session start to first frame so Provider.read works inside
    // a State init.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_sessionStarted) return;
      _sessionStarted = true;
      if (!mounted) return;
      final grammar = context.read<GrammarProvider>();
      // Deep-link safety: configure before startSession in case user
      // arrived via notification/AI-agent without passing through Hub.
      final profile = context.read<HomeProvider>().userProfile;
      if (profile != null) {
        grammar.configure(
          uid: profile.uid,
          userLevel: CefrLevelLabel.fromProficiencyId(profile.proficiencyLevel),
        );
      }
      await grammar.startSession(topicId: widget.topicId, mode: widget.mode);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;
    final grammar = context.read<GrammarProvider>();
    await grammar.submitAnswer(text);
    // Keep input populated for the user to compare against the result
    // card; clear on Next tap.
  }

  Future<void> _onNext() async {
    _answerController.clear();
    _answerFocus.requestFocus();
    final grammar = context.read<GrammarProvider>();
    await grammar.nextExercise();
  }

  Future<void> _onSaveToLibrary(GrammarTopic topic) async {
    final grammar = context.read<GrammarProvider>();
    final attempt = grammar.lastAttempt;
    if (attempt == null) return;
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // Save the corrected form (or the canonical correct answer if the
    // evaluator didn't return a `correctedAnswer`). We persist as a
    // `grammar` Library item so the existing filter chips pick it up.
    await library.addItem(SavedItem(
      id: const Uuid().v4(),
      original: attempt.userAnswer,
      correction: attempt.correctAnswer,
      type: 'grammar',
      context: '${topic.title} · ${attempt.prompt}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      explanation: attempt.feedback,
      sourceTag: 'grammar:${topic.id}',
    ));
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.loc.grammarPracticeSavedSnack),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.gold,
      ),
    );
  }

  Future<void> _confirmAndEnd() async {
    final grammar = context.read<GrammarProvider>();
    final session = grammar.activeSession;
    final loc = context.loc;
    if (session == null || session.attemptCount == 0) {
      // Nothing to summarise — just pop.
      if (mounted) context.pop();
      return;
    }
    final ok = await showClayDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.clay.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: Text(
          loc.grammarPracticeEndConfirmTitle,
          style: AppTypography.title,
        ),
        content: Text(
          loc.grammarPracticeEndConfirmBody,
          style: AppTypography.bodySm.copyWith(
            color: dialogContext.clay.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              loc.grammarPracticeEndKeepGoing,
              style: TextStyle(color: dialogContext.clay.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              loc.grammarPracticeEndConfirm,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await grammar.endSession();
    if (!mounted) return;
    context.pushReplacement(
      '/grammar/${widget.topicId}/practice/summary',
    );
  }

  @override
  Widget build(BuildContext context) {
    final grammar = context.watch<GrammarProvider>();
    final topic = GrammarCatalog.maybeById(widget.topicId);
    if (topic == null) {
      return Scaffold(
        backgroundColor: context.clay.background,
        body: Center(
          child: Text(context.loc.grammarTopicNotFoundTitle),
        ),
      );
    }

    return PopScope(
      canPop: (grammar.activeSession?.attemptCount ?? 0) == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmAndEnd();
      },
      child: Scaffold(
        backgroundColor: context.clay.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _PracticeHeader(
                topic: topic,
                session: grammar.activeSession,
                onBack: _confirmAndEnd,
              ),
              Expanded(
                child: _PracticeBody(
                  topic: topic,
                  grammar: grammar,
                  answerController: _answerController,
                  answerFocus: _answerFocus,
                  onSubmit: _onSubmit,
                  onNext: _onNext,
                  onSaveToLibrary: () => _onSaveToLibrary(topic),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _EndSessionBar(onTap: _confirmAndEnd),
      ),
    );
  }
}

// ── header ──────────────────────────────────────────────────────────────

class _PracticeHeader extends StatelessWidget {
  final GrammarTopic topic;
  final dynamic session; // GrammarSession?, dart's structural typing fine
  final Future<void> Function() onBack;

  const _PracticeHeader({
    required this.topic,
    required this.session,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final attempts = (session?.attemptCount as int?) ?? 0;
    final correct = (session?.correctCount as int?) ?? 0;
    final accuracyPct =
        attempts == 0 ? 0 : ((correct / attempts) * 100).round();
    final streak = _currentStreak(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: context.clay.background,
        border: Border(
          bottom: BorderSide(color: context.clay.border, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClayBackButton(onTap: () => onBack()),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic.title,
                      style: AppTypography.title.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _modeSubtitle(context, session),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: context.clay.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _LevelPill(level: topic.level),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),
          Row(
            children: [
              _StatTile(
                value: '$attempts',
                label: context.loc.grammarPracticeAttemptsLabel,
              ),
              const SizedBox(width: AppSpacing.xs),
              _StatTile(
                value: '$accuracyPct%',
                label: context.loc.grammarPracticeAccuracyLabel,
                valueColor: accuracyPct >= 70
                    ? AppColors.success
                    : (accuracyPct >= 40 ? AppColors.gold : AppColors.error),
              ),
              const SizedBox(width: AppSpacing.xs),
              _StatTile(
                value: '$streak',
                label: context.loc.grammarPracticeStreakLabel,
                valueColor: streak >= 3 ? AppColors.goldDark : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reads provider for the trailing-correct-streak display. Walks
  /// recent attempts via `session.correctCount` heuristic (we don't keep
  /// per-attempt history; for v1 we approximate streak as 0 when last
  /// attempt was wrong, otherwise correctCount). Fine for the header
  /// hint; can be made exact in Phase G via attempt timeline.
  int _currentStreak(BuildContext context) {
    final grammar = context.read<GrammarProvider>();
    final last = grammar.lastEvaluation;
    final session = grammar.activeSession;
    if (last == null || session == null) return 0;
    if (!last.isCorrect) return 0;
    return session.correctCount;
  }

  String _modeSubtitle(BuildContext context, dynamic session) {
    if (session == null) return '';
    final loc = context.loc;
    final mode = session.mode as GrammarPracticeMode;
    switch (mode) {
      case GrammarPracticeMode.translate:
        return loc.grammarPracticeModeTranslate;
      case GrammarPracticeMode.fillBlank:
        return loc.grammarPracticeModeFillBlank;
      case GrammarPracticeMode.transform:
        return loc.grammarPracticeModeTransform;
    }
  }
}

class _LevelPill extends StatelessWidget {
  final CefrLevel level;
  const _LevelPill({required this.level});

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
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatTile({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.smBorder,
          border: Border.all(color: context.clay.border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(
                color: valueColor ?? context.clay.text,
                fontSize: 16,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── body ────────────────────────────────────────────────────────────────

class _PracticeBody extends StatelessWidget {
  final GrammarTopic topic;
  final GrammarProvider grammar;
  final TextEditingController answerController;
  final FocusNode answerFocus;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onNext;
  final Future<void> Function() onSaveToLibrary;

  const _PracticeBody({
    required this.topic,
    required this.grammar,
    required this.answerController,
    required this.answerFocus,
    required this.onSubmit,
    required this.onNext,
    required this.onSaveToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    if (grammar.generationError != null) {
      return _ErrorState(
        message: grammar.generationError!,
        onRetry: () {
          grammar.clearError();
          grammar.nextExercise();
        },
      );
    }
    if (grammar.generatingExercise) {
      return _LoadingState();
    }
    final exercise = grammar.currentExercise;
    if (exercise == null) {
      // Brief blank state during the gap between session start + first
      // exercise. The loading branch above usually catches this.
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PromptCard(exercise: exercise),
          const SizedBox(height: AppSpacing.smd),
          if (grammar.isShowingResult) ...[
            _ReadOnlyAnswer(text: answerController.text),
            const SizedBox(height: AppSpacing.smd),
            _ResultCard(
              evaluation: grammar.lastEvaluation!,
              attempt: grammar.lastAttempt!,
              onSave: onSaveToLibrary,
              onNext: onNext,
            ),
          ] else ...[
            _AnswerInput(
              exercise: exercise,
              controller: answerController,
              focusNode: answerFocus,
              onSubmit: onSubmit,
            ),
            // Multi-choice auto-submits on tap, no Check needed there.
            // Free-text modes still need the explicit confirm button.
            if (!exercise.isMultipleChoice) ...[
              const SizedBox(height: AppSpacing.smd),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: answerController,
                builder: (context, value, _) {
                  final disabled =
                      grammar.evaluating || value.text.trim().isEmpty;
                  return ClayButton(
                    text: context.loc.grammarPracticeCheck,
                    variant: ClayButtonVariant.accentGold,
                    isLoading: grammar.evaluating,
                    onTap: disabled ? null : onSubmit,
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── prompt card ────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  final GrammarExercise exercise;

  const _PromptCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModeTag(exercise: exercise),
          const SizedBox(height: AppSpacing.smd),
          Text(
            exercise.prompt,
            style: AppTypography.bodyMd.copyWith(
              color: context.clay.text,
              fontSize: 17,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (exercise.hint != null && exercise.hint!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _HintBlock(text: exercise.hint!),
          ],
        ],
      ),
    );
  }
}

class _ModeTag extends StatelessWidget {
  final GrammarExercise exercise;
  const _ModeTag({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final label = switch (exercise.mode) {
      GrammarPracticeMode.translate =>
        exercise.direction == GrammarExerciseDirection.viToEn
            ? loc.grammarPracticeModeTagTranslateViEn
            : loc.grammarPracticeModeTagTranslateEnVi,
      GrammarPracticeMode.fillBlank => loc.grammarPracticeModeTagFillBlank,
      GrammarPracticeMode.transform => loc.grammarPracticeModeTagTransform,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.24),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: AppColors.goldDeep, width: 1.5),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.goldDark,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HintBlock extends StatelessWidget {
  final String text;
  const _HintBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: AppColors.goldDeep, width: 3),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${context.loc.grammarPracticeHintLabel.toUpperCase()}  ',
              style: AppTypography.caption.copyWith(
                color: AppColors.goldDark,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: text,
              style: AppTypography.bodySm.copyWith(
                color: context.clay.textMuted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── input ──────────────────────────────────────────────────────────────

class _AnswerInput extends StatelessWidget {
  final GrammarExercise exercise;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function() onSubmit;

  const _AnswerInput({
    required this.exercise,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (exercise.isMultipleChoice) {
      return _MultipleChoice(
        exercise: exercise,
        controller: controller,
        onSubmit: onSubmit,
      );
    }
    final loc = context.loc;
    final hint = switch (exercise.mode) {
      GrammarPracticeMode.translate => loc.grammarPracticeInputHintTranslate,
      GrammarPracticeMode.fillBlank => loc.grammarPracticeInputHintFillBlank,
      GrammarPracticeMode.transform => loc.grammarPracticeInputHintTransform,
    };
    return ClayTextInput(
      controller: controller,
      focusNode: focusNode,
      hintText: hint,
      maxLines: 3,
      onSubmitted: (_) => onSubmit(),
      autofocus: true,
      // Mode-color rule: Grammar = gold accent on focus.
      accentColor: AppColors.goldDeep,
    );
  }
}

class _MultipleChoice extends StatelessWidget {
  final GrammarExercise exercise;
  final TextEditingController controller;
  final Future<void> Function() onSubmit;

  const _MultipleChoice({
    required this.exercise,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final options = exercise.options ?? const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in options)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ClayPressable(
              // Auto-submit on tap — no separate Check step needed for
              // multiple-choice. Stamps the controller so the result
              // card has the user's chosen answer.
              onTap: () {
                controller.text = opt;
                onSubmit();
              },
              builder: (context, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.clay.surface,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: AppColors.goldDeep,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: context.clay.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReadOnlyAnswer extends StatelessWidget {
  final String text;
  const _ReadOnlyAnswer({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(
          color: context.clay.text,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── result card ────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final GrammarEvaluation evaluation;
  final GrammarPracticeAttempt attempt;
  final Future<void> Function() onSave;
  final Future<void> Function() onNext;

  const _ResultCard({
    required this.evaluation,
    required this.attempt,
    required this.onSave,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final isCorrect = evaluation.isCorrect;
    final accent = isCorrect ? AppColors.success : AppColors.error;

    // Subtle styling: neutral surface background, thin colored border,
    // colored icon + title only. Loud full-tinted backgrounds were
    // visually overwhelming once the card grew to include feedback +
    // full sentence + extra example sections.
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: accent, width: 1.5),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isCorrect
                    ? loc.grammarPracticeResultCorrect
                    : loc.grammarPracticeResultIncorrect,
                style: AppTypography.title.copyWith(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!isCorrect) ...[
            _ResultRow(
              label: loc.grammarPracticeResultYourAnswer,
              value: attempt.userAnswer,
              valueColor: AppColors.error,
            ),
            _ResultRow(
              label: loc.grammarPracticeResultCorrectAnswer,
              value: evaluation.correctedAnswer ?? attempt.correctAnswer,
              valueColor: AppColors.success,
            ),
          ] else if (evaluation.matchedAnswer != null &&
              evaluation.matchedAnswer != attempt.userAnswer) ...[
            _ResultRow(
              label: loc.grammarPracticeResultAccepted,
              value: evaluation.matchedAnswer!,
              valueColor: AppColors.success,
            ),
          ],
          if (evaluation.feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.smd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smd,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.clay.surface,
                borderRadius: AppRadius.smBorder,
              ),
              child: Text(
                evaluation.feedback,
                style: AppTypography.bodySm.copyWith(
                  color: context.clay.text,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
          // ── Full corrected sentence (EN + VI) ─────────────────────────
          if (evaluation.correctedSentence != null &&
              evaluation.correctedSentence!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.smd),
            _BilingualBlock(
              label: context.loc.grammarPracticeResultFullSentence,
              en: evaluation.correctedSentence!,
              vi: evaluation.correctedSentenceVi,
              accent: AppColors.success,
            ),
          ],
          // ── Same-pattern example (EN + VI) ────────────────────────────
          if (evaluation.extraExampleEn != null &&
              evaluation.extraExampleEn!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _BilingualBlock(
              label: context.loc.grammarPracticeResultExtraExample,
              en: evaluation.extraExampleEn!,
              vi: evaluation.extraExampleVi,
              accent: AppColors.goldDeep,
            ),
          ],
          const SizedBox(height: AppSpacing.smd),
          // Stacked buttons (vertical) instead of Row to:
          //  (a) eliminate the 9.7px Row overflow we hit when both
          //      Save + Next were Expanded with long Vietnamese labels;
          //  (b) give bigger tap targets — the result card is now busy.
          if (!isCorrect) ...[
            ClayButton(
              text: loc.grammarPracticeSaveToLibrary,
              variant: ClayButtonVariant.secondary,
              onTap: onSave,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          ClayButton(
            text: loc.grammarPracticeNext,
            variant: ClayButtonVariant.accentGold,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

/// Reusable bilingual EN + VI block used in the result card for the
/// full corrected sentence and the extra-example sections. The accent
/// drives the left border so each section is visually distinguishable
/// (success-green for the corrected sentence, gold for the example).
class _BilingualBlock extends StatelessWidget {
  final String label;
  final String en;
  final String? vi;
  final Color accent;

  const _BilingualBlock({
    required this.label,
    required this.en,
    required this.vi,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            en,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (vi != null && vi!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              vi!,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ── loading + error ────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.goldDeep),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.loc.grammarPracticeGenerating,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.loc.grammarPracticeError,
              style: AppTypography.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            ClayButton(
              text: context.loc.grammarPracticeRetry,
              variant: ClayButtonVariant.accentGold,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ── end-session bar ────────────────────────────────────────────────────

class _EndSessionBar extends StatelessWidget {
  final Future<void> Function() onTap;
  const _EndSessionBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.smd,
      ),
      child: ClayButton(
        text: context.loc.grammarPracticeEndSession,
        variant: ClayButtonVariant.ghost,
        onTap: () => onTap(),
      ),
    );
  }
}
