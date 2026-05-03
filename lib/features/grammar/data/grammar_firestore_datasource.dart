import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/grammar_exercise.dart';
import '../models/grammar_progress.dart';
import '../models/grammar_session.dart';
import 'grammar_datasource.dart';

/// Firestore-backed [GrammarDataSource]. Three subcollections under each
/// user:
///
/// - `users/{uid}/grammarProgress/{topicId}` — per-topic mastery state
/// - `users/{uid}/grammarAttempts/{attemptId}` — append-only attempt log
/// - `users/{uid}/grammarSessions/{sessionId}` — session lifecycle
///
/// All queries are scoped to one user — no cross-user reads, no Cloud
/// Function fan-out. The provider owns optimistic state, so writes are
/// fire-and-forget at the call site (`unawaited(...)`); this datasource
/// just resolves the future eventually.
class GrammarFirestoreDataSource implements GrammarDataSource {
  final FirebaseFirestore _db;

  GrammarFirestoreDataSource({required FirebaseFirestore db}) : _db = db;

  // ── collection refs ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _progressCol(String uid) =>
      _db.collection('users').doc(uid).collection('grammarProgress');

  CollectionReference<Map<String, dynamic>> _attemptsCol(String uid) =>
      _db.collection('users').doc(uid).collection('grammarAttempts');

  CollectionReference<Map<String, dynamic>> _sessionsCol(String uid) =>
      _db.collection('users').doc(uid).collection('grammarSessions');

  // ── progress ──────────────────────────────────────────────────────

  @override
  Future<List<UserGrammarProgress>> loadAllProgress(String uid) async {
    final snap = await _progressCol(uid).get();
    return snap.docs
        .map((d) => UserGrammarProgress.fromJson(d.data()))
        .toList(growable: false);
  }

  @override
  Future<UserGrammarProgress?> loadProgress(
    String uid,
    String topicId,
  ) async {
    final doc = await _progressCol(uid).doc(topicId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return UserGrammarProgress.fromJson(data);
  }

  @override
  Future<void> saveProgress(
    String uid,
    UserGrammarProgress progress,
  ) async {
    await _progressCol(uid)
        .doc(progress.topicId)
        .set(progress.toJson(), SetOptions(merge: false));
  }

  // ── attempts ──────────────────────────────────────────────────────

  @override
  Future<void> saveAttempt(String uid, GrammarPracticeAttempt attempt) async {
    await _attemptsCol(uid).doc(attempt.id).set(attempt.toJson());
  }

  @override
  Future<List<GrammarErrorType>> recentMistakeTypes(
    String uid,
    String topicId, {
    int limit = 5,
  }) async {
    // Server-side filter on topic + isCorrect=false, ordered by ts desc.
    // Compound index needed: (topicId asc, isCorrect asc, timestamp desc).
    // The Flutter app surfaces an index-required error in dev with a
    // tap-to-create link; we ship the index in firestore.indexes.json
    // alongside the rules update.
    final snap = await _attemptsCol(uid)
        .where('topicId', isEqualTo: topicId)
        .where('isCorrect', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => GrammarErrorTypeId.fromId(d.data()['errorType'] as String?))
        .toList(growable: false);
  }

  // ── sessions ──────────────────────────────────────────────────────

  @override
  Future<void> saveSession(String uid, GrammarSession session) async {
    await _sessionsCol(uid).doc(session.id).set(session.toJson());
  }
}
