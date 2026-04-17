import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/cloudinary_assets.dart';
import 'cloud_image.dart';

class AuraLogo extends StatelessWidget {
  final double fontSize;
  final bool compact;
  final Color? color;

  const AuraLogo({super.key, this.fontSize = 28, this.compact = false, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.teal;
    final orbSize = fontSize * 2.0;
    final style = AppTypography.logo.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: fontSize * 0.04,
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('AURA C', style: style.copyWith(color: effectiveColor)),
          SizedBox(
            width: orbSize - AppSpacing.lg,
            height: orbSize,
            child: CloudImage(url: CloudinaryAssets.auraOrbLarge, size: orbSize),
          ),
          Text('ACH', style: style.copyWith(color: effectiveColor)),
          Text('.AI', style: style.copyWith(color: AppColors.warmDark, letterSpacing: 0)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('AURA', style: style.copyWith(color: effectiveColor)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('C', style: style.copyWith(color: effectiveColor)),
            SizedBox(
              width: orbSize - AppSpacing.giant,
              height: orbSize,
              child: CloudImage(url: CloudinaryAssets.auraOrbLarge, size: orbSize),
            ),
            Text('ACH', style: style.copyWith(color: effectiveColor)),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text('.AI', style: style.copyWith(color: AppColors.warmDark, letterSpacing: 0)),
            ),
          ],
        ),
      ],
    );
  }
}
