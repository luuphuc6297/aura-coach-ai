import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';

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
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border(
          top: BorderSide(color: AppColors.clayBorder, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.clayWhite,
          border: Border.all(color: AppColors.clayBorder, width: 2),
          borderRadius: AppRadius.fullBorder,
        ),
        padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTypography.bodySm,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: AppTypography.bodySm.copyWith(
                    color: AppColors.warmLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Text('🎤', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _hasText ? _send : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasText ? AppColors.teal : AppColors.clayBorder,
                ),
                child: const Center(
                  child: Text('➤',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
