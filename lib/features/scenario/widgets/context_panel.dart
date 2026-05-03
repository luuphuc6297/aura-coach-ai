import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/app_icon.dart';
import '../models/scenario.dart';

class ContextPanel extends StatelessWidget {
  final Scenario scenario;
  final int hintsRevealed;
  final VoidCallback? onRevealHint;

  const ContextPanel({
    super.key,
    required this.scenario,
    required this.hintsRevealed,
    this.onRevealHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: context.clay.border, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.clay.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              children: [
                Text(
                  'Context Details',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 12),
                _infoCard(context),
                const SizedBox(height: 10),
                _hintsCard(context),
                const SizedBox(height: 10),
                _tipsCard(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.clay.surface,
        border: Border.all(color: context.clay.border, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT SCENARIO',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          if (scenario.title.isNotEmpty) ...[
            Text(
              scenario.title,
              style: AppTypography.bodyMd
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            scenario.situation,
            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Level: ${scenario.difficulty} · Topic: ${scenario.topic}',
            style: AppTypography.caption.copyWith(color: context.clay.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _hintsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.clay.surface,
        border: Border.all(color: context.clay.border, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(iconId: AppIcons.hint, size: 16),
              const SizedBox(width: 6),
              Text(
                'Hints ($hintsRevealed/${scenario.hints.toFlatList().length})',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A7B3D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(hintsRevealed, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.teal, width: 3),
                  ),
                ),
                child: Text(
                  scenario.hints.toFlatList()[i],
                  style: AppTypography.caption.copyWith(
                    color: context.clay.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
          if (hintsRevealed < scenario.hints.toFlatList().length)
            ClayPressable(
              onTap: onRevealHint,
              scaleDown: 0.95,
              builder: (context, isPressed) {
                return Text(
                  '▶ Reveal next hint',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _tipsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.clay.surface,
        border: Border.all(color: context.clay.border, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(iconId: 'practice', size: 14),
              const SizedBox(width: 6),
              Text(
                'Vocabulary Prep',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A7B3D),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (scenario.vocabularyPrep.isEmpty)
            Text(
              'No vocabulary prep for this scenario.',
              style: AppTypography.caption.copyWith(
                color: context.clay.textFaint,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...scenario.vocabularyPrep.map((word) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $word',
                    style: AppTypography.caption.copyWith(
                      color: context.clay.textMuted,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
