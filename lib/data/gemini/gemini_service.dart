import 'package:google_generative_ai/google_generative_ai.dart';
import '../prompts/prompt_constants.dart';
import '../prompts/scenario_prompts.dart';
import '../prompts/story_prompts.dart';
import '../prompts/tone_prompts.dart';
import '../prompts/vocab_prompts.dart';
import '../prompts/mindmap_prompts.dart';
import '../prompts/quiz_prompts.dart';
import '../prompts/video_prompt.dart';
import 'config.dart';
import 'helpers.dart';
import 'schemas.dart';
import 'types.dart';

/// Mobile-side mirror of aura-coach/services/geminiService.ts. Each public
/// method wires a specific model tier + temperature + responseSchema +
/// prompt, with [retryOperation] wrapping transient 429/503 failures.
///
/// Callers receive raw JSON strings (for payloads with mobile-specific
/// models like Scenario/AssessmentResult) or typed objects (for pure web
/// payloads like WordAnalysis/MindMapNode).
class GeminiService {
  GeminiService();

  // ---------- Scenario Coach ----------

  /// Generate the next Scenario Coach lesson. Returns raw JSON string so the
  /// caller can deserialize into the mobile [Scenario] model and enrich it
  /// with the topic / sentence type the prompt enforced.
  Future<NextLessonOutcome> generateNextLesson({
    required CefrLevel userLevel,
    required List<String> userTopics,
    required List<String> previousTitles,
  }) async {
    final built = buildGenerateNextLessonPrompt(
      userLevel: userLevel,
      userTopics: userTopics,
      previousTitles: previousTitles,
    );
    final model = GeminiConfig.flash(
      temperature: 0.9,
      responseSchema: GeminiSchemas.lesson,
    );
    final raw = await _run(model, built.prompt);
    return NextLessonOutcome(
      rawJson: raw,
      chosenTopic: built.chosenTopic,
      chosenSentenceType: built.chosenSentenceType,
    );
  }

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
    final model = GeminiConfig.flash(
      temperature: 0.3,
      responseSchema: GeminiSchemas.assessment,
    );
    return _run(model, prompt);
  }

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
    final model = GeminiConfig.flash(temperature: 0.3);
    return _run(model, prompt);
  }

  // ---------- Tone Translator ----------

  Future<String> generateToneTranslations(String text) async {
    final prompt = buildToneTranslationPrompt(text);
    final model = GeminiConfig.flash(
      temperature: 0.7,
      responseSchema: GeminiSchemas.translation,
    );
    return _run(model, prompt);
  }

  // ---------- Story Mode ----------

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
    final model = GeminiConfig.pro(
      temperature: 0.8,
      responseSchema: GeminiSchemas.story,
    );
    return _run(model, prompt);
  }

  Future<String> evaluateStoryTurn({
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
    final model = GeminiConfig.pro(
      temperature: 0.4,
      responseSchema: GeminiSchemas.assessment,
    );
    return _run(model, prompt);
  }

  // ---------- Quiz ----------

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
    final model = GeminiConfig.flash(
      temperature: 0.4,
      responseSchema: GeminiSchemas.assessment,
    );
    return _run(model, prompt);
  }

  Future<List<Exercise>> generateExercises(
      List<Map<String, String>> vocabList) async {
    if (vocabList.isEmpty) return const [];
    final prompt = buildExercisesPrompt(vocabList);
    final model = GeminiConfig.flash(
      temperature: 0.7,
      responseSchema: GeminiSchemas.exercises,
    );
    final raw = await _run(model, prompt);
    final list = parseJsonArray(raw);
    return list
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------- Vocab Hub — Dictionary & Word Analysis ----------

  Future<DictionaryResult> generateDictionaryExplanation({
    required String phrase,
    required String context,
  }) async {
    final prompt = buildDictionaryPrompt(phrase: phrase, context: context);
    final model = GeminiConfig.pro(
      temperature: 0.7,
      responseSchema: GeminiSchemas.dictionary,
    );
    final raw = await _run(model, prompt);
    return DictionaryResult.fromJson(parseJsonObject(raw));
  }

  Future<WordAnalysis> generateWordAnalysis({
    required String word,
    String? context,
  }) async {
    final prompt = buildWordAnalysisPrompt(word: word, context: context);
    final model = GeminiConfig.flash(
      temperature: 0.2,
      responseSchema: GeminiSchemas.wordAnalysis,
    );
    final raw = await _run(model, prompt);
    return WordAnalysis.fromJson(parseJsonObject(raw));
  }

  // ---------- Vocab Hub — Mind Map ----------

  Future<MindMapNode> generateTopicMindMap({
    required String topic,
    required CefrLevel level,
  }) async {
    final prompt = buildMindMapRootPrompt(topic: topic, level: level);
    final model = GeminiConfig.flash(
      temperature: 0.2,
      responseSchema: GeminiSchemas.mindMapRoot,
    );
    final raw = await _run(model, prompt);
    return MindMapNode.fromJson(parseJsonObject(raw));
  }

  Future<List<MindMapNode>> expandMindMapNode({
    required String nodeLabel,
    required String rootTopic,
    required CefrLevel level,
  }) async {
    final prompt = buildMindMapExpandPrompt(
      nodeLabel: nodeLabel,
      rootTopic: rootTopic,
      level: level,
    );
    final model = GeminiConfig.flash(
      temperature: 0.2,
      responseSchema: GeminiSchemas.mindMapChildren,
    );
    final raw = await _run(model, prompt);
    final list = parseJsonArray(raw);
    return list
        .map((e) => MindMapNode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomNodeResult> analyzeCustomNode({
    required String customWord,
    required List<Map<String, String>> existingNodes,
  }) async {
    final prompt = buildCustomNodePrompt(
      customWord: customWord,
      existingNodes: existingNodes,
    );
    final model = GeminiConfig.flash(
      temperature: 0.1,
      responseSchema: GeminiSchemas.customNode,
    );
    final raw = await _run(model, prompt);
    return CustomNodeResult.fromJson(parseJsonObject(raw));
  }

  // ---------- Video prompt (passthrough, no Gemini call) ----------

  String buildVideoGenerationPrompt({
    required String situation,
    required String phrase,
  }) =>
      buildVideoPrompt(situation: situation, phrase: phrase);

  // ---------- Internals ----------

  Future<String> _run(GenerativeModel model, String prompt) {
    return retryOperation<String>(() async {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw StateError('Empty response from Gemini');
      }
      return text;
    });
  }
}

/// Wrapper for [GeminiService.generateNextLesson] — carries the topic and
/// sentence type that the prompt's own random picker enforced, so the
/// provider can persist them alongside the AI output.
class NextLessonOutcome {
  final String rawJson;
  final String chosenTopic;
  final String chosenSentenceType;

  const NextLessonOutcome({
    required this.rawJson,
    required this.chosenTopic,
    required this.chosenSentenceType,
  });
}
