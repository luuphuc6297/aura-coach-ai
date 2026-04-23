import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_dialog.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../insights/providers/analytics_provider.dart';
import '../../insights/widgets/progress_preview_card.dart';

/// Profile tab. Combines identity, preferences, a Your-Progress preview card
/// that deep-links into the Insights tab, and an account-actions row group.
///
/// [onOpenInsights] is supplied by the HomeScreen tab host and is invoked
/// when the user taps the preview card or the "View full →" link. When null
/// (e.g., if the screen is ever routed standalone), the deep-link falls back
/// to a no-op rather than crashing.
class ProfileScreen extends StatelessWidget {
  final VoidCallback? onOpenInsights;

  const ProfileScreen({super.key, this.onOpenInsights});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final profile = homeProvider.userProfile;

    if (homeProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.teal,
          strokeWidth: 2.5,
        ),
      );
    }

    if (profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(iconId: AppIcons.profile, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Profile not available',
              style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
            ),
          ],
        ),
      );
    }

    final analytics = context.watch<AnalyticsProvider>();
    final isPremium = profile.tier == 'premium';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          _AvatarHeader(
            avatarUrl: profile.avatarUrl,
            name: profile.name,
            tier: profile.tier,
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoSection(
            items: [
              _InfoItem(
                iconUrl: AppIcons.level,
                label: 'Level',
                value: _formatLevel(profile.proficiencyLevel),
              ),
              _InfoItem(
                iconUrl: AppIcons.clock,
                label: 'Daily Goal',
                value: '${profile.dailyMinutes} min',
              ),
              _InfoItem(
                iconUrl: AppIcons.crown,
                label: 'Plan',
                value: _formatTier(profile.tier),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProgressPreviewCard(
            fluencyScore: analytics.fluencyScore,
            streakDays: analytics.currentStreak,
            sessionsThisPeriod: analytics.sessionsInPeriod,
            topWeakWord: analytics.topWeakWord,
            onOpenInsights: onOpenInsights ?? () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          if (profile.selectedGoals.isNotEmpty) ...[
            _TagSection(
              iconUrl: AppIcons.goal,
              title: 'Goals',
              tags: profile.selectedGoals,
              tagColor: AppColors.teal,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (profile.selectedTopics.isNotEmpty) ...[
            _TagSection(
              iconUrl: AppIcons.topic,
              title: 'Topics',
              tags: profile.selectedTopics,
              tagColor: AppColors.purple,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _ActionRowCard(
            rows: [
              _ActionRow(
                icon: Icons.edit_rounded,
                label: 'Edit profile',
                subtitle: 'Name, avatar, level, daily goal',
                accent: AppColors.teal,
                onTap: () => context.push('/edit-profile'),
              ),
              _ActionRow(
                icon: Icons.settings_rounded,
                label: 'Settings',
                subtitle: 'Language, notifications, privacy',
                accent: AppColors.purple,
                onTap: () => context.push('/settings'),
              ),
              if (!isPremium)
                _ActionRow(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Upgrade to Premium',
                  subtitle: 'Unlimited practice + AI illustrations',
                  accent: AppColors.goldDeep,
                  onTap: () => context.push('/subscription'),
                  showBadge: true,
                ),
              _ActionRow(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                subtitle: profile.name.isEmpty
                    ? 'End your session'
                    : 'Signed in as ${profile.name}',
                accent: AppColors.coral,
                onTap: () => _showSignOutConfirmation(context),
                isDanger: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  String _formatLevel(String level) {
    if (level.isEmpty) return 'Not set';
    return '${level[0].toUpperCase()}${level.substring(1)}';
  }

  String _formatTier(String tier) {
    if (tier.isEmpty) return 'Free';
    return '${tier[0].toUpperCase()}${tier.substring(1)}';
  }

  void _showSignOutConfirmation(BuildContext context) {
    showClayDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.clayWhite,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(iconId: AppIcons.signOut, size: 40),
                const SizedBox(height: AppSpacing.lg),
                Text('Sign Out', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Are you sure you want to sign out?',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        text: 'Cancel',
                        variant: ClayButtonVariant.secondary,
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ClayButton(
                        text: 'Sign Out',
                        variant: ClayButtonVariant.danger,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AuthProvider>().signOut();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarHeader extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String tier;

  const _AvatarHeader({
    required this.avatarUrl,
    required this.name,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.teal, width: 3),
            boxShadow: AppShadows.clay,
            color: AppColors.clayWhite,
          ),
          child: ClipOval(
            child: CloudImage(url: avatarUrl, size: 82),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          name.isNotEmpty ? name : 'Aura Learner',
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: tier == 'premium'
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.teal.withValues(alpha: 0.12),
            borderRadius: AppRadius.fullBorder,
            border: Border.all(
              color: tier == 'premium'
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : AppColors.teal.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            tier == 'premium' ? 'Premium' : 'Free Plan',
            style: AppTypography.sentenceLabel.copyWith(
              color: tier == 'premium' ? AppColors.goldDark : AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final String iconUrl;
  final String label;
  final String value;

  const _InfoItem({
    required this.iconUrl,
    required this.label,
    required this.value,
  });
}

class _InfoSection extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.mdd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  Container(
                    width: 1,
                    height: 36,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    color: AppColors.clayBorder,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      AppIcon(iconId: item.iconUrl, size: 22),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.value,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.label,
                        style: AppTypography.micro.copyWith(
                          color: AppColors.warmLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final String iconUrl;
  final String title;
  final List<String> tags;
  final Color tagColor;

  const _TagSection({
    required this.iconUrl,
    required this.title,
    required this.tags,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(iconId: iconUrl, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                    color: tagColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  _formatTag(tag),
                  style: AppTypography.caption.copyWith(
                    color: tagColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatTag(String tag) {
    if (tag.isEmpty) return tag;
    return '${tag[0].toUpperCase()}${tag.substring(1)}';
  }
}

class _ActionRow {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool isDanger;
  final bool showBadge;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.isDanger = false,
    this.showBadge = false,
  });
}

class _ActionRowCard extends StatelessWidget {
  final List<_ActionRow> rows;

  const _ActionRowCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              _ActionRowWidget(row: row),
              if (i < rows.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                  color: AppColors.clayBorder,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionRowWidget extends StatelessWidget {
  final _ActionRow row;

  const _ActionRowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: row.onTap,
      scaleDown: 0.98,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: row.accent.withValues(alpha: 0.14),
                borderRadius: AppRadius.smBorder,
              ),
              child: Icon(
                row.icon,
                color: row.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          row.label,
                          style: AppTypography.labelLg.copyWith(
                            color: row.isDanger
                                ? AppColors.coral
                                : AppColors.warmDark,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (row.showBadge) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldDeep,
                            borderRadius: AppRadius.fullBorder,
                          ),
                          child: Text(
                            'PRO',
                            style: AppTypography.micro.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warmMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.warmLight,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
