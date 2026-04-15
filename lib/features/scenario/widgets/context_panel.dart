import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
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
        color: AppColors.clayWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.clayBorder, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.clayBorder,
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
                  style: AppTypography.h2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                _infoCard(),
                const SizedBox(height: 10),
                _hintsCard(),
                const SizedBox(height: 10),
                _tipsCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
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
            style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
          ),
        ],
      ),
    );
  }

  Widget _hintsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
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
                    color: AppColors.warmMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
          if (hintsRevealed < scenario.hints.toFlatList().length)
            GestureDetector(
              onTap: onRevealHint,
              child: Text(
                '▶ Reveal next hint',
                style: AppTypography.caption.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
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
                color: AppColors.warmLight,
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
                      color: AppColors.warmMuted,
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
