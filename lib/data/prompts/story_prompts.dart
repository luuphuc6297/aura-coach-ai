import 'prompt_constants.dart';

/// Build the initial scenario prompt for Story Mode.
/// [customContext] overrides [topic] when provided.
String buildStoryScenarioPrompt({
  required CefrLevel level,
  required String topic,
  required List<String> previousTitles,
  String? customContext,
}) {
  final recent = previousTitles.length > 20
      ? previousTitles.sublist(previousTitles.length - 20)
      : previousTitles;
  final recentContextStr = recent.join(' | ');

  final contextBlock = customContext != null && customContext.isNotEmpty
      ? 'Context/Scenario: $customContext'
      : 'Topic: $topic.\n    6. **STRICT UNIQUENESS**: You MUST NOT generate any scenario that is similar in theme, title, or situation to these previously generated scenarios: [$recentContextStr]. Think outside the box and create a completely new sub-topic or situation.';

  return '''
Create a conversation starter scenario for an English learner.
Level: ${level.code}.
$contextBlock

Instructions:
1. Define a specific, highly unique situation where the User interacts with an Agent based on the context/topic above.
2. Give the Agent a name.
3. Write the FIRST line (opening line) that the Agent says to the User. It should be a greeting or a question to start the conversation.
4. Provide the Vietnamese translation for that opening line.
5. Provide 3 progressive hints for the USER on how to reply to this opening line:
   - Level 1: Meaning/Intent hint (e.g., "You should greet back and ask about...").
   - Level 2: Structure hint (e.g., "Start with 'Hi', then use Present Perfect...").
   - Level 3: Vocabulary hint (e.g., "Use the word '...'").

Respond with ONLY a JSON object:
{
  "title": "Short 3-6 word headline",
  "situation": "Specific situation description",
  "agentName": "Agent's name",
  "agentOpeningLine": "First line the agent says in English",
  "agentOpeningLineVietnamese": "Vietnamese translation of the opening line",
  "difficulty": "${level.code}",
  "hints": {
    "level1": "Intent/meaning hint in Vietnamese",
    "level2": "English structure hint with skeleton",
    "level3": "Key vocabulary with Vietnamese meanings"
  }
}
''';
}

/// Build a standalone "help me reply" hint prompt for Story Mode. Produces
/// the same level1/level2/level3 structure as the opening-turn hints so the
/// UI can reuse the same progressive-reveal widget regardless of turn.
String buildStoryReplyHintsPrompt({
  required String situation,
  required String agentName,
  required String agentMessage,
  required CefrLevel level,
}) {
  return '''
Role: English conversation coach helping a Vietnamese learner reply to a chat partner.

Context:
- Scene: $situation
- Agent name: $agentName
- Agent just said: "$agentMessage"
- Learner CEFR level: ${level.code}

Task: Produce 3 progressive hints for how the learner should reply to the agent's message.

Respond with ONLY a JSON object:
{
  "level1": "Meaning / intent hint, written in Vietnamese. Explain what the learner should say conceptually.",
  "level2": "English structure hint with a skeleton pattern (e.g. 'I\\'ve been ___ for ___ because ___'). Keep under 18 words.",
  "level3": "Key English vocabulary to use, each followed by the Vietnamese meaning in parentheses. Comma-separated."
}
''';
}

/// Build a simple English → Vietnamese translation prompt. Used when the
/// learner taps "Translate" on an AI message in any chat mode.
String buildVietnameseTranslationPrompt(String englishText) {
  return '''
Translate the following English sentence into natural, conversational Vietnamese.
Keep the same tone and register. Do NOT add commentary.

Sentence: "$englishText"

Respond with ONLY a JSON object:
{
  "translation": "Vietnamese translation here"
}
''';
}

/// Build the per-turn evaluation prompt for Story Mode.
String buildStoryTurnPrompt({
  required String situation,
  required String agentName,
  required String agentLastMessage,
  required String userReply,
  required CefrLevel targetLevel,
}) {
  return '''
Role: Conversational English Coach.

Context:
- Scene: $situation
- Agent Name: $agentName
- Agent just said: "$agentLastMessage"
- User replied: "$userReply"
- Target Level: ${targetLevel.code}

Task:
1. Evaluate the user's reply for logic (does it make sense?), grammar, and appropriate tone for the situation.
2. Assign scores (1-10).
3. **Identify Specific Improvements**: Find exact substrings in the user's input that are wrong or unnatural. Provide corrections and explanations for each.
4. Generate the Next Logical Reply for the Agent to continue the conversation naturally.
5. **Grammar Breakdown** (Vietnamese learner deliverable):
   Populate `grammarBreakdown` with TWO variants when applicable:
   - `userVersion` — break down the user's exact sentence (as-is, errors included).
   - `correctVersion` — break down the canonical correct version. Set to null when the user's reply is already grammatically correct AND natural.
   Each variant must include: `tense` (English) + `tenseVi` (Vietnamese name like "Hiện tại đơn") + `tenseExplanation` (1-2 sentences Vietnamese, explain why this tense fits), `components[]` (Subject / Main Verb / Object / Adverbial — each with role + roleVi in Vietnamese), `auxiliaries[]` (be / have / do / modals / key prepositions / conjunctions — each with `function` in Vietnamese explaining its job in THIS sentence, flag VN learner pitfalls), optional `structureNote` formula.
   If the user reply is a fragment / single word / non-sentence utterance, set `grammarBreakdown` to null.

Respond with ONLY a JSON object:
{
  "score": 8,
  "accuracyScore": 9,
  "naturalnessScore": 8,
  "logicScore": 9,
  "feedback": "Overall feedback",
  "grammarAnalysis": "Grammar feedback",
  "improvements": [
    {"original": "exact substring", "correction": "better version", "type": "grammar | vocabulary", "explanation": "why"}
  ],
  "grammarBreakdown": {
    "userVersion": {
      "sentence": "...",
      "tense": "Present Simple",
      "tenseVi": "Hiện tại đơn",
      "tenseExplanation": "Vietnamese: why this tense fits here.",
      "components": [
        {"text": "I", "role": "Subject", "roleVi": "Chủ ngữ"},
        {"text": "go", "role": "Main Verb", "roleVi": "Động từ chính"}
      ],
      "auxiliaries": [
        {"text": "to", "type": "infinitive marker", "function": "Vietnamese explanation"}
      ],
      "structureNote": "S + V + O"
    },
    "correctVersion": null
  },
  "nextAgentReply": "Agent's next line in English",
  "nextAgentReplyVietnamese": "Vietnamese translation of the agent's next line"
}
''';
}
