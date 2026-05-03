import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/clay_palette.dart';
import 'clay_pressable.dart';

enum ClayButtonVariant {
  primary,
  secondary,
  danger,
  ghost,
  pill,
  accentPurple,
  accentCoral,
  accentGold,
}

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

  Color _bg(BuildContext context) {
    if (onTap == null) return context.clay.surfaceAlt;
    switch (variant) {
      case ClayButtonVariant.primary:
        return AppColors.teal;
      case ClayButtonVariant.secondary:
        return context.clay.surface;
      case ClayButtonVariant.danger:
        return AppColors.error;
      case ClayButtonVariant.ghost:
        return Colors.transparent;
      case ClayButtonVariant.pill:
        return AppColors.teal;
      case ClayButtonVariant.accentPurple:
        return AppColors.purple;
      case ClayButtonVariant.accentCoral:
        return AppColors.coral;
      case ClayButtonVariant.accentGold:
        return AppColors.gold;
    }
  }

  Color _fg(BuildContext context) {
    if (onTap == null) return context.clay.textFaint;
    switch (variant) {
      // Accent backgrounds (teal/coral/gold/purple) and danger are
      // intentionally bright in BOTH modes — keep dark text on top so the
      // label stays readable. Don't flip with theme.
      case ClayButtonVariant.primary:
      case ClayButtonVariant.danger:
      case ClayButtonVariant.pill:
      case ClayButtonVariant.accentPurple:
      case ClayButtonVariant.accentCoral:
      case ClayButtonVariant.accentGold:
        return AppColors.warmDark;
      case ClayButtonVariant.secondary:
        return context.clay.text;
      case ClayButtonVariant.ghost:
        return context.clay.textMuted;
    }
  }

  List<BoxShadow> _shadow(BuildContext context, bool isPressed) {
    if (onTap == null || variant == ClayButtonVariant.ghost) {
      return [];
    }
    if (variant == ClayButtonVariant.primary ||
        variant == ClayButtonVariant.accentPurple ||
        variant == ClayButtonVariant.accentCoral ||
        variant == ClayButtonVariant.accentGold) {
      return isPressed
          ? AppShadows.clayBoldPressed(context)
          : AppShadows.clayBold(context);
    }
    if (isPressed) return AppShadows.clayPressed(context);
    return AppShadows.clay(context);
  }

  Border? _border(BuildContext context) {
    if (onTap != null &&
        (variant == ClayButtonVariant.primary ||
            variant == ClayButtonVariant.accentPurple ||
            variant == ClayButtonVariant.accentCoral ||
            variant == ClayButtonVariant.accentGold)) {
      // Bold outline on accent buttons — dark in light mode, cream in dark.
      // Both pop against the constant accent fill.
      return Border.all(color: context.clay.text, width: 2);
    }
    if (variant == ClayButtonVariant.secondary) {
      return Border.all(color: context.clay.border, width: 2);
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
              color: _bg(context),
              borderRadius: variant == ClayButtonVariant.pill
                  ? AppRadius.fullBorder
                  : AppRadius.lgBorder,
              border: _border(context),
              boxShadow: _shadow(context, isPressed),
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
                                          .copyWith(color: _fg(context)),
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
                                  valueColor: AlwaysStoppedAnimation(_fg(context)),
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
                                    AppTypography.button.copyWith(color: _fg(context)),
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
