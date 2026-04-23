import 'package:flutter/foundation.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/gemini/gemini_service.dart';
import '../models/saved_item.dart';

class LibraryProvider extends ChangeNotifier {
  final FirebaseDatasource _firebase;
  final GeminiService _gemini;
  String? _uid;

  List<SavedItem> _items = [];
  // Items added before uid was available — flushed on init.
  final List<SavedItem> _pendingSave = [];
  // Tracks vocabulary items currently generating an AI illustration so the
  // card can render a shimmer without firing duplicate requests.
  final Set<String> _generatingImageIds = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _filterType = 'all';
  String _filterPos = 'all';
  String _filterCategory = 'all';

  List<SavedItem> get items => _filteredItems;
  // Unfiltered view — needed by callers that check membership regardless of
  // the active filter state (e.g., "is this word already saved?").
  List<SavedItem> get allItems => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterPos => _filterPos;
  String get filterCategory => _filterCategory;
  int get totalCount => _items.length;
  int get dueCount => _items.where((i) => i.isDueForReview).length;

  List<String> get categories {
    final cats = _items
        .where((i) => i.category != null && i.category!.isNotEmpty)
        .map((i) => i.category!)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  int get categoryCount => categories.length;

  bool isGeneratingImage(String itemId) => _generatingImageIds.contains(itemId);

  LibraryProvider({
    required FirebaseDatasource firebase,
    required GeminiService gemini,
  })  : _firebase = firebase,
        _gemini = gemini;

  List<SavedItem> get _filteredItems {
    var result = _items;
    if (_filterType != 'all') {
      result = result.where((i) => i.type == _filterType).toList();
    }
    // POS filter only meaningful for vocabulary items.
    if (_filterPos != 'all' && _filterType == 'vocabulary') {
      result = result
          .where((i) =>
              i.partOfSpeech
                  ?.toLowerCase()
                  .contains(_filterPos.toLowerCase()) ??
              false)
          .toList();
    }
    if (_filterCategory != 'all') {
      result = result.where((i) => i.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((i) =>
              i.original.toLowerCase().contains(q) ||
              i.correction.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    if (_filterType == type) return;
    _filterType = type;
    // Reset downstream filters to avoid stale state hiding all items
    // when the user switches between top-level tabs.
    _filterPos = 'all';
    _filterCategory = 'all';
    notifyListeners();
  }

  void setFilterPos(String pos) {
    if (_filterPos == pos) return;
    _filterPos = pos;
    notifyListeners();
  }

  void setFilterCategory(String cat) {
    if (_filterCategory == cat) return;
    _filterCategory = cat;
    notifyListeners();
  }

  Future<void> init(String uid) async {
    if (uid.isEmpty) return;
    final isNewUid = _uid != uid;
    _uid = uid;

    if (_pendingSave.isNotEmpty) {
      final queued = List<SavedItem>.from(_pendingSave);
      _pendingSave.clear();
      for (final item in queued) {
        try {
          await _firebase.saveSavedItem(uid, item);
        } catch (e) {
          debugPrint(
              'LibraryProvider: failed to flush pending item ${item.id}: $e');
        }
      }
    }

    if (isNewUid) {
      await loadItems();
    }
  }

  Future<void> loadItems() async {
    if (_uid == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _firebase.getSavedItems(_uid!);
      _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      debugPrint(
          'LibraryProvider: loaded ${_items.length} items for uid $_uid');
      _backfillVocabularyEnrichment();
    } catch (e) {
      _error = 'Failed to load library: $e';
      debugPrint('LibraryProvider: loadItems failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fire-and-forget pass that fills in missing explanations for vocabulary
  /// items that pre-date the dictionary feature. Image generation is
  /// intentionally excluded — AI illustrations are opt-in and gated behind
  /// the paid tier, so we never auto-generate them on load.
  Future<void> _backfillVocabularyEnrichment() async {
    for (final item in List<SavedItem>.from(_items)) {
      if (item.type != 'vocabulary') continue;
      if (item.explanation == null) {
        await _enrichVocabularyItem(item);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Future<void> addItem(SavedItem item) async {
    if (_items.any((i) =>
        i.original == item.original && i.correction == item.correction)) {
      return;
    }
    _items.insert(0, item);
    notifyListeners();
    if (_uid != null) {
      try {
        await _firebase.saveSavedItem(_uid!, item);
      } catch (e) {
        debugPrint('LibraryProvider: saveSavedItem failed for ${item.id}: $e');
      }
    } else {
      _pendingSave.add(item);
      debugPrint('LibraryProvider: uid null, queued item ${item.id} for save');
    }
    if (item.type == 'vocabulary' && item.explanation == null) {
      _enrichVocabularyItem(item);
    }
    // Illustration generation is intentionally not triggered here — it's a
    // paid, opt-in action the user initiates from the item card.
  }

  /// Public entry point used by the library UI when a learner taps
  /// "Generate" on a vocabulary card. Caller is responsible for gating this
  /// behind the subscription paywall. No-ops if an illustration already exists
  /// or a generation is already in flight for this item.
  Future<void> generateIllustrationForItem(String itemId) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    final item = _items[idx];
    if (item.type != 'vocabulary') return;
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) return;
    if (_generatingImageIds.contains(itemId)) return;
    _generatingImageIds.add(itemId);
    notifyListeners();
    try {
      await _enrichVocabularyImage(item);
    } finally {
      _generatingImageIds.remove(itemId);
      notifyListeners();
    }
  }

  Future<void> _enrichVocabularyItem(SavedItem item) async {
    try {
      final dictData = await _gemini.generateDictionaryExplanation(
        phrase: item.correction,
        context: item.context,
      );
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx < 0) return;
      // Merge onto the *current* item in the list so concurrent image
      // enrichment isn't clobbered.
      final current = _items[idx];
      final enriched = current.copyWith(
        explanation: dictData.explanation,
        partOfSpeech: dictData.partOfSpeech,
        examples:
            dictData.examples.map((e) => {'en': e.en, 'vn': e.vn}).toList(),
      );
      _items[idx] = enriched;
      notifyListeners();
      if (_uid != null) {
        try {
          await _firebase.saveSavedItem(_uid!, enriched);
        } catch (e) {
          debugPrint('LibraryProvider: enrich save failed for ${item.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('LibraryProvider: enrichment failed for ${item.id}: $e');
    }
  }

  Future<void> _enrichVocabularyImage(SavedItem item) async {
    try {
      final imageDataUri = await _gemini.generateIllustration(
        word: item.correction,
        context: item.context,
      );
      if (imageDataUri == null || imageDataUri.isEmpty) return;
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx < 0) return;
      final current = _items[idx];
      final enriched = current.copyWith(imageUrl: imageDataUri);
      _items[idx] = enriched;
      notifyListeners();
      if (_uid != null) {
        try {
          await _firebase.saveSavedItem(_uid!, enriched);
        } catch (e) {
          debugPrint('LibraryProvider: image save failed for ${item.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('LibraryProvider: image enrichment failed for ${item.id}: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    _pendingSave.removeWhere((i) => i.id == itemId);
    notifyListeners();
    if (_uid != null) {
      try {
        await _firebase.deleteSavedItem(_uid!, itemId);
      } catch (e) {
        debugPrint('LibraryProvider: deleteSavedItem failed for $itemId: $e');
      }
    }
  }

  Future<void> updateItem(SavedItem item) async {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
      notifyListeners();
      if (_uid != null) {
        try {
          await _firebase.saveSavedItem(_uid!, item);
        } catch (e) {
          debugPrint(
              'LibraryProvider: updateItem save failed for ${item.id}: $e');
        }
      }
    }
  }
}
