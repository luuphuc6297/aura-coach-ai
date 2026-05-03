import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/my_library/providers/library_provider.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import 'notification_service.dart';

/// Orchestrator that turns app state into scheduled local notifications.
///
/// Owns the rules ("when does each kind fire?") so the caller (HomeScreen
/// `initState`, post-session hooks) just calls [refresh] and we pick the
/// right times based on user activity + due cards. Idempotent — every call
/// cancels previous schedules of the same kind first, so repeated taps on
/// Home don't pile up duplicate notifications.
///
/// Triggers covered in v1:
/// - **daily** — fires every day at the user's preferred reminder time
///   (default 08:00). Encourages consistent practice.
/// - **review** — when SM-2 due cards > 0, fires the next morning at 08:30
///   to remind the learner before the queue grows.
/// - **streak** — fires 18h after last recorded activity (computed from
///   SharedPreferences) so the user gets ~6h of warning before the streak
///   day boundary.
/// - **quota** — fires at midnight when free-tier daily quotas reset.
///
/// Each kind uses a deterministic notification id so re-scheduling
/// overwrites cleanly. The matching Firestore log is written via
/// [NotificationsProvider.record] at schedule time so the in-app
/// Notification Center has a row before the OS fires (we couldn't otherwise
/// catch a fire while the app was killed).
class NotificationTriggers {
  NotificationTriggers._();
  static final NotificationTriggers instance = NotificationTriggers._();

  static const _kPrefLastActivityMs = 'aura.notif.lastActivityMs';
  static const _kPrefReminderHour = 'aura.notif.reminderHour';
  static const _kPrefReminderMinute = 'aura.notif.reminderMinute';

  // Deterministic ids — keep in sync; never reuse across kinds.
  static const int _idDaily = 1001;
  static const int _idReview = 1002;
  static const int _idStreak = 1003;
  static const int _idQuota = 1004;

  static const _defaultReminderHour = 8;
  static const _defaultReminderMinute = 0;

