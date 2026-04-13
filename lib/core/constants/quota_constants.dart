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
