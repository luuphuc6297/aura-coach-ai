import '../models/grammar_exercise.dart';
import '../models/grammar_topic.dart';

/// Result of evaluating one user answer. Kept separate from
/// [GrammarPracticeAttempt] because evaluations are sometimes resolved
/// client-side (multiple-choice exact match) without an AI round-trip;
/// the provider then synthesises the attempt from the exercise +
/// evaluation pair.
class GrammarEvaluation {
  /// Convenience: `score >= 0.85`. The threshold is centralised here so
  /// UI doesn't have to recompute and we only have one place to tune.
  final bool isCorrect;

  /// 0..1. `1.0` for exact match; `0.5` for "vocab right, tense wrong";
  /// `0.0` for completely off.
  final double score;

  /// Which acceptable answer the user matched (exact, alternate, or AI's
  /// best canonical form). Null when score < threshold.
  final String? matchedAnswer;

  /// Free-form feedback shown on the result card. Vietnamese-friendly
  /// study aid copy.
  final String feedback;

  /// AI's corrected version of the user's answer. Null when correct or
  /// when the AI didn't supply a specific correction.
  final String? correctedAnswer;

  final GrammarErrorType errorType;

  const GrammarEvaluation({
    required this.isCorrect,
    required this.score,
    required this.feedback,
    required this.errorType,
    this.matchedAnswer,
    this.correctedAnswer,
  });

  /// Helpful constructor for client-side exact-match evaluations.
  factory GrammarEvaluation.exact({required String matchedAnswer}) =>
      GrammarEvaluation(
        isCorrect: true,
        score: 1.0,
        matchedAnswer: matchedAnswer,
        feedback: '',
        errorType: GrammarErrorType.other,
      );

  /// Helpful constructor for client-side wrong multiple-choice answers.
  factory GrammarEvaluation.wrongMultipleChoice({
    required String correctAnswer,
  }) =>
      GrammarEvaluation(
        isCorrect: false,
        score: 0.0,
        feedback: '',
        correctedAnswer: correctAnswer,
        errorType: GrammarErrorType.other,
      );
}

/// AI surface for Grammar Coach. Two endpoints:
/// - [generateExercise] — produces one fresh AI-generated exercise scoped
///   to the topic + mode + user level + session history.
/// - [evaluateAnswer] — grades a free-text answer (translate / transform
///   / fill-blank text input). Multiple-choice and exact-match cases are
///   resolved client-side and never reach this method.
///
/// Concrete impl lives at `grammar_gemini_service_impl.dart` (Phase B3),
/// wraps the existing `GeminiService` plumbing with strict JSON schemas
/// and a 30s timeout (Flash, per memory note about Pro preview).
abstract class GrammarGeminiService {
  /// Generate one exercise. Throws on network / parse failure; provider
  /// catches and surfaces a retry CTA on the practice screen.
  Future<GrammarExercise> generateExercise({
    required GrammarTopic topic,
    required GrammarPracticeMode mode,
    required CefrLevel userLevel,

    /// Last few normalized prompts so the AI varies vocab and structure
    /// from one exercise to the next within a session.
    required List<String> recentPromptFingerprints,

    /// Last few error categories the user made; the AI biases toward
    /// drilling those (e.g. user keeps missing word order → generate
    /// more transformation prompts that hinge on word order).
    required List<GrammarErrorType> recentMistakeTypes,

    /// Translate-only — null for fillBlank / transform.
    GrammarExerciseDirection? direction,
  });

  /// Grade one free-text answer. Returns deterministic structure even
  /// on partial failure (e.g. AI returns malformed feedback) — the
  /// provider can rely on every field.
  Future<GrammarEvaluation> evaluateAnswer({
    required GrammarExercise exercise,
    required String userAnswer,
    required GrammarTopic topic,
  });
}
