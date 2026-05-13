import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/chat_message.dart';
import '../models/session.dart';
import '../providers/scenario_provider.dart';
import '../widgets/assessment_card.dart';
import '../widgets/chat_bubble_ai.dart';
import '../widgets/chat_bubble_user.dart';
import '../widgets/lesson_card.dart';
import '../widgets/scenario_app_bar.dart';

/// Read-only replay of a past scenario. Activates [ScenarioProvider]'s
/// replay mode on mount and restores the active scenario state on dispose
/// so the user lands back exactly where they left the chat screen.
///
/// "Branch" buttons start a fresh scenario in the same session using the
/// chosen difficulty adjustment — the replayed scenario stays untouched.
class ScenarioReplayScreen extends StatefulWidget {
  final String conversationId;

  const ScenarioReplayScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ScenarioReplayScreen> createState() => _ScenarioReplayScreenState();
}

class _ScenarioReplayScreenState extends State<ScenarioReplayScreen> {
  static final _tts = TtsService();

  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    // Defer to a post-frame callback so context.read works after the widget
    // is mounted and the provider tree is fully established.
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterReplay());
  }

  Future<void> _enterReplay() async {
    final provider = context.read<ScenarioProvider>();
    await provider.enterReplayMode(widget.conversationId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadFailed = !provider.isReplayMode;
    });
  }

  @override
  void dispose() {
    // Restore active state when the user leaves the screen for ANY reason
    // (back gesture, system back, branch tap). Use a read because the
    // widget tree is being torn down — no listeners to re-trigger.
    final provider = context.read<ScenarioProvider>();
    if (provider.isReplayMode) {
      provider.exitReplayMode();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScenarioProvider>();
    final loc = context.loc;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.clay.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
                const SizedBox(height: 12),
                Text(
                  loc.replayLoading,
                  style: AppTypography.bodyMd
                      .copyWith(color: context.clay.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_loadFailed || provider.currentScenario == null) {
      return _ErrorView(
        title: loc.replayLoadErrorTitle,
        body: loc.replayLoadErrorBody,
        backLabel: loc.replayLoadErrorBack,
        onBack: () => _popBack(context),
      );
    }

    final scenario = provider.currentScenario!;
    final meta = _findMetaForConversation(provider, widget.conversationId);

    return Scaffold(
      backgroundColor: context.clay.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScenarioAppBar(
              title: meta != null
                  ? loc.replayTitle(meta.orderInSession)
                  : (scenario.title.isNotEmpty ? scenario.title : ''),
              emoji: '🔁',
              category: scenario.topic,
              level: scenario.difficulty,
              scenarioIndex: meta?.orderInSession ?? 0,
              progress: 1.0,
              onBack: () => _popBack(context),
            ),
            _ReadOnlyBanner(label: loc.replayBannerText),
            LessonCard(
              vietnameseSentence: provider.isVnToEn
                  ? scenario.vietnamesePhrase
                  : scenario.englishPhrase,
              isVnToEn: provider.isVnToEn,
              situation: scenario.situation,
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
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                itemCount: provider.messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == provider.messages.length) {
                    return _BranchPanel(
                      onBranch: (difficulty) =>
                          _branch(context, provider, difficulty),
                    );
                  }
                  final msg = provider.messages[index];
                  return Padding(
                    key: ValueKey(msg.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildMessage(context, msg),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessage msg) {
    switch (msg.type) {
      case MessageType.ai:
      case MessageType.system:
        return ChatBubbleAi(text: msg.text);
      case MessageType.user:
        return ChatBubbleUser(
          text: msg.text,
          onListen: () => _tts.speakEnglish(msg.text),
        );
      case MessageType.assessment:
        final assessment = msg.assessment;
        if (assessment == null) return const SizedBox.shrink();
        // Pass NO difficulty callbacks: AssessmentCard auto-hides the
        // Easier/Same/Harder row when all three are null, so the dedicated
        // _BranchPanel below the list is the only way to fork.
        return AssessmentCard(
          assessment: assessment,
          onListen: (text) => _tts.speakEnglish(text),
        );
    }
  }

  Future<void> _branch(
    BuildContext context,
    ScenarioProvider provider,
    String difficulty,
  ) async {
    // branchFromReplay handles exitReplayMode internally before starting
    // the new scenario. Pop replay route AFTER the new scenario is loaded
    // so the chat screen has fresh state when it rebuilds.
    await provider.branchFromReplay(difficulty: difficulty);
    if (!context.mounted) return;
    _popBack(context);
  }

  void _popBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/scenario');
    }
  }

  SessionScenarioMeta? _findMetaForConversation(
      ScenarioProvider provider, String conversationId) {
    for (final m in provider.sessionMetas) {
      if (m.conversationId == conversationId) return m;
    }
    return null;
  }
}

// ---------- internal layout pieces ----------

class _ReadOnlyBanner extends StatelessWidget {
  final String label;
  const _ReadOnlyBanner({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 8),
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, 4, AppSpacing.md, 0),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: AppRadius.smBorder,
        border: Border.all(
            color: AppColors.goldDeep.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined,
              size: 16, color: AppColors.goldDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchPanel extends StatelessWidget {
  final void Function(String difficulty) onBranch;
  const _BranchPanel({required this.onBranch});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.replayBranchSectionTitle,
            style: AppTypography.sentenceLabel.copyWith(
              color: AppColors.tealDeep,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.replayBranchSectionSubtitle,
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              color: context.clay.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BranchButton(
                  label: loc.replayBranchEasier,
                  color: AppColors.success,
                  onTap: () => onBranch('easier'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BranchButton(
                  label: loc.replayBranchSame,
                  color: AppColors.gold,
                  onTap: () => onBranch('same'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BranchButton(
                  label: loc.replayBranchHarder,
                  color: AppColors.coral,
                  onTap: () => onBranch('harder'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BranchButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: AppRadius.smBorder,
            border: Border.all(
                color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String title;
  final String body;
  final String backLabel;
  final VoidCallback onBack;

  const _ErrorView({
    required this.title,
    required this.body,
    required this.backLabel,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.clay.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 36, color: context.clay.textMuted),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: context.clay.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(onPressed: onBack, child: Text(backLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
