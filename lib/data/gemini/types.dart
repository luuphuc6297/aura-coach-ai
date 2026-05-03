/// Types returned by Vocab Hub endpoints (word analysis, mind map, custom
/// node classification). Ported from aura-coach/services/gemini/types.ts.

class Morpheme {
  final String morpheme;
  final String meaning;
  final String? origin;

  const Morpheme({
    required this.morpheme,
    required this.meaning,
    this.origin,
  });

  factory Morpheme.fromJson(Map<String, dynamic> json) => Morpheme(
        morpheme: json['morpheme'] as String? ?? '',
        meaning: json['meaning'] as String? ?? '',
        origin: json['origin'] as String?,
      );
}

class Morphology {
  final Morpheme? prefix;
  final Morpheme root;
  final Morpheme? suffix;
  final String equation;

  const Morphology({
    this.prefix,
    required this.root,
    this.suffix,
    required this.equation,
  });

  factory Morphology.fromJson(Map<String, dynamic> json) => Morphology(
        prefix: json['prefix'] is Map<String, dynamic>
            ? Morpheme.fromJson(json['prefix'] as Map<String, dynamic>)
            : null,
        root: Morpheme.fromJson(
            (json['root'] as Map<String, dynamic>?) ?? const {}),
        suffix: json['suffix'] is Map<String, dynamic>
            ? Morpheme.fromJson(json['suffix'] as Map<String, dynamic>)
            : null,
        equation: json['equation'] as String? ?? '',
      );
}

class EnVnExample {
  final String en;
  final String vn;

  const EnVnExample({required this.en, required this.vn});

  factory EnVnExample.fromJson(Map<String, dynamic> json) => EnVnExample(
        en: json['en'] as String? ?? '',
        vn: json['vn'] as String? ?? '',
      );
}

class ContextualEmbedding {
  final EnVnExample positiveExample;
  final EnVnExample neutralExample;
  final EnVnExample negativeExample;
  final List<String> collocations;

  const ContextualEmbedding({
    required this.positiveExample,
    required this.neutralExample,
    required this.negativeExample,
    required this.collocations,
  });

  /// Ordered [positive, neutral, negative] example tuple. Callers that want to
  /// render the three-tile example strip should use this instead of reaching
  /// into the named fields directly.
  List<EnVnExample> get orderedExamples => [
        positiveExample,
        neutralExample,
        negativeExample,
      ];

