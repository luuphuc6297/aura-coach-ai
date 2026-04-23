import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../my_library/providers/library_provider.dart';
import '../../my_library/models/saved_item.dart';
import '../providers/scenario_provider.dart';
import '../models/chat_message.dart';
import '../widgets/scenario_app_bar.dart';
import '../widgets/lesson_card.dart';
import '../widgets/chat_bubble_user.dart';
import '../widgets/chat_bubble_ai.dart';
import '../widgets/assessment_card.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/context_panel.dart';
import '../../../shared/widgets/message_entrance.dart';
import '../../../shared/widgets/end_session_dialog.dart';
import '../../../shared/widgets/thinking_indicator.dart';

class ScenarioChatScreen extends StatelessWidget {
  const ScenarioChatScreen({super.key});

  static final _tts = TtsService();

  static const _topicEmojis = {
    'travel': '✈️',
    'business': '💼',
    'social': '🥂',
    'daily': '🏠',
    'tech': '💻',
    'food': '🍽️',
    'medical': '🏥',
    'shopping': '🛍️',
    'entertainment': '🎬',
    'sports': '⚽',
    'education': '🎓',
    'environment': '🌿',
    'finance': '💰',
    'relationships': '❤️',
    'legal': '⚖️',
    'property': '🔑',
  };

  static const _topicLabels = {
    'travel': 'Travel',
    'business': 'Business',
    'social': 'Social',
    'daily': 'Daily Life',
    'tech': 'Technology',
    'food': 'Food & Dining',
    'medical': 'Medical',
    'shopping': 'Shopping',
    'entertainment': 'Entertainment',
    'sports': 'Sports',
    'education': 'Education',
    'environment': 'Environment',
    'finance': 'Finance',
    'relationships': 'Relationships',
    'legal': 'Legal',
    'property': 'Property',
  };

