import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../subscription/services/revenuecat_ui.dart';

/// Subscription / paywall screen at `/subscription`.
///
/// Two render modes:
/// 1. **Free user** → embeds RevenueCat's hosted [PaywallView] so the
///    monthly / three-month / yearly packages render with native
///    pricing, trial badges, and platform-specific Buy buttons. We
///    supply our own header on top so the user can navigate back.
/// 2. **Pro user** → shows an active-plan summary with a CTA to open
///    RevenueCat's hosted Customer Center for managing the
///    subscription (cancel, refund request, billing issues, etc.).
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    return Scaffold(
      backgroundColor: context.clay.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isPro: sub.isPro),
            Expanded(
              child: !sub.isPurchasingSupported
                  ? const _UnsupportedPlatformState()
                  : (sub.isPro ? _ProActiveState(sub: sub) : _PaywallState(sub: sub)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isPro;
  const _Header({required this.isPro});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.clay.text),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isPro ? 'Aura Coach Pro' : 'Go Pro',
            style: AppTypography.title.copyWith(
              fontSize: 18,
              color: context.clay.text,
            ),
          ),
          const Spacer(),
          if (isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18),
                borderRadius: AppRadius.fullBorder,
                border: Border.all(color: AppColors.goldDeep, width: 1.5),
              ),
              child: Text(
                'PRO',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── free user → paywall ───────────────────────────────────────────────

class _PaywallState extends StatelessWidget {
  final SubscriptionProvider sub;
  const _PaywallState({required this.sub});

  @override
  Widget build(BuildContext context) {
    if (!sub.initialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.goldDeep),
      );
    }
    final offering = sub.currentOffering;
    if (offering == null) {
      return _OfferingsErrorState(error: sub.lastError, onRetry: sub.refresh);
    }
    // Embed RevenueCat's hosted paywall. Pricing, trial badges, and
    // package selection are all driven by the RevenueCat dashboard, so
    // experiments / region-specific paywalls work without app updates.
    return EmbeddedPaywall(
      offering: offering,
      onPurchaseCompleted: (info) {
        if (!context.mounted) return;
        if (info.entitlements.active.containsKey(
          SubscriptionProvider.proEntitlementId,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to Aura Coach Pro!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      },
      onRestoreCompleted: (info) {
        if (!context.mounted) return;
        final restored = info.entitlements.active.containsKey(
          SubscriptionProvider.proEntitlementId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(restored
                ? 'Pro restored — welcome back!'
                : 'No previous purchases found on this account.'),
            backgroundColor:
                restored ? AppColors.success : AppColors.warning,
          ),
        );
      },
    );
  }
}

class _OfferingsErrorState extends StatelessWidget {
  final String? error;
  final Future<void> Function() onRetry;
  const _OfferingsErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Plans unavailable right now',
              style: AppTypography.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              error ??
                  'We couldn\'t reach the payment service. Check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontSize: 12,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            ClayButton(
              text: 'Try again',
              variant: ClayButtonVariant.accentGold,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ── pro user → manage ─────────────────────────────────────────────────

class _ProActiveState extends StatelessWidget {
  final SubscriptionProvider sub;
  const _ProActiveState({required this.sub});

  @override
  Widget build(BuildContext context) {
    final expires = sub.proExpiresAt;
    final productLabel = _productLabel(sub.activeProductId);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ActivePlanCard(
            productLabel: productLabel,
            expiresAt: expires,
            inTrial: sub.isInFreeTrial,
          ),
          const SizedBox(height: AppSpacing.lg),
          ClayButton(
            text: 'Manage subscription',
            variant: ClayButtonVariant.accentGold,
            onTap: () async {
              try {
                await RevenueCatUiBridge.presentCustomerCenter();
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open Customer Center.'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ClayButton(
            text: 'Restore purchases',
            variant: ClayButtonVariant.secondary,
            onTap: () async {
              await sub.restorePurchases();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    sub.isPro ? 'Pro is active.' : 'No active purchases found.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _productLabel(String? productId) {
    switch (productId) {
      case 'monthly':
        return 'Monthly plan';
      case 'three_month':
        return 'Three-month plan';
      case 'yearly':
        return 'Yearly plan';
      default:
        return productId ?? 'Pro';
    }
  }
}

class _ActivePlanCard extends StatelessWidget {
  final String productLabel;
  final DateTime? expiresAt;
  final bool inTrial;

  const _ActivePlanCard({
    required this.productLabel,
    required this.expiresAt,
    required this.inTrial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.goldDeep, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.goldDeep, offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.goldDark, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(
                productLabel,
                style: AppTypography.title.copyWith(fontSize: 16),
              ),
              const Spacer(),
              if (inTrial)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(color: AppColors.success, width: 1),
                  ),
                  child: Text(
                    'TRIAL',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            expiresAt == null
                ? 'Active'
                : 'Renews on ${_formatDate(expiresAt!)}',
            style: AppTypography.bodySm.copyWith(
              color: context.clay.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

// ── unsupported platform ──────────────────────────────────────────────

class _UnsupportedPlatformState extends StatelessWidget {
  const _UnsupportedPlatformState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.devices_other_rounded,
                size: 56, color: context.clay.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Subscriptions are managed on iOS and Android.',
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(fontSize: 15),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Open Aura Coach on your phone to upgrade.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
