import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../core/constants/story_constants.dart';
import '../models/story_character.dart';
import 'story_gradient.dart';

/// AppBar-like strip shown at the top of the Story chat screen.
/// Displays the character avatar (gradient + initial), name + situation,
/// and a turn-count chip pegged to [StoryConstants.hardCapUserTurns]. Colors
/// go from teal→red as the user approaches the hard cap.
class StoryCharacterHeader extends StatelessWidget {
  final StoryCharacter character;
  final String title;
  final String situation;
  final int userTurnCount;
  final VoidCallback onBack;
  final VoidCallback onEnd;

  const StoryCharacterHeader({
    super.key,
    required this.character,
    required this.title,
    required this.situation,
    required this.userTurnCount,
    required this.onBack,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = storyGradientFor(character.gradient);
    final cap = StoryConstants.hardCapUserTurns;
    final warn = StoryConstants.warningTurn;
    final isWarn = userTurnCount >= warn;
    final chipColor = isWarn ? AppColors.error : AppColors.teal;
    final chipLabel = '$userTurnCount/$cap turns';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 12),
      decoration: BoxDecoration(
        color: context.clay.surface,
        border: Border(
          bottom: BorderSide(color: context.clay.border, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClayPressable(
                onTap: onBack,
                scaleDown: 0.9,
                builder: (ctx, __) => SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: ctx.clay.text,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _Avatar(gradient: gradient, initial: character.initial),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name.isNotEmpty ? character.name : 'Character',
                      style: AppTypography.labelLg.copyWith(
                        color: context.clay.text,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      character.role.isNotEmpty
                          ? character.role
                          : 'Conversation partner',
                      style: AppTypography.caption.copyWith(
                        color: context.clay.textMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TurnChip(label: chipLabel, color: chipColor),
              const SizedBox(width: 6),
              ClayPressable(
                onTap: onEnd,
                scaleDown: 0.92,
                builder: (ctx, __) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ctx.clay.surfaceAlt,
                      borderRadius: AppRadius.fullBorder,
                      border:
                          Border.all(color: ctx.clay.border, width: 1.5),
                    ),
                    child: Text(
                      'End',
                      style: AppTypography.button.copyWith(
                        fontSize: 12,
                        color: ctx.clay.text,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (title.isNotEmpty || situation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: AppTypography.labelMd.copyWith(
                              color: context.clay.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (situation.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            situation,
                            style: AppTypography.caption.copyWith(
                              color: context.clay.text,
                              fontSize: 11,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final List<Color> gradient;
  final String initial;

  const _Avatar({required this.gradient, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        shape: BoxShape.circle,
        boxShadow: AppShadows.card(context),
      ),
      alignment: Alignment.center,
      child: Text(
        initial.isNotEmpty ? initial : '?',
        style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

class _TurnChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TurnChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.micro.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
