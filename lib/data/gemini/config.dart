import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';

/// Factory for Gemini GenerativeModel instances. Each endpoint in
/// [GeminiService] creates its own model with the temperature and
/// responseSchema it needs; global defaults live here.
class GeminiConfig {
  GeminiConfig._();

  static bool get isApiKeyConfigured {
    final key = ApiConstants.geminiApiKey.trim();
    if (key.isEmpty) return false;
    if (key.startsWith('your-')) return false;
    return true;
  }

  /// Build a Flash model with the given temperature + responseSchema.
  ///
  /// Defaults to a JSON response for structured endpoints. Pass
  /// [responseMimeType] = `'text/plain'` (and omit [responseSchema]) for
  /// free-form chat surfaces like the AI Agent help bot.
  static GenerativeModel flash({
    required double temperature,
    Schema? responseSchema,
    int maxOutputTokens = ApiConstants.maxTokensFlash,
    String responseMimeType = 'application/json',
    String? systemInstruction,
  }) {
    return GenerativeModel(
      model: ApiConstants.modelFlash,
      apiKey: ApiConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: temperature,
        topP: ApiConstants.topP,
        topK: ApiConstants.topK,
        maxOutputTokens: maxOutputTokens,
        responseMimeType: responseMimeType,
        responseSchema: responseSchema,
      ),
      systemInstruction: systemInstruction == null
          ? null
          : Content.system(systemInstruction),
    );
  }

  /// Build a Pro model with the given temperature + responseSchema.
  static GenerativeModel pro({
    required double temperature,
    Schema? responseSchema,
    int maxOutputTokens = ApiConstants.maxTokensPro,
  }) {
    return GenerativeModel(
      model: ApiConstants.modelPro,
      apiKey: ApiConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: temperature,
        topP: ApiConstants.topP,
        topK: ApiConstants.topK,
        maxOutputTokens: maxOutputTokens,
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
      ),
    );
  }
}
