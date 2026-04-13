import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalDatasource {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyCachedUid = 'cached_uid';
  static const _keyActiveConversation = 'active_conversation';
  static const _keyDailyUsagePrefix = 'daily_usage_';

  final SharedPreferences _prefs;

  LocalDatasource({required SharedPreferences prefs}) : _prefs = prefs;

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  String? get cachedUid => _prefs.getString(_keyCachedUid);

  Future<void> setCachedUid(String uid) async {
    await _prefs.setString(_keyCachedUid, uid);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> cacheActiveConversation(Map<String, dynamic> data) async {
    await _prefs.setString(_keyActiveConversation, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedActiveConversation() {
    final raw = _prefs.getString(_keyActiveConversation);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveConversation() async {
    await _prefs.remove(_keyActiveConversation);
  }

  Future<void> cacheDailyUsage(String date, Map<String, int> usage) async {
    await _prefs.setString(
      '$_keyDailyUsagePrefix$date',
      jsonEncode(usage),
    );
  }

  Map<String, int>? getCachedDailyUsage(String date) {
    final raw = _prefs.getString('$_keyDailyUsagePrefix$date');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return null;
    }
  }
}
