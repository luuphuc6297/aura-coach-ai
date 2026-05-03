import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/clay_palette.dart';

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
    final palette = context.clay;
    return Shimmer.fromColors(
      baseColor: palette.surfaceAlt,
      highlightColor: palette.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: borderRadius ?? AppRadius.smBorder,
        ),
      ),
    );
  }
}
