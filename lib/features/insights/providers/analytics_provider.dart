import 'package:flutter/foundation.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../my_library/models/saved_item.dart';
import '../../my_library/providers/library_provider.dart';

/// Period window used by the Insights tab period picker. `all` disables the
/// time filter (useful when a learner has <7 days of data).
enum AnalyticsPeriod { today, week, month, all }

extension AnalyticsPeriodExt on AnalyticsPeriod {
  String get label {
    switch (this) {
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.all:
        return 'All';
    }
  }

  /// Inclusive window start. Null means "no lower bound" (all-time).
  DateTime? startFrom(DateTime now) {
    switch (this) {
      case AnalyticsPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.month:
        return now.subtract(const Duration(days: 30));
      case AnalyticsPeriod.all:
        return null;
    }
  }
}

/// Derives user-facing analytics (streak, skill averages, weak words, practice
/// heatmap) from existing Firestore documents. Intentionally does NOT create
/// new collections — every metric is computed from:
///   • `users/{uid}/conversations/*` turns (assessment scores, duration)
///   • `users/{uid}/savedItems/*` via [LibraryProvider] (masteryScore, isDue)
///
/// This keeps the Insights tab incrementally shippable: once more modes start
/// writing conversations, their data flows through here without a migration.
class AnalyticsProvider extends ChangeNotifier {
  final FirebaseDatasource _firebase;
  final LibraryProvider _library;

  String? _uid;
  List<Map<String, dynamic>> _conversations = const [];
  AnalyticsPeriod _period = AnalyticsPeriod.week;
  bool _isLoading = false;
  String? _error;

  AnalyticsProvider({
    required FirebaseDatasource firebase,
    required LibraryProvider library,
  })  : _firebase = firebase,
        _library = library {
    _library.addListener(_onLibraryChanged);
  }

  @override
  void dispose() {
    _library.removeListener(_onLibraryChanged);
    super.dispose();
  }

  // --- Public state ---

  AnalyticsPeriod get period => _period;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAnyData => _conversations.isNotEmpty || _library.totalCount > 0;

  void setPeriod(AnalyticsPeriod value) {
    if (_period == value) return;
    _period = value;
    notifyListeners();
  }

