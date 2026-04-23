import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_animations.dart';

/// Custom fade page transition matching design system spec.
CustomTransitionPage<T> fadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: AppAnimations.easeClay).animate(animation),
        child: child,
      );
    },
    transitionDuration: AppAnimations.durationNormal,
  );
}
