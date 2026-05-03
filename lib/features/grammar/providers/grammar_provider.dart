import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/grammar_catalog.dart';
import '../data/grammar_datasource.dart';
import '../models/grammar_exercise.dart';
import '../models/grammar_progress.dart';
import '../models/grammar_session.dart';
import '../models/grammar_topic.dart';
import '../services/grammar_gemini_service.dart';

/// Coordinator for Grammar Coach. Owns:
///
/// - Hub filter state (level + category + search)
/// - Per-topic progress cache (hydrated from Firestore on Hub mount)
/// - Active session lifecycle: start → loop(generate, submit, evaluate,
///   record) → end → summary stats
/// - Recent prompt fingerprints + recent mistake types (passed to the
///   Gemini service so AI varies the exercise pipeline)
///
/// Stays Flutter-agnostic — no `BuildContext`, no `material.dart` import.
/// UI screens listen via `Provider.of<GrammarProvider>(context)` and
/// dispatch user actions through the public methods on this class.
class GrammarProvider extends ChangeNotifier {
  final GrammarGeminiService _gemini;
  final GrammarDataSource _ds;
  final Uuid _uuid;

  GrammarProvider({
    required GrammarGeminiService gemini,
    required GrammarDataSource dataSource,
    Uuid? uuid,
  })  : _gemini = gemini,
        _ds = dataSource,
        _uuid = uuid ?? const Uuid();

  // ── identity / config ──────────────────────────────────────────────

  String? _uid;
  CefrLevel _userLevel = CefrLevel.b1;

  /// Wire up before any session method runs. Called from screen mount
  /// once we have an auth uid + the user's profile-level. Idempotent —
  /// safe to call on every build.
  void configure({required String uid, required CefrLevel userLevel}) {
    if (_uid == uid && _userLevel == userLevel) return;
    _uid = uid;
    _userLevel = userLevel;
    // Don't auto-hydrate — Hub screen calls hydrateProgress() once it
    // mounts, so we don't waste a Firestore read on screens that don't
    // need progress data (e.g. opening Topic Detail directly via
    // deep-link before Hub).
  }

  CefrLevel get userLevel => _userLevel;

  // ── hub filter state ───────────────────────────────────────────────

  CefrLevel? _filterLevel;
  GrammarCategory? _filterCategory;
  String _searchQuery = '';

  CefrLevel? get filterLevel => _filterLevel;
  GrammarCategory? get filterCategory => _filterCategory;
  String get searchQuery => _searchQuery;

  /// Default the level filter to "All" so users discover the full
  /// catalog. Previously defaulted to the user's CEFR level which hid
  /// most topics behind a chip switch — bad for first-impression
  /// browsing. After the first build, user changes stick.
  bool _hasInitialFilter = false;
  void initFilterIfNeeded() {
    if (_hasInitialFilter) return;
    _hasInitialFilter = true;
    _filterLevel = null;
  }

  /// Pass `null` to clear ("All" chip).
  void setFilterLevel(CefrLevel? level) {
    if (_filterLevel == level) return;
    _filterLevel = level;
    notifyListeners();
  }

  void setFilterCategory(GrammarCategory? category) {
    if (_filterCategory == category) return;
    _filterCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    final next = query.trim();
    if (_searchQuery == next) return;
    _searchQuery = next;
    notifyListeners();
  }

