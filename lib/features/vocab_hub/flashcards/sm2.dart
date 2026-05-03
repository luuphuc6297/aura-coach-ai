/// Minimal, pure-Dart SM-2 spaced repetition algorithm. Intentionally free
/// of Flutter / Firebase imports so the unit tests can run on the `flutter
/// test` host without any platform setup.
///
/// Quality mapping:
/// - [Sm2Rating.hard] → quality 2 (failed recall). Interval resets to 1,
///   ease factor decreases by 0.20 (floored at [Sm2.minEase]).
/// - [Sm2Rating.good] → quality 4 (correct). Normal SM-2 progression, ease
///   factor unchanged.
/// - [Sm2Rating.easy] → quality 5 (effortless). Interval receives the
///   [Sm2.easyBonus] multiplier, ease factor increases by 0.15.
library;

enum Sm2Rating { hard, good, easy }

class Sm2Outcome {
  final int interval;
  final double easeFactor;
  final int reviewCount;
  final double nextReviewDate;

  const Sm2Outcome({
    required this.interval,
    required this.easeFactor,
    required this.reviewCount,
    required this.nextReviewDate,
  });
}

class Sm2 {
  Sm2._();

  static const double minEase = 1.3;
  static const double easyBonus = 1.3;

  /// Applies one SM-2 review. All inputs are the card's pre-rating state —
  /// callers persist the returned outcome to their store (Firestore /
  /// provider) so the next review picks up from here.
  static Sm2Outcome next({
    required Sm2Rating rating,
    required int interval,
    required double easeFactor,
    required int reviewCount,
  }) {
    final ef = _nextEase(rating, easeFactor);
    int nextInterval;
    if (rating == Sm2Rating.hard) {
      nextInterval = 1;
    } else if (reviewCount == 0) {
      nextInterval = 1;
    } else if (reviewCount == 1) {
      nextInterval = 6;
    } else {
      nextInterval = (interval * ef).round();
    }
    if (rating == Sm2Rating.easy) {
      nextInterval = (nextInterval * easyBonus).round();
    }
    final nextDate = DateTime.now()
        .add(Duration(days: nextInterval))
        .millisecondsSinceEpoch
        .toDouble();
    return Sm2Outcome(
      interval: nextInterval,
      easeFactor: ef,
      reviewCount: reviewCount + 1,
      nextReviewDate: nextDate,
    );
  }

  static double _nextEase(Sm2Rating rating, double current) {
    final delta = switch (rating) {
      Sm2Rating.hard => -0.20,
      Sm2Rating.good => 0.0,
      Sm2Rating.easy => 0.15,
    };
    final next = current + delta;
    return next < minEase ? minEase : next;
  }
}
