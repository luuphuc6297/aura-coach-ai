import 'package:cloud_firestore/cloud_firestore.dart';

/// Practice session aggregating multiple scenarios (Scenario Coach / Story
/// Mode). Created when the user taps "Start new session" and closed when
/// they tap "End session". Persisted to `users/{uid}/sessions/{sessionId}`
/// so a force-killed app can resume the active session on next launch.
class PracticeSession {
  /// Firestore doc ID. UUID generated client-side so writes work offline.
  final String id;

  /// `'roleplay'` for Scenario Coach, `'story'` for Story Mode. Mirrors the
  /// `mode` field used on conversation docs so cross-collection joins stay
  /// simple.
  final String mode;

  final DateTime startedAt;

  /// `null` while the session is active. Set when user taps "End session".
  final DateTime? endedAt;

  /// Cached counter — incremented each time a scenario in this session is
  /// saved. Lets the header chip show "N scenarios" with one read.
  final int scenarioCount;

  /// Cached running average of `totalScore` across all scenarios in this
  /// session. Recomputed on each scenario save to avoid expensive aggregates.
  final double avgScore;

  const PracticeSession({
    required this.id,
    required this.mode,
    required this.startedAt,
    this.endedAt,
    this.scenarioCount = 0,
    this.avgScore = 0,
  });

  bool get isActive => endedAt == null;

  factory PracticeSession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return PracticeSession(
      id: doc.id,
      mode: (data['mode'] as String?) ?? 'roleplay',
      startedAt: _readTimestamp(data['startedAt']) ?? DateTime.now(),
      endedAt: _readTimestamp(data['endedAt']),
      scenarioCount: (data['scenarioCount'] as num?)?.toInt() ?? 0,
      avgScore: (data['avgScore'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFirestoreCreate() => {
        'mode': mode,
        'startedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'scenarioCount': 0,
        'avgScore': 0,
      };

  static DateTime? _readTimestamp(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

/// Lightweight metadata for ONE scenario inside a session. The full chat +
/// assessment payload lives on the conversation doc; this struct is what
/// the Session Panel renders so we only need ~200 bytes per row in memory
/// regardless of how heavy the underlying conversation is.
class SessionScenarioMeta {
  /// The Firestore conversation doc id this row points to. The Replay route
  /// uses this id to lazy-load the full doc.
  final String conversationId;

  /// 1-based position in the session ordering. Used for the `#N` badge.
  final int orderInSession;

  /// What the learner was translating. The Session Panel truncates this to
  /// fit on one line; the full phrase shows on Replay.
  final String sourcePhrase;

  final String situation;

  /// Overall score 1–10. Drives the score badge color + filter bucket.
  final int totalScore;

  /// Tense identified by AI in the most recent turn's grammar breakdown.
  /// Null when AI didn't produce a breakdown (fragment / short reply /
  /// scenario answered before the breakdown feature shipped).
  final String? tenseDetected;

  /// When the scenario was last touched (used for "2m ago" delta).
  final DateTime doneAt;

  /// `'in-progress'` while the user is still answering, `'completed'` once
  /// they tap Same/Easier/Harder and move on. Active row in the panel uses
  /// this to avoid pushing replay (replay expects a finalized turn list).
  final String status;

  const SessionScenarioMeta({
    required this.conversationId,
    required this.orderInSession,
    required this.sourcePhrase,
    required this.situation,
    required this.totalScore,
    this.tenseDetected,
    required this.doneAt,
    required this.status,
  });

  bool get isCompleted => status != 'in-progress';

  factory SessionScenarioMeta.fromConversationDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required int orderInSession,
  }) {
    final data = doc.data() ?? const {};
    final tense = _extractTense(data['turns']);
    return SessionScenarioMeta(
      conversationId: doc.id,
      orderInSession: orderInSession,
      sourcePhrase: _pickSourcePhrase(data),
      situation: (data['situation'] as String?) ?? '',
      totalScore: (data['totalScore'] as num?)?.toInt() ?? 0,
      tenseDetected: tense,
      doneAt: _readTimestamp(data['updatedAt']) ??
          _readTimestamp(data['createdAt']) ??
          DateTime.now(),
      status: (data['status'] as String?) ?? 'in-progress',
    );
  }

  /// Direction-aware: we want the phrase the user was translating FROM.
  /// Default (vn-to-en) → Vietnamese phrase. en-to-vn → English phrase.
  static String _pickSourcePhrase(Map<String, dynamic> data) {
    final direction = (data['direction'] as String?) ?? 'vn-to-en';
    final vn = (data['vietnamesePhrase'] as String?) ?? '';
    final en = (data['englishPhrase'] as String?) ?? '';
    if (direction == 'en-to-vn') return en.isNotEmpty ? en : vn;
    return vn.isNotEmpty ? vn : en;
  }

  /// Walk the turns array backwards for the most recent assessment that
  /// produced a grammarBreakdown.userVersion.tense. We prefer the user
  /// version because that's what they actually attempted. If none found,
  /// return null and the panel just hides the tense pill on that row.
  static String? _extractTense(dynamic rawTurns) {
    if (rawTurns is! List) return null;
    for (final raw in rawTurns.reversed) {
      if (raw is! Map) continue;
      final assessment = raw['assessment'];
      if (assessment is! Map) continue;
      final breakdown = assessment['grammarBreakdown'];
      if (breakdown is! Map) continue;
      final user = breakdown['userVersion'];
      if (user is! Map) continue;
      final tense = (user['tense'] as String?)?.trim();
      if (tense != null && tense.isNotEmpty) return tense;
    }
    return null;
  }

  static DateTime? _readTimestamp(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

/// Score bucket used by the Session Panel filter chips. Order matches the
/// chip row left-to-right.
enum SessionScoreFilter {
  all,
  excellent, // 9+
  good, // 7-8
  needsWork; // <6 (also covers 6 — "not yet good")

  bool accepts(int score) {
    switch (this) {
      case SessionScoreFilter.all:
        return true;
      case SessionScoreFilter.excellent:
        return score >= 9;
      case SessionScoreFilter.good:
        return score >= 7 && score <= 8;
      case SessionScoreFilter.needsWork:
        return score < 7;
    }
  }
}
