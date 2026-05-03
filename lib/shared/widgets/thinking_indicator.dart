import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/clay_palette.dart';

/// Shared "AI is thinking" bubble rendered in-line with the chat stream.
/// Replaces the mode-specific bouncing-dot indicators — a text label reads
/// more clearly during the longer assessment phase where learners can wait
/// three to five seconds.
///
/// [accentColor] skins only the spinner so Story (purple) and Scenario
/// (teal) read as distinct modes while the chrome stays clay-neutral.
/// When omitted, falls back to the active theme's text color so the spinner
/// stays visible in both light and dark mode.
class ThinkingIndicator extends StatelessWidget {
  final Color? accentColor;
  final String label;

  const ThinkingIndicator({
    super.key,
    this.accentColor,
    this.label = 'Thinking…',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.clay.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: context.clay.border, width: 1.5),
            boxShadow: AppShadows.card(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(accentColor ?? context.clay.text),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: context.clay.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
