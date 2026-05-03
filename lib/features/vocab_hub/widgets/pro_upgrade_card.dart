import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';

/// Paywall surface shown inside any Vocab Hub sub-screen that's gated behind a
/// Pro tier. Layout intentionally keeps copy short — the value prop belongs
/// here, full feature comparison belongs on /subscription.
///
/// The accent color defaults to coral so the card matches the Vocab Hub mode
/// identity. Pass a different accent when embedding inside another mode.
class ProUpgradeCard extends StatelessWidget {
  final String title;
  final String description;
  final String ctaLabel;
  final Color accentColor;
  final ClayButtonVariant ctaVariant;

  const ProUpgradeCard({
    super.key,
    required this.title,
    required this.description,
    this.ctaLabel = 'Upgrade to Pro',
    this.accentColor = AppColors.coral,
    this.ctaVariant = ClayButtonVariant.accentCoral,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ClayCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor, width: 1.2),
                    ),
                    child: Text(
                      'PRO',
                      style: AppTypography.labelSm.copyWith(
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              ClayButton(
                text: ctaLabel,
                variant: ctaVariant,
                onTap: () => context.push('/subscription'),
              ),
            ],
          ),
        ),
      );
}