  /// Bind provider to a user. Fetches conversations on the first successful
  /// call per uid; subsequent identical calls are no-ops to avoid hammering
  /// Firestore during tab switches.
  Future<void> init(String uid) async {
    if (uid.isEmpty) return;
    final isNewUid = _uid != uid;
    _uid = uid;
    if (isNewUid) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (_uid == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _firebase.getConversations(_uid!);
    } catch (e) {
      _error = 'Failed to load insights: $e';
      debugPrint('AnalyticsProvider: refresh failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Hero stats ---

  /// Consecutive practice days ending at today or yesterday. Returns 0 if the
  /// learner hasn't practiced in the last 48h (so the streak visibly resets
  /// once missed, matching Duolingo-style expectations).
  int get currentStreak {
    final days = _daysWithSessions(_conversations);
    if (days.isEmpty) return 0;
    final today = _dayOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? cursor;
    if (days.contains(today)) {
      cursor = today;
    } else if (days.contains(yesterday)) {
      cursor = yesterday;
    }
    if (cursor == null) return 0;

    int streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor!.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    final days = _daysWithSessions(_conversations).toList()..sort();
    if (days.isEmpty) return 0;
    int best = 1;
    int current = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return best;
  }

  int get sessionsInPeriod => _convosInPeriod.length;

  /// Total practice time (minutes) inside the selected period. Uses persisted
  /// `duration` when available (set by `ScenarioProvider.endSession`), and
  /// falls back to 1-minute-per-user-turn for in-progress sessions so numbers
  /// never read as zero while a learner is mid-flow.
  int get practiceMinutesInPeriod {
    int total = 0;
    for (final c in _convosInPeriod) {
      final duration = _intOrNull(c['duration']);
      if (duration != null && duration > 0) {
        total += duration;
        continue;
      }
      final userTurns = _countUserTurns(c);
      total += userTurns;
    }
    return total;
  }

  // --- Skill averages (0..100 for UI rendering) ---

  /// Keys: fluency, accuracy, naturalness, complexity. Values 0..100. Derived
  /// only from assessment turns inside the current period — falls back to 0s
  /// when nothing has been assessed yet so UI doesn't need null-guards.
  Map<String, double> get skillAverages {
    int scoreSum = 0;
    int accSum = 0;
    int natSum = 0;
    int cxSum = 0;
    int count = 0;

    for (final c in _convosInPeriod) {
      final turns = c['turns'];
      if (turns is! List) continue;
      for (final t in turns) {
        if (t is! Map) continue;
        if (t['type'] != 'assessment') continue;
        final assessment = t['assessment'];
        if (assessment is! Map) continue;
        scoreSum += _intOrZero(assessment['score']);
        accSum += _intOrZero(assessment['accuracyScore']);
        natSum += _intOrZero(assessment['naturalnessScore']);
        cxSum += _intOrZero(assessment['complexityScore']);
        count++;
      }
    }

    if (count == 0) {
      return const {
        'fluency': 0,
        'accuracy': 0,
        'naturalness': 0,
        'complexity': 0,
      };
    }

    // Assessment scores are 0..10 in the AI contract; scale to 0..100 for the
    // progress-bar UI.
    return {
      'fluency': (scoreSum / count) * 10,
      'accuracy': (accSum / count) * 10,
      'naturalness': (natSum / count) * 10,
      'complexity': (cxSum / count) * 10,
    };
  }

  /// Overall fluency score 0..100 — used by the Profile preview ring.
  double get fluencyScore => skillAverages['fluency'] ?? 0;

  // --- Heatmap ---

  /// 13 × 7 grid of daily session counts. Outer list = weeks, inner list =
  /// days (Monday=0 .. Sunday=6). Rightmost column is the current week so the
  /// newest activity reads right-to-left like a GitHub contribution graph.
  List<List<int>> get heatmap {
    const weeks = 13;
    final today = _dayOnly(DateTime.now());
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final start =
        mondayOfThisWeek.subtract(const Duration(days: (weeks - 1) * 7));

    final dayCounts = <DateTime, int>{};
    for (final c in _conversations) {
      final created = _readDate(c['createdAt']);
      if (created == null) continue;
      final day = _dayOnly(created);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    return List.generate(weeks, (w) {
      return List.generate(7, (d) {
        final date = start.add(Duration(days: w * 7 + d));
        if (date.isAfter(today)) return 0;
        return dayCounts[date] ?? 0;
      });
    });
  }

  /// Inclusive start date of the heatmap window. Useful for labeling the
  /// left-most column in the UI.
  DateTime get heatmapStart {
    const weeks = 13;
    final today = _dayOnly(DateTime.now());
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    return mondayOfThisWeek.subtract(const Duration(days: (weeks - 1) * 7));
  }

  // --- Weak words ---

  /// Top N savedItems sorted by lowest masteryScore, then by due-for-review.
  /// These are the words the learner is most at risk of forgetting.
  List<SavedItem> weakWords({int limit = 5}) {
    final items = List<SavedItem>.from(_library.allItems);
    items.sort((a, b) {
      final primary = a.masteryScore.compareTo(b.masteryScore);
      if (primary != 0) return primary;
      final aDue = a.isDueForReview ? 0 : 1;
      final bDue = b.isDueForReview ? 0 : 1;
      if (aDue != bDue) return aDue.compareTo(bDue);
      return b.timestamp.compareTo(a.timestamp);
    });
    if (limit <= 0 || items.length <= limit) return items;
    return items.sublist(0, limit);
  }

  /// Single most at-risk word — rendered in the Profile preview card.
  SavedItem? get topWeakWord {
    final list = weakWords(limit: 1);
    return list.isEmpty ? null : list.first;
  }

  // --- Internals ---

  void _onLibraryChanged() {
    // Weak words + `hasAnyData` depend on LibraryProvider state, so propagate
    // so dependent widgets (Profile preview, Insights weak-words card) rebuild.
    notifyListeners();
  }

  List<Map<String, dynamic>> get _convosInPeriod {
    final start = _period.startFrom(DateTime.now());
    if (start == null) return _conversations;
    return _conversations.where((c) {
      final created = _readDate(c['createdAt']);
      return created != null && !created.isBefore(start);
    }).toList();
  }

  Set<DateTime> _daysWithSessions(List<Map<String, dynamic>> convos) {
    final days = <DateTime>{};
    for (final c in convos) {
      final created = _readDate(c['createdAt']);
      if (created == null) continue;
      days.add(_dayOnly(created));
    }
    return days;
  }

  int _countUserTurns(Map<String, dynamic> conversation) {
    final turns = conversation['turns'];
    if (turns is! List) return 0;
    int count = 0;
    for (final t in turns) {
      if (t is Map && t['type'] == 'user') count++;
    }
    return count;
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _readDate(dynamic raw) {
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  int _intOrZero(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  int? _intOrNull(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }
}
