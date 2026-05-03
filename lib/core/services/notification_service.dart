import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Type taxonomy mirrored on the Notifications screen + Firestore log.
/// Aligned with the phase-8 mockup icon palette: streak / review / daily /
/// quota / system.
enum NotificationKind { streak, review, daily, quota, system }

/// Singleton wrapper around `flutter_local_notifications` v21.
///
/// v21 moved every public API to **all-named parameters** —
/// `initialize({required settings, ...})`, `zonedSchedule({required id,
/// required scheduledDate, required notificationDetails, required
/// androidScheduleMode, title, body, payload, ...})`, `cancel({required
/// id, tag})`. Older v17/v18 docs (and most StackOverflow answers) still
/// show positional first-args — those are wrong for v21. Match the named
/// signature exactly when changing this file.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'aura_default';
  static const String _channelName = 'Aura Coach';
  static const String _channelDesc =
      'Daily reminders, streak alerts, flashcard prompts.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Optional callback fired when the user taps a notification. The payload
  /// is whatever was passed to [scheduleAt]/[scheduleDaily] — typically a
  /// JSON-encoded [NotificationPayload].
  void Function(NotificationPayload payload)? onSelectPayload;

  /// Idempotent — safe to call from `main()` and again on hot reload.
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final raw = response.payload;
        if (raw == null || raw.isEmpty) return;
        final parsed = NotificationPayload.tryDecode(raw);
        if (parsed == null) {
          debugPrint('NotificationService: malformed payload "$raw"');
          return;
        }
        onSelectPayload?.call(parsed);
      },
    );

    // Pre-create the channel on Android so notifications scheduled before the
    // user opens settings still surface with the correct importance.
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  /// Asks the OS for permission. Returns `true` only if the user accepts.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Whether the user has already granted notification permission.
  Future<bool> hasPermission() async {
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await ios?.checkPermissions();
      return settings?.isAlertEnabled ?? false;
    }
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return true;
  }

  /// Fires a one-shot notification at [when]. If [when] is in the past the
  /// notification fires immediately (matches typical UX expectation: caller
  /// just wants the user to see it).
  Future<void> scheduleAt({
    required int id,
    required NotificationKind kind,
    required DateTime when,
    required String title,
    required String body,
    NotificationPayload? payload,
  }) async {
    if (!_initialized) await init();
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    final actual = tzWhen.isBefore(tz.TZDateTime.now(tz.local))
        ? tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1))
        : tzWhen;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: actual,
      notificationDetails: _details(kind),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: title,
      body: body,
      payload: payload?.encode(),
    );
  }

  /// Schedules a daily-recurring notification at the given local clock time.
  /// Any existing schedule with the same [id] is replaced.
  Future<void> scheduleDaily({
    required int id,
    required NotificationKind kind,
    required int hour,
    required int minute,
    required String title,
    required String body,
    NotificationPayload? payload,
  }) async {
    if (!_initialized) await init();
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (first.isBefore(now)) first = first.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: first,
      notificationDetails: _details(kind),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      title: title,
      body: body,
      payload: payload?.encode(),
    );
  }

  Future<void> cancel(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  /// Pending (scheduled but not yet fired) notifications. Useful for the
  /// Settings screen to show the user what's queued.
  Future<List<PendingNotificationRequest>> pending() async {
    if (!_initialized) await init();
    return _plugin.pendingNotificationRequests();
  }

  NotificationDetails _details(NotificationKind kind) {
    final tag = kind.name; // streak / review / daily / quota / system
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        tag: tag,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}

/// JSON-serialisable shape we ship inside a notification's `payload` field.
/// Keeping the schema narrow keeps deep-link wiring trivial: [route] is
/// passed straight to GoRouter, [params] becomes the route's extra map.
class NotificationPayload {
  final NotificationKind kind;
  final String route;
  final Map<String, dynamic> params;

  const NotificationPayload({
    required this.kind,
    required this.route,
    this.params = const {},
  });

  String encode() => jsonEncode({
        'kind': kind.name,
        'route': route,
        'params': params,
      });

  static NotificationPayload? tryDecode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final kindName = map['kind'] as String? ?? 'system';
      final kind = NotificationKind.values.firstWhere(
        (k) => k.name == kindName,
        orElse: () => NotificationKind.system,
      );
      return NotificationPayload(
        kind: kind,
        route: (map['route'] as String?) ?? '/',
        params: (map['params'] as Map<String, dynamic>?) ?? const {},
      );
    } catch (_) {
      return null;
    }
  }
}
