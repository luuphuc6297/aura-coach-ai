import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.clayBeige,
      highlightColor: AppColors.clayWhite,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.clayBeige,
          borderRadius: borderRadius ?? AppRadius.smBorder,
        ),
      ),
    );
  }
}
