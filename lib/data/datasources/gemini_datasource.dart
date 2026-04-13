import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';

class GeminiDatasource {
  late final GenerativeModel _model;

  GeminiDatasource() {
    _model = GenerativeModel(
      model: ApiConstants.modelFlash,
      apiKey: ApiConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: ApiConstants.temperature,
        topP: ApiConstants.topP,
        topK: ApiConstants.topK,
        maxOutputTokens: ApiConstants.maxTokensFlash,
      ),
    );
  }

  /// Generate a scenario lesson context + AI opening line.
  /// Returns raw JSON string for the caller to parse.
  Future<String> generateScenarioLesson(String topic, String proficiency) async {
    final prompt = '''
You are an English conversation coach. Generate a realistic scenario for practicing English.

Topic: $topic
Proficiency Level: $proficiency

Create a scenario that:
1. Is realistic and relatable
2. Matches the proficiency level (beginner = simple vocab, advanced = complex idioms)
3. Includes context (location, time, who you're talking to)
4. Starts with an opening line from the AI (role-player)
5. Includes a Vietnamese sentence for the student to translate to English

Format your response as JSON:
{
  "scenarioContext": "You are at a hotel reception desk...",
  "vietnameseSentence": "Xin chào, tôi muốn đặt phòng...",
  "englishTranslation": "Hello, I would like to book a room...",
  "openingLine": "Welcome to the Grand Hotel! How can I help you today?",
  "vocabularyPrep": ["check-in", "reservation", "room type"],
  "hints": [
    "Start with a polite greeting",
    "Specify what you need clearly",
    "Mention relevant details like dates or preferences"
  ],
  "difficulty": "$proficiency"
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '{}';
  }

  /// Evaluate user's roleplay response. Returns JSON string for AssessmentResult parsing.
  Future<String> evaluateUserResponse({
    required String userText,
    required String scenarioContext,
    required String vietnameseSentence,
    required String proficiencyLevel,
    required String direction,
  }) async {
    final prompt = '''
You are an English conversation coach evaluating a student's translation/response.

Student's Response: "$userText"
Original Sentence: "$vietnameseSentence"
Translation Direction: $direction
Scenario Context: $scenarioContext
Proficiency Level: $proficiencyLevel

Evaluate and return JSON (no markdown, pure JSON only):
{
  "score": 8,
  "accuracyScore": 9,
  "naturalnessScore": 8,
  "complexityScore": 7,
  "feedback": "Good translation! Your response captures the main idea clearly.",
  "correction": "Corrected version if needed, or null",
  "betterAlternative": "A more natural way to say it",
  "analysis": "Overall analysis of the response",
  "grammarAnalysis": "Grammar-specific feedback",
  "vocabularyAnalysis": "Vocabulary usage feedback",
  "improvements": [
    {
      "original": "what user said",
      "suggestion": "better version",
      "explanation": "why this is better"
    }
  ],
  "userTone": "Neutral",
  "alternativeTones": {
    "formal": {"text": "Formal version of the response", "color": "#6366F1"},
    "friendly": {"text": "Friendly version", "color": "#9A7B3D"},
    "informal": {"text": "Informal/casual version", "color": "#D98A8A"},
    "conversational": {"text": "Conversational version", "color": "#7BC6A0"}
  }
}

Score scale: 1-10 for each metric.
Respond with ONLY the JSON object, no extra text.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '{}';
  }

  /// Generate progressive hints for a scenario.
  Future<String> generateProgressiveHints({
    required String scenarioContext,
    required String vietnameseSentence,
    required int hintLevel,
  }) async {
    final prompt = '''
You are helping a student who is struggling with translating a sentence.

Scenario: $scenarioContext
Sentence to translate: "$vietnameseSentence"
Hint Level: $hintLevel (1=vocab hint, 2=structure hint, 3=full example)

Generate 3 progressive hints:
1. Vocabulary hint: Key words to use
2. Structure hint: Sentence pattern "I want to [verb]..."
3. Full example: A complete sentence they can adapt

Return JSON only:
{
  "hints": ["hint 1", "hint 2", "hint 3"]
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '{"hints": []}';
  }

  /// Parse JSON from Gemini response, handling markdown code blocks.
  static Map<String, dynamic> parseJson(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
