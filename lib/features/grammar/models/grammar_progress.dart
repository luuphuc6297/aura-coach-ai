/// Per-user, per-topic grammar mastery state. Persisted at
/// `users/{uid}/grammarProgress/{topicId}` — one doc per topic the user
/// has ever practiced.
///
/// SM-2 fields (`easeFactor`, `interval`, `reviewCount`, `nextReviewAt`)
/// mirror the flashcards spec at `lib/features/vocab_hub/flashcards/sm2.dart`,
/// so the same Sm2 algorithm can drive grammar review scheduling. We
/// don't depend on the flashcards code directly — the SM-2 inputs are
/// just numbers.
///
/// Mastery score (0..1) is a separate signal derived from accuracy +
/// recency, surfaced on the Hub topic card mastery ring. It's NOT the
/// SM-2 ease factor (which is bounded 1.3..2.5+ and not user-facing).
library;

/// Coarse mastery bucket surfaced on the topic card. Derived from
/// `masteryScore` + `attemptCount`.
enum GrammarMasteryLabel { notStarted, learning, mastered }

class UserGrammarProgress {
  /// Topic slug, e.g. `present_perfect`. Matches the Firestore doc id.
  final String topicId;

  /// Total submitted answers for this topic across all sessions.
  final int attemptCount;

  /// Of [attemptCount], how many were correct.
  final int correctCount;

  /// Mastery 0..1 surfaced on the hub. EWMA of accuracy weighted by
  /// recency — provider computes after each attempt.
  final double masteryScore;

  // ── SM-2 spaced repetition fields (mirrors flashcards/sm2.dart) ──

  /// Ease factor. Default 2.5 per SM-2 paper, floored at 1.3.
  final double easeFactor;

  /// Days until next review (clamped). 0 means review now.
  final int interval;

  /// Successful repetitions in a row at the SM-2 quality threshold.
  /// Resets to 0 on hard rating.
  final int reviewCount;

  /// Unix epoch milliseconds. Null = never scheduled.
  final int? lastPracticedAt;
  final int? nextReviewAt;

  const UserGrammarProgress({
    required this.topicId,
    this.attemptCount = 0,
    this.correctCount = 0,
    this.masteryScore = 0.0,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.reviewCount = 0,
    this.lastPracticedAt,
    this.nextReviewAt,
  });

  /// Factory for a topic the user has just opened but never submitted an
  /// answer for. Equivalent to `UserGrammarProgress(topicId: ...)` —
  /// kept as a named factory for readability at call sites.
  factory UserGrammarProgress.empty(String topicId) =>
      UserGrammarProgress(topicId: topicId);

  /// Accuracy 0..1. Returns 0 when `attemptCount == 0` to avoid NaN.
  double get accuracy =>
      attemptCount == 0 ? 0.0 : correctCount / attemptCount;

  /// Fraction 0..1 to render on the topic card mastery ring.
  double get masteryFraction => masteryScore.clamp(0.0, 1.0);

  /// Bucketing for the status pill on the hub card.
  /// - 0 attempts → notStarted
  /// - 1+ attempts and masteryScore < 0.85 → learning
  /// - masteryScore ≥ 0.85 AND attemptCount ≥ 8 → mastered
  ///
  /// The 8-attempt floor stops a user from "mastering" a topic by
  /// answering 1 question correctly.
  GrammarMasteryLabel get masteryLabel {
    if (attemptCount == 0) return GrammarMasteryLabel.notStarted;
    if (masteryScore >= 0.85 && attemptCount >= 8) {
      return GrammarMasteryLabel.mastered;
    }
    return GrammarMasteryLabel.learning;
  }

  /// True when the SM-2 next-review timestamp has elapsed (or null →
  /// never scheduled = always due).
  bool get isDueForReview {
    if (nextReviewAt == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= nextReviewAt!;
  }

  UserGrammarProgress copyWith({
    int? attemptCount,
    int? correctCount,
    double? masteryScore,
    double? easeFactor,
    int? interval,
    int? reviewCount,
    int? lastPracticedAt,
    int? nextReviewAt,
  }) {
    return UserGrammarProgress(
      topicId: topicId,
      attemptCount: attemptCount ?? this.attemptCount,
      correctCount: correctCount ?? this.correctCount,
      masteryScore: masteryScore ?? this.masteryScore,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      reviewCount: reviewCount ?? this.reviewCount,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  factory UserGrammarProgress.fromJson(Map<String, dynamic> json) {
    return UserGrammarProgress(
      topicId: json['topicId'] as String? ?? '',
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lastPracticedAt: (json['lastPracticedAt'] as num?)?.toInt(),
      nextReviewAt: (json['nextReviewAt'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'attemptCount': attemptCount,
        'correctCount': correctCount,
        'masteryScore': masteryScore,
        'easeFactor': easeFactor,
        'interval': interval,
        'reviewCount': reviewCount,
        'lastPracticedAt': lastPracticedAt,
        'nextReviewAt': nextReviewAt,
      };
}
