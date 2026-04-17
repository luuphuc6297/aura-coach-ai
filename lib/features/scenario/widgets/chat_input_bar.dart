import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/fluent_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final String placeholder;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.placeholder = 'Type your translation...',
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
      color: AppColors.cream,
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding + 8),
      child: AnimatedContainer(
        duration: AppAnimations.durationFast,
        curve: AppAnimations.easeClay,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: _isFocused ? AppColors.teal : AppColors.clayBorder,
            width: _isFocused ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.warmDark,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: AppTypography.bodyMd.copyWith(
                    color: AppColors.warmLight,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            ClayPressable(
              onTap: () {},
              scaleDown: 0.85,
              builder: (context, isPressed) {
                return Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.warmLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FluentIcon(AppIcons.mic, size: 22),
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            ClayPressable(
              onTap: _hasText ? _send : null,
              scaleDown: 0.85,
              builder: (context, isPressed) {
                return AnimatedContainer(
                  duration: AppAnimations.durationFast,
                  curve: AppAnimations.easeClay,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _hasText
                        ? AppColors.teal
                        : AppColors.warmLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FluentIcon(AppIcons.send, size: 22),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
