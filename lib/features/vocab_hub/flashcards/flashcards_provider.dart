import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../data/gemini/gemini_service.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../../../features/my_library/models/saved_item.dart';
import '../../../features/my_library/providers/library_provider.dart';
import 'sm2.dart';

/// Queue mode for the flashcards player.
/// - [dueToday] draws from the SM-2 due queue and persists rating outcomes.
/// - [practice] draws a random batch from the library and skips persistence
///   (practice mode must not disturb the spaced-repetition schedule).
enum FlashcardQueueMode { dueToday, practice }

class FlashcardsProvider extends ChangeNotifier {
  final LibraryProvider _library;
  final GeminiService _gemini;

  FlashcardsProvider({
    required LibraryProvider library,
    required GeminiService gemini,
  })  : _library = library,
        _gemini = gemini;

  static const int maxDueCards = 20;
  static const int practiceBatchSize = 10;
  static const int topicSuggestionCount = 8;

  final List<SavedItem> _queue = [];
  int _index = 0;
  FlashcardQueueMode _mode = FlashcardQueueMode.dueToday;

  // Tracks which topic id (if any) is currently fetching AI-suggested cards.
  // UI uses this to render a per-chip spinner and disable re-taps.
  String? _suggestingTopicId;
  String? _suggestionError;

  List<SavedItem> get queue => List.unmodifiable(_queue);
  int get currentIndex => _index;
  SavedItem? get currentCard =>
      _index < _queue.length ? _queue[_index] : null;
  FlashcardQueueMode get mode => _mode;
  bool get hasMore => _index < _queue.length;
  String? get suggestingTopicId => _suggestingTopicId;
  String? get suggestionError => _suggestionError;
  bool get isSuggesting => _suggestingTopicId != null;

  int get dueCount => _library.allItems
      .where((item) => item.type == 'vocabulary' && item.isDueForReview)
      .length;

  /// Fills the queue with cards that are due for review, oldest first. Caller
  /// typically invokes this when the Flashcards tab is opened.
  void loadDueToday() {
    _mode = FlashcardQueueMode.dueToday;
    final due = _library.allItems
        .where((item) => item.type == 'vocabulary' && item.isDueForReview)
        .toList()
      ..sort((a, b) =>
          (a.nextReviewDate ?? 0).compareTo(b.nextReviewDate ?? 0));
    _queue
      ..clear()
      ..addAll(due.take(maxDueCards));
    _index = 0;
    notifyListeners();
  }

  /// Appends a random batch of vocabulary items to the queue for free-form
  /// practice. Excludes anything already queued so the user doesn't repeat
  /// cards within a session.
  void addPracticeBatch() {
    _mode = FlashcardQueueMode.practice;
    final queuedIds = _queue.map((c) => c.id).toSet();
    final pool = _library.allItems
        .where((item) =>
            item.type == 'vocabulary' && !queuedIds.contains(item.id))
        .toList()
      ..shuffle(Random());
    _queue.addAll(pool.take(practiceBatchSize));
    notifyListeners();
  }

  /// Generates AI-suggested flashcards for one of the user's onboarding
  /// topics, persists them to the library with all dictionary fields
  /// pre-filled (so [LibraryProvider] skips the enrichment round-trip), and
  /// appends the newly saved items to the active practice queue.
  ///
  /// Returns the number of new cards added (0 if everything was already in
  /// the library or if the call failed).
  Future<int> loadTopicSuggestions({
    required String topicId,
    required String topicLabel,
    required CefrLevel level,
    int count = topicSuggestionCount,
  }) async {
    if (_suggestingTopicId != null) return 0;
    _suggestingTopicId = topicId;
    _suggestionError = null;
    notifyListeners();

    try {
      final batch = await _gemini
          .generateTopicFlashcards(
            topicLabel: topicLabel,
            level: level,
            count: count,
          )
          .timeout(const Duration(seconds: 20));

      final existingWords = _library.allItems
          .where((i) => i.type == 'vocabulary')
          .map((i) => i.correction.toLowerCase().trim())
          .toSet();

      final addedItems = <SavedItem>[];
      final tomorrow = DateTime.now()
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch
          .toDouble();

      for (final item in batch.items) {
        final word = item.word.trim();
        if (word.isEmpty) continue;
        if (existingWords.contains(word.toLowerCase())) continue;
        existingWords.add(word.toLowerCase());

        final now = DateTime.now().millisecondsSinceEpoch;
        final saved = SavedItem(
          id: 'tf-$topicId-${word.toLowerCase()}-$now',
          original: word,
          correction: word,
          type: 'vocabulary',
          context: item.definition,
          timestamp: now,
          explanation: item.translation,
          partOfSpeech: item.partOfSpeech,
          pronunciation: item.phonetic,
          examples: [
            {'en': item.example.en, 'vn': item.example.vn},
          ],
          category: topicLabel,
          sourceTag: 'vocab-hub:topic:$topicId',
          nextReviewDate: tomorrow,
          interval: 1,
        );
        // Only enqueue cards that actually persisted. If addItem returns
        // false the word was a library duplicate and the UI would otherwise
        // see a phantom card that the user can't find in their library.
        final persisted = await _library.addItem(saved);
        if (persisted) addedItems.add(saved);
      }

      if (addedItems.isNotEmpty) {
        _mode = FlashcardQueueMode.practice;
        _queue.addAll(addedItems);
      }

      _suggestingTopicId = null;
      notifyListeners();
      return addedItems.length;
    } on TimeoutException {
      debugPrint('FlashcardsProvider.loadTopicSuggestions timed out');
      _suggestionError =
          'The request is taking longer than usual. Please try again.';
      _suggestingTopicId = null;
      notifyListeners();
      return 0;
    } catch (e, st) {
      debugPrint('FlashcardsProvider.loadTopicSuggestions failed: $e\n$st');
      _suggestionError = 'Could not generate cards. Please try again.';
      _suggestingTopicId = null;
      notifyListeners();
      return 0;
    }
  }

  void clearSuggestionError() {
    if (_suggestionError == null) return;
    _suggestionError = null;
    notifyListeners();
  }

  Future<void> rate(Sm2Rating rating) async {
    final card = currentCard;
    if (card == null) return;
    if (_mode == FlashcardQueueMode.dueToday) {
      final outcome = Sm2.next(
        rating: rating,
        interval: card.interval,
        easeFactor: card.easeFactor,
        reviewCount: card.reviewCount,
      );
      final updated = card.copyWith(
        interval: outcome.interval,
        easeFactor: outcome.easeFactor,
        reviewCount: outcome.reviewCount,
        nextReviewDate: outcome.nextReviewDate,
      );
      await _library.updateItem(updated);
    }
    _index++;
    notifyListeners();
  }

  void reset() {
    _queue.clear();
    _index = 0;
    _mode = FlashcardQueueMode.dueToday;
    notifyListeners();
  }
}
