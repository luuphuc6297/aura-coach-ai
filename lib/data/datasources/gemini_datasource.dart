import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';
import '../prompts/prompt_constants.dart';
import '../prompts/scenario_prompts.dart';
import '../prompts/story_prompts.dart';
import '../prompts/tone_prompts.dart';
import '../prompts/vocab_prompts.dart';
import '../prompts/mindmap_prompts.dart';
import '../prompts/quiz_prompts.dart';
import '../prompts/video_prompt.dart';

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

  Future<String> _run(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  // ------------------- Scenario Coach -------------------

  /// Generate the next micro-scenario. Returns a [NextLessonResult] wrapping
  /// the raw JSON along with the topic and sentence type the prompt enforced.
  Future<NextLessonResult> generateNextLesson({
    required CefrLevel userLevel,
    required List<String> userTopics,
    required List<String> previousTitles,
  }) async {
    final built = buildGenerateNextLessonPrompt(
      userLevel: userLevel,
      userTopics: userTopics,
      previousTitles: previousTitles,
    );
    final raw = await _run(built.prompt);
    return NextLessonResult(
      rawJson: raw.isEmpty ? '{}' : raw,
      chosenTopic: built.chosenTopic,
      chosenSentenceType: built.chosenSentenceType,
    );
  }

  /// Evaluate the user's translation response.
  Future<String> evaluateResponse({
    required String userInput,
    required String sourcePhrase,
    required String situation,
    required CefrLevel targetLevel,
    required String direction,
  }) async {
    final prompt = buildEvaluateResponsePrompt(
      userInput: userInput,
      sourcePhrase: sourcePhrase,
      situation: situation,
      targetLevel: targetLevel,
      direction: direction,
    );
    final raw = await _run(prompt);
    return raw.isEmpty ? '{}' : raw;
  }

  /// Generate structured progressive hints for a scenario.
  Future<String> generateProgressiveHints({
    required String situation,
    required String vietnamesePhrase,
    required CefrLevel targetLevel,
  }) async {
    final prompt = buildProgressiveHintsPrompt(
      situation: situation,
      vietnamesePhrase: vietnamesePhrase,
      targetLevel: targetLevel,
    );
    final raw = await _run(prompt);
    return raw.isEmpty ? '{"hints":{}}' : raw;
  }

  // ------------------- Story Mode -------------------

  Future<String> generateStoryScenario({
    required CefrLevel level,
    required String topic,
    required List<String> previousTitles,
    String? customContext,
  }) async {
    final prompt = buildStoryScenarioPrompt(
      level: level,
      topic: topic,
      previousTitles: previousTitles,
      customContext: customContext,
    );
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  Future<String> generateStoryTurn({
    required String situation,
    required String agentName,
    required String agentLastMessage,
    required String userReply,
    required CefrLevel targetLevel,
  }) async {
    final prompt = buildStoryTurnPrompt(
      situation: situation,
      agentName: agentName,
      agentLastMessage: agentLastMessage,
      userReply: userReply,
      targetLevel: targetLevel,
    );
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  // ------------------- Tone Mode -------------------

  Future<String> generateToneTranslations(String text) async {
    final prompt = buildToneTranslationPrompt(text);
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  // ------------------- Vocab / Dictionary -------------------

  Future<String> lookupDictionary({
    required String phrase,
    required String context,
  }) async {
    final prompt = buildDictionaryPrompt(phrase: phrase, context: context);
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  Future<String> analyzeWord({required String word, String? context}) async {
    final prompt = buildWordAnalysisPrompt(word: word, context: context);
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  // ------------------- Mind Map -------------------

  Future<String> generateMindMapRoot({
    required String topic,
    required CefrLevel level,
  }) async {
    final prompt = buildMindMapRootPrompt(topic: topic, level: level);
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  Future<String> expandMindMapNode({
    required String nodeLabel,
    required String rootTopic,
    required CefrLevel level,
  }) async {
    final prompt = buildMindMapExpandPrompt(
      nodeLabel: nodeLabel,
      rootTopic: rootTopic,
      level: level,
    );
    return _run(prompt).then((v) => v.isEmpty ? '[]' : v);
  }

  Future<String> checkCustomMindMapNode({
    required String customWord,
    required List<Map<String, String>> existingNodes,
  }) async {
    final prompt = buildCustomNodePrompt(
      customWord: customWord,
      existingNodes: existingNodes,
    );
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  // ------------------- Quiz -------------------

  Future<String> evaluateQuizAnswer({
    required String itemOriginal,
    required String itemCorrection,
    required String itemType,
    required String itemContext,
    required String userAnswer,
  }) async {
    final prompt = buildQuizEvaluationPrompt(
      itemOriginal: itemOriginal,
      itemCorrection: itemCorrection,
      itemType: itemType,
      itemContext: itemContext,
      userAnswer: userAnswer,
    );
    return _run(prompt).then((v) => v.isEmpty ? '{}' : v);
  }

  Future<String> generateQuizExercises(
      List<Map<String, String>> vocabList) async {
    final prompt = buildExercisesPrompt(vocabList);
    return _run(prompt).then((v) => v.isEmpty ? '{"exercises":[]}' : v);
  }

  // ------------------- Video -------------------

  Future<String> buildVideoGenerationPrompt({
    required String situation,
    required String phrase,
  }) async {
    // This builder produces a prompt string to pass to a downstream video
    // generator; no Gemini round-trip is needed here.
    return buildVideoPrompt(situation: situation, phrase: phrase);
  }

  // ------------------- Parsing helpers -------------------

  /// Parse JSON from Gemini response, handling markdown code blocks.
  static Map<String, dynamic> parseJson(String text) {
    final cleaned = _stripFences(text);
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Parse a JSON array response (used by mindmap expansion).
  static List<dynamic> parseJsonArray(String text) {
    final cleaned = _stripFences(text);
    try {
      final decoded = jsonDecode(cleaned);
      return decoded is List ? decoded : [];
    } catch (_) {
      return [];
    }
  }

  static String _stripFences(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}

/// Wrapper returned by [GeminiDatasource.generateNextLesson] so the caller
/// can persist the topic and sentence type the prompt enforced alongside the
/// generated scenario.
class NextLessonResult {
  final String rawJson;
  final String chosenTopic;
  final String chosenSentenceType;

  const NextLessonResult({
    required this.rawJson,
    required this.chosenTopic,
    required this.chosenSentenceType,
  });
}
