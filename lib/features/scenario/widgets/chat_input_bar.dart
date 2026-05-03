import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final String placeholder;

  /// Per-mode accent color. Defaults to Scenario's teal; Story passes purple,
  /// Vocab will pass coral, etc. Controls the focused border, cursor, and
  /// active send-button fill — the neutral chrome stays clay beige so all
  /// modes remain visually consistent.
  final Color accentColor;

  /// When false, the text field and send button are disabled so the user
  /// cannot type or spam sends while an AI response is in flight.
  final bool enabled;

  /// When provided, a stop button replaces the mic while the bar is
  /// disabled — lets the user cancel an in-flight AI call.
  final VoidCallback? onStop;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.placeholder = 'Type your translation...',
    this.accentColor = AppColors.teal,
    this.enabled = true,
    this.onStop,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _isFocused) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: context.clay.background,
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding + 8),
      child: AnimatedContainer(
        duration: AppAnimations.durationFast,
        curve: AppAnimations.easeClay,
        decoration: BoxDecoration(
          color: context.clay.surfaceAlt,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: _isFocused ? widget.accentColor : context.clay.border,
            width: 2,
          ),
          boxShadow: AppShadows.clay(context),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                style: AppTypography.input.copyWith(
                  fontSize: 15,
                  color: widget.enabled
                      ? context.clay.text
                      : context.clay.textMuted,
                ),
                cursorColor: widget.accentColor,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                scrollPhysics: const BouncingScrollPhysics(),
                decoration: InputDecoration(
                  hintText: widget.enabled
                      ? widget.placeholder
                      : 'Waiting for reply…',
                  hintStyle: AppTypography.input.copyWith(
                    color: context.clay.textFaint,
                    fontSize: 15,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            if (!widget.enabled && widget.onStop != null)
              ClayPressable(
                onTap: widget.onStop,
                scaleDown: 0.85,
                builder: (context, isPressed) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.clayBold(context),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.stop_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              )
            else ...[
              ClayPressable(
                onTap: widget.enabled ? () {} : null,
                scaleDown: 0.85,
                builder: (context, isPressed) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.clay.textFaint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: AppIcon(
                        iconId: AppIcons.mic,
                        size: 22,
                        color: widget.enabled
                            ? context.clay.text
                            : context.clay.textFaint,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              ClayPressable(
                onTap: (_hasText && widget.enabled) ? _send : null,
                scaleDown: 0.85,
                builder: (context, isPressed) {
                  final isActive = _hasText && widget.enabled;
                  return AnimatedContainer(
                    duration: AppAnimations.durationFast,
                    curve: AppAnimations.easeClay,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? widget.accentColor
                          : context.clay.textFaint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isActive ? AppShadows.clayBold(context) : null,
                    ),
                    child: Center(
                      child: AppIcon(
                        iconId: AppIcons.send,
                        size: 22,
                        color: isActive
                            ? context.clay.text
                            : context.clay.textFaint,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
