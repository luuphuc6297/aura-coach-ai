import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_animations.dart';

/// Pure cross-fade transition for go() navigations (screen replacement).
CustomTransitionPage<T> fadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (AppAnimations.shouldReduceMotion(context)) return child;
      return FadeTransition(
        opacity: CurveTween(curve: AppAnimations.easeClay).animate(animation),
        child: child,
      );
    },
    transitionDuration: AppAnimations.durationNormal,
  );
}

/// Fade + slight slide-up for push() navigations (layered screens).
CustomTransitionPage<T> slideFadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (AppAnimations.shouldReduceMotion(context)) return child;
      final curvedAnimation = CurveTween(
        curve: AppAnimations.easeClay,
      ).animate(animation);

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
    transitionDuration: AppAnimations.durationNormal,
  );
}
