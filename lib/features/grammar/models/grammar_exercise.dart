/// Grammar practice exercise + attempt models.
///
/// Two distinct shapes here:
///
/// - [GrammarExercise] — ephemeral, AI-generated per turn. Held only in
///   provider state during the active session; never persisted (we keep
///   variety high by always re-generating).
/// - [GrammarPracticeAttempt] — persisted to Firestore after the user
///   submits and the answer is checked. One attempt per submitted answer.
///   The full audit trail lives under
///   `users/{uid}/grammarAttempts/{attemptId}`.
library;

/// Practice mode the user picks at session start. Persisted as a string
/// slug (`mode.id`) so renames don't break old attempts.
enum GrammarPracticeMode { translate, fillBlank, transform }

extension GrammarPracticeModeId on GrammarPracticeMode {
  String get id => switch (this) {
        GrammarPracticeMode.translate => 'translate',
        GrammarPracticeMode.fillBlank => 'fill_blank',
        GrammarPracticeMode.transform => 'transform',
      };

  static GrammarPracticeMode fromId(String id) => switch (id) {
        'translate' => GrammarPracticeMode.translate,
        'fill_blank' => GrammarPracticeMode.fillBlank,
        'transform' => GrammarPracticeMode.transform,
        _ => GrammarPracticeMode.translate,
      };
}

/// Direction for translate-mode exercises. Alternates 50/50 within a
/// session so learners practice both encoding and decoding the structure.
enum GrammarExerciseDirection { enToVi, viToEn }

extension GrammarExerciseDirectionId on GrammarExerciseDirection {
  String get id => switch (this) {
        GrammarExerciseDirection.enToVi => 'en_to_vi',
        GrammarExerciseDirection.viToEn => 'vi_to_en',
      };

  static GrammarExerciseDirection fromId(String id) => switch (id) {
        'en_to_vi' => GrammarExerciseDirection.enToVi,
        'vi_to_en' => GrammarExerciseDirection.viToEn,
        _ => GrammarExerciseDirection.enToVi,
      };
}

/// Coarse error tag returned by AI evaluation. Lets us aggregate "user keeps
/// missing word order" across attempts. `other` is the fallback when AI
/// can't classify cleanly.
enum GrammarErrorType {
  tense,
  spelling,
  wordOrder,
  vocab,
  agreement,
  other,
}

extension GrammarErrorTypeId on GrammarErrorType {
  String get id => switch (this) {
        GrammarErrorType.tense => 'tense',
        GrammarErrorType.spelling => 'spelling',
        GrammarErrorType.wordOrder => 'word_order',
        GrammarErrorType.vocab => 'vocab',
        GrammarErrorType.agreement => 'agreement',
        GrammarErrorType.other => 'other',
      };

  static GrammarErrorType fromId(String? id) => switch (id) {
        'tense' => GrammarErrorType.tense,
        'spelling' => GrammarErrorType.spelling,
        'word_order' => GrammarErrorType.wordOrder,
        'vocab' => GrammarErrorType.vocab,
        'agreement' => GrammarErrorType.agreement,
        _ => GrammarErrorType.other,
      };
}

/// One AI-generated exercise. Lives in memory during the session.
///
/// Field semantics depend on `mode`:
/// - `translate`: `prompt` is the source sentence; `direction` decides
///   which way; `correctAnswer` is the natural target translation;
///   `alternateCorrectAnswers` holds 1–2 acceptable variants; `options`
///   is null.
/// - `fillBlank`: `prompt` contains a `_____` blank; `hint` may carry
///   the verb base form `(go)`; `correctAnswer` is the inflected form;
///   `options` may hold 4 multiple-choice strings (1 right + 3 plausible
///   distractors). When `options` is null the user types the answer.
/// - `transform`: `prompt` is a base English sentence in neutral form;
///   `hint` is the Vietnamese rendering using the target structure;
///   `correctAnswer` is the transformed English sentence; `direction` is
///   null (transform is always EN → EN with VI hint).
class GrammarExercise {
  /// Stable id assigned by provider (UUID v4 typically). Used to dedupe
  /// inside a session and to reference back from
  /// [GrammarPracticeAttempt.exerciseId].
  final String id;

  /// Topic this exercise drills.
  final String topicId;

  final GrammarPracticeMode mode;

  /// The sentence shown to the user. See per-mode semantics above.
  final String prompt;

  /// Optional secondary text (verb hint, Vietnamese rendering for
  /// transform, etc.). Null when not applicable.
  final String? hint;

  /// Translate-mode direction. Null for fillBlank / transform.
  final GrammarExerciseDirection? direction;

  /// Multiple-choice options (4 items). Null = free-text answer.
  final List<String>? options;

  /// Canonical correct answer.
  final String correctAnswer;

  /// Other strings the evaluator should accept as correct (contractions,
  /// equivalent phrasings, common Vietnamese register variants).
  final List<String> alternateCorrectAnswers;

  /// Post-check explanation. Vietnamese-friendly study aid copy.
  final String explanation;

  const GrammarExercise({
    required this.id,
    required this.topicId,
    required this.mode,
    required this.prompt,
    required this.correctAnswer,
    required this.explanation,
    this.hint,
    this.direction,
    this.options,
    this.alternateCorrectAnswers = const [],
  });

  /// Convenience: true when this exercise is multiple-choice (client-side
  /// can short-circuit AI evaluation in that case).
  bool get isMultipleChoice => options != null && options!.isNotEmpty;
}

/// One submitted answer, persisted to Firestore. Append-only — we never
/// mutate an attempt after creation.
class GrammarPracticeAttempt {
  /// Firestore doc id (Firestore-generated push id).
  final String id;
  final String topicId;

  /// Session this attempt belongs to. Used to roll up per-session
  /// summary stats (accuracy, mistakes list) without scanning the whole
  /// attempts collection.
  final String sessionId;

  /// Pin a copy of the exercise id so we can look back even if exercise
  /// dedupe state was lost.
  final String exerciseId;

  final GrammarPracticeMode mode;

  /// Snapshot of the exercise prompt at the time of the attempt — keeps
  /// the attempt self-describing for the Library save flow and for the
  /// summary mistakes list.
  final String prompt;
  final String userAnswer;
  final String correctAnswer;

  final bool isCorrect;

  /// 0..1 score from the evaluator. For exact-match modes (multiple
  /// choice, fill-blank with single form) this is 1.0 / 0.0; for
  /// translate / transform / free production it can be partial (0.5 for
  /// "vocab right, tense wrong" etc.).
  final double score;

  final String feedback;

  final GrammarErrorType errorType;

  /// Unix epoch milliseconds.
  final int timestamp;

  const GrammarPracticeAttempt({
    required this.id,
    required this.topicId,
    required this.sessionId,
    required this.exerciseId,
    required this.mode,
    required this.prompt,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.score,
    required this.feedback,
    required this.errorType,
    required this.timestamp,
  });

  factory GrammarPracticeAttempt.fromJson(Map<String, dynamic> json) {
    return GrammarPracticeAttempt(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      mode: GrammarPracticeModeId.fromId(json['mode'] as String? ?? ''),
      prompt: json['prompt'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] as String? ?? '',
      errorType: GrammarErrorTypeId.fromId(json['errorType'] as String?),
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'sessionId': sessionId,
        'exerciseId': exerciseId,
        'mode': mode.id,
        'prompt': prompt,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'isCorrect': isCorrect,
        'score': score,
        'feedback': feedback,
        'errorType': errorType.id,
        'timestamp': timestamp,
      };
}
