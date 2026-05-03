import 'package:aura_coach_ai/features/vocab_hub/flashcards/sm2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sm2', () {
    test('first correct (Good) sets interval=1 day', () {
      final next = Sm2.next(
        rating: Sm2Rating.good,
        interval: 0,
        easeFactor: 2.5,
        reviewCount: 0,
      );
      expect(next.interval, 1);
      expect(next.reviewCount, 1);
      expect(next.easeFactor, closeTo(2.5, 0.001));
    });

    test('second correct (Good) interval becomes 6 days', () {
      final next = Sm2.next(
        rating: Sm2Rating.good,
        interval: 1,
        easeFactor: 2.5,
        reviewCount: 1,
      );
      expect(next.interval, 6);
      expect(next.reviewCount, 2);
    });

    test('subsequent Good multiplies previous interval by ease factor', () {
      final next = Sm2.next(
        rating: Sm2Rating.good,
        interval: 6,
        easeFactor: 2.5,
        reviewCount: 2,
      );
      expect(next.interval, 15); // 6 * 2.5
    });

    test('Hard resets interval to 1 and lowers ease factor', () {
      final next = Sm2.next(
        rating: Sm2Rating.hard,
        interval: 15,
        easeFactor: 2.5,
        reviewCount: 3,
      );
      expect(next.interval, 1);
      expect(next.easeFactor, lessThan(2.5));
      expect(next.easeFactor, greaterThanOrEqualTo(Sm2.minEase));
    });

    test('Easy produces a longer interval than Good at the same stage', () {
      final good = Sm2.next(
        rating: Sm2Rating.good,
        interval: 6,
        easeFactor: 2.5,
        reviewCount: 2,
      );
      final easy = Sm2.next(
        rating: Sm2Rating.easy,
        interval: 6,
        easeFactor: 2.5,
        reviewCount: 2,
      );
      // Easy bonus (1.3x) and ease-factor bump combine to make the Easy
      // interval strictly longer than Good. Exact value depends on rounding
      // order, so assert the invariant rather than pinning the number.
      expect(easy.interval, greaterThan(good.interval));
      expect(easy.easeFactor, greaterThan(2.5));
    });

    test('ease factor is clamped at minimum 1.3 after repeated Hard ratings',
        () {
      var ef = 1.35;
      for (var i = 0; i < 10; i++) {
        final result = Sm2.next(
          rating: Sm2Rating.hard,
          interval: 1,
          easeFactor: ef,
          reviewCount: 1,
        );
        ef = result.easeFactor;
      }
      expect(ef, greaterThanOrEqualTo(Sm2.minEase));
    });

    test('nextReviewDate is now() + interval days', () {
      final before = DateTime.now().millisecondsSinceEpoch;
      final next = Sm2.next(
        rating: Sm2Rating.good,
        interval: 0,
        easeFactor: 2.5,
        reviewCount: 0,
      );
      final after = DateTime.now().millisecondsSinceEpoch;
      final oneDayMs = const Duration(days: 1).inMilliseconds;
      expect(next.nextReviewDate, greaterThanOrEqualTo((before + oneDayMs).toDouble()));
      expect(next.nextReviewDate, lessThanOrEqualTo((after + oneDayMs).toDouble()));
    });
  });
}
