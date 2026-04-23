// ignore_for_file: subtype_of_sealed_class

import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/data/datasources/firebase_datasource.dart';
import 'package:aura_coach_ai/data/repositories/story_repository.dart';
import 'package:aura_coach_ai/features/story/models/story.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NeverCalledFirestore extends Fake implements FirebaseFirestore {}

class _FakeFirebase extends FirebaseDatasource {
  _FakeFirebase({required this.live, this.shouldThrow = false})
      : super(db: _NeverCalledFirestore());

  List<Story> live;
  bool shouldThrow;

  @override
  Future<List<Story>> getFeaturedStories({String? level}) async {
    if (shouldThrow) throw StateError('offline');
    return live.where((s) => level == null || s.level == level).toList();
  }
}

Story _story({required String id, String level = 'B1'}) => Story(
      id: id,
      title: 'Story $id',
      topic: 'travel',
      level: level,
      situation: 'context',
      character: const StoryCharacter(
        name: 'X',
        role: 'r',
        personality: 'p',
        initial: 'X',
        gradient: 'teal-purple',
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('fetchFeatured returns Firestore result and updates cache', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    final repo = StoryRepository(
      firebase: _FakeFirebase(live: [_story(id: 's1'), _story(id: 's2')]),
      cache: cache,
    );

    final result = await repo.fetchFeatured(level: 'B1');
    expect(result, hasLength(2));
    final cached = await cache.getFeatured();
    expect(cached, hasLength(2));
  });

  test('fetchFeatured falls back to cache on Firestore failure', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    await cache.saveFeatured([_story(id: 'cached')]);

    final repo = StoryRepository(
      firebase: _FakeFirebase(live: [], shouldThrow: true),
      cache: cache,
    );

    final result = await repo.fetchFeatured(level: 'B1');
    expect(result, hasLength(1));
    expect(result.first.id, 'cached');
  });
}
