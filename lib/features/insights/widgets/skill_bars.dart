import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_card.dart';

/// Four horizontal progress bars — one per skill axis. Input values are 0..100.
/// Each axis gets its own Clay accent so the card reads as a small-multiple
/// rather than a repeating teal block.
class SkillBars extends StatelessWidget {
  final double fluency;
  final double accuracy;
  final double naturalness;
  final double complexity;

  const SkillBars({
    super.key,
    required this.fluency,
    required this.accuracy,
    required this.naturalness,
    required this.complexity,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skill breakdown', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          _SkillRow(
            label: 'Fluency',
            value: fluency,
            color: AppColors.teal,
          ),
          const SizedBox(height: AppSpacing.md),
          _SkillRow(
            label: 'Accuracy',
            value: accuracy,
            color: AppColors.formalTone,
          ),
          const SizedBox(height: AppSpacing.md),
          _SkillRow(
            label: 'Naturalness',
            value: naturalness,
            color: AppColors.gold,
          ),
          const SizedBox(height: AppSpacing.md),
          _SkillRow(
            label: 'Complexity',
            value: complexity,
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SkillRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.labelLg.copyWith(
                color: context.clay.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              clamped == 0 ? '—' : clamped.round().toString(),
              style: AppTypography.labelLg.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.clay.surfaceAlt,
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * (clamped / 100),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