  /// Single entry point — re-evaluate every trigger. Safe to call on every
  /// HomeScreen build that finds an authenticated user; internally
  /// idempotent thanks to deterministic ids + cancel-then-schedule.
  Future<void> refresh({
    required NotificationsProvider notifications,
    required LibraryProvider library,
  }) async {
    final granted = await NotificationService.instance.hasPermission();
    if (!granted) {
      // Don't try to schedule before the user has accepted permission —
      // the OS would silently drop the call and we'd accumulate ghosts.
      if (kDebugMode) {
        debugPrint('NotificationTriggers.refresh skipped: no permission');
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_kPrefReminderHour) ?? _defaultReminderHour;
    final minute = prefs.getInt(_kPrefReminderMinute) ?? _defaultReminderMinute;

    await Future.wait([
      _scheduleDaily(notifications, hour, minute),
      _scheduleReview(notifications, library),
      _scheduleStreakWarning(notifications, prefs),
      _scheduleQuotaRefresh(notifications),
    ]);
  }

  /// Updates the user's preferred daily reminder time + immediately
  /// reschedules so the change takes effect without an app restart.
  Future<void> setReminderTime({
    required int hour,
    required int minute,
    required NotificationsProvider notifications,
    required LibraryProvider library,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefReminderHour, hour);
    await prefs.setInt(_kPrefReminderMinute, minute);
    await refresh(notifications: notifications, library: library);
  }

  /// Records a "user is active right now" beacon — used by [_scheduleStreakWarning]
  /// to push the streak alert forward. Call from session start/end hooks
  /// (or just from HomeScreen.initState as a coarse signal).
  Future<void> markActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _kPrefLastActivityMs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> cancelAll() async {
    await Future.wait([
      NotificationService.instance.cancel(_idDaily),
      NotificationService.instance.cancel(_idReview),
      NotificationService.instance.cancel(_idStreak),
      NotificationService.instance.cancel(_idQuota),
    ]);
  }

  // ---------- internals ----------

  Future<void> _scheduleDaily(
    NotificationsProvider notifications,
    int hour,
    int minute,
  ) async {
    const title = 'Time to practice!';
    const body = 'Your daily English lesson is waiting. Keep your streak alive!';
    const payload = NotificationPayload(
      kind: NotificationKind.daily,
      route: '/home',
    );
    await NotificationService.instance.scheduleDaily(
      id: _idDaily,
      kind: NotificationKind.daily,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
      payload: payload,
    );
    await notifications.record(
      notifId: 'daily_${_dateKey(_atToday(hour, minute))}',
      kind: NotificationKind.daily,
      title: title,
      body: body,
      payload: payload,
      scheduledAt: _atToday(hour, minute),
    );
  }

  Future<void> _scheduleReview(
    NotificationsProvider notifications,
    LibraryProvider library,
  ) async {
    final due = library.dueCount;
    if (due <= 0) {
      await NotificationService.instance.cancel(_idReview);
      return;
    }
    final title = '$due ${due == 1 ? "word" : "words"} need your attention';
    const body =
        'You have flashcards due for review. Quick revision keeps knowledge fresh!';
    const payload = NotificationPayload(
      kind: NotificationKind.review,
      route: '/vocab-hub/flashcards',
    );
    final tomorrowMorning = _tomorrowAt(8, 30);
    await NotificationService.instance.scheduleAt(
      id: _idReview,
      kind: NotificationKind.review,
      when: tomorrowMorning,
      title: title,
      body: body,
      payload: payload,
    );
    await notifications.record(
      notifId: 'review_${_dateKey(tomorrowMorning)}',
      kind: NotificationKind.review,
      title: title,
      body: body,
      payload: payload,
      scheduledAt: tomorrowMorning,
    );
  }

  Future<void> _scheduleStreakWarning(
    NotificationsProvider notifications,
    SharedPreferences prefs,
  ) async {
    final lastMs = prefs.getInt(_kPrefLastActivityMs);
    if (lastMs == null) {
      // Fresh install — no streak yet, nothing to warn about.
      return;
    }
    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    final fireAt = last.add(const Duration(hours: 18));
    if (fireAt.isBefore(DateTime.now())) {
      // Already past the warning window; skip to avoid an instant ping.
      return;
    }
    const title = 'Don\'t lose your streak!';
    const body =
        'You haven\'t practiced today. Complete one lesson to keep your streak going.';
    const payload = NotificationPayload(
      kind: NotificationKind.streak,
      route: '/home',
    );
    await NotificationService.instance.scheduleAt(
      id: _idStreak,
      kind: NotificationKind.streak,
      when: fireAt,
      title: title,
      body: body,
      payload: payload,
    );
    await notifications.record(
      notifId: 'streak_${_dateKey(fireAt)}',
      kind: NotificationKind.streak,
      title: title,
      body: body,
      payload: payload,
      scheduledAt: fireAt,
    );
  }

  Future<void> _scheduleQuotaRefresh(
    NotificationsProvider notifications,
  ) async {
    final midnight = _tomorrowAt(0, 1);
    const title = 'Quota refreshed!';
    const body =
        'Your daily limits have reset. Scenarios, stories, and word lookups — all available again.';
    const payload = NotificationPayload(
      kind: NotificationKind.quota,
      route: '/home',
    );
    await NotificationService.instance.scheduleAt(
      id: _idQuota,
      kind: NotificationKind.quota,
      when: midnight,
      title: title,
      body: body,
      payload: payload,
    );
    await notifications.record(
      notifId: 'quota_${_dateKey(midnight)}',
      kind: NotificationKind.quota,
      title: title,
      body: body,
      payload: payload,
      scheduledAt: midnight,
    );
  }

  // ---------- date helpers ----------

  DateTime _atToday(int hour, int minute) {
    final now = DateTime.now();
    var t = DateTime(now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  DateTime _tomorrowAt(int hour, int minute) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day, hour, minute)
        .add(const Duration(days: 1));
    return tomorrow;
  }

  String _dateKey(DateTime t) =>
      '${t.year.toString().padLeft(4, "0")}'
      '-${t.month.toString().padLeft(2, "0")}'
      '-${t.day.toString().padLeft(2, "0")}';
}
