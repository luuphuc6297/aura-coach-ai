import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../home/providers/home_provider.dart';
import '../widgets/vocab_feature_card.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Vocab Hub landing screen. Replaces the old 5-tab TabBar layout with a
/// vertical list of feature cards grouped into Free (6) and Pro (1) tiers.
/// Icon tiles use animated `AppIcon` painters (same family as onboarding) so
/// the deep-dive surface stays visually consistent with the rest of the app.
/// The mode accent (coral) is reserved for the hero banner, PRO badge, and
/// upgrade affordances.
class VocabHubHomeScreen extends StatelessWidget {
  const VocabHubHomeScreen({super.key});

  static const Color _accent = AppColors.coral;
  static const Set<String> _paidTiers = {'pro', 'premium'};

  /// Feature lists are built per-frame so localized titles/descriptions flow
  /// through `context.loc`. Icon colors and routes stay theme-invariant.
  List<_VocabFeature> _freeFeatures(BuildContext context) {
    final loc = context.loc;
    return [
      _VocabFeature(
        iconId: 'feat_magnifier',
        title: loc.vocabHubCardWordAnalysis,
        description: loc.vocabHubCardWordAnalysisDesc,
        route: '/vocab-hub/analysis',
        iconColor: AppColors.teal,
      ),
      _VocabFeature(
        iconId: 'feat_describe',
        title: loc.vocabHubCardDescribeWord,
        description: loc.vocabHubCardDescribeWordDesc,
        route: '/vocab-hub/describe',
        iconColor: AppColors.purple,
      ),
      _VocabFeature(
        iconId: 'feat_cards',
        title: loc.vocabHubCardFlashcards,
        description: loc.vocabHubCardFlashcardsDesc,
        route: '/vocab-hub/flashcards',
        iconColor: AppColors.coral,
      ),
      _VocabFeature(
        iconId: 'feat_compare',
        title: loc.vocabHubCardCompareWords,
        description: loc.vocabHubCardCompareWordsDesc,
        route: '/vocab-hub/compare',
        iconColor: AppColors.gold,
      ),
      _VocabFeature(
        iconId: 'feat_openBook',
        title: loc.vocabHubCardLearningLibrary,
        description: loc.vocabHubCardLearningLibraryDesc,
        route: '/vocab-hub/library',
        iconColor: AppColors.gold,
      ),
      _VocabFeature(
        iconId: 'feat_chartUp',
        title: loc.vocabHubCardProgressDashboard,
        description: loc.vocabHubCardProgressDashboardDesc,
        route: '/vocab-hub/progress',
        iconColor: AppColors.success,
      ),
    ];
  }

  List<_VocabFeature> _proFeatures(BuildContext context) {
    final loc = context.loc;
    return [
      _VocabFeature(
        iconId: 'feat_brain',
        title: loc.vocabHubCardMindMaps,
        description: loc.vocabHubCardMindMapsDesc,
        route: '/vocab-hub/mind-map',
        iconColor: AppColors.purple,
        isPro: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tier = context.select<HomeProvider, String>(
      (p) => p.userProfile?.tier ?? 'free',
    );
    final hasPro = _paidTiers.contains(tier);

    final freeFeatures = _freeFeatures(context);
    final proFeatures = _proFeatures(context);

    return VocabHubScaffold(
      title: context.loc.vocabHubTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          const _ModeHeroBanner(),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(
            label: context.loc.vocabHubSectionFreeTools,
            count: freeFeatures.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...freeFeatures.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VocabFeatureCard(
                iconId: f.iconId,
                title: f.title,
                description: f.description,
                iconColor: f.iconColor,
                accentColor: _accent,
                onTap: () => context.push(f.route),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(
            label: context.loc.vocabHubSectionProTools,
            count: proFeatures.length,
            trailingBadge: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...proFeatures.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VocabFeatureCard(
                iconId: f.iconId,
                title: f.title,
                description: f.description,
                iconColor: f.iconColor,
                accentColor: _accent,
                isPro: f.isPro,
                isLocked: f.isPro && !hasPro,
                onTap: () => context.push(f.route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabFeature {
  final String iconId;
  final String title;
  final String description;
  final String route;
  final Color iconColor;
  final bool isPro;

  const _VocabFeature({
    required this.iconId,
    required this.title,
    required this.description,
    required this.route,
    required this.iconColor,
    this.isPro = false,
  });
}

/// Coral → gold gradient hero banner at the top of Vocab Hub home. Matches
/// the `.mode-hero` block in `docs/mockup-design/mockups-vocab-hub-deep-dive
/// .html` — 52×52 icon tile on the left, Fredoka headline + Inter subline on
/// the right, 2px warm-dark border + 3×3 clay shadow.
class _ModeHeroBanner extends StatelessWidget {
  const _ModeHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.coral, AppColors.gold],
        ),
        border: Border.all(color: context.clay.text, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.clay(context),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: const AppIcon(
              iconId: 'vocabHub',
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Deep-dive into any word',
                  style: AppTypography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Analysis · Describe · Flashcards · Compare · Library',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12,
                    height: 1.4,
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

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool trailingBadge;

  const _SectionHeader({
    required this.label,
    required this.count,
    this.trailingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count $label',
          style: AppTypography.sectionTitle.copyWith(
            fontWeight: FontWeight.w700,
            color: context.clay.text,
          ),
        ),
        if (trailingBadge) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.coral, width: 1),
            ),
            child: Text(
              '👑 PRO',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.coral,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
