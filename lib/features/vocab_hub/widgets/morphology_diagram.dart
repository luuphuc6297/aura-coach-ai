import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';

/// Renders prefix + root + suffix as a colored pill chain with the full
/// equation below. Missing affixes are omitted.
class MorphologyDiagram extends StatelessWidget {
  final Morphology morphology;
  const MorphologyDiagram({super.key, required this.morphology});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (morphology.prefix != null &&
        morphology.prefix!.morpheme.isNotEmpty) {
      chips.add(_Chip(
        label: morphology.prefix!.morpheme,
        sub: morphology.prefix!.meaning,
        color: AppColors.purple,
      ));
      chips.add(const _Plus());
    }
    chips.add(_Chip(
      label: morphology.root.morpheme,
      sub: morphology.root.meaning,
      color: AppColors.teal,
    ));
    if (morphology.suffix != null &&
        morphology.suffix!.morpheme.isNotEmpty) {
      chips.add(const _Plus());
      chips.add(_Chip(
        label: morphology.suffix!.morpheme,
        sub: morphology.suffix!.meaning,
        color: AppColors.coral,
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Morphology', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(morphology.equation, style: AppTypography.bodySm),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _Chip({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.sectionTitle.copyWith(color: color),
            ),
            Text(sub, style: AppTypography.caption),
          ],
        ),
      );
}

class _Plus extends StatelessWidget {
  const _Plus();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('+', style: TextStyle(fontSize: 18)),
      );
}
