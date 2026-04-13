import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

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

  Future<List<Map<String, dynamic>>> getConversations(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
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
    await _db
        .collection('users')
        .doc(uid)
        .collection('usage')
        .doc(date)
        .set(
          {
            fieldName: FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }
}
