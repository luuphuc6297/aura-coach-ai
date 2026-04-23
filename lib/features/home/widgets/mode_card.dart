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
          _FloatingIcon(
            accentColor: accentColor,
            iconUrl: iconUrl,
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
                      ? Stack(
                          key: const ValueKey('loading'),
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: Text(
                                '$ctaText \u{2192}',
                                style: AppTypography.button,
                              ),
                            ),
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.warmDark),
                              ),
                            ),
                          ],
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

class _FloatingIcon extends StatefulWidget {
  final Color accentColor;
  final String iconUrl;

  const _FloatingIcon({required this.accentColor, required this.iconUrl});

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.durationFloat,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeClay),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppAnimations.shouldReduceMotion(context);

    final container = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.xlBorder,
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Center(child: CloudImage(url: widget.iconUrl, size: 100)),
    );

    if (reduceMotion) return container;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: container,
    );
  }
}
