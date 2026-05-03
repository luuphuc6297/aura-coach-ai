import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../models/app_notification.dart';
import '../providers/notifications_provider.dart';

/// Notification Center matching `mockups-phase8-notifications.html` —
/// "New" (unread) and "Earlier" (read) sections with type-tinted icon
/// chips, tap-to-deep-link, swipe-to-delete (with undo), and a Mark-all-read
/// app-bar action that surfaces only when unread > 0. Empty state mirrors
/// screen 3 of the mockup (bell-off icon + helper copy).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final groups = provider.grouped();
    final hasAny = provider.items.isNotEmpty;

    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(context.loc.notificationsTitle, style: AppTypography.h2),
        actions: [
          if (provider.hasUnread)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: TextButton(
                onPressed: () => _onMarkAllRead(context, provider),
                child: Text(
                  'Mark all read',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.tealDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: provider.loading && !hasAny
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.coral),
              ),
            )
          : !hasAny
              ? const _EmptyState()
              : RefreshIndicator(
                  color: AppColors.coral,
                  backgroundColor: context.clay.surface,
                  // The Firestore stream is already live, so refresh is just
                  // a tactile confirmation — wait one frame so the spinner
                  // shows briefly even when data is already current.
                  onRefresh: () =>
                      Future<void>.delayed(const Duration(milliseconds: 350)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    children: [
                      if (groups.newOnes.isNotEmpty) ...[
                        _SectionHeading(label: context.loc.notificationsSectionNew),
                        const SizedBox(height: AppSpacing.sm),
                        for (final notif in groups.newOnes)
                          _DismissibleCard(
                            notif: notif,
                            onTap: () => _onTapNotif(context, provider, notif),
                            onDelete: () => provider.delete(notif.id),
                          ),
                      ],
                      if (groups.newOnes.isNotEmpty &&
                          groups.earlier.isNotEmpty)
                        const SizedBox(height: AppSpacing.md),
                      if (groups.earlier.isNotEmpty) ...[
                        _SectionHeading(label: context.loc.notificationsSectionEarlier),
                        const SizedBox(height: AppSpacing.sm),
                        for (final notif in groups.earlier)
                          _DismissibleCard(
                            notif: notif,
                            onTap: () => _onTapNotif(context, provider, notif),
                            onDelete: () => provider.delete(notif.id),
                          ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Future<void> _onMarkAllRead(
    BuildContext context,
    NotificationsProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final flipped = await provider.markAllRead();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          flipped == 0
              ? 'No unread notifications'
              : flipped == 1
                  ? 'Marked 1 notification as read'
                  : 'Marked $flipped notifications as read',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onTapNotif(
    BuildContext context,
    NotificationsProvider provider,
    AppNotification notif,
  ) async {
    if (notif.isUnread) {
      // Don't await — keep navigation snappy. The stream/optimistic update
      // will reconcile the UI.
      // ignore: unawaited_futures
      provider.markRead(notif.id);
    }
    final route = notif.payload?.route;
    if (route == null || route.isEmpty || route == '/') return;
    try {
      context.push(route);
    } catch (e) {
      debugPrint('NotificationsScreen: deep-link "$route" failed: $e');
    }
  }
}

class _SectionHeading extends StatelessWidget {
  final String label;
  const _SectionHeading({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
          color: context.clay.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DismissibleCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DismissibleCard({
    required this.notif,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(notif.id),
        direction: DismissDirection.endToStart,
        background: _SwipeBackground(),
        // Delete synchronously inside confirmDismiss so the row is gone from
        // _items before Dismissible removes its child — otherwise a stream
        // tick during the dismiss animation can re-insert the item under the
        // same key and trip Flutter's "duplicate key" assertion.
        confirmDismiss: (_) async {
          onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.loc.notificationsRemovedSnack(notif.title)),
              duration: const Duration(seconds: 3),
            ),
          );
          return true;
        },
        child: _NotificationCard(notif: notif, onTap: onTap),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.85),
        borderRadius: AppRadius.lgBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: context.clay.surface,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            'Delete',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.clay.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotificationCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = _accentForKind(context, notif.kind);
    final bg = notif.isUnread
        ? AppColors.teal.withValues(alpha: 0.06)
        : context.clay.surface;
    return Opacity(
      opacity: notif.isUnread ? 1.0 : 0.78,
      child: ClayPressable(
        onTap: onTap,
        scaleDown: 0.98,
        builder: (context, _) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: context.clay.border, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeIcon(kind: notif.kind, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notif.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.clay.text,
                        height: 1.4,
                      ),
                    ),
                    if (notif.body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        notif.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.clay.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _formatRelative(
                    notif.firedAt ?? notif.createdAt,
                  ),
                  style: AppTypography.caption
                      .copyWith(color: context.clay.textFaint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentForKind(BuildContext context, NotificationKind kind) {
    switch (kind) {
      case NotificationKind.streak:
        return AppColors.gold;
      case NotificationKind.review:
        return AppColors.purple;
      case NotificationKind.daily:
        return AppColors.teal;
      case NotificationKind.quota:
        return AppColors.success;
      case NotificationKind.system:
        return context.clay.textMuted;
    }
  }
}

class _TypeIcon extends StatelessWidget {
  final NotificationKind kind;
  final Color color;
  const _TypeIcon({required this.kind, required this.color});

  IconData get _icon {
    switch (kind) {
      case NotificationKind.streak:
        return Icons.local_fire_department_rounded;
      case NotificationKind.review:
        return Icons.style_rounded;
      case NotificationKind.daily:
        return Icons.wb_twilight_rounded;
      case NotificationKind.quota:
        return Icons.refresh_rounded;
      case NotificationKind.system:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(_icon, size: 20, color: color),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 56,
              color: context.clay.textFaint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No notifications yet',
              style: AppTypography.h3.copyWith(color: context.clay.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Daily reminders, streak alerts, and flashcard prompts will '
              'appear here once you start practicing.',
              style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Smart relative-time formatter — matches the mockup's "2h ago / Yesterday
/// / 3 days ago" style. Falls back to ISO date for entries older than a week
/// so we never show "60 days ago" which gets noisy.
String _formatRelative(DateTime when) {
  final now = DateTime.now();
  final diff = now.difference(when);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return '${weeks}w ago';
  }
  final months = (diff.inDays / 30).floor();
  return '${months}mo ago';
}
