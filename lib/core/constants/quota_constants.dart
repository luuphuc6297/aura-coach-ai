class QuotaConstants {
  QuotaConstants._();

  static const freeRoleplayQuota = 5;
  static const freeStoryQuota = 3;
  static const freeTranslatorQuota = 10;
  static const freeDictionaryQuota = 5;
  static const freeMindMapQuota = 3;
  static const freeTtsQuota = 5;

  static const proRoleplayQuota = 15;
  static const proStoryQuota = 10;
  static const proTranslatorQuota = -1;
  static const proDictionaryQuota = -1;
  static const proMindMapQuota = 10;
  static const proTtsQuota = 15;

  /// Aggregate cap on conversations a user may keep across all modes.
  /// Prevents unbounded per-user Firestore growth from heavy daily use.
  static const storageCapFree = 20;
  static const storageCapPro = 200;
  static const storageCapPremium = 500;

  /// Fraction of the cap at which the soft-warning banner kicks in.
  static const storageWarningThreshold = 0.80;

  /// Storage cap for a given subscription tier. Unknown tiers fall back to
  /// the free cap — matches the fail-closed posture we use for daily
  /// quotas and avoids paid behaviour leaking via an unexpected tier string.
  static int getStorageCap(String tier) {
    switch (tier) {
      case 'pro':
        return storageCapPro;
      case 'premium':
        return storageCapPremium;
      case 'free':
      default:
        return storageCapFree;
    }
  }

  static int getLimit(String tier, String feature) {
    final limits = {
      'free': {
        'roleplay': freeRoleplayQuota,
        'story': freeStoryQuota,
        'translator': freeTranslatorQuota,
        'dictionary': freeDictionaryQuota,
        'mindmap': freeMindMapQuota,
        'tts': freeTtsQuota,
      },
      'pro': {
        'roleplay': proRoleplayQuota,
        'story': proStoryQuota,
        'translator': proTranslatorQuota,
        'dictionary': proDictionaryQuota,
        'mindmap': proMindMapQuota,
        'tts': proTtsQuota,
      },
      'premium': {
        'roleplay': -1,
        'story': -1,
        'translator': -1,
        'dictionary': -1,
        'mindmap': -1,
        'tts': -1,
      },
    };
    return limits[tier]?[feature] ?? 0;
  }
}
