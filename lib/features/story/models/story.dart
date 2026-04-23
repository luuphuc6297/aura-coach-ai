import 'story_character.dart';

class Story {
  final String id;
  final String title;
  final String topic;
  final String level;
  final String situation;
  final StoryCharacter character;
  final int suggestedTurns;
  final String thumbnailIcon;
  final int order;

  const Story({
    required this.id,
    required this.title,
    required this.topic,
    required this.level,
    required this.situation,
    required this.character,
    this.suggestedTurns = 6,
    this.thumbnailIcon = '📖',
    this.order = 0,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        topic: json['topic'] as String? ?? 'social',
        level: json['level'] as String? ?? 'B1',
        situation: json['situation'] as String? ?? '',
        character: StoryCharacter.fromJson(
          (json['character'] as Map<String, dynamic>?) ?? const {},
        ),
        suggestedTurns: (json['suggestedTurns'] as num?)?.toInt() ?? 6,
        thumbnailIcon: json['thumbnailIcon'] as String? ?? '📖',
        order: (json['order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'topic': topic,
        'level': level,
        'situation': situation,
        'character': character.toJson(),
        'suggestedTurns': suggestedTurns,
        'thumbnailIcon': thumbnailIcon,
        'order': order,
      };
}
