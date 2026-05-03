import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';

/// Owns the Compare Words Pro flow state: loading flag, last error, and the
/// Gemini payload. Always wraps the LLM call with a 30s timeout so the Pro
/// gate never sits on a spinner longer than the user is willing to wait.
class CompareWordsProvider extends ChangeNotifier {
  CompareWordsProvider({required GeminiService gemini}) : _gemini = gemini;

  final GeminiService _gemini;

  bool _loading = false;
  String? _error;
  WordComparison? _result;
  String _lastWordA = '';
  String _lastWordB = '';

  bool get loading => _loading;
  String? get error => _error;
  WordComparison? get result => _result;
  String get lastWordA => _lastWordA;
  String get lastWordB => _lastWordB;

  Future<void> compare({required String wordA, required String wordB}) async {
    final a = wordA.trim();
    final b = wordB.trim();
    if (a.isEmpty || b.isEmpty) {
      _error = 'Please enter both words to compare.';
      _result = null;
      notifyListeners();
      return;
    }
    if (a.toLowerCase() == b.toLowerCase()) {
      _error = 'Pick two different words to compare.';
      _result = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _result = null;
    _lastWordA = a;
    _lastWordB = b;
    notifyListeners();

    try {
      final result = await _gemini
          .generateWordComparison(wordA: a, wordB: b)
          .timeout(const Duration(seconds: 30));
      _result = result;
    } on TimeoutException {
      debugPrint('CompareWordsProvider.compare timed out');
      _error = 'The comparison is taking longer than usual. Please try again.';
    } catch (e, st) {
      debugPrint('CompareWordsProvider.compare failed: $e\n$st');
      _error = kDebugMode
          ? 'Comparison failed: $e'
          : 'Comparison failed. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _result = null;
    _error = null;
    _lastWordA = '';
    _lastWordB = '';
    notifyListeners();
  }
}
