import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/clay_badge.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_pressable.dart';

class ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconUrl;
  final Color accentColor;
  final String badgeText;
  final String ctaText;
  final String quotaText;
  final List<String> tags;
  final VoidCallback? onTap;
  final bool isLoading;

  const ModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.accentColor,
    required this.badgeText,
    required this.ctaText,
    required this.quotaText,
    required this.tags,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cream, accentColor.withValues(alpha: 0.08)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.fullBorder,
            ),
            child: Text(
              badgeText,
              style: AppTypography.caption.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.xlBorder,
              border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 2),
            ),
            child: Center(child: CloudImage(url: iconUrl, size: 100)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: AppTypography.h1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: tags.map((tag) {
              return ClayBadge(text: tag, accentColor: accentColor);
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClayPressable(
            onTap: isLoading ? null : onTap,
            builder: (context, isPressed) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.giant,
                  vertical: AppSpacing.mdd,
                ),
                decoration: BoxDecoration(
                  color: isLoading
                      ? accentColor.withValues(alpha: 0.6)
                      : accentColor,
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: AppShadows.colored(accentColor),
                ),
                child: AnimatedSwitcher(
                  duration: AppAnimations.durationFast,
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Text(
                          key: const ValueKey('text'),
                          '$ctaText \u{2192}',
                          style: AppTypography.button,
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(quotaText, style: AppTypography.caption),
        ],
      ),
    );
  }
}
