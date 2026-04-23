import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Maps the Story character gradient slug to a concrete Material gradient.
/// Mirrors `StoryConstants.characterGradients` so new slugs there need a
/// corresponding entry here (unknown slugs fall back to teal→purple).
List<Color> storyGradientFor(String slug) {
  switch (slug) {
    case 'teal-purple':
      return [AppColors.teal, AppColors.purpleDeep];
    case 'gold-peach':
      return [AppColors.gold, AppColors.coral];
    case 'purple-pink':
      return [AppColors.purple, AppColors.coral];
    case 'teal-gold':
      return [AppColors.teal, AppColors.gold];
    default:
      return [AppColors.teal, AppColors.purpleDeep];
  }
}
