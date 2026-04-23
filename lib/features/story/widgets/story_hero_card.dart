import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/story.dart';
import 'story_gradient.dart';

/// Oversized featured card used at the top of the Story Home library PageView.
/// One-tap on the card starts the story — the Begin CTA is the whole surface.
class StoryHeroCard extends StatelessWidget {
  final Story story;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const StoryHeroCard({
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
      scaleDown: 0.98,
      builder: (context, isPressed) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: AppRadius.xlBorder,
            boxShadow: AppShadows.lifted,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _LevelBadge(level: story.level),
                  const SizedBox(width: 8),
                  _TopicBadge(topic: story.topic),
                  const Spacer(),
                  Text(
                    story.thumbnailIcon,
                    style: const TextStyle(fontSize: 34),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                story.title,
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                story.situation,
                style: AppTypography.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 13,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _CharacterAvatar(
                    initial: story.character.initial,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.character.name,
                          style: AppTypography.labelLg.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          story.character.role,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _BeginPill(isLoading: isLoading),
                ],
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

class _LevelBadge extends StatelessWidget {
  final String level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Text(
        level,
        style: AppTypography.micro.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _TopicBadge extends StatelessWidget {
  final String topic;

  const _TopicBadge({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        topic.toUpperCase(),
        style: AppTypography.micro.copyWith(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CharacterAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const _CharacterAvatar({required this.initial, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.28),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.h2.copyWith(
          color: Colors.white,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

class _BeginPill extends StatelessWidget {
  final bool isLoading;

  const _BeginPill({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.fullBorder,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.purpleDeep),
              ),
            )
          else
            Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: AppColors.purpleDeep,
            ),
          const SizedBox(width: 4),
          Text(
            isLoading ? 'Starting…' : 'Begin',
            style: AppTypography.button.copyWith(
              color: AppColors.purpleDeep,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
