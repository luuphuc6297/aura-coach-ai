import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const modelFlash = 'gemini-3-flash-preview';
  static const modelPro = 'gemini-3.1-pro-preview';
  static const modelTts = 'gemini-2.5-flash-preview-tts';
  static const modelVeo = 'veo-3.1-fast-generate-preview';
  static const modelImage = 'gemini-2.5-flash-image';

  static const topP = 0.95;
  static const topK = 40;
  static const maxTokensFlash = 2048;
  static const maxTokensPro = 4096;
}
