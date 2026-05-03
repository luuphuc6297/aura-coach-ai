import '../models/grammar_exercise.dart';
import '../models/grammar_progress.dart';
import '../models/grammar_session.dart';

/// Persistence surface for Grammar Coach. Concrete impl lives at
/// `grammar_firestore_datasource.dart` (Phase B3) and wraps Firestore
/// CRUD against:
///
/// - `users/{uid}/grammarProgress/{topicId}` — per-topic mastery state
/// - `users/{uid}/grammarAttempts/{attemptId}` — append-only attempt log
/// - `users/{uid}/grammarSessions/{sessionId}` — session lifecycle
///
/// All methods take `uid` explicitly so the provider can defer to the
/// auth provider for the current user instead of caching an internal
/// reference. Datasource is stateless.
abstract class GrammarDataSource {
  // ── progress ──────────────────────────────────────────────────────

  /// Bulk-load every progress doc for the user. Used on Hub mount so
  /// every topic card can render its mastery ring without N round-trips.
  Future<List<UserGrammarProgress>> loadAllProgress(String uid);

  /// Single-doc load. Returns null when the user has never opened the
  /// topic before.
  Future<UserGrammarProgress?> loadProgress(String uid, String topicId);

  /// Upsert. Concrete impl uses `set(merge:false)` because every field
  /// on `UserGrammarProgress` is owned by the provider — there's no
  /// other writer.
  Future<void> saveProgress(String uid, UserGrammarProgress progress);

  // ── attempts ──────────────────────────────────────────────────────

  /// Append one attempt. Doc id matches `attempt.id`.
  Future<void> saveAttempt(String uid, GrammarPracticeAttempt attempt);

  /// Most recent error categories for one topic, newest first. Used by
  /// the AI prompt grounding (recentMistakeTypes). Default cap: 5.
  Future<List<GrammarErrorType>> recentMistakeTypes(
    String uid,
    String topicId, {
    int limit = 5,
  });

  // ── sessions ──────────────────────────────────────────────────────

  /// Create + upsert. Called twice per session — once on `start()` (open
  /// session, no end stamp) and once on `endSession()` with totals
  /// filled in.
  Future<void> saveSession(String uid, GrammarSession session);
}
