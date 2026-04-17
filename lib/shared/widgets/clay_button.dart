import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_animations.dart';

enum ClayButtonVariant { primary, secondary, danger, ghost, pill }

class ClayButton extends StatefulWidget {
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

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  Color get _bg {
    if (widget.onTap == null) return AppColors.clayBeige;
    switch (widget.variant) {
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
    }
  }

  Color get _fg {
    if (widget.onTap == null) return AppColors.warmLight;
    switch (widget.variant) {
      case ClayButtonVariant.primary:
      case ClayButtonVariant.danger:
      case ClayButtonVariant.pill:
        return AppColors.white;
      case ClayButtonVariant.secondary:
        return AppColors.warmDark;
      case ClayButtonVariant.ghost:
        return AppColors.warmMuted;
    }
  }

  List<BoxShadow> get _shadow {
    if (widget.onTap == null || widget.variant == ClayButtonVariant.ghost) {
      return [];
    }
    if (_isPressed) return AppShadows.clayPressed;
    return AppShadows.clay;
  }

  Border? get _border {
    if (widget.variant == ClayButtonVariant.secondary) {
      return Border.all(color: AppColors.clayBorder, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.text,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: AppAnimations.durationFast,
          curve: AppAnimations.easeClay,
          width: widget.isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.variant == ClayButtonVariant.pill ? 24 : 20,
            vertical: widget.variant == ClayButtonVariant.pill ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: widget.variant == ClayButtonVariant.pill
                ? AppRadius.fullBorder
                : AppRadius.lgBorder,
            border: _border,
            boxShadow: _shadow,
          ),
          child: AnimatedOpacity(
            duration: AppAnimations.durationFast,
            opacity: widget.onTap == null ? 0.5 : 1.0,
            child: Row(
              mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_fg),
                    ),
                  ),
                ] else ...[
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.text,
                    style: AppTypography.button.copyWith(color: _fg),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
