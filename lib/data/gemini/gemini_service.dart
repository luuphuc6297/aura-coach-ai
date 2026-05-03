import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
import '../prompts/describe_word_prompt.dart';
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
  ///
  /// [excludeVietnamesePhrases] is populated by the provider only on a retry
  /// after a client-side duplicate check rejected a previous generation —
  /// the list reinforces the "avoid repetition" instruction so the LLM
  /// actually produces a different sentence this time.
  Future<NextLessonOutcome> generateNextLesson({
    required CefrLevel userLevel,
    required List<String> userTopics,
    required List<String> previousTitles,
    List<String> excludeVietnamesePhrases = const [],
  }) async {
    final built = buildGenerateNextLessonPrompt(
      userLevel: userLevel,
      userTopics: userTopics,
      previousTitles: previousTitles,
      excludeVietnamesePhrases: excludeVietnamesePhrases,
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
    // Use Flash instead of Pro for Story scenario generation: Pro preview
    // models have been intermittently slow/unavailable, causing users to wait
    // 45-90s on "Generate Story". Flash produces comparable quality for a
    // conversation starter (title + opening line + 3 hints).
    final model = GeminiConfig.flash(
      temperature: 0.8,
      responseSchema: GeminiSchemas.story,
    );
    return _run(model, prompt);
  }

  /// Generate fresh level1/level2/level3 hints to help the learner reply to
  /// the agent's most recent message. Called on-demand from the Story chat
  /// "Hint" affordance. Flash is plenty for a short JSON payload.
  Future<String> generateStoryReplyHints({
    required String situation,
    required String agentName,
    required String agentMessage,
    required CefrLevel level,
  }) async {
    final prompt = buildStoryReplyHintsPrompt(
      situation: situation,
      agentName: agentName,
      agentMessage: agentMessage,
      level: level,
    );
    final model = GeminiConfig.flash(
      temperature: 0.5,
      responseSchema: GeminiSchemas.storyReplyHints,
    );
    return _run(model, prompt);
  }

  /// On-demand English → Vietnamese translation for a single chat message.
  /// Returns the translated text (without JSON wrapping). Used by the AI
  /// bubble's "Translate" pill in Story / Scenario chats.
  Future<String> translateToVietnamese(String englishText) async {
    final prompt = buildVietnameseTranslationPrompt(englishText);
    final model = GeminiConfig.flash(
      temperature: 0.2,
      responseSchema: GeminiSchemas.vietnameseTranslation,
    );
    final raw = await _run(model, prompt);
    final parsed = parseJsonObject(raw);
    final translated = parsed['translation'] as String?;
    if (translated == null || translated.trim().isEmpty) {
      throw StateError('Empty translation from Gemini');
    }
    return translated.trim();
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
    // Use Flash for per-turn assessments too: latency compounds across turns
    // and Flash is reliable enough for the INLINE assessment payload.
    final model = GeminiConfig.flash(
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
    // Use Flash instead of Pro for dictionary: Pro preview models have been
    // intermittently unavailable and dictionary enrichment must resolve
    // quickly so library items don't sit on "Loading explanation..." forever.
    final model = GeminiConfig.flash(
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

  /// Generates a flashcard-ready vocabulary batch for one onboarding topic
  /// (e.g. "Travel", "Business"). Returns already-enriched items so the
  /// library provider can skip its per-item dictionary enrichment call.
  ///
  /// [count] is capped to a small range so the round-trip stays snappy and
  /// the user gets back a bite-sized study set. Temperature is moderate so
  /// repeated taps on the same chip produce a somewhat different set rather
  /// than identical words every time.
  Future<TopicFlashcardBatch> generateTopicFlashcards({
    required String topicLabel,
    required CefrLevel level,
    int count = 8,
  }) async {
    final clampedCount = count.clamp(4, 12);
    final prompt = buildTopicFlashcardsPrompt(
      topic: topicLabel,
      cefrLevel: level.code,
      count: clampedCount,
    );
    final model = GeminiConfig.flash(
      temperature: 0.6,
      responseSchema: GeminiSchemas.topicFlashcards,
    );
    final raw = await _run(model, prompt);
    return TopicFlashcardBatch.fromJson(parseJsonObject(raw));
  }

  /// Side-by-side comparison for the Compare Words Pro screen. Low
  /// temperature so the nuance payload stays grounded across retries.
  Future<WordComparison> generateWordComparison({
    required String wordA,
    required String wordB,
  }) async {
    final prompt = buildWordComparisonPrompt(wordA: wordA, wordB: wordB);
    final model = GeminiConfig.flash(
      temperature: 0.3,
      responseSchema: GeminiSchemas.wordComparison,
    );
    final raw = await _run(model, prompt);
    return WordComparison.fromJson(parseJsonObject(raw));
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

  // ---------- Describe-a-Word (Reverse dictionary) ----------

  /// Reverse dictionary lookup: Vietnamese description → ranked English
  /// candidates. Temperature is kept low (0.3) so answers stay grounded while
  /// still offering a handful of near-matches for tip-of-the-tongue recovery.
  Future<ReverseDictionaryResult> reverseDictionary(
    String vietnameseDescription,
  ) async {
    final prompt = buildReverseDictionaryPrompt(vietnameseDescription);
    final model = GeminiConfig.flash(
      temperature: 0.3,
      responseSchema: GeminiSchemas.reverseDictionary,
    );
    final raw = await _run(model, prompt);
    return ReverseDictionaryResult.fromJson(parseJsonObject(raw));
  }

  // ---------- Image generation ----------

  /// Generates a minimalist illustration PNG for a vocabulary item and
  /// returns it as a data URI (`data:image/png;base64,...`). Returns null on
  /// failure so callers can surface the item without blocking the save flow.
  ///
  /// Uses the REST endpoint directly because google_generative_ai 0.4.7 does
  /// not expose [responseModalities] needed for image-output models.
  Future<String?> generateIllustration({
    required String word,
    String? context,
  }) async {
    if (!GeminiConfig.isApiKeyConfigured) return null;

    final prompt = _buildIllustrationPrompt(word: word, context: context);
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${ApiConstants.modelImage}:generateContent'
      '?key=${ApiConstants.geminiApiKey}',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['IMAGE', 'TEXT'],
      },
    });

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(body);

      final response = await request.close().timeout(
            const Duration(seconds: 45),
            onTimeout: () =>
                throw StateError('Illustration request timed out after 45s'),
          );

      if (response.statusCode != 200) {
        final err = await response.transform(utf8.decoder).join();
        debugPrint(
            'GeminiService: illustration HTTP ${response.statusCode}: $err');
        return null;
      }

      final raw = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final parts = (candidates.first as Map<String, dynamic>)['content']
          ?['parts'] as List<dynamic>?;
      if (parts == null) return null;

      for (final part in parts) {
        final inline =
            (part as Map<String, dynamic>)['inlineData'] ?? part['inline_data'];
        if (inline is Map<String, dynamic>) {
          final data = inline['data'] as String?;
          final mime = (inline['mimeType'] ?? inline['mime_type']) as String? ??
              'image/png';
          if (data != null && data.isNotEmpty) {
            return 'data:$mime;base64,$data';
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('GeminiService: illustration failed: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  String _buildIllustrationPrompt({required String word, String? context}) {
    final ctx = (context == null || context.trim().isEmpty)
        ? ''
        : '\nContext sentence: "$context"';
    return '''
Generate a single warm, friendly flat-illustration image that visually explains the English word or phrase: "$word".$ctx

Style requirements:
- Minimalist illustration, rounded shapes, claymorphism feel
- Soft cream background (#FFF8F0)
- Muted pastel palette — teal, coral, warm gold, purple accents
- No text, letters, words, or captions anywhere in the image
- Single focal subject, clearly conveys the meaning of the word
- Centered composition, square aspect ratio
- Do NOT include any logos or watermarks''';
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
      final response =
          await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw StateError('Gemini request timed out after 45s'),
      );
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
