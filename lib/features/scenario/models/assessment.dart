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
      feedback: json['feedback'] as String? ?? 'No feedback available.',
      correction: json['correction'] as String?,
      betterAlternative: json['betterAlternative'] as String?,
      analysis: json['analysis'] as String? ?? '',
      grammarAnalysis: json['grammarAnalysis'] as String? ?? '',
      vocabularyAnalysis: json['vocabularyAnalysis'] as String? ?? '',
      improvements: (json['improvements'] as List<dynamic>?)
              ?.map((e) => Improvement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userTone: json['userTone'] as String? ?? 'Neutral',
      alternativeTones: json['alternativeTones'] != null
          ? AlternativeTones.fromJson(json['alternativeTones'] as Map<String, dynamic>)
          : AlternativeTones(
              formal: ToneVariation(text: '', color: '#6366F1'),
              friendly: ToneVariation(text: '', color: '#9A7B3D'),
              informal: ToneVariation(text: '', color: '#D98A8A'),
              conversational: ToneVariation(text: '', color: '#7BC6A0'),
            ),
      nextAgentReply: json['nextAgentReply'] as String?,
      nextAgentReplyVietnamese: json['nextAgentReplyVietnamese'] as String?,
    );
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
        'userTone': userTone,
        'alternativeTones': alternativeTones.toJson(),
      };
}

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

  factory AlternativeTones.fromJson(Map<String, dynamic> json) {
    return AlternativeTones(
      formal: _parseTone(json['formal']),
      friendly: _parseTone(json['friendly']),
      informal: _parseTone(json['informal']),
      conversational: _parseTone(json['conversational']),
    );
  }

  static ToneVariation _parseTone(dynamic value) {
    if (value is Map<String, dynamic>) {
      return ToneVariation.fromJson(value);
    }
    if (value is String) {
      return ToneVariation(text: value);
    }
    return const ToneVariation(text: '');
  }

  Map<String, dynamic> toJson() => {
        'formal': formal.toJson(),
        'friendly': friendly.toJson(),
        'informal': informal.toJson(),
        'conversational': conversational.toJson(),
      };
}

class ToneVariation {
  final String text;
  final String? color;

  const ToneVariation({
    required this.text,
    this.color,
  });

  factory ToneVariation.fromJson(Map<String, dynamic> json) {
    return ToneVariation(
      text: json['text'] as String? ?? '',
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'color': color,
      };
}

class Improvement {
  final String original;
  final String suggestion;
  final String explanation;

  const Improvement({
    required this.original,
    required this.suggestion,
    required this.explanation,
  });

  factory Improvement.fromJson(Map<String, dynamic> json) {
    return Improvement(
      original: json['original'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'original': original,
        'suggestion': suggestion,
        'explanation': explanation,
      };
}
