import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_triggers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../my_library/providers/library_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/settings_provider.dart';

/// Settings screen — every row is reactive against [SettingsProvider] and
/// hooks into the appropriate side-effect (NotificationTriggers for
/// reminders, MaterialApp.themeMode via provider for theme, AuthProvider
/// for delete-account, etc.).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
        title: Text(context.loc.settingsTitle, style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Group(
              title: context.loc.settingsGroupPractice,
              children: [
                _SwitchRow(
                  icon: Icons.notifications_active_rounded,
                  accent: AppColors.teal,
                  label: context.loc.settingsRowDailyReminders,
                  value: settings.dailyRemindersEnabled,
                  onChanged: (v) => _toggleReminders(context, v),
                ),
                const _Divider(),
                _ValueRow(
                  icon: Icons.schedule_rounded,
                  accent: AppColors.teal,
                  label: context.loc.settingsRowReminderTime,
                  value: settings.reminderTime.format(context),
                  enabled: settings.dailyRemindersEnabled,
                  onTap: () => _pickReminderTime(context),
                ),
                const _Divider(),
                _SwitchRow(
                  icon: Icons.volume_up_rounded,
                  accent: AppColors.teal,
                  label: context.loc.settingsRowAutoPlayAudio,
                  value: settings.autoPlayAudio,
                  onChanged: settings.setAutoPlayAudio,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Group(
              title: context.loc.settingsGroupApp,
              children: [
                _ValueRow(
                  icon: Icons.language_rounded,
                  accent: AppColors.purple,
                  label: context.loc.settingsRowDisplayLanguage,
                  value: _languageLabel(settings.language),
                  onTap: () => _pickLanguage(context),
                ),
                const _Divider(),
                _ValueRow(
                  icon: Icons.dark_mode_rounded,
                  accent: AppColors.purple,
                  label: context.loc.settingsRowTheme,
                  value: _themeLabel(context, settings.themeMode),
                  onTap: () => _pickTheme(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Group(
              title: context.loc.settingsGroupPrivacy,
              children: [
                _ValueRow(
                  icon: Icons.shield_rounded,
                  accent: AppColors.coral,
                  label: context.loc.settingsRowDataPrivacy,
                  value: '',
                  onTap: () => context.push('/privacy'),
                ),
                const _Divider(),
                _ValueRow(
                  icon: Icons.delete_outline_rounded,
                  accent: AppColors.coral,
                  label: context.loc.settingsRowDeleteAccount,
                  value: '',
                  isDanger: true,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- handlers ----------

  Future<void> _toggleReminders(BuildContext context, bool enabled) async {
    final settings = context.read<SettingsProvider>();
    final notifications = context.read<NotificationsProvider>();
    final library = context.read<LibraryProvider>();
    await settings.setDailyRemindersEnabled(enabled);
    if (enabled) {
      // Make sure the OS permission is granted before scheduling.
      final granted = await NotificationService.instance.hasPermission();
      if (!granted) await NotificationService.instance.requestPermission();
      await NotificationTriggers.instance
          .refresh(notifications: notifications, library: library);
    } else {
      await NotificationTriggers.instance.cancelAll();
    }
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.dailyRemindersEnabled) return;
    final notifications = context.read<NotificationsProvider>();
    final library = context.read<LibraryProvider>();
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
      helpText: context.loc.settingsReminderTimeHelp,
    );
    if (picked == null) return;
    await settings.setReminderTime(picked);
    await NotificationTriggers.instance.setReminderTime(
      hour: picked.hour,
      minute: picked.minute,
      notifications: notifications,
      library: library,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final loc = context.loc;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.settingsDeleteTitle),
        content: Text(loc.settingsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: Text(loc.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result = await auth.deleteAccount();
    if (!context.mounted) return;
    if (result == null) {
      // Success — auth listener will redirect to /auth.
      messenger.showSnackBar(
        SnackBar(content: Text(loc.settingsDeleteSuccess)),
      );
    } else if (result == 'requires-recent-login') {
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.settingsDeleteRequiresLogin),
          duration: const Duration(seconds: 4),
        ),
      );
      await auth.signOut();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(loc.settingsDeleteFailed)),
      );
    }
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return 'System';
    }
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.clay.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.clay.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.loc.settingsLanguagePickerTitle,
                  style: AppTypography.h2,
                ),
              ),
            ),
            for (final code in const ['en', 'vi'])
              ListTile(
                leading: const Icon(
                  Icons.language_rounded,
                  color: AppColors.purple,
                ),
                title: Text(_languageLabel(code)),
                trailing: settings.language == code
                    ? const Icon(Icons.check_rounded, color: AppColors.purple)
                    : null,
                onTap: () => Navigator.of(ctx).pop(code),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await settings.setLanguage(picked);
  }

  String _themeLabel(BuildContext context, ThemeMode mode) {
    final loc = context.loc;
    switch (mode) {
      case ThemeMode.light:
        return loc.settingsThemeLight;
      case ThemeMode.dark:
        return loc.settingsThemeDark;
      case ThemeMode.system:
        return loc.settingsThemeSystem;
    }
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  Future<void> _pickTheme(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: context.clay.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.clay.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.loc.settingsThemePickerTitle,
                  style: AppTypography.h2,
                ),
              ),
            ),
            for (final mode in ThemeMode.values)
              ListTile(
                leading: Icon(_themeIcon(mode), color: AppColors.purple),
                title: Text(_themeLabel(ctx, mode)),
                trailing: settings.themeMode == mode
                    ? const Icon(Icons.check_rounded, color: AppColors.purple)
                    : null,
                onTap: () => Navigator.of(ctx).pop(mode),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await settings.setThemeMode(picked);
  }
}

// ---------- row primitives ----------

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Group({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 8),
          child: Text(
            title,
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        ClayCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: context.clay.border);
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 8,
      ),
      child: Row(
        children: [
          _LeadingIcon(icon: icon, accent: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                color: context.clay.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.teal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isDanger;
  final bool enabled;

  const _ValueRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.onTap,
    this.isDanger = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _LeadingIcon(icon: icon, accent: accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    color: isDanger ? AppColors.coral : context.clay.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value,
                    style: AppTypography.labelMd.copyWith(
                      color: context.clay.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.clay.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;
  const _LeadingIcon({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: AppRadius.smBorder,
      ),
      child: Icon(icon, size: 18, color: accent),
    );
  }
}

