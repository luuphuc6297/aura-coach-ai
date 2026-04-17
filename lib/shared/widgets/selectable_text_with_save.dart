import 'package:flutter/material.dart';

class SelectableTextWithSave extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final void Function(String selectedText, String fullContext)? onSave;

  const SelectableTextWithSave({
    super.key,
    required this.text,
    this.style,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: style,
      contextMenuBuilder: (context, editableTextState) {
        final selection = editableTextState.textEditingValue.selection;
        final selectedText = selection.isValid && !selection.isCollapsed
            ? editableTextState.textEditingValue.text
                .substring(selection.start, selection.end)
            : '';

        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          children: [
            ...editableTextState.contextMenuButtonItems
                .map((item) => _buildToolbarButton(
                      item.label ?? '',
                      item.onPressed,
                    )),
            if (selectedText.isNotEmpty && onSave != null)
              _buildToolbarButton(
                '\u{1F4DA} Save to Dictionary',
                () {
                  onSave!(selectedText, text);
                  editableTextState.hideToolbar();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback? onPressed) {
    return TextSelectionToolbarTextButton(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onPressed: onPressed ?? () {},
      child: Text(label),
    );
  }
}