  factory ContextualEmbedding.fromJson(Map<String, dynamic> json) =>
      ContextualEmbedding(
        positiveExample: EnVnExample.fromJson(
            (json['positiveExample'] as Map<String, dynamic>?) ?? const {}),
        neutralExample: EnVnExample.fromJson(
            (json['neutralExample'] as Map<String, dynamic>?) ?? const {}),
        negativeExample: EnVnExample.fromJson(
            (json['negativeExample'] as Map<String, dynamic>?) ?? const {}),
        collocations: (json['collocations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

class Derivatives {
  final String? noun;
  final String? verb;
  final String? adjective;
  final String? adverb;

  const Derivatives({this.noun, this.verb, this.adjective, this.adverb});

  factory Derivatives.fromJson(Map<String, dynamic> json) => Derivatives(
        noun: _sanitize(json['noun']),
        verb: _sanitize(json['verb']),
        adjective: _sanitize(json['adjective']),
        adverb: _sanitize(json['adverb']),
      );

  /// Defensive scrubber for derivative fields. Gemini has been observed to
  /// occasionally splice response metadata (HTTP status lines, JSON
  /// fragments, timestamps) into what should be a single-word string.
  /// We keep only the first lexical token, allow a simple hyphenated
  /// compound (e.g. "well-known"), and drop anything that still looks
  /// non-lexical (wrong character set, empty, or unreasonably long).
  static String? _sanitize(dynamic raw) {
    if (raw is! String) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;

    final cutIndex = value.indexOf(RegExp(r'[\s:;,{}\[\]"()<>\n\r\t/]'));
    if (cutIndex == 0) return null;
    if (cutIndex > 0) value = value.substring(0, cutIndex);

    if (value.length > 40) return null;
    if (!RegExp(r"^[A-Za-z][A-Za-z'\-]*$").hasMatch(value)) return null;

    return value;
  }
}

class WordAnalysis {
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String translation;
  final Morphology morphology;
  final ContextualEmbedding contextualEmbedding;
  final Derivatives derivatives;
  final List<String> synonyms;
  final List<String> antonyms;

  const WordAnalysis({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.translation,
    required this.morphology,
    required this.contextualEmbedding,
    required this.derivatives,
    required this.synonyms,
    required this.antonyms,
  });

  factory WordAnalysis.fromJson(Map<String, dynamic> json) => WordAnalysis(
        word: json['word'] as String? ?? '',
        phonetic: json['phonetic'] as String? ?? '',
        partOfSpeech: json['partOfSpeech'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        morphology: Morphology.fromJson(
            (json['morphology'] as Map<String, dynamic>?) ?? const {}),
        contextualEmbedding: ContextualEmbedding.fromJson(
            (json['contextualEmbedding'] as Map<String, dynamic>?) ?? const {}),
        derivatives: Derivatives.fromJson(
            (json['derivatives'] as Map<String, dynamic>?) ?? const {}),
        synonyms: (json['synonyms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        antonyms: (json['antonyms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

enum MindMapNodeType {
  topic,
  category,
  word;

  static MindMapNodeType fromString(String value) {
    switch (value) {
      case 'topic':
        return MindMapNodeType.topic;
      case 'category':
        return MindMapNodeType.category;
      case 'word':
      default:
        return MindMapNodeType.word;
    }
  }

  String get value => name;
}

class MindMapNode {
  final String id;
  final String label;
  final MindMapNodeType type;
  final String? translation;
  final String? partOfSpeech;
  final String? phonetic;
  final String? context;
  final List<MindMapNode> children;

  const MindMapNode({
    required this.id,
    required this.label,
    required this.type,
    this.translation,
    this.partOfSpeech,
    this.phonetic,
    this.context,
    this.children = const [],
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) => MindMapNode(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: MindMapNodeType.fromString(json['type'] as String? ?? 'word'),
        translation: json['translation'] as String?,
        partOfSpeech: json['partOfSpeech'] as String?,
        phonetic: _normalizePhonetic(json['phonetic']),
        context: json['context'] as String?,
        children: (json['children'] as List<dynamic>?)
                ?.map((e) => MindMapNode.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type.value,
        'translation': translation,
        'partOfSpeech': partOfSpeech,
        'phonetic': phonetic,
        'context': context,
        'children': children.map((c) => c.toJson()).toList(),
      };

  /// Returns a copy of this node with selected fields overridden. Provider
  /// mutations (replace children, append child, remove subtree) MUST funnel
  /// through this method so per-node metadata like [phonetic] never gets
  /// silently dropped when the tree is rebuilt.
  MindMapNode copyWith({
    String? id,
    String? label,
    MindMapNodeType? type,
    String? translation,
    String? partOfSpeech,
    String? phonetic,
    String? context,
    List<MindMapNode>? children,
  }) {
    return MindMapNode(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      translation: translation ?? this.translation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      phonetic: phonetic ?? this.phonetic,
      context: context ?? this.context,
      children: children ?? this.children,
    );
  }

  /// Coerces an empty string to null so the UI can use `phonetic != null` as a
  /// "should I render the IPA line?" check without falling for whitespace.
  static String? _normalizePhonetic(dynamic raw) {
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

enum CustomNodeStatus { connected, unrelated }

class CustomNodeResult {
  final CustomNodeStatus status;
  final String? parentNodeId;
  final String? message;
  final String? translation;
  final String? partOfSpeech;
  final String? phonetic;
  final String? context;

  const CustomNodeResult({
    required this.status,
    this.parentNodeId,
    this.message,
    this.translation,
    this.partOfSpeech,
    this.phonetic,
    this.context,
  });

  factory CustomNodeResult.fromJson(Map<String, dynamic> json) =>
      CustomNodeResult(
        status: (json['status'] as String? ?? 'unrelated') == 'connected'
            ? CustomNodeStatus.connected
            : CustomNodeStatus.unrelated,
        parentNodeId: json['parentNodeId'] as String?,
        message: json['message'] as String?,
        translation: json['translation'] as String?,
        partOfSpeech: json['partOfSpeech'] as String?,
        phonetic: MindMapNode._normalizePhonetic(json['phonetic']),
        context: json['context'] as String?,
      );
}

/// Dictionary lookup result for Vocab Hub save flow.
class DictionaryResult {
  final String partOfSpeech;
  final String pronunciation;
  final String explanation;
  final List<EnVnExample> examples;
  final List<String> synonyms;
  final String contextUsage;

  const DictionaryResult({
    required this.partOfSpeech,
    required this.pronunciation,
    required this.explanation,
    required this.examples,
    required this.synonyms,
    required this.contextUsage,
  });

  factory DictionaryResult.fromJson(Map<String, dynamic> json) =>
      DictionaryResult(
        partOfSpeech: json['partOfSpeech'] as String? ?? 'Other (Khác)',
        pronunciation: json['pronunciation'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        examples: (json['examples'] as List<dynamic>?)
                ?.map((e) => EnVnExample.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        synonyms: (json['synonyms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        contextUsage: json['contextUsage'] as String? ?? '',
      );
}

/// Single English candidate returned from the reverse dictionary (describe-a-
/// word) endpoint. Confidence is a 0.0-1.0 decimal.
class EnCandidate {
  final String en;
  final String vn;
  final String definition;
  final double confidence;
  final String example;

  const EnCandidate({
    required this.en,
    required this.vn,
    required this.definition,
    required this.confidence,
    required this.example,
  });

  factory EnCandidate.fromJson(Map<String, dynamic> json) => EnCandidate(
        en: json['en'] as String? ?? '',
        vn: json['vn'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
        example: json['example'] as String? ?? '',
      );
}

/// Per-word breakdown inside a [WordComparison]. Each field is meant to stand
/// on its own so the UI can render two columns side-by-side without extra
/// cross-referencing logic.
class ComparisonEntry {
  final String word;
  final String phonetic;
  final String translation;
  final String partOfSpeech;
  final String definition;

  /// Human label: "Formal" | "Neutral" | "Casual".
  final String register;

  /// Human label: "Positive" | "Neutral" | "Negative".
  final String connotation;

  final EnVnExample example;
  final List<String> collocations;

  const ComparisonEntry({
    required this.word,
    required this.phonetic,
    required this.translation,
    required this.partOfSpeech,
    required this.definition,
    required this.register,
    required this.connotation,
    required this.example,
    required this.collocations,
  });

  factory ComparisonEntry.fromJson(Map<String, dynamic> json) =>
      ComparisonEntry(
        word: json['word'] as String? ?? '',
        phonetic: json['phonetic'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        partOfSpeech: json['partOfSpeech'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        register: json['register'] as String? ?? 'Neutral',
        connotation: json['connotation'] as String? ?? 'Neutral',
        example: EnVnExample.fromJson(
            (json['example'] as Map<String, dynamic>?) ?? const {}),
        collocations: (json['collocations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

/// Side-by-side nuance comparison of two English words. Used by the Compare
/// Words Pro sub-screen.
class WordComparison {
  final ComparisonEntry wordA;
  final ComparisonEntry wordB;

  /// One short paragraph summarising the headline nuance between the two.
  final String keyDifference;

  /// Single-sentence guidance for when to pick word A.
  final String whenToUseA;

  /// Single-sentence guidance for when to pick word B.
  final String whenToUseB;

  const WordComparison({
    required this.wordA,
    required this.wordB,
    required this.keyDifference,
    required this.whenToUseA,
    required this.whenToUseB,
  });

  factory WordComparison.fromJson(Map<String, dynamic> json) => WordComparison(
        wordA: ComparisonEntry.fromJson(
            (json['wordA'] as Map<String, dynamic>?) ?? const {}),
        wordB: ComparisonEntry.fromJson(
            (json['wordB'] as Map<String, dynamic>?) ?? const {}),
        keyDifference: json['keyDifference'] as String? ?? '',
        whenToUseA: json['whenToUseA'] as String? ?? '',
        whenToUseB: json['whenToUseB'] as String? ?? '',
      );
}

/// Reverse dictionary lookup result — Vietnamese description → English
/// candidates ranked by confidence.
class ReverseDictionaryResult {
  final List<EnCandidate> candidates;

  const ReverseDictionaryResult({required this.candidates});

  factory ReverseDictionaryResult.fromJson(Map<String, dynamic> json) =>
      ReverseDictionaryResult(
        candidates: (json['candidates'] as List<dynamic>?)
                ?.map((e) => EnCandidate.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// Exercise generated by Quiz mode from a SavedItem list.
class Exercise {
  final String id;
  final String type; // 'fill-in-the-blank' | 'sentence-construction'
  final String question;
  final List<String> options;
  final String answer;
  final String? hint;
  final String explanation;
  final String targetWord;

  const Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
    this.hint,
    required this.explanation,
    required this.targetWord,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'fill-in-the-blank',
        question: json['question'] as String? ?? '',
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        answer: json['answer'] as String? ?? '',
        hint: json['hint'] as String?,
        explanation: json['explanation'] as String? ?? '',
        targetWord: json['targetWord'] as String? ?? '',
      );
}

/// Payload for the Story mode agent state.
class StoryScenario {
  final String id;
  final String topic;
  final String situation;
  final String agentName;
  final String openingLine;
  final String openingLineVietnamese;
  final String difficulty;
  final StoryHints hints;

  const StoryScenario({
    required this.id,
    required this.topic,
    required this.situation,
    required this.agentName,
    required this.openingLine,
    required this.openingLineVietnamese,
    required this.difficulty,
    required this.hints,
  });

  factory StoryScenario.fromJson(Map<String, dynamic> json) => StoryScenario(
        id: json['id'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        situation: json['situation'] as String? ?? '',
        agentName: json['agentName'] as String? ?? '',
        openingLine: json['openingLine'] as String? ?? '',
        openingLineVietnamese: json['openingLineVietnamese'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'A1-A2',
        hints: StoryHints.fromJson(
            (json['hints'] as Map<String, dynamic>?) ?? const {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'situation': situation,
        'agentName': agentName,
        'openingLine': openingLine,
        'openingLineVietnamese': openingLineVietnamese,
        'difficulty': difficulty,
        'hints': hints.toJson(),
      };
}

class StoryHints {
  final String level1;
  final String level2;
  final String level3;

  const StoryHints({
    required this.level1,
    required this.level2,
    required this.level3,
  });

  factory StoryHints.fromJson(Map<String, dynamic> json) => StoryHints(
        level1: json['level1'] as String? ?? '',
        level2: json['level2'] as String? ?? '',
        level3: json['level3'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'level1': level1, 'level2': level2, 'level3': level3};
}

/// Payload for the Tone Translator.
class TranslationResult {
  final String original;
  final ToneSet tones;
  final GrammarAnalysis? grammarAnalysis;

  const TranslationResult({
    required this.original,
    required this.tones,
    this.grammarAnalysis,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      TranslationResult(
        original: json['original'] as String? ?? '',
        tones: ToneSet.fromJson(
            (json['tones'] as Map<String, dynamic>?) ?? const {}),
        grammarAnalysis: json['grammarAnalysis'] is Map<String, dynamic>
            ? GrammarAnalysis.fromJson(
                json['grammarAnalysis'] as Map<String, dynamic>)
            : null,
      );
}

class ToneEntry {
  final String text;
  final String quote;

  const ToneEntry({required this.text, required this.quote});

  factory ToneEntry.fromJson(Map<String, dynamic> json) => ToneEntry(
        text: json['text'] as String? ?? '',
        quote: json['quote'] as String? ?? '',
      );
}

class ToneSet {
  final ToneEntry formal;
  final ToneEntry friendly;
  final ToneEntry informal;
  final ToneEntry conversational;

  const ToneSet({
    required this.formal,
    required this.friendly,
    required this.informal,
    required this.conversational,
  });

  factory ToneSet.fromJson(Map<String, dynamic> json) => ToneSet(
        formal: ToneEntry.fromJson(
            (json['formal'] as Map<String, dynamic>?) ?? const {}),
        friendly: ToneEntry.fromJson(
            (json['friendly'] as Map<String, dynamic>?) ?? const {}),
        informal: ToneEntry.fromJson(
            (json['informal'] as Map<String, dynamic>?) ?? const {}),
        conversational: ToneEntry.fromJson(
            (json['conversational'] as Map<String, dynamic>?) ?? const {}),
      );
}

class GrammarComponent {
  final String text;
  final String type;
  final String explanation;

  const GrammarComponent({
    required this.text,
    required this.type,
    required this.explanation,
  });

  factory GrammarComponent.fromJson(Map<String, dynamic> json) =>
      GrammarComponent(
        text: json['text'] as String? ?? '',
        type: json['type'] as String? ?? 'other',
        explanation: json['explanation'] as String? ?? '',
      );
}

class GrammarAnalysis {
  final String sentence;
  final List<GrammarComponent> components;
  final String generalExplanation;

  const GrammarAnalysis({
    required this.sentence,
    required this.components,
    required this.generalExplanation,
  });

  factory GrammarAnalysis.fromJson(Map<String, dynamic> json) =>
      GrammarAnalysis(
        sentence: json['sentence'] as String? ?? '',
        components: (json['components'] as List<dynamic>?)
                ?.map(
                    (e) => GrammarComponent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        generalExplanation: json['generalExplanation'] as String? ?? '',
      );
}

/// One flashcard-ready word returned by the topic-suggestion endpoint. Shape
/// mirrors what the library flashcard view consumes, so the provider can
/// persist the payload without a follow-up Gemini enrichment call.
class TopicFlashcardWord {
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String translation;
  final EnVnExample example;

  const TopicFlashcardWord({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.translation,
    required this.example,
  });

  factory TopicFlashcardWord.fromJson(Map<String, dynamic> json) =>
      TopicFlashcardWord(
        word: (json['word'] as String? ?? '').trim(),
        phonetic: json['phonetic'] as String? ?? '',
        partOfSpeech: json['partOfSpeech'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        example: EnVnExample.fromJson(
            (json['example'] as Map<String, dynamic>?) ?? const {}),
      );
}

/// Wrapper payload for a topic-driven flashcard batch. Echoes the topic
/// label so the caller can verify the model stayed on-topic and label the
/// confirmation snackbar.
class TopicFlashcardBatch {
  final String topic;
  final List<TopicFlashcardWord> items;

  const TopicFlashcardBatch({required this.topic, required this.items});

  factory TopicFlashcardBatch.fromJson(Map<String, dynamic> json) =>
      TopicFlashcardBatch(
        topic: json['topic'] as String? ?? '',
        items: (json['items'] as List<dynamic>?)
                ?.map((e) =>
                    TopicFlashcardWord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
