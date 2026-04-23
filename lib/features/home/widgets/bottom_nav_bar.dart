import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../core/constants/cloudinary_assets.dart';

/// Four-tab bottom nav: Home / Library / Insights / Profile.
/// Library and Insights use Material icons since the Cloudinary asset set
/// only ships dedicated artwork for Home and Profile today; swap them out
/// once the design team produces matching glyphs.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.clayWhite,
          border:
              Border(top: BorderSide(color: AppColors.clayBorder, width: 2)),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              imageUrl: CloudinaryAssets.navHome,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.menu_book_rounded,
              label: 'Library',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.insights_rounded,
              label: 'Insights',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              fluentIconUrl: AppIcons.profile,
              label: 'Profile',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String? fluentIconUrl;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.imageUrl,
    this.icon,
    this.fluentIconUrl,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: isActive,
      child: ClayPressable(
        onTap: onTap,
        scaleDown: 0.85,
        builder: (context, isPressed) {
          return SizedBox(
            width: 56,
            height: 44,
            child: Center(
              child: AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: AppAnimations.durationMedium,
                curve: AppAnimations.easeClay,
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.45,
                  child: _buildIcon(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    if (imageUrl != null) {
      return CloudImage(url: imageUrl!, size: 32);
    } else if (fluentIconUrl != null) {
      return AppIcon(iconId: fluentIconUrl!, size: 28);
    } else {
      return Icon(
        icon,
        size: 30,
        color: isActive ? AppColors.tealDeep : AppColors.warmLight,
      );
    }
  }
}
