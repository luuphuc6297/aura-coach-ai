import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Active models — bump versions here, not at call sites.
  static const modelFlash = 'gemini-3-flash-preview';
  static const modelImage = 'gemini-2.5-flash-image';
  static const modelTts = 'gemini-2.5-flash-preview-tts';

  // Declared but no callers yet. `GeminiConfig.pro()` factory in
  // config.dart references modelPro — kept here so that factory
  // compiles. Once we wire a Pro-tier feature (deep reasoning,
  // long-form analysis), the factory has somewhere to point.
  static const modelPro = 'gemini-3.1-pro-preview';
  // Future video gen — no caller, no factory yet.
  static const modelVeo = 'veo-3.1-fast-generate-preview';

  static const topP = 0.95;
  static const topK = 40;
  static const maxTokensFlash = 8192;
  static const maxTokensPro = 16384;
}
