import 'package:aura_coach_ai/features/story/models/story_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorySessionStatusX', () {
    test('fromWire("abandoned") normalises to inProgress for legacy docs', () {
      expect(
        StorySessionStatusX.fromWire('abandoned'),
        StorySessionStatus.inProgress,
      );
    });

    test('fromWire("completed") stays completed', () {
      expect(
        StorySessionStatusX.fromWire('completed'),
        StorySessionStatus.completed,
      );
    });

    test('fromWire("in-progress") is inProgress', () {
      expect(
        StorySessionStatusX.fromWire('in-progress'),
        StorySessionStatus.inProgress,
      );
    });

    test('fromWire unknown string falls back to inProgress', () {
      expect(
        StorySessionStatusX.fromWire('anything-else'),
        StorySessionStatus.inProgress,
      );
    });

    test('fromWire(null) falls back to inProgress', () {
      expect(
        StorySessionStatusX.fromWire(null),
        StorySessionStatus.inProgress,
      );
    });

    test('wireValue only emits in-progress or completed', () {
      final values = StorySessionStatus.values.map((s) => s.wireValue).toSet();
      expect(values, {'in-progress', 'completed'});
    });
  });
}
