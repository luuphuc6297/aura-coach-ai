import 'grammar_exercise.dart';

/// One practice-screen session. Persisted at
/// `users/{uid}/grammarSessions/{sessionId}` so the Summary screen can
/// roll up stats from the attempts collection without a full scan, and
/// so the Insights tab can show "minutes practiced" cross-mode.
///
/// Sessions are open-ended per spec — `endedAt` is null while the user is
/// still in the practice screen. The provider stamps it when the user
/// taps "End session" or backgrounds the app from the practice screen.
class GrammarSession {
  /// UUID v4. Doubles as the Firestore doc id.
  final String id;
  final String topicId;
  final GrammarPracticeMode mode;

  /// Unix epoch milliseconds.
  final int startedAt;

  /// Null while the session is still in progress.
  final int? endedAt;

  /// Running totals — mutated through [copyWith] each time an attempt is
  /// recorded, then persisted via [GrammarProvider]. The attempts
  /// collection is the source of truth; these are denormalized for the
  /// summary screen to avoid a second Firestore query.
  final int attemptCount;
  final int correctCount;

  /// Mastery delta (post − pre) for the topic, computed when the session
  /// ends. Null while in progress. Surfaced on the Summary screen as
  /// "Mastery +8%".
  final double? masteryDelta;

  const GrammarSession({
    required this.id,
    required this.topicId,
    required this.mode,
    required this.startedAt,
    this.endedAt,
    this.attemptCount = 0,
    this.correctCount = 0,
    this.masteryDelta,
  });

  factory GrammarSession.start({
    required String id,
    required String topicId,
    required GrammarPracticeMode mode,
  }) =>
      GrammarSession(
        id: id,
        topicId: topicId,
        mode: mode,
        startedAt: DateTime.now().millisecondsSinceEpoch,
      );

  /// True when the session has been wrapped up (user tapped End session
  /// or the provider auto-closed on background).
  bool get isClosed => endedAt != null;

  /// Wall-clock duration. While in progress, returns "now − startedAt"
  /// so the practice screen header can show a live timer.
  Duration get duration {
    final end = endedAt ?? DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds: end - startedAt);
  }

  /// Accuracy 0..1 within this session. Returns 0 on empty session.
  double get accuracy =>
      attemptCount == 0 ? 0.0 : correctCount / attemptCount;

  GrammarSession copyWith({
    int? endedAt,
    int? attemptCount,
    int? correctCount,
    double? masteryDelta,
  }) {
    return GrammarSession(
      id: id,
      topicId: topicId,
      mode: mode,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      correctCount: correctCount ?? this.correctCount,
      masteryDelta: masteryDelta ?? this.masteryDelta,
    );
  }

  factory GrammarSession.fromJson(Map<String, dynamic> json) {
    return GrammarSession(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      mode: GrammarPracticeModeId.fromId(json['mode'] as String? ?? ''),
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (json['endedAt'] as num?)?.toInt(),
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      masteryDelta: (json['masteryDelta'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'mode': mode.id,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'attemptCount': attemptCount,
        'correctCount': correctCount,
        'masteryDelta': masteryDelta,
      };
}
