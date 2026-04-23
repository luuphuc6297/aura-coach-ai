import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_animations.dart';
import 'clay_pressable.dart';

enum ClayButtonVariant { primary, secondary, danger, ghost, pill, accentPurple }

class ClayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final ClayButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const ClayButton({
    super.key,
    required this.text,
    this.onTap,
    this.variant = ClayButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  Color get _bg {
    if (onTap == null) return AppColors.clayBeige;
    switch (variant) {
      case ClayButtonVariant.primary:
        return AppColors.teal;
      case ClayButtonVariant.secondary:
        return AppColors.clayWhite;
      case ClayButtonVariant.danger:
        return AppColors.error;
      case ClayButtonVariant.ghost:
        return Colors.transparent;
      case ClayButtonVariant.pill:
        return AppColors.teal;
      case ClayButtonVariant.accentPurple:
        return AppColors.purple;
    }
  }

  Color get _fg {
    if (onTap == null) return AppColors.warmLight;
    switch (variant) {
      case ClayButtonVariant.primary:
      case ClayButtonVariant.danger:
      case ClayButtonVariant.pill:
      case ClayButtonVariant.secondary:
      case ClayButtonVariant.accentPurple:
        return AppColors.warmDark;
      case ClayButtonVariant.ghost:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow> _shadow(bool isPressed) {
    if (onTap == null || variant == ClayButtonVariant.ghost) {
      return [];
    }
    if (variant == ClayButtonVariant.primary ||
        variant == ClayButtonVariant.accentPurple) {
      return isPressed ? AppShadows.clayBoldPressed : AppShadows.clayBold;
    }
    if (isPressed) return AppShadows.clayPressed;
    return AppShadows.clay;
  }

  Border? get _border {
    if (onTap != null &&
        (variant == ClayButtonVariant.primary ||
            variant == ClayButtonVariant.accentPurple)) {
      return Border.all(color: AppColors.warmDark, width: 2);
    }
    if (variant == ClayButtonVariant.secondary) {
      return Border.all(color: AppColors.clayBorder, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
      child: ClayPressable(
        onTap: isLoading ? null : onTap,
        enabled: onTap != null,
        builder: (context, isPressed) {
          return AnimatedContainer(
            duration: AppAnimations.durationFast,
            curve: AppAnimations.easeClay,
            width: isFullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: variant == ClayButtonVariant.pill ? 24 : 20,
              vertical: variant == ClayButtonVariant.pill ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: variant == ClayButtonVariant.pill
                  ? AppRadius.fullBorder
                  : AppRadius.lgBorder,
              border: _border,
              boxShadow: _shadow(isPressed),
            ),
            child: AnimatedOpacity(
              duration: AppAnimations.durationFast,
              opacity: onTap == null ? 0.5 : 1.0,
              child: Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: AppAnimations.durationFast,
                    child: isLoading
                        ? Stack(
                            key: const ValueKey('loading'),
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (icon != null) ...[
                                      icon!,
                                      const SizedBox(width: 10),
                                    ],
                                    Text(
                                      text,
                                      style: AppTypography.button
                                          .copyWith(color: _fg),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(_fg),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('content'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                icon!,
                                const SizedBox(width: 10),
                              ],
                              Text(
                                text,
                                style:
                                    AppTypography.button.copyWith(color: _fg),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
