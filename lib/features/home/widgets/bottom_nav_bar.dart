import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../l10n/app_loc_context.dart';

/// Five-tab bottom nav: Home / Insight / AI Agent / Notifications / Profile.
///
/// Insight tab now wraps both the saved-vocabulary library and analytics
/// (sub-tabs inside [InsightsHubScreen]) — the standalone Library tab from
/// the previous 4-tab layout was dropped to make room for the AI Agent and
/// Notifications surfaces. AI Agent / Notifications / Insight currently
/// render with Material icons; swap to Cloudinary glyphs once the design
/// team ships dedicated artwork.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Unread notification count surfaced as a tiny coral dot on the bell
  /// icon. Wired from [NotificationsProvider] in N6; stays 0 until then.
  final int unreadNotificationCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadNotificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Container outside the SafeArea so the nav surface paints edge-to-edge
    // (including the iOS home-indicator zone). Inverting the order would
    // leave a gap below the icons where the Scaffold background bleeds
    // through and the top border floats above empty space on devices with
    // a bottom safe-area inset.
    return Container(
      decoration: BoxDecoration(
        color: context.clay.surface,
        border: Border(top: BorderSide(color: context.clay.border, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                imageUrl: CloudinaryAssets.navHome,
                label: context.loc.navHome,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.insights_rounded,
                label: context.loc.navInsight,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.support_agent_rounded,
                label: context.loc.navAiAgent,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.notifications_rounded,
                label: context.loc.navAlerts,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                badgeCount: unreadNotificationCount,
              ),
              _NavItem(
                fluentIconUrl: AppIcons.profile,
                label: context.loc.navProfile,
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
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
  final int badgeCount;

  const _NavItem({
    this.imageUrl,
    this.icon,
    this.fluentIconUrl,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: badgeCount > 0
          ? '$label, ${context.loc.navUnreadCount(badgeCount)}'
          : label,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildIcon(context),
                      if (badgeCount > 0)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: _UnreadBadge(count: badgeCount),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (imageUrl != null) {
      return CloudImage(url: imageUrl!, size: 32);
    } else if (fluentIconUrl != null) {
      return AppIcon(iconId: fluentIconUrl!, size: 28);
    } else {
      return Icon(
        icon,
        size: 30,
        color: isActive ? AppColors.tealDeep : context.clay.textFaint,
      );
    }
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : count.toString();
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.clay.surface, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
