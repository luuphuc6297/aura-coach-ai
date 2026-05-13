import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';
import '../../features/my_library/models/saved_item.dart';
import '../../features/scenario/models/session.dart';
import '../../features/story/models/story.dart';

class FirebaseDatasource {
  final FirebaseFirestore _db;

  FirebaseDatasource({required FirebaseFirestore db}) : _db = db;

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Update an existing profile without touching `createdAt`. Used by the
  /// Edit Profile screen.
  Future<void> updateUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
          profile.toFirestore(forUpdate: true),
          SetOptions(merge: true),
        );
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data != null &&
        (data['name'] as String?)?.isNotEmpty == true &&
        (data['selectedTopics'] as List?)?.isNotEmpty == true;
  }

  // --- Conversation persistence ---

  Future<void> saveConversation({
    required String uid,
    required String conversationId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> addMessageToConversation({
    required String uid,
    required String conversationId,
    required Map<String, dynamic> message,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'turns': FieldValue.arrayUnion([message]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getConversations(String uid,
      {String? mode}) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    var results =
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    if (mode != null) {
      results = results.where((doc) => doc['mode'] == mode).toList();
    }
    return results;
  }

  Future<Map<String, dynamic>?> getConversation(
      String uid, String conversationId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  Future<void> renameConversation({
    required String uid,
    required String conversationId,
    required String newTitle,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteConversation({
    required String uid,
    required String conversationId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .delete();
  }

  /// Total number of conversation docs the user has stored, regardless of
  /// mode or status. Uses Firestore's `count()` aggregation — billed as one
  /// aggregate read, not a per-doc read, so this stays cheap even for
  /// long-term power users.
  ///
  /// Returns 0 on failure so the storage-quota gate fails open (prefer
  /// letting the user create a session over blocking them on a transient
  /// Firestore hiccup).
  Future<int> countConversations(String uid) async {
    try {
      final aggregate = await _db
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .count()
          .get();
      return aggregate.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Per-mode breakdown used by the storage banner. Walks the list of
  /// conversations once and tallies by the `mode` field. For users with
  /// thousands of docs this is the expensive path — the banner reads it
  /// lazily (only when storage is in warning or cap state).
  Future<Map<String, int>> breakdownConversationsByMode(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final mode = (doc.data()['mode'] as String?) ?? 'other';
        counts[mode] = (counts[mode] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return const {};
    }
  }

  // --- Session persistence (Scenario Coach + Story Mode) ---
  //
  // A session groups consecutive scenario attempts so the Session Panel can
  // surface "what did I just practice?" without scanning the entire
  // conversations subcollection. Each session doc lives at
  // `users/{uid}/sessions/{sessionId}` and stores cached aggregates
  // (scenarioCount, avgScore) updated on every scenario save.

  /// Create a new session doc with a client-generated id. The id is the
  /// caller's responsibility (UUID) so writes can be queued offline.
  Future<void> createSession({
    required String uid,
    required String sessionId,
    required String mode,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .set({
      'mode': mode,
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'scenarioCount': 0,
      'avgScore': 0,
    });
  }

  /// Stamp `endedAt` so the session no longer surfaces as active. Idempotent
  /// — calling twice is a harmless overwrite of the same timestamp field.
  Future<void> endSession({
    required String uid,
    required String sessionId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .update({
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns the most recently started active session for [mode], or null.
  /// Used on app launch to ask the user "resume or start new?".
  Future<PracticeSession?> loadActiveSession({
    required String uid,
    required String mode,
  }) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .where('mode', isEqualTo: mode)
        .where('endedAt', isNull: true)
        .orderBy('startedAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return PracticeSession.fromFirestore(snapshot.docs.first);
  }

  /// Lazily-loaded list of metadata for every scenario in [sessionId].
  /// Ordered by `createdAt ASC` so #1 is the oldest, #N is the newest —
  /// matches the panel's "session timeline" presentation.
  Future<List<SessionScenarioMeta>> listSessionScenarios({
    required String uid,
    required String sessionId,
  }) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('createdAt')
        .get();
    return [
      for (final (index, doc) in snapshot.docs.indexed)
        SessionScenarioMeta.fromConversationDoc(doc, orderInSession: index + 1),
    ];
  }

  /// Increment counter + recompute avg score atomically. Called right after
  /// `saveConversation` finishes for a completed scenario so the chip stays
  /// in sync without a second client read.
  Future<void> updateSessionAggregates({
    required String uid,
    required String sessionId,
    required int newScore,
  }) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() ?? const {};
      final prevCount = (data['scenarioCount'] as num?)?.toInt() ?? 0;
      final prevAvg = (data['avgScore'] as num?)?.toDouble() ?? 0;
      final nextCount = prevCount + 1;
      final nextAvg = ((prevAvg * prevCount) + newScore) / nextCount;
      tx.update(ref, {
        'scenarioCount': nextCount,
        'avgScore': nextAvg,
      });
    });
  }

  // --- Daily usage tracking ---

  Future<Map<String, int>> getDailyUsage(String uid, String date) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('usage')
        .doc(date)
        .get();
    if (!doc.exists) {
      return {
        'roleplayCount': 0,
        'storyCount': 0,
        'translatorCount': 0,
        'dictionaryCount': 0,
        'mindmapCount': 0,
        'ttsCount': 0,
      };
    }
    final data = doc.data()!;
    return {
      'roleplayCount': data['roleplayCount'] as int? ?? 0,
      'storyCount': data['storyCount'] as int? ?? 0,
      'translatorCount': data['translatorCount'] as int? ?? 0,
      'dictionaryCount': data['dictionaryCount'] as int? ?? 0,
      'mindmapCount': data['mindmapCount'] as int? ?? 0,
      'ttsCount': data['ttsCount'] as int? ?? 0,
    };
  }

  Future<void> incrementDailyUsage(
      String uid, String date, String feature) async {
    final fieldName = '${feature}Count';
    await _db.collection('users').doc(uid).collection('usage').doc(date).set(
      {
        fieldName: FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<List<SavedItem>> getSavedItems(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .orderBy('timestamp', descending: true)
        .limit(200)
        .get();
    return snapshot.docs
        .map((doc) => SavedItem.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<void> saveSavedItem(String uid, SavedItem item) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .doc(item.id)
        .set(item.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteSavedItem(String uid, String itemId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .doc(itemId)
        .delete();
  }

  // --- Story library ---

  Future<List<Story>> getFeaturedStories({String? level}) async {
    Query<Map<String, dynamic>> q = _db.collection('stories').orderBy('order');
    if (level != null && level.isNotEmpty) {
      q = q.where('level', isEqualTo: level);
    }
    final snapshot = await q.limit(20).get();
    return snapshot.docs
        .map((doc) => Story.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<Story?> getStoryById(String storyId) async {
    final doc = await _db.collection('stories').doc(storyId).get();
    if (!doc.exists) return null;
    return Story.fromJson({'id': doc.id, ...doc.data()!});
  }

  // --- Seen-sentence dedup (Scenario Coach uniqueness guarantee) ---

  /// Returns the set of hash doc IDs under `users/{uid}/seenSentences`. Each
  /// doc ID is the SHA-1 of a normalized Vietnamese phrase the user has
  /// already been asked to translate. Only IDs are fetched (no field reads)
  /// to keep this cheap on cold-start — a user with years of history still
  /// costs a single list operation.
  Future<Set<String>> listSeenSentenceHashes(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('seenSentences')
        .get();
    return snapshot.docs.map((d) => d.id).toSet();
  }

  /// Persists a single seen sentence. Using [hash] as the doc ID makes the
  /// write idempotent — re-saving the same hash is a no-op at the Firestore
  /// level, so the caller never has to check before writing.
  Future<void> saveSeenSentence({
    required String uid,
    required String hash,
    required String text,
    required String conversationId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('seenSentences')
        .doc(hash)
        .set(
      {
        'text': text,
        'conversationId': conversationId,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // --- Mind Map persistence (Vocab Hub — Pro-only) ---

  /// Returns the user's mind-map documents ordered by most recently updated.
  /// Capped at 50 to match the storage UX budget.
  Future<List<Map<String, dynamic>>> listMindMaps(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('mindMaps')
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<Map<String, dynamic>?> getMindMap(String uid, String mapId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('mindMaps')
        .doc(mapId)
        .get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  /// Upserts a mind-map doc. Caller controls [mapId] so repeated saves
  /// (e.g. node-expand writes during a session) stay idempotent.
  Future<void> saveMindMap({
    required String uid,
    required String mapId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('mindMaps')
        .doc(mapId)
        .set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteMindMap(String uid, String mapId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('mindMaps')
        .doc(mapId)
        .delete();
  }

  // --- Notifications log ---

  /// Live stream of the user's notification log, newest-first. Capped to 100
  /// to keep the list snappy and avoid unbounded reads.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  /// One-shot write: caller owns the [notifId] (typically the same id passed
  /// to [NotificationService.scheduleAt] so the row + the scheduled local
  /// notification can be cross-referenced).
  Future<void> writeNotification({
    required String uid,
    required String notifId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> markNotificationRead({
    required String uid,
    required String notifId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .set({'readAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
  }

  /// Batched write — flips every unread notification to read. Returns the
  /// count actually flipped so the caller can show "Marked X as read".
  Future<int> markAllNotificationsRead(String uid) async {
    final unread = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('readAt', isNull: true)
        .get();
    if (unread.docs.isEmpty) return 0;
    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();
    for (final doc in unread.docs) {
      batch.set(doc.reference, {'readAt': now}, SetOptions(merge: true));
    }
    await batch.commit();
    return unread.docs.length;
  }

  Future<void> deleteNotification({
    required String uid,
    required String notifId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .delete();
  }
}
