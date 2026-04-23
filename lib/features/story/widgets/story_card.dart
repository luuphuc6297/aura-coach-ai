import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/story.dart';
import 'story_gradient.dart';

/// Compact story card for the "More Stories" grid under the hero PageView.
/// Tapping it starts the story directly — same contract as [StoryHeroCard].
class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final bool isLoading;
  final bool disabled;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    this.isLoading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = storyGradientFor(story.character.gradient);
    final isInactive = disabled || isLoading;

    final card = ClayPressable(
      onTap: isInactive ? null : onTap,
      scaleDown: 0.96,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.clayBorder, width: 1.5),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      borderRadius: AppRadius.mdBorder,
                    ),
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            story.thumbnailIcon,
                            style: const TextStyle(fontSize: 22),
                          ),
                  ),
                  const Spacer(),
                  _MiniLevelBadge(level: story.level),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isLoading ? 'Starting…' : story.title,
                style: AppTypography.cardBody.copyWith(
                  color: AppColors.warmDark,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                story.character.name,
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );

    if (disabled) {
      return IgnorePointer(
        child: Opacity(opacity: 0.45, child: card),
      );
    }
    return card;
  }
}

class _MiniLevelBadge extends StatelessWidget {
  final String level;

  const _MiniLevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.18),
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        level,
        style: AppTypography.micro.copyWith(
          color: AppColors.purpleDeep,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
