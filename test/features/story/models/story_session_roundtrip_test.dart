import 'package:aura_coach_ai/features/scenario/models/assessment.dart';
import 'package:aura_coach_ai/features/story/models/story_character.dart';
import 'package:aura_coach_ai/features/story/models/story_session.dart';
import 'package:aura_coach_ai/features/story/models/story_turn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AssessmentResult buildAssessment() => AssessmentResult(
        score: 8,
        accuracyScore: 9,
        naturalnessScore: 8,
        complexityScore: 7,
        feedback: 'Nice phrasing.',
        analysis: 'Detailed analysis.',
        grammarAnalysis: 'Grammar Point: clean.',
        vocabularyAnalysis: 'Vocabulary Point: rich.',
        improvements: const [],
        userTone: 'Friendly',
        alternativeTones: AlternativeTones.fromAiJson(const {
          'formal': 'Good day.',
          'friendly': 'Hey!',
          'informal': 'yo',
          'conversational': 'Hi there.',
        }),
      );

  StorySession buildSession() => StorySession(
        conversationId: 'conv-1',
        storyId: 'story-1',
        title: 'Hotel Check-in',
        situation: 'You arrive at a hotel after a long flight.',
        character: const StoryCharacter(
          name: 'Maria',
          role: 'Receptionist',
          personality: 'warm, efficient',
          initial: 'M',
          gradient: 'teal-purple',
        ),
        topic: 'travel',
        level: 'B1',
        customContext: null,
        characterPreference: null,
        status: StorySessionStatus.inProgress,
        turns: [
          StoryTurn(
            id: 't0',
            role: StoryTurnRole.ai,
            text: 'Welcome! Do you have a reservation?',
            timestamp: DateTime.utc(2026, 4, 19, 10),
          ),
          StoryTurn(
            id: 't1',
            role: StoryTurnRole.user,
            text: 'Yes, under Smith.',
            timestamp: DateTime.utc(2026, 4, 19, 10, 1),
            assessment: buildAssessment(),
          ),
          StoryTurn(
            id: 't2',
            role: StoryTurnRole.ai,
            text: 'Found it. Welcome.',
            timestamp: DateTime.utc(2026, 4, 19, 10, 2),
          ),
        ],
        startedAt: DateTime.utc(2026, 4, 19, 9, 59),
        endedAt: null,
        updatedAt: DateTime.utc(2026, 4, 19, 10, 2),
        quotaCharged: true,
      );

  test('StorySession.toJson then fromJson preserves all turns and assessment',
      () {
    final original = buildSession();
    final restored = StorySession.fromJson(original.toJson());

    expect(restored.conversationId, original.conversationId);
    expect(restored.title, original.title);
    expect(restored.character.name, 'Maria');
    expect(restored.turns.length, 3);

    final userTurn = restored.turns[1];
    expect(userTurn.role, StoryTurnRole.user);
    expect(userTurn.assessment, isNotNull);
    expect(userTurn.assessment!.score, 8);
    expect(userTurn.assessment!.alternativeTones.formal.text, 'Good day.');
  });

  test('StoryTurn.fromJson rejects role="assessment" (regression guard)', () {
    expect(
      () => StoryTurn.fromJson({
        'id': 'x',
        'role': 'assessment',
        'text': '',
        'timestamp': DateTime.utc(2026, 4, 19).toIso8601String(),
      }),
      throwsA(isA<StateError>()),
    );
  });

  test('Average score uses only user-role turns with assessments', () {
    final s = buildSession();
    expect(s.averageScore, 8.0);
    expect(s.userTurnCount, 1);
  });
}
