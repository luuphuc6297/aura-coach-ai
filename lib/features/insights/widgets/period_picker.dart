import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../providers/analytics_provider.dart';

/// Horizontal segmented control that drives [AnalyticsProvider.setPeriod].
/// Kept stateless so rebuilds are driven entirely by provider state.
class PeriodPicker extends StatelessWidget {
  final AnalyticsPeriod value;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const PeriodPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: context.clay.border, width: 2),
      ),
      child: Row(
        children: AnalyticsPeriod.values.map((option) {
          final isActive = option == value;
          return Expanded(
            child: ClayPressable(
              onTap: () => onChanged(option),
              scaleDown: 0.95,
              builder: (context, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.teal : Colors.transparent,
                    borderRadius: AppRadius.fullBorder,
                  ),
                  child: Center(
                    child: Text(
                      option.label,
                      style: AppTypography.labelMd.copyWith(
                        color: isActive ? AppColors.white : context.clay.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
