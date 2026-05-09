import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../../../data/gemini/config.dart';
import '../models/grammar_exercise.dart';
import '../models/grammar_topic.dart';
import 'grammar_gemini_service.dart';

/// Concrete [GrammarGeminiService] backed by Gemini Flash.
///
/// Two endpoints — one for fresh exercise generation, one for free-text
/// answer evaluation. Both use strict response schemas so partial /
/// malformed AI output fails fast instead of producing garbled UI.
///
/// Per the project memory note about Gemini Pro preview being slow,
/// everything routes through Flash. 30-second wall-clock timeout on
/// every call so the user can retry rather than stare at a spinner.
class GrammarGeminiServiceImpl implements GrammarGeminiService {
  final Uuid _uuid;
  static const Duration _timeout = Duration(seconds: 30);

  GrammarGeminiServiceImpl({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  // ─────────────────────────────────────────────────────────────────────
  //  generateExercise
  // ─────────────────────────────────────────────────────────────────────

  @override
  Future<GrammarExercise> generateExercise({
    required GrammarTopic topic,
    required GrammarPracticeMode mode,
    required CefrLevel userLevel,
    required List<String> recentPromptFingerprints,
    required List<GrammarErrorType> recentMistakeTypes,
    GrammarExerciseDirection? direction,
  }) async {
    if (!GeminiConfig.isApiKeyConfigured) {
      throw const SocketException('Gemini API key is not configured');
    }

    final prompt = _buildGeneratePrompt(
      topic: topic,
      mode: mode,
      userLevel: userLevel,
      recentPromptFingerprints: recentPromptFingerprints,
      recentMistakeTypes: recentMistakeTypes,
      direction: direction,
    );

    // Higher temperature than evaluation — we want creative variety in
    // generated prompts, but not so high that the structure drifts.
    final model = GeminiConfig.flash(
      temperature: 0.85,
      responseSchema: _generateSchema,
    );

    final raw = await _run(model, prompt);
    final json = _parseJson(raw);

    return GrammarExercise(
      id: _uuid.v4(),
      topicId: topic.id,
      mode: mode,
      prompt: (json['prompt'] as String).trim(),
      hint: (json['hint'] as String?)?.trim(),
      direction: direction,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(growable: false),
      correctAnswer: (json['correctAnswer'] as String).trim(),
      alternateCorrectAnswers: (json['alternateCorrectAnswers']
                  as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList(growable: false) ??
          const [],
      explanation: (json['explanation'] as String? ?? '').trim(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  evaluateAnswer
  // ─────────────────────────────────────────────────────────────────────

  @override
  Future<GrammarEvaluation> evaluateAnswer({
    required GrammarExercise exercise,
    required String userAnswer,
    required GrammarTopic topic,
  }) async {
    if (!GeminiConfig.isApiKeyConfigured) {
      throw const SocketException('Gemini API key is not configured');
    }

    final prompt = _buildEvaluatePrompt(
      exercise: exercise,
      userAnswer: userAnswer,
      topic: topic,
    );

    // Lower temperature for evaluation — we want consistent, predictable
    // grading across the same answer (the user can't tell whether they
    // got marks for "creativity" or "luck"; consistency matters more).
    final model = GeminiConfig.flash(
      temperature: 0.1,
      responseSchema: _evaluateSchema,
    );

    final raw = await _run(model, prompt);
    final json = _parseJson(raw);

    final score = ((json['score'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
    return GrammarEvaluation(
      isCorrect: (json['isCorrect'] as bool?) ?? (score >= 0.85),
      score: score,
      matchedAnswer: (json['matchedAnswer'] as String?)?.trim(),
      feedback: (json['feedback'] as String? ?? '').trim(),
      correctedAnswer: (json['correctedAnswer'] as String?)?.trim(),
      correctedSentence: (json['correctedSentence'] as String?)?.trim(),
      correctedSentenceVi: (json['correctedSentenceVi'] as String?)?.trim(),
      extraExampleEn: (json['extraExampleEn'] as String?)?.trim(),
      extraExampleVi: (json['extraExampleVi'] as String?)?.trim(),
      errorType: GrammarErrorTypeId.fromId(json['errorType'] as String?),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  prompts
  // ─────────────────────────────────────────────────────────────────────

  String _buildGeneratePrompt({
    required GrammarTopic topic,
    required GrammarPracticeMode mode,
    required CefrLevel userLevel,
    required List<String> recentPromptFingerprints,
    required List<GrammarErrorType> recentMistakeTypes,
    GrammarExerciseDirection? direction,
  }) {
    final exampleSeed = topic.examples.take(2).map((e) => '- "${e.en}"').join('\n');
    final mistakeTags = recentMistakeTypes.map((t) => t.id).toSet().join(', ');
    final recent = recentPromptFingerprints
        .map((s) => '- "$s"')
        .take(5)
        .join('\n');

    final modeBlock = switch (mode) {
      GrammarPracticeMode.translate =>
        _translateModeBlock(direction ?? GrammarExerciseDirection.enToVi),
      GrammarPracticeMode.fillBlank => _fillBlankModeBlock(),
      GrammarPracticeMode.transform => _transformModeBlock(),
    };

    return '''
You are a Vietnamese-English grammar coach building a single practice exercise.

Topic: ${topic.title} (${topic.titleVi})
CEFR level: ${userLevel.label}
Formula: ${topic.formula}
Reference examples (do NOT reuse verbatim):
${exampleSeed.isEmpty ? '(none)' : exampleSeed}

Practice mode: ${mode.id}

$modeBlock

Constraints:
- Keep the English sentence natural and within 14 words.
- Match the learner's CEFR level (${userLevel.label}); avoid niche idioms or rare vocabulary one band above.
- DO NOT generate a prompt close to any of these recent ones:
${recent.isEmpty ? '(none)' : recent}
${mistakeTags.isEmpty ? '' : '- Lean toward exercises that drill these recent error types: $mistakeTags.'}

Output JSON only — match the schema exactly. Vietnamese strings must be natural Vietnamese (no literal word-for-word translation).
''';
  }

  String _translateModeBlock(GrammarExerciseDirection direction) {
    final isEnToVi = direction == GrammarExerciseDirection.enToVi;
    return '''
Translate mode rules:
- direction: ${isEnToVi ? 'EN → VI' : 'VI → EN'}.
- "prompt" = the SOURCE sentence (${isEnToVi ? 'English' : 'Vietnamese'}). It MUST naturally use the target structure.
- "correctAnswer" = the natural ${isEnToVi ? 'Vietnamese' : 'English'} translation.
- "alternateCorrectAnswers" = up to 2 acceptable phrasings (e.g. contractions, register variants).
- "hint" = null.
- "options" = null.
- "explanation" = ONE short Vietnamese sentence stating why this tense / structure fits.
''';
  }

  String _fillBlankModeBlock() {
    return '''
Fill-in-blank mode rules:
- "prompt" = an English sentence with exactly one "_____" blank where the target form goes.
- "hint" = the verb base form in parentheses, e.g. "(go)" — or null if the blank is not a verb.
- "correctAnswer" = the inflected/correct word or short phrase that fills the blank.
- "alternateCorrectAnswers" = up to 2 alternative correct forms (e.g. "have got" alongside "have").
- "options" = null (free text). Set to a 4-element list ONLY when 4 plausible distractors are obvious; default null.
- "explanation" = ONE short Vietnamese sentence stating why this form is required.
''';
  }

  String _transformModeBlock() {
    return '''
Transform mode rules:
- "prompt" = a base English sentence in a NEUTRAL tense/form (e.g. "I didn't study, so I failed.").
- "hint" = the Vietnamese rendering using the target structure (e.g. "Nếu tôi đã học thì tôi đã không trượt.").
- "correctAnswer" = the transformed English sentence using the target structure (e.g. "If I had studied, I wouldn't have failed.").
- "alternateCorrectAnswers" = up to 2 acceptable variants (different word order, equivalent phrasing).
- "options" = null.
- "explanation" = ONE short Vietnamese sentence with the grammatical rationale.
''';
  }

  String _buildEvaluatePrompt({
    required GrammarExercise exercise,
    required String userAnswer,
    required GrammarTopic topic,
  }) {
    final modeLabel = switch (exercise.mode) {
      GrammarPracticeMode.translate =>
        'Translate (${exercise.direction?.id ?? 'unspecified'})',
      GrammarPracticeMode.fillBlank => 'Fill in the blank',
      GrammarPracticeMode.transform => 'Transform',
    };

    final alternates = exercise.alternateCorrectAnswers.isEmpty
        ? '(none)'
        : exercise.alternateCorrectAnswers.map((s) => '"$s"').join(', ');

    return '''
You are evaluating one learner answer for a grammar practice exercise.

Topic: ${topic.title} — Formula: ${topic.formula}
Mode: $modeLabel
Prompt: "${exercise.prompt}"
${exercise.hint == null ? '' : 'Hint: "${exercise.hint}"'}
Canonical correct answer: "${exercise.correctAnswer}"
Alternate accepted answers: $alternates

Learner answer: "$userAnswer"

Grade strictly:
- Score 1.0 → correct in form, tense, agreement, and naturalness. Minor casing / punctuation differences allowed.
- Score 0.7–0.9 → essentially correct but with small lapses (spelling, missing article, casing only).
- Score 0.4–0.6 → partially correct (e.g. right vocab but wrong tense / wrong word order).
- Score 0.0–0.3 → off-topic or fundamentally wrong.

Set "isCorrect" = true ONLY when score ≥ 0.85.
"errorType" must be one of: tense, spelling, word_order, vocab, agreement, other (use "other" when correct).
"feedback" — one-to-two SHORT Vietnamese sentences explaining what's right or wrong. No mention of scores. Avoid praise inflation.
"correctedAnswer" — show the polished form when the learner is wrong; null when correct.
"matchedAnswer" — when correct, copy the canonical or alternate string they matched; null otherwise.
"correctedSentence" — the FULL correct English sentence the learner should have produced. Crucially:
   • Fill-blank: the prompt with the blank replaced by the canonical answer (NO "_____" remaining).
   • Translate VI→EN: the target English sentence.
   • Translate EN→VI: the original English prompt unchanged.
   • Transform: the rewritten English sentence.
   Always non-null. No ellipses or trailing commentary.

"correctedSentenceVi" — the Vietnamese MEANING of the prompt sentence. This is a natural Vietnamese rendering of what the FULL English sentence (i.e. correctedSentence) actually says. NOT a grammar explanation, NOT a hint, NOT feedback — just the plain meaning translation. One sentence. Idiomatic Vietnamese, not a word-for-word transliteration.
   • Translate EN→VI: same as the user's expected answer (the canonical Vietnamese rendering).
   • Translate VI→EN: copy the original Vietnamese prompt here.
   • Fill-blank / Transform: translate the full English sentence above.
   Always non-null.

"extraExampleEn" — ONE additional original English sentence using the SAME grammar pattern as the exercise (≤ 14 words). Different vocabulary and context so the learner can generalise. Always non-null.

"extraExampleVi" — natural Vietnamese MEANING of "extraExampleEn" (one sentence, idiomatic). Always non-null.

Output JSON only.
''';
  }

  // ─────────────────────────────────────────────────────────────────────
  //  schemas
  // ─────────────────────────────────────────────────────────────────────

  static final Schema _generateSchema = Schema.object(
    properties: {
      'prompt': Schema.string(
        description: 'Sentence shown to the user. Per-mode semantics.',
      ),
      'hint': Schema.string(
        description: 'Optional secondary text (verb base, VI rendering).',
        nullable: true,
      ),
      'options': Schema.array(
        items: Schema.string(),
        nullable: true,
        description: 'Multiple-choice options (4 items) or null for free text.',
      ),
      'correctAnswer': Schema.string(
        description: 'Canonical correct answer.',
      ),
      'alternateCorrectAnswers': Schema.array(
        items: Schema.string(),
        description: 'Up to 2 acceptable variants.',
      ),
      'explanation': Schema.string(
        description: 'One Vietnamese sentence justifying the structure.',
      ),
    },
    requiredProperties: const [
      'prompt',
      'correctAnswer',
      'alternateCorrectAnswers',
      'explanation',
    ],
  );

  static final Schema _evaluateSchema = Schema.object(
    properties: {
      'isCorrect': Schema.boolean(),
      'score': Schema.number(
        description: '0.0..1.0 grading score.',
      ),
      'matchedAnswer': Schema.string(
        nullable: true,
        description:
            'Which canonical or alternate the user matched; null when wrong.',
      ),
      'feedback': Schema.string(
        description: 'One-to-two short Vietnamese sentences.',
      ),
      'correctedAnswer': Schema.string(
        nullable: true,
        description: 'Polished form when learner was wrong.',
      ),
      'correctedSentence': Schema.string(
        description:
            'Full English sentence the learner should produce; substitute '
            'the blank for fill-blank, full target for translate/transform.',
      ),
      'correctedSentenceVi': Schema.string(
        description: 'Vietnamese translation of correctedSentence.',
      ),
      'extraExampleEn': Schema.string(
        description:
            'One extra English sentence using the same grammar pattern, '
            'different vocabulary, ≤ 14 words.',
      ),
      'extraExampleVi': Schema.string(
        description: 'Vietnamese translation of extraExampleEn.',
      ),
      'errorType': Schema.enumString(enumValues: const [
        'tense',
        'spelling',
        'word_order',
        'vocab',
        'agreement',
        'other',
      ]),
    },
    requiredProperties: const [
      'isCorrect',
      'score',
      'feedback',
      'errorType',
      'correctedSentence',
      'correctedSentenceVi',
      'extraExampleEn',
      'extraExampleVi',
    ],
  );

  // ─────────────────────────────────────────────────────────────────────
  //  helpers
  // ─────────────────────────────────────────────────────────────────────

  /// Run the model with a wall-clock timeout. Throws on timeout or empty
  /// response so the provider's catch block can surface a retry CTA.
  Future<String> _run(GenerativeModel model, String prompt) async {
    try {
      final response = await model
          .generateContent([Content.text(prompt)]).timeout(_timeout);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const FormatException('Gemini returned empty response.');
      }
      return text;
    } on TimeoutException {
      throw const SocketException('Gemini request timed out (30s).');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GrammarGemini] _run failed: $e');
      }
      rethrow;
    }
  }

  /// Strip an optional ```json fence the model sometimes adds despite
  /// `application/json` mime, then decode. Throws [FormatException] on
  /// malformed payload.
  Map<String, dynamic> _parseJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      // Drop the first fence line and the trailing ``` if present.
      final firstNl = text.indexOf('\n');
      if (firstNl > 0) text = text.substring(firstNl + 1);
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
      text = text.trim();
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
          'Gemini response is not a JSON object: ${raw.substring(0, raw.length.clamp(0, 200))}');
    }
    return decoded;
  }
}

