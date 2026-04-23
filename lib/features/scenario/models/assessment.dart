import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// AI-driven evaluation of a user's response. Matches the web assessment
/// schema 1:1 on business-logic fields (scores, improvements, userTone,
/// alternativeTones payload). Mobile wraps the web's flat string payload
/// with a [ToneVariation] UI layer that assigns the Clay palette color per
/// tone key — colors stay mobile-owned, never round-tripped to the AI.
class AssessmentResult {
  final int score;
  final int accuracyScore;
  final int naturalnessScore;
  final int complexityScore;
  final String feedback;
  final String? correction;
  final String? betterAlternative;
  final String analysis;
  final String grammarAnalysis;
  final String vocabularyAnalysis;
  final List<Improvement> improvements;
  final List<KeyVocabulary> keyVocabulary;
  final String userTone;
  final AlternativeTones alternativeTones;
  final String? nextAgentReply;
  final String? nextAgentReplyVietnamese;

  const AssessmentResult({
    required this.score,
    required this.accuracyScore,
    required this.naturalnessScore,
    required this.complexityScore,
    required this.feedback,
    this.correction,
    this.betterAlternative,
    required this.analysis,
    required this.grammarAnalysis,
    required this.vocabularyAnalysis,
    required this.improvements,
    this.keyVocabulary = const [],
    required this.userTone,
    required this.alternativeTones,
    this.nextAgentReply,
    this.nextAgentReplyVietnamese,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      score: (json['score'] as num?)?.toInt() ?? 5,
      accuracyScore: (json['accuracyScore'] as num?)?.toInt() ?? 5,
      naturalnessScore: (json['naturalnessScore'] as num?)?.toInt() ?? 5,
      complexityScore: (json['complexityScore'] as num?)?.toInt() ?? 5,
      feedback: json['feedback'] as String? ?? '',
      correction: json['correction'] as String?,
      betterAlternative: json['betterAlternative'] as String?,
      analysis: json['analysis'] as String? ?? '',
      grammarAnalysis: json['grammarAnalysis'] as String? ?? '',
      vocabularyAnalysis: json['vocabularyAnalysis'] as String? ?? '',
      improvements: (json['improvements'] as List<dynamic>?)
              ?.map((e) => Improvement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keyVocabulary: (json['keyVocabulary'] as List<dynamic>?)
              ?.map((e) => KeyVocabulary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userTone: json['userTone'] as String? ?? 'Neutral',
      alternativeTones: _readAlternativeTones(json['alternativeTones']),
      nextAgentReply: json['nextAgentReply'] as String?,
      nextAgentReplyVietnamese: json['nextAgentReplyVietnamese'] as String?,
    );
  }

  /// Firestore round-trips use [toJson]/[fromJson]. Live AI responses arrive
  /// in the web's flat-string shape for `alternativeTones` — persisted docs
  /// store the mobile nested shape. Dispatch to the right factory by sniffing
  /// the first tone value so resumed conversations don't crash the chat.
  static AlternativeTones _readAlternativeTones(dynamic raw) {
    if (raw is! Map) return AlternativeTones.fromAiJson(null);
    final map = Map<String, dynamic>.from(raw);
    final isPersistedShape = map.values.any((v) => v is Map);
    return isPersistedShape
        ? AlternativeTones.fromJson(map)
        : AlternativeTones.fromAiJson(map);
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'accuracyScore': accuracyScore,
        'naturalnessScore': naturalnessScore,
        'complexityScore': complexityScore,
        'feedback': feedback,
        'correction': correction,
        'betterAlternative': betterAlternative,
        'analysis': analysis,
        'grammarAnalysis': grammarAnalysis,
        'vocabularyAnalysis': vocabularyAnalysis,
        'improvements': improvements.map((e) => e.toJson()).toList(),
        'keyVocabulary': keyVocabulary.map((e) => e.toJson()).toList(),
        'userTone': userTone,
        'alternativeTones': alternativeTones.toJson(),
        'nextAgentReply': nextAgentReply,
        'nextAgentReplyVietnamese': nextAgentReplyVietnamese,
      };
}

/// A noteworthy vocabulary item the AI surfaced from the user's response or
/// the better alternative so the learner can one-tap save it to their
/// dictionary.
class KeyVocabulary {
  final String word;
  final String partOfSpeech;
  final String meaning;
  final String example;

  const KeyVocabulary({
    required this.word,
    required this.partOfSpeech,
    required this.meaning,
    this.example = '',
  });

  factory KeyVocabulary.fromJson(Map<String, dynamic> json) => KeyVocabulary(
        word: (json['word'] as String?)?.trim() ?? '',
        partOfSpeech: (json['partOfSpeech'] as String?)?.trim() ?? '',
        meaning: (json['meaning'] as String?)?.trim() ?? '',
        example: (json['example'] as String?)?.trim() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'word': word,
        'partOfSpeech': partOfSpeech,
        'meaning': meaning,
        'example': example,
      };
}

/// Classification of an [Improvement]. Matches web Improvement.type.
/// SavedItems and Quiz mode use this to split grammar vs vocabulary drills.
enum ImprovementType {
  grammar,
  vocabulary;

  static ImprovementType fromString(String? value) {
    return value == 'grammar'
        ? ImprovementType.grammar
        : ImprovementType.vocabulary;
  }

  String get value => name;
}

class Improvement {
  final String original;
  final String correction;
  final ImprovementType type;
  final String explanation;

  const Improvement({
    required this.original,
    required this.correction,
    required this.type,
    required this.explanation,
  });

  factory Improvement.fromJson(Map<String, dynamic> json) => Improvement(
        original: json['original'] as String? ?? '',
        correction: json['correction'] as String? ?? '',
        type: ImprovementType.fromString(json['type'] as String?),
        explanation: json['explanation'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'original': original,
        'correction': correction,
        'type': type.value,
        'explanation': explanation,
      };
}

/// Four tonal variations surfaced in the Inline Assessment. AI contract
/// (web schema) is a flat string map; mobile decorates each string with a
/// palette color for widget rendering.
class AlternativeTones {
  final ToneVariation formal;
  final ToneVariation friendly;
  final ToneVariation informal;
  final ToneVariation conversational;

  const AlternativeTones({
    required this.formal,
    required this.friendly,
    required this.informal,
    required this.conversational,
  });

  /// Build from the AI flat string shape:
  /// `{formal: "...", friendly: "...", informal: "...", conversational: "..."}`
  factory AlternativeTones.fromAiJson(Map<String, dynamic>? json) {
    String read(String key) => (json?[key] as String?) ?? '';
    return AlternativeTones(
      formal: ToneVariation(text: read('formal'), color: AppColors.formalTone),
      friendly:
          ToneVariation(text: read('friendly'), color: AppColors.friendlyTone),
      informal:
          ToneVariation(text: read('informal'), color: AppColors.casualTone),
      conversational: ToneVariation(
          text: read('conversational'), color: AppColors.neutralTone),
    );
  }

  /// Build from persisted mobile shape (toJson output, e.g. Firestore cache).
  factory AlternativeTones.fromJson(Map<String, dynamic> json) =>
      AlternativeTones(
        formal: ToneVariation.fromJson(
            (json['formal'] as Map<String, dynamic>?) ?? const {},
            fallbackColor: AppColors.formalTone),
        friendly: ToneVariation.fromJson(
            (json['friendly'] as Map<String, dynamic>?) ?? const {},
            fallbackColor: AppColors.friendlyTone),
        informal: ToneVariation.fromJson(
            (json['informal'] as Map<String, dynamic>?) ?? const {},
            fallbackColor: AppColors.casualTone),
        conversational: ToneVariation.fromJson(
            (json['conversational'] as Map<String, dynamic>?) ?? const {},
            fallbackColor: AppColors.neutralTone),
      );

  Map<String, dynamic> toJson() => {
        'formal': formal.toJson(),
        'friendly': friendly.toJson(),
        'informal': informal.toJson(),
        'conversational': conversational.toJson(),
      };
}

class ToneVariation {
  final String text;
  final Color color;

  const ToneVariation({required this.text, required this.color});

  factory ToneVariation.fromJson(
    Map<String, dynamic> json, {
    required Color fallbackColor,
  }) {
    Color color = fallbackColor;
    final raw = json['color'];
    if (raw is String && raw.startsWith('#') && raw.length == 7) {
      final value = int.tryParse(raw.substring(1), radix: 16);
      if (value != null) color = Color(0xFF000000 | value);
    }
    return ToneVariation(
      text: json['text'] as String? ?? '',
      color: color,
    );
  }

  Map<String, dynamic> toJson() {
    final hex = color.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
    return {
      'text': text,
      'color': '#$hex',
    };
  }
}
