import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_animations.dart';

/// Wrapper for Lottie animations with reduced-motion and error handling.
///
/// When reduced motion is enabled, shows the last frame (static).
/// Falls back to [fallback] widget on load error.
class LottieAsset extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool animate;
  final bool repeat;
  final Widget? fallback;
  final void Function(LottieComposition)? onLoaded;

  const LottieAsset({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.animate = true,
    this.repeat = true,
    this.fallback,
    this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = animate && !AppAnimations.shouldReduceMotion(context);

    return Lottie.network(
      url,
      width: width,
      height: height,
      fit: fit,
      animate: shouldAnimate,
      repeat: repeat,
      onLoaded: onLoaded,
      errorBuilder: (context, error, stackTrace) {
        return fallback ?? SizedBox(width: width, height: height);
      },
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return fallback ?? SizedBox(width: width, height: height);
        }
        return child;
      },
    );
  }
}

/// LottieAsset variant that loads from a local asset path.
class LottieLocalAsset extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool animate;
  final bool repeat;
  final Widget? fallback;

  const LottieLocalAsset({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.animate = true,
    this.repeat = true,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = animate && !AppAnimations.shouldReduceMotion(context);

    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      animate: shouldAnimate,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        return fallback ?? SizedBox(width: width, height: height);
      },
    );
  }
}
