import 'package:flutter_test/flutter_test.dart';
import 'package:aura_coach_ai/features/shared/providers/storage_quota_provider.dart';

void main() {
  group('StorageQuotaProvider.deriveState', () {
    test('0/20 → healthy', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 0, cap: 20),
        StorageQuotaState.healthy,
      );
    });
    test('15/20 (75%) → healthy (below 80% threshold)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 15, cap: 20),
        StorageQuotaState.healthy,
      );
    });
    test('16/20 (80%) → warning', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 16, cap: 20),
        StorageQuotaState.warning,
      );
    });
    test('19/20 → warning', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 19, cap: 20),
        StorageQuotaState.warning,
      );
    });
    test('20/20 → cap', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 20, cap: 20),
        StorageQuotaState.cap,
      );
    });
    test('25/20 → cap (over-cap stays cap)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 25, cap: 20),
        StorageQuotaState.cap,
      );
    });
    test('cap==0 is treated as healthy (fail-open)', () {
      expect(
        StorageQuotaProvider.deriveStateForTest(total: 5, cap: 0),
        StorageQuotaState.healthy,
      );
    });
  });
}
