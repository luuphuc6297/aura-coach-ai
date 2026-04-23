import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/end_session_dialog.dart';
import '../../../shared/widgets/message_entrance.dart';
import '../../../shared/widgets/thinking_indicator.dart';
import '../../my_library/models/saved_item.dart';
import '../../my_library/providers/library_provider.dart';
import '../../scenario/models/assessment.dart';
import '../../scenario/widgets/assessment_card.dart';
import '../../scenario/widgets/chat_bubble_ai.dart';
import '../../scenario/widgets/chat_bubble_user.dart';
import '../../scenario/widgets/chat_input_bar.dart';
import '../models/story_session.dart';
import '../models/story_turn.dart';
import '../providers/story_provider.dart';
import '../widgets/story_character_header.dart';

/// Story conversation screen. Renders the running turn list with assessment
/// cards inlined under the user's own turn, not as a separate bubble. Sends
/// new turns through [StoryProvider.sendUserMessage], taps "End" via the
/// header to wrap up and navigate to the summary.
class StoryChatScreen extends StatefulWidget {
  const StoryChatScreen({super.key});

  @override
  State<StoryChatScreen> createState() => _StoryChatScreenState();
}

class _StoryChatScreenState extends State<StoryChatScreen> {
  static final _tts = TtsService();
  final ScrollController _scrollController = ScrollController();
  int _lastTurnCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollIfNew(StorySession session) {
    if (session.turns.length == _lastTurnCount) return;
    _lastTurnCount = session.turns.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _confirmEndAndNavigate(StoryProvider provider) async {
    final session = provider.activeSession;
    if (session == null) return;

    final confirmed = await showEndSessionDialog(
      context: context,
      accentColor: AppColors.purpleDeep,
      stats: _buildStats(provider, session),
      title: 'End this story?',
    );
    if (confirmed != true) return;

    await provider.endSession();
    if (!mounted) return;
    context.push('/story/summary');
  }

  Future<void> _onBackPressed(StoryProvider provider) async {
    final session = provider.activeSession;

    // No active session means nothing to end — just pop back.
    if (session == null) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
      return;
    }

    final confirmed = await showEndSessionDialog(
      context: context,
      accentColor: AppColors.purpleDeep,
      stats: _buildStats(provider, session),
      title: 'End this story?',
    );
    if (!mounted) return;

    if (confirmed == true) {
      await provider.endSession();
      if (!mounted) return;
      context.push('/story/summary');
    } else {
      // Learner chose Keep going (or dismissed). Story stays in-progress;
      // they can pick it back up from Home > Continue.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  EndSessionStats _buildStats(StoryProvider provider, StorySession session) {
    final turns = session.userTurnCount;
    final avg = session.averageScore;
    final duration = DateTime.now().difference(session.startedAt);

    final usedToday = provider.storyUsedToday;
    final limit = provider.storyLimit;
    final remainingLabel = limit == -1
        ? null
        : '${(limit - usedToday).clamp(0, limit)}/$limit stories left today';

    String? highlight;
    final bestUser = _findBestUserTurn(session);
    if (bestUser != null) {
      final preview = bestUser.text.length > 48
          ? '${bestUser.text.substring(0, 48)}…'
          : bestUser.text;
      highlight = 'Best line: "$preview"';
    }

    return EndSessionStats(
      turns: turns,
      averageScore: turns == 0 || avg == 0 ? null : avg,
      duration: duration.inSeconds > 5 ? duration : null,
      highlight: highlight,
      quotaReminder: remainingLabel,
    );
  }

  StoryTurn? _findBestUserTurn(StorySession session) {
    StoryTurn? best;
    double bestScore = -1;
    for (final t in session.turns) {
      if (t.role != StoryTurnRole.user) continue;
      final s = t.assessment?.score.toDouble();
      if (s == null) continue;
      if (s > bestScore) {
        bestScore = s;
        best = t;
      }
    }
    return best;
  }

  void _saveImprovement(Improvement imp) {
    final library = context.read<LibraryProvider>();
    library.addItem(SavedItem.fromImprovement(
      id: const Uuid().v4(),
      original: imp.original,
      correction: imp.correction,
      type: imp.type.value,
      context: '',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved: ${imp.correction}'),
        backgroundColor: AppColors.purpleDeep,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveVocabulary(KeyVocabulary vocab) {
    final library = context.read<LibraryProvider>();
    final now = DateTime.now().millisecondsSinceEpoch;
    library.addItem(SavedItem(
      id: const Uuid().v4(),
      original: vocab.word,
      correction: vocab.word,
      type: 'vocabulary',
      context: vocab.example,
      timestamp: now,
      masteryScore: 0,
      partOfSpeech: vocab.partOfSpeech.isEmpty ? null : vocab.partOfSpeech,
      explanation: vocab.meaning.isEmpty ? null : vocab.meaning,
      examples: vocab.example.isEmpty
          ? null
          : [
              {'en': vocab.example, 'vn': vocab.meaning},
            ],
      nextReviewDate: now.toDouble(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved: ${vocab.word}'),
        backgroundColor: AppColors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveSelection(String selected, String fullContext) {
    final library = context.read<LibraryProvider>();
    library.addItem(SavedItem(
      id: const Uuid().v4(),
      original: selected,
      correction: selected,
      type: 'vocabulary',
      context: fullContext,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      masteryScore: 0,
      easeFactor: 2.5,
      interval: 0,
      reviewCount: 0,
      nextReviewDate: DateTime.now().millisecondsSinceEpoch.toDouble(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved: $selected'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.purpleDeep,
      ),
    );
  }

  Future<void> _onHintPressed(StoryProvider provider) async {
    await provider.requestNextHint();
    if (!mounted) return;
    await _showHintSheet(provider);
  }

  Future<void> _showHintSheet(StoryProvider provider) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider<StoryProvider>.value(
        value: provider,
        child: const _HintSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Consumer<StoryProvider>(
          builder: (context, provider, _) {
            final session = provider.activeSession;
            if (session == null) {
              return _NoSessionView(isLoading: provider.isLoading);
            }
            _autoScrollIfNew(session);
            final isAwaitingReply = session.turns.isNotEmpty &&
                session.turns.last.role != StoryTurnRole.user;

            return Column(
              children: [
                StoryCharacterHeader(
                  character: session.character,
                  title: session.title,
                  situation: session.situation,
                  userTurnCount: session.userTurnCount,
                  onBack: () => _onBackPressed(provider),
                  onEnd: () => _confirmEndAndNavigate(provider),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    itemCount:
                        session.turns.length + (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == session.turns.length && provider.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: ThinkingIndicator(
                            accentColor: AppColors.purpleDeep,
                          ),
                        );
                      }
                      final turn = session.turns[index];
                      return MessageEntrance(
                        key: ValueKey(turn.id),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildTurn(context, turn, provider),
                        ),
                      );
                    },
                  ),
                ),
                if (provider.persistenceError != null)
                  const _PersistenceBanner(
                    message: 'Last save failed — retrying on next message.',
                  ),
                if (provider.error != null && !provider.isLoading)
                  _ErrorBanner(message: provider.error!),
                SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAwaitingReply)
                        _HintAffordance(
                          revealedLevel: provider.revealedHintLevel,
                          isLoading: provider.isHintLoading,
                          onTap: () => _onHintPressed(provider),
                        ),
                      ChatInputBar(
                        placeholder: 'Reply in English…',
                        accentColor: AppColors.purple,
                        enabled: !provider.isLoading,
                        onStop: provider.cancelCurrentMessage,
                        onSend: (text) async {
                          await provider.sendUserMessage(text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTurn(
    BuildContext context,
    StoryTurn turn,
    StoryProvider provider,
  ) {
    switch (turn.role) {
      case StoryTurnRole.system:
      case StoryTurnRole.ai:
        return ChatBubbleAi(
          text: turn.text,
          senderName: provider.activeSession?.character.name ?? 'Coach',
          accentColor: AppColors.purpleDeep,
          onSaveSelection: _saveSelection,
          onListen: () => _tts.speakEnglish(turn.text),
          onTranslate: () => provider.translateAiMessage(turn.id, turn.text),
          translation: provider.translationFor(turn.id),
          isTranslating: provider.isTranslatingTurn(turn.id),
        );
      case StoryTurnRole.user:
        final assessment = turn.assessment;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ChatBubbleUser(
              text: turn.text,
              accentColor: AppColors.purple,
              onListen: () => _tts.speakEnglish(turn.text),
              onSaveSelection: _saveSelection,
            ),
            if (assessment != null) ...[
              const SizedBox(height: 8),
              Consumer<LibraryProvider>(
                builder: (context, library, _) => AssessmentCard(
                  assessment: assessment,
                  onListen: (text) => _tts.speakEnglish(text),
                  onSaveImprovement: _saveImprovement,
                  onSaveVocabulary: _saveVocabulary,
                  isVocabularySaved: (vocab) {
                    final normalized = vocab.word.trim().toLowerCase();
                    return library.allItems.any(
                      (i) => i.correction.trim().toLowerCase() == normalized,
                    );
                  },
                ),
              ),
            ],
          ],
        );
    }
  }
}

class _NoSessionView extends StatelessWidget {
  final bool isLoading;

  const _NoSessionView({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Preparing your story…'),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📕', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(
            'No active story',
            style: AppTypography.h2.copyWith(color: AppColors.warmDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Head back and pick one from the library.',
            style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _PersistenceBanner extends StatelessWidget {
  final String message;

  const _PersistenceBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.gold.withValues(alpha: 0.18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 14, color: AppColors.goldDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.goldDark,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error.withValues(alpha: 0.16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: AppColors.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.error,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintAffordance extends StatelessWidget {
  final int revealedLevel;
  final bool isLoading;
  final VoidCallback onTap;

  const _HintAffordance({
    required this.revealedLevel,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasRevealed = revealedLevel > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: Row(
        children: [
          ClayPressable(
            onTap: isLoading ? null : onTap,
            scaleDown: 0.92,
            builder: (context, isPressed) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasRevealed
                      ? AppColors.purple.withValues(alpha: 0.16)
                      : AppColors.clayBeige,
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                    color: hasRevealed
                        ? AppColors.purple.withValues(alpha: 0.5)
                        : AppColors.clayBorder,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.6,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.purpleDeep),
                        ),
                      )
                    else
                      const AppIcon(
                        iconId: AppIcons.hint,
                        size: 14,
                        color: AppColors.purpleDeep,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      hasRevealed ? 'Hint $revealedLevel/3' : 'Need a hint?',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purpleDeep,
                      ),
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
}

/// Bottom sheet that shows hints progressively (level 1 → 3). Reads
/// [StoryProvider] via Consumer so the "Next hint" button updates the sheet
/// in place without rebuilding the chat screen underneath.
class _HintSheet extends StatelessWidget {
  const _HintSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, provider, _) {
        final hints = provider.currentHints ?? const <String>[];
        final revealed = provider.revealedHintLevel;
        final visibleHints = hints.take(revealed).toList();
        final canReveal = revealed < 3 &&
            (hints.isEmpty || revealed < hints.length) &&
            !provider.isHintLoading;

        return Container(
          padding: EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.clayBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const AppIcon(
                    iconId: AppIcons.hint,
                    size: 18,
                    color: AppColors.purpleDeep,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reply hints',
                    style: AppTypography.title.copyWith(
                      color: AppColors.purpleDeep,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Reveal hints one step at a time.',
                style: AppTypography.caption
                    .copyWith(color: AppColors.warmMuted, fontSize: 11),
              ),
              const SizedBox(height: 14),
              if (provider.hintError != null)
                _HintErrorCard(
                  message: provider.hintError!,
                  onDismiss: provider.dismissHintError,
                )
              else if (provider.isHintLoading && visibleHints.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.purpleDeep),
                      ),
                    ),
                  ),
                )
              else ...[
                for (var i = 0; i < visibleHints.length; i++)
                  _HintCard(
                    level: i + 1,
                    label: _labelForLevel(i + 1),
                    body: visibleHints[i],
                  ),
                if (visibleHints.isEmpty && provider.hintError == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Tap "Reveal next hint" to get started.',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.warmMuted),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ClayPressable(
                      onTap: () => Navigator.of(context).pop(),
                      builder: (_, __) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.clayBeige,
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(
                              color: AppColors.clayBorder, width: 1.5),
                        ),
                        child: Text(
                          'Close',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.warmDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClayPressable(
                      onTap:
                          canReveal ? () => provider.requestNextHint() : null,
                      builder: (_, __) => Opacity(
                        opacity: canReveal ? 1.0 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.purple, AppColors.purpleDeep],
                            ),
                            borderRadius: AppRadius.mdBorder,
                            boxShadow: AppShadows.colored(
                              AppColors.purple,
                              alpha: 0.32,
                            ),
                          ),
                          child: Text(
                            revealed == 0
                                ? 'Reveal first hint'
                                : revealed >= 3
                                    ? 'All hints shown'
                                    : 'Reveal next hint',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelForLevel(int level) {
    switch (level) {
      case 1:
        return 'Meaning / intent';
      case 2:
        return 'Structure';
      case 3:
        return 'Vocabulary';
      default:
        return 'Hint';
    }
  }
}

class _HintCard extends StatelessWidget {
  final int level;
  final String label;
  final String body;

  const _HintCard({
    required this.level,
    required this.label,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: AppColors.purple.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.purpleDeep,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '$level',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.purpleDeep,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.warmDark,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _HintErrorCard({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
          ClayPressable(
            onTap: onDismiss,
            scaleDown: 0.9,
            builder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child:
                  Icon(Icons.close_rounded, size: 16, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
