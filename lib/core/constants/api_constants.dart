import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const modelFlash = 'gemini-2.0-flash';
  static const modelPro = 'gemini-2.0-pro';

  static const temperature = 0.7;
  static const topP = 0.95;
  static const topK = 40;
  static const maxTokensFlash = 2048;
  static const maxTokensPro = 4096;
}