  void _showContextPanel(BuildContext context) {
    final provider = context.read<ScenarioProvider>();
    if (provider.currentScenario == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ScenarioProvider>(
          builder: (_, p, __) => ContextPanel(
            scenario: p.currentScenario!,
            hintsRevealed: p.hintsRevealed,
            onRevealHint: () => p.revealNextHint(),
          ),
        ),
      ),
    );
  }

  Future<void> _onBackPressed(
      BuildContext context, ScenarioProvider provider) async {
    // No active scenario means nothing to end — just pop back.
    if (provider.currentScenario == null) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
      return;
    }

    final confirmed = await showEndSessionDialog(
      context: context,
      accentColor: AppColors.teal,
      stats: _buildStats(provider),
      title: 'End this session?',
    );
    if (!context.mounted) return;

    if (confirmed == true) {
      await provider.endSession();
      if (!context.mounted) return;
      context.push('/scenario/summary');
    } else {
      // Learner chose Keep going (or dismissed). Keep the session alive —
      // they can resume simply by not leaving the screen. Back-nav still
      // honours their intent if the dialog was dismissed explicitly.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  EndSessionStats _buildStats(ScenarioProvider provider) {
    final turns = provider.totalTurns;
    final avg = provider.averageScore;
    final duration = provider.sessionDuration;

    final usedToday = provider.roleplayUsedToday;
    final limit = provider.roleplayLimitToday;
    final remainingLabel = limit == -1
        ? null
        : '${(limit - usedToday).clamp(0, limit)}/$limit sessions left today';

    String? highlight;
    final best = _findBestUserLine(provider.messages);
    if (best != null) {
      final preview =
          best.text.length > 48 ? '${best.text.substring(0, 48)}…' : best.text;
      highlight = 'Best line: "$preview"';
    }

    return EndSessionStats(
      turns: turns,
      averageScore: turns == 0 || avg == 0 ? null : avg,
      duration: (duration != null && duration.inSeconds > 5) ? duration : null,
      highlight: highlight,
      quotaReminder: remainingLabel,
    );
  }

  /// Scenario stores user turns and their scores on separate messages:
  /// a `MessageType.user` bubble is followed immediately by a
  /// `MessageType.assessment`. Walk the list in order so each user bubble
  /// can be paired with the very next assessment — then pick the one with
  /// the highest score.
  ChatMessage? _findBestUserLine(List<ChatMessage> messages) {
    ChatMessage? best;
    double bestScore = -1;
    for (var i = 0; i < messages.length - 1; i++) {
      final msg = messages[i];
      if (msg.type != MessageType.user) continue;
      final next = messages[i + 1];
      if (next.type != MessageType.assessment || next.assessment == null) {
        continue;
      }
      final score = next.assessment!.score.toDouble();
      if (score > bestScore) {
        bestScore = score;
        best = msg;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Consumer<ScenarioProvider>(
          builder: (context, provider, _) {
            final scenario = provider.currentScenario;
            if (scenario == null) {
              return AnimatedSwitcher(
                duration: AppAnimations.durationNormal,
                child: provider.isLoading
                    ? const Center(
                        key: ValueKey('loading'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Preparing your scenario...'),
                          ],
                        ),
                      )
                    : Center(
                        key: const ValueKey('error'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              provider.error ?? 'No scenario loaded',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMd
                                  .copyWith(color: AppColors.warmMuted),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.go('/home'),
                              child: const Text('Back to Home'),
                            ),
                          ],
                        ),
                      ),
              );
            }

            final topicEmoji = _topicEmojis[scenario.topic] ?? '📌';
            final topicLabel = _topicLabels[scenario.topic] ?? 'Scenario';

            return Column(
              children: [
                ScenarioAppBar(
                  title:
                      scenario.title.isNotEmpty ? scenario.title : topicLabel,
                  emoji: topicEmoji,
                  category: topicLabel,
                  level: scenario.difficulty,
                  scenarioIndex: provider.scenarioIndex,
                  progress: 0.0,
                  onBack: () => _onBackPressed(context, provider),
                  onHistory: () => context.push('/history'),
                  onMyLearning: () => context.push('/my-library'),
                ),
                LessonCard(
                  vietnameseSentence: provider.isVnToEn
                      ? scenario.vietnamesePhrase
                      : scenario.englishPhrase,
                  isVnToEn: provider.isVnToEn,
                  situation: scenario.situation,
                  onHint: () => _showContextPanel(context),
                  onToggleDirection: () => provider.toggleDirection(),
                  onListen: (text) {
                    if (provider.isVnToEn) {
                      _tts.speakVietnamese(text);
                    } else {
                      _tts.speakEnglish(text);
                    }
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    itemCount: provider.messages.length +
                        (provider.isAiTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.messages.length &&
                          provider.isAiTyping) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: ThinkingIndicator(accentColor: AppColors.teal),
                        );
                      }
                      final msg = provider.messages[index];
                      return MessageEntrance(
                        key: ValueKey(msg.id),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildMessage(context, msg, provider),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: ChatInputBar(
                    enabled: !provider.isAiTyping,
                    onStop: provider.cancelCurrentMessage,
                    onSend: (text) async {
                      await provider.sendUserMessage(text);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _saveSelectionToDictionary(
      BuildContext context, String selectedText, String fullContext) {
    final libraryProvider = context.read<LibraryProvider>();
    libraryProvider.addItem(SavedItem(
      id: const Uuid().v4(),
      original: selectedText,
      correction: selectedText,
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
        content: Text('Saved: $selectedText'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.teal,
      ),
    );
  }

  Widget _buildMessage(
      BuildContext context, ChatMessage msg, ScenarioProvider provider) {
    switch (msg.type) {
      case MessageType.ai:
      case MessageType.system:
        return ChatBubbleAi(
          text: msg.text,
          onSaveSelection: (selectedText, fullContext) =>
              _saveSelectionToDictionary(context, selectedText, fullContext),
        );
      case MessageType.user:
        return ChatBubbleUser(
          text: msg.text,
          onListen: () => _tts.speakEnglish(msg.text),
          onSaveSelection: (selectedText, fullContext) =>
              _saveSelectionToDictionary(context, selectedText, fullContext),
        );
      case MessageType.assessment:
        // Belt-and-suspenders: the resume path drops orphan assessment turns,
        // so this should never be null in practice. Guard anyway so a single
        // malformed doc can never brick the chat again.
        final assessment = msg.assessment;
        if (assessment == null) return const SizedBox.shrink();
        // Consumer so the saved-state badge updates live as the user taps
        // through the Key Vocabulary list.
        return Consumer<LibraryProvider>(
          builder: (context, libraryProvider, _) => AssessmentCard(
            assessment: assessment,
            onEasier: () async {
              await provider.startNewScenario(difficulty: 'easier');
            },
            onSameDifficulty: () async {
              await provider.startNewScenario(difficulty: 'same');
            },
            onHarder: () async {
              await provider.startNewScenario(difficulty: 'harder');
            },
            onListen: (text) => _tts.speakEnglish(text),
            onSaveImprovement: (imp) {
              libraryProvider.addItem(SavedItem.fromImprovement(
                id: const Uuid().v4(),
                original: imp.original,
                correction: imp.correction,
                type: imp.type.value,
                context: '',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved: ${imp.correction}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.teal,
                ),
              );
            },
            onSaveVocabulary: (vocab) {
              libraryProvider.addItem(SavedItem(
                id: const Uuid().v4(),
                original: vocab.word,
                correction: vocab.word,
                type: 'vocabulary',
                context: vocab.example,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                masteryScore: 0,
                partOfSpeech:
                    vocab.partOfSpeech.isEmpty ? null : vocab.partOfSpeech,
                explanation: vocab.meaning.isEmpty ? null : vocab.meaning,
                examples: vocab.example.isEmpty
                    ? null
                    : [
                        {'en': vocab.example, 'vn': vocab.meaning},
                      ],
                nextReviewDate:
                    DateTime.now().millisecondsSinceEpoch.toDouble(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved: ${vocab.word}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.purple,
                ),
              );
            },
            isVocabularySaved: (vocab) {
              final normalized = vocab.word.trim().toLowerCase();
              return libraryProvider.allItems
                  .any((i) => i.correction.trim().toLowerCase() == normalized);
            },
          ),
        );
    }
  }
}
