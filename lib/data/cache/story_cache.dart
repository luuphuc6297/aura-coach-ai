import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/story/models/story.dart';

class StoryCache {
  static const _kFeaturedKey = 'story_cache.featured.v1';

  final Future<SharedPreferences> _prefs;

  StoryCache({SharedPreferences? prefs})
      : _prefs = prefs == null
            ? SharedPreferences.getInstance()
            : Future.value(prefs);

  Future<void> saveFeatured(List<Story> stories) async {
    try {
      final prefs = await _prefs;
      final raw = jsonEncode(stories.map((s) => s.toJson()).toList());
      await prefs.setString(_kFeaturedKey, raw);
    } catch (e) {
      debugPrint('[StoryCache] saveFeatured failed: $e');
    }
  }

  Future<List<Story>> getFeatured() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kFeaturedKey);
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Story.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[StoryCache] getFeatured failed: $e');
      return const [];
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_kFeaturedKey);
    } catch (e) {
      debugPrint('[StoryCache] clear failed: $e');
    }
  }
}
