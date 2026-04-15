/// Structured hints produced by the Gemini scenario prompt. Matches web
/// LessonContext.hints shape: three progressive levels of help.
class ScenarioHints {
  final String level1;
  final String level2;
  final String level3;

  const ScenarioHints({
    required this.level1,
    required this.level2,
    required this.level3,
  });

  factory ScenarioHints.empty() =>
      const ScenarioHints(level1: '', level2: '', level3: '');

  factory ScenarioHints.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ScenarioHints.empty();
    return ScenarioHints(
      level1: (json['level1'] as String?) ?? '',
      level2: (json['level2'] as String?) ?? '',
      level3: (json['level3'] as String?) ?? '',
    );
  }

  List<String> toFlatList() {
    return [level1, level2, level3].where((s) => s.isNotEmpty).toList();
  }

  Map<String, dynamic> toJson() => {
        'level1': level1,
        'level2': level2,
        'level3': level3,
      };
}

/// Scenario Coach lesson payload. Field names align with web LessonContext
/// (vietnamesePhrase / englishPhrase / situation) so JSON from Gemini
/// deserializes without an adapter. Two mobile-specific additions:
/// [sentenceType] (used for uniqueness tracking) and [vocabularyPrep]
/// (surfaced in ContextPanel).
class Scenario {
  final String id;
  final String topic;
  final String title;
  final String situation;
  final String vietnamesePhrase;
  final String englishPhrase;
  final String difficulty;
  final String sentenceType;
  final ScenarioHints hints;
  final List<String> vocabularyPrep;

  const Scenario({
    required this.id,
    required this.topic,
    required this.title,
    required this.situation,
    required this.vietnamesePhrase,
    required this.englishPhrase,
    required this.difficulty,
    required this.hints,
    this.sentenceType = '',
    this.vocabularyPrep = const [],
  });

  factory Scenario.fromJson(Map<String, dynamic> json) => Scenario(
        id: json['id'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        title: json['title'] as String? ?? '',
        situation: json['situation'] as String? ?? '',
        vietnamesePhrase: json['vietnamesePhrase'] as String? ?? '',
        englishPhrase: json['englishPhrase'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'A1-A2',
        sentenceType: json['sentenceType'] as String? ?? '',
        hints: ScenarioHints.fromJson(json['hints'] as Map<String, dynamic>?),
        vocabularyPrep: (json['vocabularyPrep'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'title': title,
        'situation': situation,
        'vietnamesePhrase': vietnamesePhrase,
        'englishPhrase': englishPhrase,
        'difficulty': difficulty,
        'sentenceType': sentenceType,
        'hints': hints.toJson(),
        'vocabularyPrep': vocabularyPrep,
      };

  Scenario copyWith({
    String? id,
    String? topic,
    String? title,
    String? situation,
    String? vietnamesePhrase,
    String? englishPhrase,
    String? difficulty,
    String? sentenceType,
    ScenarioHints? hints,
    List<String>? vocabularyPrep,
  }) =>
      Scenario(
        id: id ?? this.id,
        topic: topic ?? this.topic,
        title: title ?? this.title,
        situation: situation ?? this.situation,
        vietnamesePhrase: vietnamesePhrase ?? this.vietnamesePhrase,
        englishPhrase: englishPhrase ?? this.englishPhrase,
        difficulty: difficulty ?? this.difficulty,
        sentenceType: sentenceType ?? this.sentenceType,
        hints: hints ?? this.hints,
        vocabularyPrep: vocabularyPrep ?? this.vocabularyPrep,
      );
}
