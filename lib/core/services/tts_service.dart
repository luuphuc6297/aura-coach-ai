import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _tts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _tts = FlutterTts();
    await _tts!.setSharedInstance(true);
    await _tts!.setSpeechRate(0.42);
    await _tts!.setVolume(1.0);
    await _tts!.setPitch(1.05);

    _tts!.setStartHandler(() => _isSpeaking = true);
    _tts!.setCompletionHandler(() => _isSpeaking = false);
    _tts!.setCancelHandler(() => _isSpeaking = false);
    _tts!.setErrorHandler((_) => _isSpeaking = false);

    _isInitialized = true;
  }

  Future<void> speak(String text, {String language = 'en-GB'}) async {
    try {
      await _ensureInitialized();
      if (_isSpeaking) {
        await _tts!.stop();
      }
      await _tts!.setLanguage(language);
      await _tts!.speak(text);
    } catch (e) {
      debugPrint('[TtsService] speak failed: $e');
      _isSpeaking = false;
    }
  }

  Future<void> speakVietnamese(String text) async {
    await speak(text, language: 'vi-VN');
  }

  Future<void> speakEnglish(String text) async {
    await speak(text, language: 'en-GB');
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
      _isSpeaking = false;
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();
    _isInitialized = false;
    _tts = null;
  }
}
