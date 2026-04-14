import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/scenario_provider.dart';
import '../models/chat_message.dart';
import '../widgets/scenario_app_bar.dart';
import '../widgets/translate_prompt.dart';
import '../widgets/chat_bubble_user.dart';
import '../widgets/chat_bubble_ai.dart';
import '../widgets/inline_assessment.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/context_panel.dart';

class ScenarioChatScreen extends StatelessWidget {
  const ScenarioChatScreen({super.key});

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

  void _showEndSessionDialog(BuildContext context, ScenarioProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.clayWhite,
        title: Text('End Session?', style: AppTypography.h2.copyWith(fontSize: 18)),
        content: Text(
          'Your progress will be saved.',
          style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue', style: TextStyle(color: AppColors.warmMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.endSession();
              if (context.mounted) {
                context.go('/scenario/summary');
              }
            },
            child: Text('End & Review', style: TextStyle(color: AppColors.teal)),
          ),
        ],
      ),
    );
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
              if (provider.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Preparing your scenario...'),
                    ],
                  ),
                );
              }
              return Center(
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
              );
            }

            final topicEmojis = {
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

            final topicLabels = {
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

            final topicEmoji = topicEmojis[scenario.topic] ?? '📌';
            final topicLabel = topicLabels[scenario.topic] ?? 'Scenario';

            return Column(
              children: [
                ScenarioAppBar(
                  title: scenario.title.isNotEmpty
                      ? scenario.title
                      : topicLabel,
                  emoji: topicEmoji,
                  category: topicLabel,
                  level: scenario.difficulty,
                  progress: 0.0,
                  onBack: () => _showEndSessionDialog(context, provider),
                  onHint: () => _showContextPanel(context),
                  onMore: () => _showContextPanel(context),
                ),
                LessonCard(
                  vietnameseSentence: provider.isVnToEn
                      ? scenario.vietnameseSentence
                      : scenario.englishTranslation,
                  topic: scenario.topic,
                  difficulty: scenario.difficulty,
                  scenarioIndex: provider.scenarioIndex,
                  isVnToEn: provider.isVnToEn,
                  title: scenario.title,
                  situation: scenario.context,
                  onHint: () => _showContextPanel(context),
                  onToggleDirection: () => provider.toggleDirection(),
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
                        return _TypingIndicator();
                      }
                      final msg = provider.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildMessage(context, msg, provider),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: ChatInputBar(
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

  Widget _buildMessage(
      BuildContext context, ChatMessage msg, ScenarioProvider provider) {
    switch (msg.type) {
      case MessageType.ai:
      case MessageType.system:
        return ChatBubbleAi(text: msg.text);
      case MessageType.user:
        return ChatBubbleUser(text: msg.text);
      case MessageType.assessment:
        return AssessmentCard(
          assessment: msg.assessment!,
          onEasier: () async {
            await provider.startNewScenario(difficulty: 'easier');
          },
          onSameDifficulty: () async {
            await provider.startNewScenario(difficulty: 'same');
          },
          onHarder: () async {
            await provider.startNewScenario(difficulty: 'harder');
          },
        );
    }
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 46),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            border: Border.all(color: AppColors.clayBorder, width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(28),
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: AppShadows.card,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = (_controller.value - delay).clamp(0.0, 1.0);
                final y = t < 0.3
                    ? -6 * (t / 0.3)
                    : t < 0.6
                        ? -6 * (1 - (t - 0.3) / 0.3)
                        : 0.0;
                return Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Transform.translate(
                    offset: Offset(0, y),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.clayShadow
                            .withValues(alpha: y < -2 ? 1 : 0.4),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