  /// Topics filtered by current level + category + search. Search
  /// matches against `title`, `titleVi`, and `formula` case-insensitive.
  /// Catalog ordering preserved — we don't sort.
  List<GrammarTopic> get filteredTopics {
    final base = GrammarCatalog.filtered(
      level: _filterLevel,
      category: _filterCategory,
    );
    if (_searchQuery.isEmpty) return base;
    final q = _searchQuery.toLowerCase();
    return base.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.titleVi.toLowerCase().contains(q) ||
          t.formula.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  // ── progress cache ─────────────────────────────────────────────────

  final Map<String, UserGrammarProgress> _progressByTopic = {};
  bool _progressHydrated = false;
  bool _hydratingProgress = false;

  bool get progressHydrated => _progressHydrated;
  bool get hydratingProgress => _hydratingProgress;

  /// Bulk-load every progress doc. Idempotent — safe to call from Hub
  /// mount.
  Future<void> hydrateProgress() async {
    final uid = _uid;
    if (uid == null || _progressHydrated || _hydratingProgress) return;
    _hydratingProgress = true;
    notifyListeners();
    try {
      final docs = await _ds.loadAllProgress(uid);
      _progressByTopic
        ..clear()
        ..addEntries(docs.map((p) => MapEntry(p.topicId, p)));
      _progressHydrated = true;
    } catch (_) {
      // Hub still renders — progress just shows as Not Started until
      // the user retries. Don't surface to UI; the empty/zero state is
      // valid product behavior on a cold start with no network.
    } finally {
      _hydratingProgress = false;
      notifyListeners();
    }
  }

  /// Returns the cached progress, or an empty `UserGrammarProgress` for
  /// topics the user has never touched. Always non-null so UI doesn't
  /// have to null-check.
  UserGrammarProgress progressFor(String topicId) =>
      _progressByTopic[topicId] ?? UserGrammarProgress.empty(topicId);

  /// How many topics show as Mastered. Used in the Hub header subtitle
  /// "B1 · 14/55 mastered".
  int get masteredCount => _progressByTopic.values
      .where((p) => p.masteryLabel == GrammarMasteryLabel.mastered)
      .length;

  // ── active session ─────────────────────────────────────────────────

  GrammarSession? _activeSession;
  GrammarTopic? _activeTopic;
  GrammarExercise? _currentExercise;
  GrammarPracticeAttempt? _lastAttempt;
  GrammarEvaluation? _lastEvaluation;

  bool _generatingExercise = false;
  bool _evaluating = false;
  String? _generationError;

  /// AI grounding — last 5 prompts + last 5 error types within this
  /// session. Reset when a new session starts.
  final List<String> _recentPromptFingerprints = [];
  final List<GrammarErrorType> _recentMistakeTypes = [];

  /// All attempts within the current session, in chronological order.
  /// Used by the summary screen to render recent mistakes. Cleared on
  /// startSession / clearSession.
  final List<GrammarPracticeAttempt> _sessionAttempts = [];

  List<GrammarPracticeAttempt> get sessionAttempts =>
      List.unmodifiable(_sessionAttempts);

  /// Convenience: only the wrong answers from this session.
  List<GrammarPracticeAttempt> get sessionMistakes =>
      _sessionAttempts.where((a) => !a.isCorrect).toList(growable: false);

  /// Toggles per-question direction for translate mode within a
  /// session. Starts EN→VI, alternates.
  bool _nextTranslateIsEnToVi = true;

  /// Captured at startSession() so endSession() can report the exact
  /// delta — `currentMastery − sessionStartMastery`. Otherwise we'd
  /// have to reconstruct it from per-attempt EWMA which is lossy.
  double _sessionStartMastery = 0.0;

  GrammarSession? get activeSession => _activeSession;
  GrammarTopic? get activeTopic => _activeTopic;
  GrammarExercise? get currentExercise => _currentExercise;
  GrammarPracticeAttempt? get lastAttempt => _lastAttempt;
  GrammarEvaluation? get lastEvaluation => _lastEvaluation;
  bool get generatingExercise => _generatingExercise;
  bool get evaluating => _evaluating;
  String? get generationError => _generationError;

  /// True between submit + nextExercise — the result card is on screen
  /// and the user must tap Next to continue. UI uses this to gate the
  /// answer input.
  bool get isShowingResult => _lastAttempt != null;

  /// Fire on tap of "Start practice" CTA. Creates a fresh session and
  /// kicks off the first exercise generation.
  Future<void> startSession({
    required String topicId,
    required GrammarPracticeMode mode,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final topic = GrammarCatalog.maybeById(topicId);
    if (topic == null) return;

    final session = GrammarSession.start(
      id: _uuid.v4(),
      topicId: topicId,
      mode: mode,
    );
    _activeSession = session;
    _activeTopic = topic;
    _currentExercise = null;
    _lastAttempt = null;
    _lastEvaluation = null;
    _recentPromptFingerprints.clear();
    _recentMistakeTypes.clear();
    _sessionAttempts.clear();
    _nextTranslateIsEnToVi = true;
    _generationError = null;
    _sessionStartMastery = progressFor(topicId).masteryScore;
    notifyListeners();

    // Persist the open session so analytics / recovery flows can find
    // it even if the app is force-quit before endSession() runs.
    unawaited(_ds.saveSession(uid, session));

    // Pre-seed mistake types from history so AI grounding has signal
    // even on the very first exercise of a returning user.
    try {
      final priorMistakes =
          await _ds.recentMistakeTypes(uid, topicId, limit: 5);
      _recentMistakeTypes.addAll(priorMistakes);
    } catch (_) {/* non-fatal */}

    await nextExercise();
  }

  /// Generates the next AI exercise. Called automatically after
  /// startSession() and after submitAnswer() → "Next" tap.
  Future<void> nextExercise() async {
    final session = _activeSession;
    final topic = _activeTopic;
    if (session == null || topic == null) return;

    _currentExercise = null;
    _lastAttempt = null;
    _lastEvaluation = null;
    _generationError = null;
    _generatingExercise = true;
    notifyListeners();

    GrammarExerciseDirection? direction;
    if (session.mode == GrammarPracticeMode.translate) {
      direction = _nextTranslateIsEnToVi
          ? GrammarExerciseDirection.enToVi
          : GrammarExerciseDirection.viToEn;
      _nextTranslateIsEnToVi = !_nextTranslateIsEnToVi;
    }

    try {
      final exercise = await _gemini.generateExercise(
        topic: topic,
        mode: session.mode,
        userLevel: _userLevel,
        recentPromptFingerprints: List.unmodifiable(_recentPromptFingerprints),
        recentMistakeTypes: List.unmodifiable(_recentMistakeTypes),
        direction: direction,
      );
      _currentExercise = exercise;
      _recordRecentPrompt(exercise.prompt);
    } catch (e) {
      _generationError = e.toString();
    } finally {
      _generatingExercise = false;
      notifyListeners();
    }
  }

  /// Submit the user's answer for the current exercise. Persists the
  /// attempt + bumps progress. UI then shows the result card until the
  /// user taps Next (which calls [nextExercise]).
  Future<void> submitAnswer(String userAnswer) async {
    final uid = _uid;
    final session = _activeSession;
    final topic = _activeTopic;
    final exercise = _currentExercise;
    if (uid == null ||
        session == null ||
        topic == null ||
        exercise == null ||
        _evaluating) {
      return;
    }

    final trimmed = userAnswer.trim();
    if (trimmed.isEmpty) return;

    _evaluating = true;
    notifyListeners();

    GrammarEvaluation evaluation;
    try {
      evaluation = await _resolveEvaluation(exercise, trimmed, topic);
    } catch (e) {
      _evaluating = false;
      // Surface the failure so the UI can show a retry CTA without
      // leaving the user stuck. We don't record an attempt for a failed
      // evaluation — only successful submits advance the session.
      _generationError = e.toString();
      notifyListeners();
      return;
    }

    final attempt = GrammarPracticeAttempt(
      id: _uuid.v4(),
      topicId: topic.id,
      sessionId: session.id,
      exerciseId: exercise.id,
      mode: session.mode,
      prompt: exercise.prompt,
      userAnswer: trimmed,
      correctAnswer: exercise.correctAnswer,
      isCorrect: evaluation.isCorrect,
      score: evaluation.score,
      feedback: evaluation.feedback,
      errorType: evaluation.errorType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Update in-memory state first so UI re-renders immediately. Persist
    // in the background — we don't gate UX on Firestore latency.
    _lastEvaluation = evaluation;
    _lastAttempt = attempt;
    _sessionAttempts.add(attempt);
    _activeSession = session.copyWith(
      attemptCount: session.attemptCount + 1,
      correctCount: session.correctCount + (evaluation.isCorrect ? 1 : 0),
    );
    if (!evaluation.isCorrect) {
      _recordRecentMistake(evaluation.errorType);
    }
    final updatedProgress = _bumpProgress(topic.id, evaluation);
    _progressByTopic[topic.id] = updatedProgress;
    _evaluating = false;
    notifyListeners();

    // Persist (non-blocking).
    unawaited(_ds.saveAttempt(uid, attempt));
    unawaited(_ds.saveProgress(uid, updatedProgress));
  }

  /// Wraps the session up. Persists the closed session with totals +
  /// mastery delta. Caller routes to the summary screen, which reads
  /// from `activeSession` — so we keep `_activeSession` populated until
  /// the next `startSession()` clears it.
  Future<void> endSession() async {
    final uid = _uid;
    final session = _activeSession;
    final topic = _activeTopic;
    if (uid == null || session == null || topic == null) return;
    if (session.isClosed) return;

    final progress = progressFor(topic.id);
    // Exact delta from the snapshot taken at startSession(). Negative
    // values are possible (a bad session can erode mastery) and that's
    // fine — the summary screen renders the sign.
    final masteryDelta = progress.masteryScore - _sessionStartMastery;

    _activeSession = session.copyWith(
      endedAt: DateTime.now().millisecondsSinceEpoch,
      masteryDelta: masteryDelta,
    );
    notifyListeners();

    unawaited(_ds.saveSession(uid, _activeSession!));
  }

  /// Reset session state when leaving the summary screen. Caller
  /// invokes this from "Browse other topics" / back-to-hub navigation.
  void clearSession() {
    _activeSession = null;
    _activeTopic = null;
    _currentExercise = null;
    _lastAttempt = null;
    _lastEvaluation = null;
    _recentPromptFingerprints.clear();
    _recentMistakeTypes.clear();
    _sessionAttempts.clear();
    _generationError = null;
    notifyListeners();
  }

  /// Clears any pending generation/evaluation error banner.
  void clearError() {
    if (_generationError == null) return;
    _generationError = null;
    notifyListeners();
  }

  // ── helpers ────────────────────────────────────────────────────────

  /// Multiple-choice + exact-match cases short-circuit AI evaluation.
  /// Free-text falls through to [GrammarGeminiService.evaluateAnswer].
  Future<GrammarEvaluation> _resolveEvaluation(
    GrammarExercise exercise,
    String userAnswer,
    GrammarTopic topic,
  ) async {
    if (exercise.isMultipleChoice) {
      final picked = userAnswer;
      if (_normalize(picked) == _normalize(exercise.correctAnswer)) {
        return GrammarEvaluation.exact(matchedAnswer: exercise.correctAnswer);
      }
      return GrammarEvaluation.wrongMultipleChoice(
        correctAnswer: exercise.correctAnswer,
      );
    }

    // Exact-match short-circuit on canonical or alternate answers.
    final norm = _normalize(userAnswer);
    if (_normalize(exercise.correctAnswer) == norm) {
      return GrammarEvaluation.exact(matchedAnswer: exercise.correctAnswer);
    }
    for (final alt in exercise.alternateCorrectAnswers) {
      if (_normalize(alt) == norm) {
        return GrammarEvaluation.exact(matchedAnswer: alt);
      }
    }

    // Fall through to AI for nuanced grading (translate, transform,
    // longer fill-blank).
    return _gemini.evaluateAnswer(
      exercise: exercise,
      userAnswer: userAnswer,
      topic: topic,
    );
  }

  /// EWMA-style mastery update + counter bumps. Phase G will replace
  /// this with proper SM-2 wiring (easeFactor / interval / nextReviewAt
  /// computed from a `Sm2Rating` derived from `evaluation.score`). For
  /// now we keep mastery + counters honest so the Hub ring + status
  /// pill behave correctly.
  UserGrammarProgress _bumpProgress(
    String topicId,
    GrammarEvaluation evaluation,
  ) {
    final prior = progressFor(topicId);
    const alpha = 0.3; // EWMA weight on the new attempt's score
    final newMastery =
        (prior.masteryScore * (1 - alpha) + evaluation.score * alpha)
            .clamp(0.0, 1.0);
    return prior.copyWith(
      attemptCount: prior.attemptCount + 1,
      correctCount: prior.correctCount + (evaluation.isCorrect ? 1 : 0),
      masteryScore: newMastery,
      lastPracticedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Cap the recent-prompt list at 5 entries. Most recent first.
  void _recordRecentPrompt(String prompt) {
    final fp = _fingerprint(prompt);
    _recentPromptFingerprints.remove(fp);
    _recentPromptFingerprints.insert(0, fp);
    if (_recentPromptFingerprints.length > 5) {
      _recentPromptFingerprints.removeLast();
    }
  }

  void _recordRecentMistake(GrammarErrorType type) {
    _recentMistakeTypes.insert(0, type);
    if (_recentMistakeTypes.length > 5) {
      _recentMistakeTypes.removeLast();
    }
  }

  /// Lowercase + collapse whitespace + strip outer punctuation. Good
  /// enough for prompt-dedup + exact-answer matching across casing,
  /// extra spaces, and trailing periods.
  String _normalize(String s) {
    final lower = s.trim().toLowerCase();
    final collapsed = lower.replaceAll(RegExp(r'\s+'), ' ');
    return collapsed.replaceAll(RegExp(r'^[\p{P}\s]+|[\p{P}\s]+$', unicode: true), '');
  }

  /// First 60 chars of the normalized prompt — coarse enough that
  /// near-duplicate prompts collide, fine enough that distinct prompts
  /// don't.
  String _fingerprint(String prompt) {
    final n = _normalize(prompt);
    return n.length <= 60 ? n : n.substring(0, 60);
  }
}

