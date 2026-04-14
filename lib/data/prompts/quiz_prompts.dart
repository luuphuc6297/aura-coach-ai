import 'dart:convert';

/// Build the prompt that evaluates a user's answer to a saved-item quiz.
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
4. **Identify Specific Improvements**: Find exact substrings in the user's input that are wrong or unnatural. Provide corrections and explanations for each.
5. Generate the Next Logical Reply (nextAgentReply) which should be a short encouraging message or a follow-up question.

Respond with ONLY a JSON object:
{
  "score": 8,
  "accuracyScore": 9,
  "naturalnessScore": 8,
  "feedback": "Constructive feedback",
  "improvements": [
    {"original": "exact substring", "suggestion": "better version", "explanation": "why"}
  ],
  "nextAgentReply": "Encouraging follow-up in English",
  "nextAgentReplyVietnamese": "Vietnamese translation"
}
''';
}

/// Build the prompt that generates exercises for a vocabulary list.
/// [vocabList] is a list of maps with keys `word` and `context`.
String buildExercisesPrompt(List<Map<String, String>> vocabList) {
  final vocabJson = const JsonEncoder.withIndent('  ').convert(vocabList);
  return '''
Create ${vocabList.length} interactive exercises based on this vocabulary list:
$vocabJson

For each word, create either a 'fill-in-the-blank' or 'sentence-construction' exercise.
- For 'fill-in-the-blank', provide a sentence with the target word missing (use "___"), 4 options (including the correct one), and the correct answer.
- For 'sentence-construction', provide a prompt or a scenario where the user needs to use the target word, and provide a sample correct answer.

Include a helpful hint and a brief explanation of why the answer is correct or how the word is used.

Respond with ONLY a JSON object:
{
  "exercises": [
    {
      "word": "target word",
      "type": "fill-in-the-blank",
      "sentence": "The cat ___ on the mat.",
      "options": ["sat", "ran", "ate", "slept"],
      "correctAnswer": "sat",
      "hint": "Past tense of 'sit'",
      "explanation": "..."
    },
    {
      "word": "target word",
      "type": "sentence-construction",
      "prompt": "Describe what you did yesterday using 'went'.",
      "sampleAnswer": "I went to the park yesterday.",
      "hint": "Use past tense",
      "explanation": "..."
    }
  ]
}
''';
}
