import '../models/grammar_topic.dart';
import 'grammar_a1.dart';
import 'grammar_a2.dart';
import 'grammar_b1.dart';
import 'grammar_b2.dart';
import 'grammar_c1.dart';
import 'grammar_c2.dart';

/// Single source of truth for the Grammar Coach catalog. The list is
/// hand-curated against Cambridge English Grammar in Use + Oxford
/// Practice Grammar (see `docs/superpowers/plans/2026-04-29-grammar-mode.md`).
///
/// Phase A1 ships every topic with id/title/level/category/formula. The
/// rich content (summary, useCases, examples, commonMistakes, related)
/// lands in Phase A3.
abstract final class GrammarCatalog {
  /// Ordered list — A1 → C2, in the order curated within each level. UI
  /// surfaces should respect this ordering rather than re-sorting.
  static const List<GrammarTopic> all = [
    ...grammarA1,
    ...grammarA2,
    ...grammarB1,
    ...grammarB2,
    ...grammarC1,
    ...grammarC2,
  ];

  /// Lookup by stable slug. Throws [StateError] if the id is unknown —
  /// callers should validate routes before reaching here. Use
  /// [maybeById] for tolerant lookup.
  static GrammarTopic byId(String id) =>
      all.firstWhere((t) => t.id == id);

  /// Tolerant lookup — returns null when the id is missing. Useful when
  /// loading user progress docs that may reference a topic that was
  /// renamed or removed in a later catalog version.
  static GrammarTopic? maybeById(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// All topics at a given CEFR level, in catalog order.
  static List<GrammarTopic> byLevel(CefrLevel level) =>
      all.where((t) => t.level == level).toList(growable: false);

  /// All topics in a given coarse category, in catalog order.
  static List<GrammarTopic> byCategory(GrammarCategory category) =>
      all.where((t) => t.category == category).toList(growable: false);

  /// Filter by both level and category. Either filter can be null to
  /// mean "all". Used by the Grammar Hub when both filter rows are
  /// active.
  static List<GrammarTopic> filtered({
    CefrLevel? level,
    GrammarCategory? category,
  }) {
    if (level == null && category == null) return all;
    return all.where((t) {
      if (level != null && t.level != level) return false;
      if (category != null && t.category != category) return false;
      return true;
    }).toList(growable: false);
  }

  /// Total topic count — useful for Hub header subtitle ("55 topics
  /// across 6 levels"). Compile-time constant.
  static int get totalCount => all.length;
}
