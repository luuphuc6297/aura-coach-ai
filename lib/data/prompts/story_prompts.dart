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

Respond with ONLY a JSON object:
{
  "score": 8,
  "accuracyScore": 9,
  "naturalnessScore": 8,
  "logicScore": 9,
  "feedback": "Overall feedback",
  "grammarAnalysis": "Grammar feedback",
  "improvements": [
    {"original": "exact substring", "suggestion": "better version", "explanation": "why"}
  ],
  "nextAgentReply": "Agent's next line in English",
  "nextAgentReplyVietnamese": "Vietnamese translation of the agent's next line"
}
''';
}
