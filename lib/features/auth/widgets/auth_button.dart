import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';

enum AuthButtonVariant {
  google,
  apple,
  guest,
}

class AuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final AuthButtonVariant style;
  final VoidCallback? onTap;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.style,
    this.onTap,
    this.isLoading = false,
  });

  Color get _bg {
    switch (style) {
      case AuthButtonVariant.google:
        return AppColors.teal;
      case AuthButtonVariant.apple:
        return AppColors.warmDark;
      case AuthButtonVariant.guest:
        return Colors.transparent;
    }
  }

  Color get _fg {
    switch (style) {
      case AuthButtonVariant.google:
      case AuthButtonVariant.apple:
        return AppColors.white;
      case AuthButtonVariant.guest:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow>? get _shadow {
    switch (style) {
      case AuthButtonVariant.google:
        return AppShadows.clay;
      case AuthButtonVariant.apple:
        return AppShadows.colored(AppColors.warmDark, alpha: 0.3);
      case AuthButtonVariant.guest:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: isLoading ? null : onTap,
      enabled: onTap != null,
      builder: (context, isPressed) {
        return AnimatedOpacity(
          duration: AppAnimations.durationFast,
          opacity: onTap == null ? 0.5 : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: AppRadius.lgBorder,
              border: style == AuthButtonVariant.guest
                  ? Border.all(color: AppColors.clayBorder, width: 2)
                  : null,
              boxShadow: _shadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppAnimations.durationFast,
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(_fg),
                          ),
                        )
                      : Row(
                          key: const ValueKey('content'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            icon,
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              text,
                              style: AppTypography.button.copyWith(color: _fg),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
