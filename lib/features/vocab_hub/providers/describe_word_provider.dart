import 'package:flutter/foundation.dart';

import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';

/// Owns the "Describe-a-Word" reverse dictionary state: loading flag, last
/// error, and the ranked English candidates returned by Gemini. Always wraps
/// the LLM call with a 30s timeout — the Flash model occasionally stalls on
/// multilingual prompts and we must not leave the UI spinning forever.
class DescribeWordProvider extends ChangeNotifier {
  DescribeWordProvider({required GeminiService gemini}) : _gemini = gemini;

  final GeminiService _gemini;

  bool _loading = false;
  String? _error;
  ReverseDictionaryResult? _result;

  bool get loading => _loading;
  String? get error => _error;
  ReverseDictionaryResult? get result => _result;

  Future<void> lookup(String vietnameseDescription) async {
    final trimmed = vietnameseDescription.trim();
    if (trimmed.isEmpty) return;

    _loading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      final result = await _gemini
          .reverseDictionary(trimmed)
          .timeout(const Duration(seconds: 30));
      _result = result;
    } catch (_) {
      _error = 'Lookup failed. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _result = null;
    _error = null;
    notifyListeners();
  }
}
