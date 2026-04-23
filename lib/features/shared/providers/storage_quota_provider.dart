import 'package:flutter/foundation.dart';
import '../../../core/constants/quota_constants.dart';
import '../../../data/datasources/firebase_datasource.dart';

enum StorageQuotaState { healthy, warning, cap }

class StorageQuotaSnapshot {
  final int total;
  final int cap;
  final StorageQuotaState state;
  final Map<String, int> perMode;

  const StorageQuotaSnapshot({
    required this.total,
    required this.cap,
    required this.state,
    required this.perMode,
  });

  bool get canCreate => state != StorageQuotaState.cap;
  double get usageFraction => cap <= 0 ? 0 : total / cap;

  static StorageQuotaSnapshot empty() => const StorageQuotaSnapshot(
        total: 0,
        cap: QuotaConstants.storageCapFree,
        state: StorageQuotaState.healthy,
        perMode: {},
      );
}

/// Tracks how many conversations the user has stored across all modes.
///
/// - Reads the aggregate count up front via Firestore `count()` — one
///   billed read per refresh, cached for [_cacheTtl].
/// - Reads the per-mode breakdown lazily: only when the state enters
///   `warning` or `cap` (the banner needs those numbers; the healthy state
///   does not).
/// - Invalidated from the outside via [invalidate] after any create or
///   delete of a conversation doc so the next getter call refetches.
class StorageQuotaProvider extends ChangeNotifier {
  static const Duration _cacheTtl = Duration(seconds: 60);

  final FirebaseDatasource _firebase;
  String? _uid;
  String _tier = 'free';
  StorageQuotaSnapshot _snapshot = StorageQuotaSnapshot.empty();
  DateTime? _fetchedAt;
  bool _isRefreshing = false;

  StorageQuotaProvider({required FirebaseDatasource firebase})
      : _firebase = firebase;

  StorageQuotaSnapshot get snapshot => _snapshot;
  bool get isRefreshing => _isRefreshing;

  Future<void> init({required String uid, required String tier}) async {
    _uid = uid;
    _tier = tier;
    await refresh();
  }

  /// Call after any create or delete of a conversation doc so the next
  /// [refresh] bypasses the TTL cache and hits Firestore again.
  void invalidate() {
    _fetchedAt = null;
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    if (_isRefreshing) return;
    if (_fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < _cacheTtl) {
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    try {
      final total = await _firebase.countConversations(uid);
      final cap = QuotaConstants.getStorageCap(_tier);
      final state = _deriveState(total: total, cap: cap);

      Map<String, int> breakdown = const {};
      if (state != StorageQuotaState.healthy) {
        breakdown = await _firebase.breakdownConversationsByMode(uid);
      }

      _snapshot = StorageQuotaSnapshot(
        total: total,
        cap: cap,
        state: state,
        perMode: breakdown,
      );
      _fetchedAt = DateTime.now();
    } catch (_) {
      // Fail open — keep last snapshot. Next refresh will try again.
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  static StorageQuotaState deriveStateForTest({
    required int total,
    required int cap,
  }) =>
      _deriveState(total: total, cap: cap);

  static StorageQuotaState _deriveState({
    required int total,
    required int cap,
  }) {
    if (cap <= 0) return StorageQuotaState.healthy;
    if (total >= cap) return StorageQuotaState.cap;
    if (total >= (cap * QuotaConstants.storageWarningThreshold).floor()) {
      return StorageQuotaState.warning;
    }
    return StorageQuotaState.healthy;
  }
}
