import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../cache/story_cache.dart';
import '../datasources/firebase_datasource.dart';
import '../prompts/prompt_constants.dart';
import '../../features/story/models/story.dart';

/// Sources the Story library from three layers in order:
/// 1. Firestore `stories` collection (live, curated via admin tooling)
/// 2. SharedPreferences cache (last live snapshot, served offline)
/// 3. Bundled `assets/data/story_seeds.json` (ships with the app so a fresh
///    install on an unseeded Firestore still shows 12 curated stories).
class StoryRepository {
  static const _seedAsset = 'assets/data/story_seeds.json';

  final FirebaseDatasource _firebase;
  final StoryCache _cache;

  StoryRepository({
    required FirebaseDatasource firebase,
    required StoryCache cache,
  })  : _firebase = firebase,
        _cache = cache;

  Future<List<Story>> fetchFeatured({String? level}) async {
    try {
      // Always fetch the whole library from Firestore and filter client-side.
      // Profile levels arrive as 'beginner'/'intermediate'/'advanced' while
      // story documents store CEFR codes ('A1', 'B1', ...), so server-side
      // equality filtering would falsely return zero rows.
      final live = await _firebase.getFeaturedStories();
      if (live.isNotEmpty) {
        await _cache.saveFeatured(live);
        final filtered = _filterByLevel(live, level);
        if (filtered.isNotEmpty) return filtered;
      }
      // Firestore returned 0 docs — fall through to cache, then bundled
      // defaults, so first-launch users on an unseeded backend still see
      // something to start from.
    } catch (e) {
      debugPrint('[StoryRepository] fetchFeatured live read failed: $e');
    }

    final cached = await _cache.getFeatured();
    final filteredCache = _filterByLevel(cached, level);
    if (filteredCache.isNotEmpty) return filteredCache;

    final bundled = await _loadBundledStories();
    return _filterByLevel(bundled, level);
  }

  Future<Story?> fetchById(String storyId) async {
    try {
      final live = await _firebase.getStoryById(storyId);
      if (live != null) return live;
    } catch (e) {
      debugPrint('[StoryRepository] fetchById live read failed: $e');
    }
    final cached = await _cache.getFeatured();
    final match = _firstOrNull(cached, storyId);
    if (match != null) return match;
    final bundled = await _loadBundledStories();
    return _firstOrNull(bundled, storyId);
  }

  Future<List<Story>> _loadBundledStories() async {
    try {
      final raw = await rootBundle.loadString(_seedAsset);
      final decoded = jsonDecode(raw) as List<dynamic>;
      final stories = decoded
          .whereType<Map<String, dynamic>>()
          .map(Story.fromJson)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return stories;
    } catch (e) {
      debugPrint('[StoryRepository] bundled seeds failed: $e');
      return const [];
    }
  }

  List<Story> _filterByLevel(List<Story> stories, String? level) {
    if (level == null || level.isEmpty) return stories;
    final target = CefrLevel.fromProficiencyId(level);
    return stories
        .where((s) => CefrLevel.fromProficiencyId(s.level) == target)
        .toList();
  }

  /// Returns all stories whose CEFR level is NOT the learner's level,
  /// sorted by distance from that level (closest first). For a B1/B2 learner
  /// the order is A1/A2 → C1/C2. Used by the "Other Levels" section on the
  /// Story Home screen for gentle difficulty exploration.
  Future<List<Story>> fetchOtherLevels({required String userLevel}) async {
    List<Story> pool;
    try {
      pool = await _firebase.getFeaturedStories();
      if (pool.isEmpty) pool = await _cache.getFeatured();
      if (pool.isEmpty) pool = await _loadBundledStories();
    } catch (_) {
      pool = await _cache.getFeatured();
      if (pool.isEmpty) pool = await _loadBundledStories();
    }

    final target = CefrLevel.fromProficiencyId(userLevel);
    final other =
        pool.where((s) => CefrLevel.fromProficiencyId(s.level) != target);

    final targetRank = _levelRank(target);
    final sorted = other.toList()
      ..sort((a, b) {
        final distA =
            (_levelRank(CefrLevel.fromProficiencyId(a.level)) - targetRank)
                .abs();
        final distB =
            (_levelRank(CefrLevel.fromProficiencyId(b.level)) - targetRank)
                .abs();
        return distA.compareTo(distB);
      });
    return sorted;
  }

  int _levelRank(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1a2:
        return 0;
      case CefrLevel.b1b2:
        return 1;
      case CefrLevel.c1c2:
        return 2;
    }
  }

  Story? _firstOrNull(List<Story> stories, String id) {
    for (final s in stories) {
      if (s.id == id) return s;
    }
    return null;
  }
}
