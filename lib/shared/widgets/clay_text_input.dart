import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/clay_palette.dart';

/// Canonical clay-style text input. Renders the entire visual chrome from
/// scratch (fill, border, shadow, padding) so it does NOT depend on the
/// global Material `InputDecorationTheme` — this keeps rendering identical
/// across screens regardless of Material3 quirks (default underline leaks,
/// surface tint overrides, focus indicator double-render, etc.).
///
/// Use this for every primary text input in the app: onboarding name,
/// edit-profile name, library search, vocab-hub query, etc. Keeps the
/// "single shell" rule that the design system promises.
///
/// Per the mode-color rule, pass [accentColor] to tint the focused-border
/// + cursor with the host mode's accent (Vocab Hub = coral, Story = purple,
/// Tone = gold, Scenario = teal). Defaults to teal when omitted.
class ClayTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? accentColor;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final TextStyle? textStyle;

  const ClayTextInput({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
    this.accentColor,
    this.minLines,
    this.maxLines,
    this.enabled = true,
    this.textStyle,
  });

  @override
  State<ClayTextInput> createState() => _ClayTextInputState();
}

class _ClayTextInputState extends State<ClayTextInput> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.teal;
    final borderColor = _hasFocus ? accent : context.clay.border;
    final isMultiline = (widget.maxLines ?? 1) > 1;
    final baseStyle = widget.textStyle ?? AppTypography.input;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: AppShadows.clay(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        // For multi-line inputs, anchor the prefix icon to the top of the
        // text column so it doesn't drift down as the user types extra rows.
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: isMultiline ? 2 : 0),
              child: Icon(
                widget.prefixIcon,
                size: 22,
                color: context.clay.textMuted,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              minLines: widget.minLines,
              maxLines: widget.maxLines ?? 1,
              cursorColor: accent,
              cursorWidth: 2,
              style: baseStyle.copyWith(color: context.clay.text),
              // Explicitly nullify EVERY border state. `InputDecoration.collapsed`
              // only sets `border` and inherits the rest from the global
              // `InputDecorationTheme` — that's why the teal `focusedBorder`
              // pill was leaking inside the Container shell on focus.
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    baseStyle.copyWith(color: context.clay.textFaint),
                isDense: true,
                isCollapsed: true,
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: 8),
            widget.suffix!,
          ],
        ],
      ),
    );
  }
}
