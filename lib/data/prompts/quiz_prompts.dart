import 'dart:convert';

/// Build the prompt that evaluates a user's answer to a saved-item quiz.
/// The response MUST match the assessment responseSchema — no ad-hoc fields.
String buildQuizEvaluationPrompt({
  required String itemOriginal,
  required String itemCorrection,
  required String itemType,
  required String itemContext,
  required String userAnswer,
}) {
  return '''
Role: Vocabulary and Grammar Quiz Master.

Context:
The user is being tested on a saved item from their learning history.
- Original phrase/context: "$itemOriginal"
- Correct target phrase/usage: "$itemCorrection"
- Item Type: $itemType
- Full Context: "$itemContext"

The user's answer to the quiz question is: "$userAnswer"

Task:
1. Evaluate if the user's answer correctly demonstrates understanding of the target phrase/usage ("$itemCorrection").
2. Assign scores (1-10). If they nailed it, give high scores.
3. Provide constructive feedback.
4. **Identify Specific Improvements**: Find exact substrings in the user's input that are wrong or unnatural. Each improvement MUST include type: 'grammar' | 'vocabulary'.
5. Generate nextAgentReply (short encouraging follow-up in English) plus nextAgentReplyVietnamese.

Respond with a JSON object matching the assessment responseSchema.
''';
}

/// Build the prompt that generates exercises for a vocabulary list.
/// [vocabList] is a list of maps with keys `word` and `context`.
/// Response shape matches web's exerciseSchema: an array of objects with
/// fields {id, type, question, options, answer, hint, explanation,
/// targetWord}.
String buildExercisesPrompt(List<Map<String, String>> vocabList) {
  final vocabJson = const JsonEncoder.withIndent('  ').convert(vocabList);
  return '''
Create ${vocabList.length} interactive exercises based on this vocabulary list:
$vocabJson

For each word, create either a 'fill-in-the-blank' or 'sentence-construction' exercise.
- 'fill-in-the-blank': use "___" for the blank in the question; provide 4 options (including the correct one); set answer to the correct option.
- 'sentence-construction': question is a prompt/scenario; answer is a sample correct sentence using the targetWord.

Always provide: id (unique string), type, question, options (array; empty for sentence-construction if not applicable), answer, hint (optional), explanation, targetWord.

Respond with a JSON array matching the exercises responseSchema.
''';
}
