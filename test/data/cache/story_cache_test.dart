import 'package:aura_coach_ai/data/cache/story_cache.dart';
import 'package:aura_coach_ai/features/story/models/story.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveFeatured roundtrips stories through SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);

    final input = [
      const Story(
        id: 's1',
        title: 'Airport Check-in',
        topic: 'travel',
        level: 'A2',
        situation: 'At the airport.',
        character: StoryCharacter(
          name: 'Liam',
          role: 'Agent',
          personality: 'helpful',
          initial: 'L',
          gradient: 'teal-gold',
        ),
      ),
    ];

    await cache.saveFeatured(input);
    final read = await cache.getFeatured();

    expect(read, hasLength(1));
    expect(read.first.title, 'Airport Check-in');
    expect(read.first.character.name, 'Liam');
  });

  test('getFeatured returns empty list when nothing cached', () async {
    final prefs = await SharedPreferences.getInstance();
    final cache = StoryCache(prefs: prefs);
    expect(await cache.getFeatured(), isEmpty);
  });
}
