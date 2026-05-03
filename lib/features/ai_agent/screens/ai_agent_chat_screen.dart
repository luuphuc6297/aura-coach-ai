import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../providers/ai_agent_chat_provider.dart';

/// Full-screen Ask AI chat. Top app bar with back + reset, message list in
/// the middle (auto-scroll to newest), sticky composer at the bottom.
///
/// Provider state survives navigation (it's app-scoped) so the user can
/// pop back to the help center, change something, and return without
/// losing context. The "Reset chat" action explicitly wipes when needed.
class AIAgentChatScreen extends StatefulWidget {
  const AIAgentChatScreen({super.key});

  @override
  State<AIAgentChatScreen> createState() => _AIAgentChatScreenState();
}

class _AIAgentChatScreenState extends State<AIAgentChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(AIAgentChatProvider provider) async {
    final text = _input.text;
    if (text.trim().isEmpty || provider.sending) return;
    _input.clear();
    await provider.send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AIAgentChatProvider>();
    // Auto-scroll on every message append.
    _scrollToBottom();

    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: ClayBackButton(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.purpleDeep, width: 1.5),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 16,
                color: AppColors.purpleDeep,
              ),
            ),
            const SizedBox(width: 8),
            Text('Ask Aura', style: AppTypography.h2),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: context.clay.textMuted,
            ),
            tooltip: 'Reset chat',
            onPressed: provider.sending ? null : provider.reset,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final m = provider.messages[index];
                return _MessageBubble(message: m);
              },
            ),
          ),
          if (provider.sending)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 4,
              ),
              child: _TypingIndicator(),
            ),
          _Composer(
            controller: _input,
            focusNode: _focus,
            sending: provider.sending,
            onSend: () => _send(provider),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final HelpChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == HelpChatRole.user;
    final isError = message.isError;

    final bubbleColor = isUser
        ? AppColors.coral
        : isError
            ? AppColors.coral.withValues(alpha: 0.12)
            : context.clay.surface;
    final textColor = isUser
        ? context.clay.surface
        : isError
            ? AppColors.coral
            : context.clay.text;
    final borderColor = isUser
        ? context.clay.text
        : isError
            ? AppColors.coral.withValues(alpha: 0.45)
            : context.clay.border;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const _AvatarBadge(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(color: borderColor, width: isUser ? 2 : 1.5),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: context.clay.text,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: SelectableText(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.purpleDeep],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: context.clay.text, width: 1.5),
      ),
      child: const Icon(
        Icons.support_agent_rounded,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

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
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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
      children: [
        const _AvatarBadge(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.clay.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: context.clay.border, width: 1.5),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final t = _controller.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  // 3 staggered dots, sinusoidal opacity
                  final phased = ((t + i * 0.18) % 1.0);
                  final pulse = phased < 0.5 ? phased * 2 : (1 - phased) * 2;
                  final alpha = 0.25 + pulse * 0.65;
                  return Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.clay.textMuted.withValues(alpha: alpha),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.clay.surface,
          border: Border(
            top: BorderSide(color: context.clay.border, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.smd,
          AppSpacing.lg,
          AppSpacing.smd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppTypography.bodyMd
                    .copyWith(color: context.clay.text, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Ask anything about the app…',
                  hintStyle: AppTypography.bodyMd
                      .copyWith(color: context.clay.textFaint),
                  filled: true,
                  fillColor: context.clay.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.lgBorder,
                    borderSide: BorderSide(
                      color: context.clay.border,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.lgBorder,
                    borderSide: BorderSide(
                      color: context.clay.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.lgBorder,
                    borderSide: const BorderSide(
                      color: AppColors.coral,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ClayPressable(
              onTap: sending ? null : onSend,
              scaleDown: 0.92,
              builder: (context, _) => Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sending
                      ? AppColors.coral.withValues(alpha: 0.55)
                      : AppColors.coral,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.clay.text, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: context.clay.text,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: sending
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(context.clay.surface),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: context.clay.surface,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
