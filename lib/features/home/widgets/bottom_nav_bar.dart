import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../core/constants/cloudinary_assets.dart';

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
          border: Border(top: BorderSide(color: AppColors.clayBorder, width: 2)),
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
              emoji: '\u{1F464}',
              label: 'Profile',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              imageUrl: CloudinaryAssets.navSettings,
              label: 'Settings',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
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
  final String? emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.imageUrl,
    this.icon,
    this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
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
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (imageUrl != null) {
      return CloudImage(url: imageUrl!, size: 32);
    } else if (emoji != null) {
      return Text(
        emoji!,
        style: const TextStyle(fontSize: 28),
      );
    } else {
      return Icon(
        icon,
        size: 32,
        color: isActive ? AppColors.teal : AppColors.warmLight,
      );
    }
  }
}
