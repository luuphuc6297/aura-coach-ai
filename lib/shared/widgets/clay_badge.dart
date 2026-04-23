import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class ClayBadge extends StatelessWidget {
  final String text;
  final Color accentColor;
  final bool isOutlined;

  const ClayBadge({
    super.key,
    required this.text,
    this.accentColor = AppColors.teal,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined
            ? Colors.transparent
            : accentColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
        border: isOutlined
            ? Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
