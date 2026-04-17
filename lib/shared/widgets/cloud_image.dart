import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import 'shimmer_placeholder.dart';

class CloudImage extends StatelessWidget {
  final String url;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CloudImage({
    super.key,
    required this.url,
    this.size = 64,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: fit,
      placeholder: (_, __) => ShimmerPlaceholder(
        width: size,
        height: size,
        borderRadius: borderRadius,
      ),
      errorWidget: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.broken_image, color: AppColors.warmLight),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
