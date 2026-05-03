import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

/// Horizontal feature card shown on the Vocab Hub home screen. Icon tile on
/// the left (per-feature natural color), two-line copy on the right, chevron
/// affordance pinned to the far right. Tapping the card triggers [onTap].
///
/// - [iconId]: registered id in [iconRegistry] (e.g. `feat_magnifier`) so the
///   card reuses the same animated custom-painter style as the onboarding
///   icons instead of Material Icons. Keeps visual language consistent.
/// - [iconColor]: per-feature hue for the icon tile and painter tint. Kept
///   distinct from the mode accent so the feature list reads as varied.
/// - [accentColor]: mode accent reserved for the PRO badge and other Pro-tier
///   affordances on the card.
/// - [isLocked]: when true, a padlock overlay appears on the icon tile and
///   the whole card is dimmed to communicate the feature is gated. The card
///   remains tappable so the user can still reach the upgrade surface.
class VocabFeatureCard extends StatelessWidget {
  final String iconId;
  final String title;
  final String description;
  final Color iconColor;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isPro;
  final bool isLocked;

  const VocabFeatureCard({
    super.key,
    required this.iconId,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.accentColor,
    required this.onTap,
    this.isPro = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.98,
      builder: (context, isPressed) {
        final card = AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.clay.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: context.clay.border, width: 2),
            boxShadow: isPressed ? AppShadows.clayPressed(context) : AppShadows.clay(context),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconTile(
                iconId: iconId,
                iconColor: iconColor,
                isLocked: isLocked,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTypography.sectionTitle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPro) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: accentColor, width: 1),
                            ),
                            child: Text(
                              'PRO',
                              style: AppTypography.labelSm.copyWith(
                                color: accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13,
                        color: context.clay.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLocked
                    ? Icons.lock_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: isLocked ? 16 : 14,
                color: isLocked ? accentColor : context.clay.textFaint,
              ),
            ],
          ),
        );

        if (!isLocked) return card;
        // Dim the entire card when locked so the gated state is obvious
        // without hiding the title/description (users should still see what
        // they're unlocking).
        return Opacity(opacity: 0.72, child: card);
      },
    );
  }
}

class _IconTile extends StatelessWidget {
  final String iconId;
  final Color iconColor;
  final bool isLocked;

  const _IconTile({
    required this.iconId,
    required this.iconColor,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.14),
        borderRadius: AppRadius.mdBorder,
      ),
      child: AppIcon(iconId: iconId, size: 26, color: iconColor),
    );
    if (!isLocked) return tile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.clay.text,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: context.clay.surface, width: 2),
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 11,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
