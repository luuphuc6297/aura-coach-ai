import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/scenario/models/scenario.dart';
import '../../features/scenario/models/assessment.dart';

/// Persists the last successful Scenario Coach payloads so the UI can
/// gracefully degrade when the Gemini API is unavailable. Single source of
/// truth for the "cache + error" fallback strategy — no mock data, no
/// synthetic fake lessons.
class ScenarioCache {
  static const _kLessonKey = 'scenario_cache.last_lesson.v1';
  static const _kAssessmentKey = 'scenario_cache.last_assessment.v1';

  final Future<SharedPreferences> _prefs;

  ScenarioCache({SharedPreferences? prefs})
      : _prefs = prefs == null
            ? SharedPreferences.getInstance()
            : Future.value(prefs);

  Future<void> saveLastLesson(Scenario scenario) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_kLessonKey, jsonEncode(scenario.toJson()));
    } catch (e) {
      debugPrint('[ScenarioCache] saveLastLesson failed: $e');
    }
  }

  Future<Scenario?> getLastLesson() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kLessonKey);
      if (raw == null || raw.isEmpty) return null;
      return Scenario.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ScenarioCache] getLastLesson failed: $e');
      return null;
    }
  }

  Future<void> saveLastAssessment(AssessmentResult assessment) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_kAssessmentKey, jsonEncode(assessment.toJson()));
    } catch (e) {
      debugPrint('[ScenarioCache] saveLastAssessment failed: $e');
    }
  }

  Future<AssessmentResult?> getLastAssessment() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_kAssessmentKey);
      if (raw == null || raw.isEmpty) return null;
      return AssessmentResult.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ScenarioCache] getLastAssessment failed: $e');
      return null;
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_kLessonKey);
      await prefs.remove(_kAssessmentKey);
    } catch (e) {
      debugPrint('[ScenarioCache] clear failed: $e');
    }
  }
}
