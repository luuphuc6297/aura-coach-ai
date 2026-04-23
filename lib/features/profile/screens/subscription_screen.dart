import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';

/// Placeholder Subscription / Upgrade screen. Outlines the Premium value
/// proposition with a disabled CTA until billing integration (Stripe / Play
/// Billing / App Store) lands in Phase 2.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
        title: Text('Go Premium', style: AppTypography.sectionTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(),
            const SizedBox(height: AppSpacing.lg),
            _BenefitsCard(),
            const SizedBox(height: AppSpacing.lg),
            _PricingCard(),
            const SizedBox(height: AppSpacing.xl),
            const ClayButton(
              text: 'Billing coming in Phase 2',
              onTap: null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Subscriptions activate once payment integration is live.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.25),
            AppColors.goldDeep.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.goldDeep.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.goldDeep.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 44,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Unlock Aura Premium',
            style: AppTypography.h1.copyWith(color: AppColors.warmDark),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Practice without limits. Get richer feedback on every session.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const benefits = [
      _Benefit(
        icon: Icons.all_inclusive_rounded,
        accent: AppColors.teal,
        title: 'Unlimited sessions',
        subtitle:
            'Scenarios, stories, and tone translations with no daily cap.',
      ),
      _Benefit(
        icon: Icons.auto_awesome_rounded,
        accent: AppColors.purple,
        title: 'AI illustrations',
        subtitle: 'Generate custom visuals for every saved word and moment.',
      ),
      _Benefit(
        icon: Icons.insights_rounded,
        accent: AppColors.coral,
        title: 'Deeper insights',
        subtitle: 'Trend lines, tone breakdowns, and weekly AI read-outs.',
      ),
      _Benefit(
        icon: Icons.headset_mic_rounded,
        accent: AppColors.goldDeep,
        title: 'Priority support',
        subtitle: 'Direct line to the Aura team for issues and feedback.',
      ),
    ];

    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s included',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.warmDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < benefits.length; i++) ...[
            benefits[i],
            if (i < benefits.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: AppRadius.smBorder,
          ),
          child: Icon(icon, size: 20, color: accent),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.warmDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Indicative pricing',
                style: AppTypography.sectionTitle.copyWith(
                  color: AppColors.warmDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Text(
                  'PREVIEW',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PlanRow(
            title: 'Monthly',
            subtitle: 'Billed every month',
            price: '\$9.99',
            cadence: '/mo',
          ),
          const SizedBox(height: AppSpacing.sm),
          _PlanRow(
            title: 'Yearly',
            subtitle: 'Save 40% — billed annually',
            price: '\$71.88',
            cadence: '/yr',
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String cadence;
  final bool highlight;

  const _PlanRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.cadence,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.goldDeep.withValues(alpha: 0.1)
            : AppColors.clayBeige,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: highlight
              ? AppColors.goldDeep.withValues(alpha: 0.4)
              : AppColors.clayBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.warmDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (highlight) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldDeep,
                          borderRadius: AppRadius.fullBorder,
                        ),
                        child: Text(
                          'BEST VALUE',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.clayWhite,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: AppTypography.h2.copyWith(
                color: AppColors.warmDark,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: price),
                TextSpan(
                  text: cadence,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
