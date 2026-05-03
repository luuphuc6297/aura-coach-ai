import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/notification_service.dart';

/// In-app notification record. One row per fired notification — used by the
/// Notification Center screen and the bell badge.
///
/// The `kind` mirrors [NotificationKind] so we keep the icon palette
/// (streak / review / daily / quota / system) consistent between the local
/// notification and the in-app entry.
///
/// `readAt == null` means unread. `firedAt` is filled in when the local
/// notification actually fires (so `scheduledAt` can be in the future for
/// pre-queued reminders).
class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final NotificationPayload? payload;
  final DateTime? readAt;
  final DateTime scheduledAt;
  final DateTime? firedAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.createdAt,
    this.payload,
    this.readAt,
    this.firedAt,
  });

  bool get isUnread => readAt == null;

  AppNotification copyWith({
    DateTime? readAt,
    DateTime? firedAt,
  }) {
    return AppNotification(
      id: id,
      kind: kind,
      title: title,
      body: body,
      payload: payload,
      readAt: readAt ?? this.readAt,
      scheduledAt: scheduledAt,
      firedAt: firedAt ?? this.firedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'kind': kind.name,
        'title': title,
        'body': body,
        if (payload != null) 'payload': {
          'kind': payload!.kind.name,
          'route': payload!.route,
          'params': payload!.params,
        },
        // IMPORTANT: only emit readAt when set. Writing null with merge:true
        // would clobber any existing readAt and silently mark the row unread
        // every time the trigger schedule re-runs.
        if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        if (firedAt != null) 'firedAt': Timestamp.fromDate(firedAt!),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final kindName = data['kind'] as String? ?? 'system';
    final kind = NotificationKind.values.firstWhere(
      (k) => k.name == kindName,
      orElse: () => NotificationKind.system,
    );

    NotificationPayload? payload;
    final rawPayload = data['payload'];
    if (rawPayload is Map) {
      final pKindName = rawPayload['kind'] as String? ?? kindName;
      final pKind = NotificationKind.values.firstWhere(
        (k) => k.name == pKindName,
        orElse: () => kind,
      );
      payload = NotificationPayload(
        kind: pKind,
        route: (rawPayload['route'] as String?) ?? '/',
        params: (rawPayload['params'] as Map?)?.cast<String, dynamic>() ??
            const {},
      );
    }

    return AppNotification(
      id: doc.id,
      kind: kind,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      payload: payload,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firedAt: (data['firedAt'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
