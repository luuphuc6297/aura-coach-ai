import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Retry a Gemini call on transient errors (429 quota, 503 unavailable,
/// RESOURCE_EXHAUSTED). Matches web `retryOperation` behaviour: 1 retry by
/// default, exponential backoff starting at 1000ms. Non-transient errors
/// rethrow immediately.
Future<T> retryOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 1,
  Duration initialDelay = const Duration(milliseconds: 1000),
}) async {
  Object? lastError;
  var delay = initialDelay;

  for (var attempt = 0; attempt < maxRetries + 1; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;
      if (!_isTransient(error) || attempt == maxRetries) {
        rethrow;
      }
      if (kDebugMode) {
        debugPrint(
          '[Gemini] Transient error hit. Retry ${attempt + 1}/$maxRetries in ${delay.inMilliseconds}ms: $error',
        );
      }
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  throw lastError ?? StateError('retryOperation: unreachable');
}

bool _isTransient(Object error) {
  final msg = error.toString();
  return msg.contains('429') ||
      msg.contains('503') ||
      msg.contains('RESOURCE_EXHAUSTED') ||
      msg.contains('UNAVAILABLE') ||
      msg.contains('quota');
}

/// Parse a JSON object response from Gemini. Handles optional markdown fences
/// that some models still emit even with responseMimeType=application/json.
/// Throws [FormatException] on malformed input so callers can differentiate
/// "AI failed" from "AI returned garbage".
Map<String, dynamic> parseJsonObject(String text) {
  final cleaned = _stripFences(text);
  final decoded = jsonDecode(cleaned);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Expected JSON object, got ${decoded.runtimeType}');
  }
  return decoded;
}

/// Parse a JSON array response (used by mindmap expansion, exercises).
List<dynamic> parseJsonArray(String text) {
  final cleaned = _stripFences(text);
  final decoded = jsonDecode(cleaned);
  if (decoded is! List) {
    throw FormatException('Expected JSON array, got ${decoded.runtimeType}');
  }
  return decoded;
}

String _stripFences(String text) {
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
