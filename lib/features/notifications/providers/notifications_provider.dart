import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../models/app_notification.dart';

/// Owns the in-app notification log: live list, unread counter, mark-as-read
/// helpers, and the bridge that records every fired local notification into
/// Firestore so the same log shows up across devices.
///
/// Listens to [FirebaseDatasource.watchNotifications] for the active uid;
/// resets when the user signs out. Capped at the same 100 the datasource
/// query enforces — older rows are pruned via a Cloud Function later (out
/// of scope for this phase).
class NotificationsProvider extends ChangeNotifier {
  final FirebaseDatasource _firebase;
  final NotificationService _service;

  NotificationsProvider({
    required FirebaseDatasource firebase,
    NotificationService? service,
  })  : _firebase = firebase,
        _service = service ?? NotificationService.instance;

  String? _uid;
  StreamSubscription? _sub;
  List<AppNotification> _items = const [];
  bool _loading = false;

  List<AppNotification> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  int get unreadCount => _items.where((n) => n.isUnread).length;
  bool get hasUnread => unreadCount > 0;

  /// Wires the live Firestore listener for the signed-in user. Safe to call
  /// repeatedly — only re-subscribes when the uid actually changes.
  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    if (uid == null) {
      _items = const [];
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    _sub = _firebase.watchNotifications(uid).listen(
      (snap) {
        _items = snap.docs.map(AppNotification.fromFirestore).toList();
        _loading = false;
        notifyListeners();
      },
      onError: (e, st) {
        debugPrint('NotificationsProvider stream error: $e\n$st');
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Records a freshly-scheduled / fired notification. The `notifId` is the
  /// deterministic id (e.g. `daily_2026-04-26`) so we never write more than
  /// one Firestore row per kind+date.
  ///
  /// **Idempotency contract**: if a row with this id already exists locally
  /// (loaded via the live stream), we skip the write entirely. This is what
  /// preserves the user's `readAt` — without the guard, every HomeScreen
  /// open would re-issue this write with `readAt: null` and silently mark
  /// the bell badge unread again.
  Future<void> record({
    required String notifId,
    required NotificationKind kind,
    required String title,
    required String body,
    NotificationPayload? payload,
    DateTime? scheduledAt,
  }) async {
    if (_uid == null) return;
    // Skip if the row already exists — preserves readAt + avoids spam.
    if (_items.any((n) => n.id == notifId)) return;
    final now = DateTime.now();
    final entry = AppNotification(
      id: notifId,
      kind: kind,
      title: title,
      body: body,
      payload: payload,
      scheduledAt: scheduledAt ?? now,
      firedAt: now,
      createdAt: now,
    );
    try {
      await _firebase.writeNotification(
        uid: _uid!,
        notifId: notifId,
        data: entry.toFirestore(),
      );
    } catch (e) {
      debugPrint('NotificationsProvider.record failed: $e');
    }
  }

  Future<void> markRead(String notifId) async {
    if (_uid == null) return;
    // Optimistic local update — Firestore stream will eventually reconcile.
    _items = _items
        .map((n) =>
            n.id == notifId && n.isUnread ? n.copyWith(readAt: DateTime.now()) : n)
        .toList();
    notifyListeners();
    try {
      await _firebase.markNotificationRead(uid: _uid!, notifId: notifId);
    } catch (e) {
      debugPrint('NotificationsProvider.markRead failed: $e');
    }
  }

  Future<int> markAllRead() async {
    if (_uid == null) return 0;
    final unreadIds = _items.where((n) => n.isUnread).map((n) => n.id).toSet();
    if (unreadIds.isEmpty) return 0;
    final now = DateTime.now();
    _items = _items
        .map((n) => unreadIds.contains(n.id) ? n.copyWith(readAt: now) : n)
        .toList();
    notifyListeners();
    try {
      return await _firebase.markAllNotificationsRead(_uid!);
    } catch (e) {
      debugPrint('NotificationsProvider.markAllRead failed: $e');
      return 0;
    }
  }

  Future<void> delete(String notifId) async {
    if (_uid == null) return;
    _items = _items.where((n) => n.id != notifId).toList();
    notifyListeners();
    try {
      await _firebase.deleteNotification(uid: _uid!, notifId: notifId);
      await _service.cancel(notifId.hashCode);
    } catch (e) {
      debugPrint('NotificationsProvider.delete failed: $e');
    }
  }

  /// Convenience: notifications grouped into "New" (unread) and "Earlier"
  /// (read), preserving the newest-first order from Firestore. Used by the
  /// Notifications screen so the UI doesn't have to re-sort.
  ({List<AppNotification> newOnes, List<AppNotification> earlier}) grouped() {
    final newList = <AppNotification>[];
    final old = <AppNotification>[];
    for (final n in _items) {
      (n.isUnread ? newList : old).add(n);
    }
    return (newOnes: newList, earlier: old);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
