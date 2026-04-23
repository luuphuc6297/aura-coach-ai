import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_card.dart';

/// Placeholder Settings screen. Preview-only list so users understand what's
/// coming; actual toggles (notifications, reminder time, language, privacy,
/// data export, delete account) land in Phase 2.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text('Settings', style: AppTypography.sectionTitle),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Banner(
              accent: AppColors.purple,
              icon: Icons.settings_rounded,
              title: 'Settings — coming soon',
              description:
                  'Preferences below are a preview of Phase 2. Everything will '
                  'be editable once the backing providers are wired up.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsGroup(
              title: 'Practice',
              rows: [
                _SettingsRow(
                  icon: Icons.notifications_active_rounded,
                  accent: AppColors.teal,
                  label: 'Daily reminders',
                  trailing: 'Off',
                ),
                _SettingsRow(
                  icon: Icons.schedule_rounded,
                  accent: AppColors.teal,
                  label: 'Reminder time',
                  trailing: '8:00 PM',
                ),
                _SettingsRow(
                  icon: Icons.volume_up_rounded,
                  accent: AppColors.teal,
                  label: 'Auto-play audio',
                  trailing: 'On',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsGroup(
              title: 'App',
              rows: [
                _SettingsRow(
                  icon: Icons.language_rounded,
                  accent: AppColors.purple,
                  label: 'Display language',
                  trailing: 'English',
                ),
                _SettingsRow(
                  icon: Icons.dark_mode_rounded,
                  accent: AppColors.purple,
                  label: 'Theme',
                  trailing: 'System',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsGroup(
              title: 'Privacy',
              rows: [
                _SettingsRow(
                  icon: Icons.shield_rounded,
                  accent: AppColors.coral,
                  label: 'Data & privacy',
                  trailing: '',
                ),
                _SettingsRow(
                  icon: Icons.delete_outline_rounded,
                  accent: AppColors.coral,
                  label: 'Delete account',
                  trailing: '',
                  isDanger: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String description;

  const _Banner({
    required this.accent,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: AppRadius.mdBorder,
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
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warmMuted,
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

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsRow> rows;

  const _SettingsGroup({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.warmMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        ClayCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  const Divider(height: 1, color: AppColors.clayBorder),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String trailing;
  final bool isDanger;

  const _SettingsRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.trailing,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                color: isDanger ? AppColors.coral : AppColors.warmDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.warmMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.warmMuted,
          ),
        ],
      ),
    );
  }
}
