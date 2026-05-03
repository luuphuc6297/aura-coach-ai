/// Grammar Coach domain model.
///
/// `GrammarTopic` is the canonical, hand-curated unit of content. The full
/// catalog is registered in `lib/features/grammar/data/grammar_catalog.dart`
/// (split per CEFR level for readability).
///
/// Phase A1 ships every topic with id, title, level, category, and formula —
/// enough to drive the Hub UI and route resolution. Heavy fields (`summary`,
/// `useCases`, `examples`, `commonMistakes`, `relatedTopicIds`) default to
/// empty / const [] and are populated in Phase A3.
library;

/// CEFR proficiency level. Used both as a topic property and as the user's
/// level filter on the Grammar Hub.
///
/// Distinct from the existing `CefrLevel` enum in
/// `lib/data/prompts/prompt_constants.dart` (which is geared toward AI
/// prompt grounding and uses different value semantics). The two never
/// share an import scope.
enum CefrLevel { a1, a2, b1, b2, c1, c2 }

extension CefrLevelLabel on CefrLevel {
  /// Display label, e.g. "A1", "B2", "C1".
  String get label => name.toUpperCase();

  /// Map the user-profile proficiency id (`'beginner' | 'intermediate' |
  /// 'advanced'`, plus tolerant CEFR-string fallbacks) onto the catalog's
  /// CEFR enum. Defaults to B1 for unknown ids — beginner B1 is the
  /// centre of the 6-band ladder, safer than over-promoting.
  static CefrLevel fromProficiencyId(String id) {
    switch (id.trim().toLowerCase()) {
      case 'beginner':
      case 'a1':
        return CefrLevel.a1;
      case 'a2':
      case 'elementary':
        return CefrLevel.a2;
      case 'intermediate':
      case 'b1':
        return CefrLevel.b1;
      case 'b2':
      case 'upper-intermediate':
      case 'upper_intermediate':
        return CefrLevel.b2;
      case 'advanced':
      case 'c1':
        return CefrLevel.c1;
      case 'c2':
      case 'proficient':
        return CefrLevel.c2;
      default:
        return CefrLevel.b1;
    }
  }
}

/// Coarse category bucket for filter chips. The taxonomy is intentionally
/// short — finer slicing (e.g. "perfect tenses") would fragment the filter
/// row. Topics that don't fit elsewhere fall into [other].
enum GrammarCategory {
  tense,
  modal,
  conditional,
  passive,
  reported,
  articleQuantifier,
  clause,
  comparison,
  linkingInversion,
  other,
}

/// One example sentence used in the Topic Detail "Examples" section. `gloss`
/// is an optional grammatical hint (e.g. "have + V3" highlight). `vi` is the
/// natural Vietnamese translation, not a literal gloss — it's what we'd
/// teach the learner to recognise.
class GrammarExample {
  final String en;
  final String vi;
  final String? gloss;

  const GrammarExample({
    required this.en,
    required this.vi,
    this.gloss,
  });
}

/// Common-mistake card content. `wrong` shows the typical learner error,
/// `right` the correct form, `why` the one-sentence reason (Vietnamese is
/// fine — this is study aid copy, not chrome).
class GrammarMistake {
  final String wrong;
  final String right;
  final String why;

  const GrammarMistake({
    required this.wrong,
    required this.right,
    required this.why,
  });
}

/// A single grammar topic in the Aura catalog.
///
/// Equality is by `id` so any duplicate registration during dev would
/// surface immediately when the catalog assembles into a `Map`. Catalog
/// stores them as a `List` for deterministic ordering, but `byId` lookups
/// hit a `Map` built once at startup.
class GrammarTopic {
  /// Stable slug, e.g. `present_perfect`. Used in routes
  /// (`/grammar/:topicId`) and as the Firestore doc ID for progress. Must
  /// stay stable across releases — never rename a published id.
  final String id;

  /// English title surfaced in UI chrome. Length budget: ≤ 28 characters
  /// so it fits in a 2-column grid card without ellipsis on a 375pt phone.
  final String title;

  /// Vietnamese title. Same length budget. Some titles legitimately keep
  /// English idiom in quotes (e.g. `"used to" / "would"`) when there is
  /// no clean Vietnamese rendering.
  final String titleVi;

  /// CEFR level — drives the hub filter row + AI prompt difficulty band.
  final CefrLevel level;

  /// Coarse category bucket for the secondary filter row.
  final GrammarCategory category;

  /// One-line grammatical formula in code-friendly notation. Always English
  /// because formulas are language-agnostic notation. Examples:
  /// - `"S + have/has + V3"` (Present Perfect)
  /// - `"If + S + V(past), S + would + V"` (2nd Conditional)
  final String formula;

  /// Topic summary — 1–2 sentences. Empty in Phase A1 skeleton; populated
  /// in Phase A3.
  final String summary;
  final String summaryVi;

  /// "When to use" bullet list, EN + VI. Empty in Phase A1.
  final List<String> useCases;
  final List<String> useCasesVi;

  /// Example sentences. Empty in Phase A1.
  final List<GrammarExample> examples;

  /// Common mistakes. Empty in Phase A1.
  final List<GrammarMistake> commonMistakes;

  /// Cross-links to related topics by id. Used for the Topic Detail
  /// "Related topics" chip row. Empty in Phase A1.
  final List<String> relatedTopicIds;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.level,
    required this.category,
    required this.formula,
    this.summary = '',
    this.summaryVi = '',
    this.useCases = const [],
    this.useCasesVi = const [],
    this.examples = const [],
    this.commonMistakes = const [],
    this.relatedTopicIds = const [],
  });

  @override
  bool operator ==(Object other) =>
      other is GrammarTopic && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
