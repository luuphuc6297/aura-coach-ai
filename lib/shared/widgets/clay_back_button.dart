import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'clay_pressable.dart';

/// Canonical back button used in every navigable header. Keeping this in one
/// place means the icon, touch target, scale animation, and fallback pop
/// behavior stay consistent no matter which screen hosts it.
class ClayBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color iconColor;
  final double size;

  const ClayBackButton({
    super.key,
    this.onTap,
    this.iconColor = AppColors.warmDark,
    this.size = 44,
  });

  void _defaultPop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap ?? () => _defaultPop(context),
      scaleDown: 0.90,
      builder: (context, isPressed) {
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
        );
      },
    );
  }
}
