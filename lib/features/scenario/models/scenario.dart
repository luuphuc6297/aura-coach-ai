/// Structured hints produced by the Gemini scenario prompt. Each level has a
/// specific purpose:
///  - [level1]: Vietnamese description of the intent, no English words.
///  - [level2]: English sentence skeleton with `___` blanks.
///  - [level3]: Key vocabulary list with Vietnamese meanings.
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

  /// Legacy helper: stuff a flat list of 0-3 hint strings into level1/2/3.
  factory ScenarioHints.fromList(List<String> list) {
    return ScenarioHints(
      level1: list.isNotEmpty ? list[0] : '',
      level2: list.length > 1 ? list[1] : '',
      level3: list.length > 2 ? list[2] : '',
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

class Scenario {
  final String id;
  final String topic;
  final String vietnameseSentence;
  final String englishTranslation;
  final String context;
  final String difficulty;
  final String title;
  final String sentenceType;
  final ScenarioHints structuredHints;
  final List<String> vocabularyPrep;

  Scenario({
    required this.id,
    required this.topic,
    required this.vietnameseSentence,
    required this.englishTranslation,
    required this.context,
    required this.difficulty,
    this.title = '',
    this.sentenceType = '',
    ScenarioHints? structuredHints,
    List<String>? hints,
    required this.vocabularyPrep,
  }) : structuredHints = structuredHints ??
            (hints != null
                ? ScenarioHints.fromList(hints)
                : ScenarioHints.empty());

  /// Flat view of hints for widgets that still iterate hints as a list.
  List<String> get hints => structuredHints.toFlatList();
}
