import 'package:flutter/material.dart';

import '../../core/constants/topic_constants.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/clay_palette.dart';
import 'app_icon.dart';
import 'clay_pressable.dart';

/// Shared clay pill used for topic selection everywhere a [TopicOption] is
/// offered to the learner. Single source of truth for the look & feel across
/// the onboarding topic picker and the Vocab Hub flashcard suggestions so
/// they can never drift apart again.
///
/// States:
/// - default         — per-topic tinted background (0.10 alpha), clayBorder
/// - selected        — stronger tint (0.25 alpha), warmDark border, clayBold shadow
/// - loading         — async work in progress, spinner replaces icon,
///                     warmDark border + deeper tint, tap is swallowed
/// - disabled        — 55% opacity, tap is swallowed (e.g. a sibling chip is
///                     already loading)
class TopicChip extends StatelessWidget {
  final TopicOption topic;
  final bool isSelected;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onTap;

  const TopicChip({
    super.key,
    required this.topic,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.onTap,
  });

  bool get _interactive => onTap != null && !isLoading && !isDisabled;

  @override
  Widget build(BuildContext context) {
    final isActive = isSelected || isLoading;
    final backgroundAlpha = isLoading
        ? 0.22
        : (isSelected ? 0.25 : 0.10);
    final background = topic.color.withValues(alpha: backgroundAlpha);
    final borderColor = isActive ? context.clay.text : context.clay.border;

    final chip = AnimatedContainer(
      duration: AppAnimations.durationMedium,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isActive ? AppShadows.clayBold(context) : const <BoxShadow>[],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 24,
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(3),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(topic.color),
                    ),
                  )
                : AppIcon(iconId: topic.iconId, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            topic.label,
            style: AppTypography.labelMd.copyWith(
              fontSize: 13,
              color: context.clay.text,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final body = Opacity(
      opacity: (isDisabled && !isLoading) ? 0.55 : 1,
      child: chip,
    );

    if (!_interactive) {
      // Preserve layout but eat taps when chip can't be activated.
      return IgnorePointer(
        ignoring: true,
        child: body,
      );
    }

    return ClayPressable(
      onTap: onTap,
      builder: (context, _) => body,
    );
  }
}
