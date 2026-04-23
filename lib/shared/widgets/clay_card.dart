import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_animations.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final Color selectedBorderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final String? semanticLabel;

  const ClayCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.selectedBorderColor = AppColors.teal,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.boxShadow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimations.durationFast,
          curve: AppAnimations.easeClay,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isSelected ? selectedBorderColor : AppColors.clayBorder,
              width: 2,
            ),
            boxShadow: boxShadow ?? (isSelected ? AppShadows.clay : AppShadows.card),
          ),
          child: child,
        ),
      ),
    );
  }
}
