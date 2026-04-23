# Vocab Hub MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a fully functional Vocab Hub feature routed from the Home screen's fourth mode card, exposing Overview (saved items), Word Analysis, Mind Map (Pro-only), Flashcards with SM-2, and Describe-a-word (reverse dictionary). Fix the existing save-to-dictionary pipeline along the way.

**Architecture:** Single-route `/vocab-hub` entry from Home, internal `TabBar` with five tabs. Provider pattern for state (existing `LibraryProvider` extended; new `MindMapProvider`, `FlashcardsProvider`). Persistence via `FirebaseDatasource` (extended with mind-map CRUD + illustrations via Firebase Storage). Gemini 2.5 Flash for all AI calls with a 30 s provider-level timeout. Clay Design tokens from `core/theme/*` for every UI.

**Tech Stack:** Flutter 3.x · Provider/ChangeNotifier · GoRouter · Cloud Firestore · Firebase Storage · Gemini `google_generative_ai` 0.4.7 · `crypto` · CustomPainter + `TransformationController` for the Mind Map canvas.

---

## Cross-Phase Conventions

- No Vietnamese comments in code. All comments must be English.
- Naming: `camelCase` variables/methods, `PascalCase` classes, `snake_case` files.
- No `print()` — use `debugPrint`.
- Commit after every Step marked with "Commit".
- Keep files small and focused — if a widget exceeds ~350 lines, split it.
- Every network call (Gemini, Firestore, Storage) must be wrapped in try/catch with a user-visible error via `ScaffoldMessenger` or an in-provider `error` field.
- Before every Step that runs the app, the engineer should run `flutter analyze` and fix any new warnings they introduced.

---

## Phase A — Fixes & Quota Enforcement

### File Structure for Phase A

- Modify: `lib/features/my_library/models/saved_item.dart` — add `dictionaryData`, `pronunciation`, `sourceTag`, `illustrationEmoji` fields; fix `fromImprovement` SM-2 bug.
- Modify: `lib/features/my_library/providers/library_provider.dart` — quota enforcement in `addItem`; cap `_backfillVocabularyEnrichment` retry count.
- Modify: `lib/data/prompts/vocab_prompts.dart` — extend `buildDictionaryPrompt` with pronunciation, synonyms, contextUsage.
- Modify: `lib/data/gemini/schemas.dart` — update `dictionary` responseSchema to match new payload.
- Modify: `lib/data/gemini/types.dart` — extend `DictionaryResult` with new fields.
- Modify: `lib/features/scenario/screens/scenario_chat_screen.dart` and `lib/features/story/screens/story_chat_screen.dart` — gate `libraryProvider.addItem` behind quota.
- Modify: `lib/data/datasources/firebase_datasource.dart` — add `incrementDailyUsage` calls for `dictionary`; no functional change to signature.

### Task A1: Extend SavedItem model

**Files:**
- Modify: `lib/features/my_library/models/saved_item.dart`

- [ ] **Step 1: Add new fields to `SavedItem`**

Add to the field list, constructor, `copyWith`, `fromJson`, `toJson`:

```dart
final String? pronunciation;       // IPA e.g. "/ɪˈfem.ər.əl/"
final String? sourceTag;           // 'scenario' | 'story' | 'manual'
final String? illustrationEmoji;   // optional single emoji shown on the card
final List<String>? synonyms;
final String? contextUsage;        // one-line note on when to use this word
```

Keep the ordering consistent: `pronunciation`, `sourceTag`, `illustrationEmoji`, `synonyms`, `contextUsage` all placed after `category`.

- [ ] **Step 2: Fix the SM-2 "immediately due" bug in `fromImprovement`**

In `fromImprovement`, replace:

```dart
nextReviewDate: DateTime.now().millisecondsSinceEpoch.toDouble(),
```

with

```dart
// New items are scheduled for tomorrow so they don't pollute today's queue.
nextReviewDate: DateTime.now()
    .add(const Duration(days: 1))
    .millisecondsSinceEpoch
    .toDouble(),
interval: 1,
```

- [ ] **Step 3: Verify `copyWith`, `toJson`, `fromJson` parity**

Every new field must appear in all four methods. Read the file end-to-end and confirm.

- [ ] **Step 4: Commit**

```bash
git add lib/features/my_library/models/saved_item.dart
git commit -m "feat(library): extend SavedItem with dictionary payload + fix SM-2 new-item schedule"
```

### Task A2: Extend dictionary prompt + schema

**Files:**
- Modify: `lib/data/prompts/vocab_prompts.dart`
- Modify: `lib/data/gemini/schemas.dart`
- Modify: `lib/data/gemini/types.dart`

- [ ] **Step 1: Rewrite `buildDictionaryPrompt` to request richer payload**

Replace the current body with the following exact template (preserves existing POS list):

```dart
String buildDictionaryPrompt({
  required String phrase,
  required String context,
}) {
  return '''
You are an expert English teacher. The user wants to save the phrase/word "$phrase" from the following context:
"$context"

Please provide:
1. The part of speech of this phrase/word in this context. You MUST choose EXACTLY ONE from this list: "Noun (Danh từ)", "Verb (Động từ)", "Adjective (Tính từ)", "Adverb (Trạng từ)", "Phrasal Verb (Cụm động từ)", "Idiom (Thành ngữ)", "Expression (Cụm từ)", "Other (Khác)".
2. The IPA pronunciation wrapped in slashes, e.g. "/ɪˈfem.ər.əl/".
3. A clear, concise explanation in Vietnamese (1-2 sentences).
4. 3 practical example sentences, each with Vietnamese translation.
5. 3 common synonyms (single words or short phrases).
6. A one-line note in Vietnamese describing when to use this word versus its close synonyms.

Respond with ONLY a JSON object in this exact shape:
{
  "partOfSpeech": "One of the exact options above",
  "pronunciation": "/.../",
  "explanation": "Giải thích ý nghĩa bằng tiếng Việt...",
  "examples": [
    {"en": "English example 1", "vn": "Vietnamese translation 1"},
    {"en": "English example 2", "vn": "Vietnamese translation 2"},
    {"en": "English example 3", "vn": "Vietnamese translation 3"}
  ],
  "synonyms": ["syn1", "syn2", "syn3"],
  "contextUsage": "Dùng khi..."
}
''';
}
```

- [ ] **Step 2: Update the `dictionary` response schema in `schemas.dart`**

Locate `GeminiSchemas.dictionary` and add the new required fields. The schema must match exactly what the prompt asks for — `pronunciation: String`, `synonyms: List<String>`, `contextUsage: String`. Leave existing fields intact.

- [ ] **Step 3: Extend `DictionaryResult` in `types.dart`**

```dart
class DictionaryResult {
  final String partOfSpeech;
  final String pronunciation;
  final String explanation;
  final List<EnVnExample> examples;
  final List<String> synonyms;
  final String contextUsage;

  const DictionaryResult({
    required this.partOfSpeech,
    required this.pronunciation,
    required this.explanation,
    required this.examples,
    required this.synonyms,
    required this.contextUsage,
  });

  factory DictionaryResult.fromJson(Map<String, dynamic> json) =>
      DictionaryResult(
        partOfSpeech:
            json['partOfSpeech'] as String? ?? 'Other (Khác)',
        pronunciation: json['pronunciation'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        examples: (json['examples'] as List<dynamic>?)
                ?.map((e) =>
                    EnVnExample.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        synonyms: (json['synonyms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        contextUsage: json['contextUsage'] as String? ?? '',
      );
}
```

- [ ] **Step 4: Run `flutter analyze` and fix every new error/warning**

Expected: zero new errors.

- [ ] **Step 5: Commit**

```bash
git add lib/data/prompts/vocab_prompts.dart lib/data/gemini/schemas.dart lib/data/gemini/types.dart
git commit -m "feat(gemini): enrich dictionary payload with pronunciation, synonyms, contextUsage"
```

### Task A3: Wire enriched payload into LibraryProvider

**Files:**
- Modify: `lib/features/my_library/providers/library_provider.dart`

- [ ] **Step 1: Update `_enrichVocabularyItem` to persist new fields**

Inside the method, replace the `copyWith` call with:

```dart
final enriched = current.copyWith(
  explanation: dictData.explanation,
  partOfSpeech: dictData.partOfSpeech,
  pronunciation: dictData.pronunciation,
  synonyms: dictData.synonyms,
  contextUsage: dictData.contextUsage,
  examples: dictData.examples
      .map((e) => {'en': e.en, 'vn': e.vn})
      .toList(),
);
```

- [ ] **Step 2: Cap the backfill loop to prevent retry storms**

Replace `_backfillVocabularyEnrichment` body with:

```dart
Future<void> _backfillVocabularyEnrichment() async {
  const maxPerLoad = 5;
  var processed = 0;
  for (final item in List<SavedItem>.from(_items)) {
    if (item.type != 'vocabulary') continue;
    if (item.explanation != null) continue;
    if (processed >= maxPerLoad) break;
    await _enrichVocabularyItem(item);
    processed++;
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/my_library/providers/library_provider.dart
git commit -m "feat(library): persist enriched dictionary fields + cap enrichment backfill"
```

### Task A4: Quota enforcement on save-to-dictionary

**Files:**
- Create: `lib/features/my_library/providers/dictionary_quota_guard.dart`
- Modify: `lib/features/scenario/screens/scenario_chat_screen.dart`
- Modify: `lib/features/story/screens/story_chat_screen.dart`

- [ ] **Step 1: Create the quota guard helper**

```dart
// lib/features/my_library/providers/dictionary_quota_guard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/quota_constants.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../home/providers/home_provider.dart';
import '../../../domain/entities/user_profile.dart';
import 'package:go_router/go_router.dart';

/// Returns true if the user may save another dictionary item right now.
/// Surfaces a SnackBar with an Upgrade CTA when the free-tier cap is hit.
Future<bool> ensureDictionaryQuota(BuildContext context) async {
  final home = context.read<HomeProvider>();
  final firebase = context.read<FirebaseDatasource>();
  final UserProfile? profile = home.userProfile;
  if (profile == null) return true;

  final tier = profile.tier;
  final limit = QuotaConstants.getLimit(tier, 'dictionary');
  if (limit < 0) return true;

  final dateKey = DateTime.now().toIso8601String().substring(0, 10);
  final usage = await firebase.getDailyUsage(profile.uid, dateKey);
  final used = usage['dictionaryCount'] ?? 0;
  if (used >= limit) {
    _showUpgradeSnack(context, limit);
    return false;
  }
  return true;
}

void _showUpgradeSnack(BuildContext context, int limit) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Bạn đã dùng hết $limit lượt lưu từ điển hôm nay'),
      action: SnackBarAction(
        label: 'Upgrade',
        onPressed: () => context.push('/subscription'),
      ),
    ),
  );
}
```

- [ ] **Step 2: Gate `_saveSelectionToDictionary`, `onSaveImprovement`, `onSaveVocabulary` in scenario_chat_screen**

For every `libraryProvider.addItem(...)` call, wrap it:

```dart
final allowed = await ensureDictionaryQuota(context);
if (!allowed) return;
if (!context.mounted) return;
await libraryProvider.addItem(item);
await context.read<FirebaseDatasource>().incrementDailyUsage(
      uid,
      DateTime.now().toIso8601String().substring(0, 10),
      'dictionary',
    );
```

- [ ] **Step 3: Repeat the same wrapping in `story_chat_screen.dart`**

Apply to `_saveImprovement`, `_saveVocabulary`, `_saveSelection`.

- [ ] **Step 4: Run `flutter analyze` — zero new warnings**

- [ ] **Step 5: Manual smoke test checklist (author these as inline TODO comments only if testing infra missing)**

- Save 5 items as a free user → 6th attempt shows SnackBar with Upgrade.
- Save 1 item as a pro user → no SnackBar, item saved.
- Dictionary count in Firestore `users/{uid}/usage/{date}.dictionaryCount` increments by 1 per save.

- [ ] **Step 6: Commit**

```bash
git add lib/features/my_library/providers/dictionary_quota_guard.dart \
        lib/features/scenario/screens/scenario_chat_screen.dart \
        lib/features/story/screens/story_chat_screen.dart
git commit -m "feat(quota): enforce dictionary quota on save + upgrade CTA"
```

---

## Phase B — Word Analysis Screen

### File Structure for Phase B

- Create: `lib/features/vocab_hub/screens/vocab_hub_screen.dart` — root screen with TabBar (5 tabs: Overview / Word Analysis / Mind Map / Flashcards / Describe).
- Create: `lib/features/vocab_hub/tabs/word_analysis_tab.dart` — deep-dive UI consuming `GeminiService.generateWordAnalysis`.
- Create: `lib/features/vocab_hub/widgets/word_analysis_card.dart` — reusable card rendering morphology + examples + derivatives + synonyms/antonyms.
- Create: `lib/features/vocab_hub/widgets/morphology_diagram.dart` — visual prefix + root + suffix pill chain.
- Modify: `lib/app.dart` — register `/vocab-hub` route.
- Modify: `lib/features/home/screens/home_screen.dart` — set `route: '/vocab-hub'` on the Vocab Hub `_ModeConfig`.

### Task B1: Register /vocab-hub route + Home card tap

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/features/home/screens/home_screen.dart`
- Create: `lib/features/vocab_hub/screens/vocab_hub_screen.dart` (stub)

- [ ] **Step 1: Create the stub screen with TabBar**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';

class VocabHubScreen extends StatelessWidget {
  const VocabHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.clayCream,
        appBar: AppBar(
          backgroundColor: AppColors.clayCream,
          elevation: 0,
          leading: const ClayBackButton(),
          title: Text('Vocab Hub', style: AppTypography.headingSmall),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.coral,
            labelColor: AppColors.warmDark,
            unselectedLabelColor: AppColors.warmLight,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Word Analysis'),
              Tab(text: 'Mind Map'),
              Tab(text: 'Flashcards'),
              Tab(text: 'Describe'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ComingSoon(label: 'Overview'),
            _ComingSoon(label: 'Word Analysis'),
            _ComingSoon(label: 'Mind Map'),
            _ComingSoon(label: 'Flashcards'),
            _ComingSoon(label: 'Describe'),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String label;
  const _ComingSoon({required this.label});

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$label — coming soon'));
}
```

- [ ] **Step 2: Register the route in `app.dart`**

Add import:

```dart
import 'features/vocab_hub/screens/vocab_hub_screen.dart';
```

Add after the `/my-library` route:

```dart
GoRoute(
  path: '/vocab-hub',
  pageBuilder: (_, state) => slideFadeTransitionPage(
    key: state.pageKey,
    child: const VocabHubScreen(),
  ),
),
```

- [ ] **Step 3: Wire the Vocab Hub Home card**

In `lib/features/home/screens/home_screen.dart`, find the `_ModeConfig` for Vocab Hub (`title: 'Vocab Hub'`) and add `route: '/vocab-hub',` as its last field.

- [ ] **Step 4: Smoke test**

Run the app, tap Vocab Hub on Home → the Vocab Hub screen with TabBar appears, all tabs say "coming soon".

- [ ] **Step 5: Commit**

```bash
git add lib/app.dart lib/features/home/screens/home_screen.dart lib/features/vocab_hub/screens/vocab_hub_screen.dart
git commit -m "feat(vocab-hub): scaffold /vocab-hub route with 5-tab TabBar"
```

### Task B2: Build WordAnalysisTab (UI shell)

**Files:**
- Create: `lib/features/vocab_hub/tabs/word_analysis_tab.dart`
- Modify: `lib/features/vocab_hub/screens/vocab_hub_screen.dart` — replace `_ComingSoon('Word Analysis')` with `WordAnalysisTab`.

- [ ] **Step 1: Create `WordAnalysisTab` with input field + state**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';
import '../../../shared/widgets/clay_button.dart';
import '../widgets/word_analysis_card.dart';

class WordAnalysisTab extends StatefulWidget {
  const WordAnalysisTab({super.key});

  @override
  State<WordAnalysisTab> createState() => _WordAnalysisTabState();
}

class _WordAnalysisTabState extends State<WordAnalysisTab> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  WordAnalysis? _result;

  Future<void> _analyze() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final gemini = context.read<GeminiService>();
      final result = await gemini
          .generateWordAnalysis(word: word)
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Analysis failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter a word to analyze',
              filled: true,
              fillColor: AppColors.clayWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.clayBorder),
              ),
            ),
            onSubmitted: (_) => _analyze(),
          ),
          const SizedBox(height: AppSpacing.md),
          ClayButton(
            label: _loading ? 'Analyzing...' : 'Analyze',
            onPressed: _loading ? null : _analyze,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null)
            Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.coral)),
          if (_result != null) WordAnalysisCard(analysis: _result!),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Register `GeminiService` as a top-level `Provider` in `app.dart`**

In the `MultiProvider.providers` list, above the existing providers, add:

```dart
Provider<GeminiService>.value(value: _geminiService),
```

- [ ] **Step 3: Replace the tab placeholder in `vocab_hub_screen.dart`**

Replace `_ComingSoon('Word Analysis')` with `const WordAnalysisTab()` and add the import.

- [ ] **Step 4: Commit**

```bash
git add lib/features/vocab_hub/tabs/word_analysis_tab.dart \
        lib/features/vocab_hub/screens/vocab_hub_screen.dart \
        lib/app.dart
git commit -m "feat(vocab-hub): word analysis tab with Gemini backend wire-up"
```

### Task B3: Render the analysis payload

**Files:**
- Create: `lib/features/vocab_hub/widgets/word_analysis_card.dart`
- Create: `lib/features/vocab_hub/widgets/morphology_diagram.dart`

- [ ] **Step 1: Build `MorphologyDiagram`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/gemini/types.dart';

class MorphologyDiagram extends StatelessWidget {
  final Morphology morphology;
  const MorphologyDiagram({super.key, required this.morphology});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (morphology.prefix != null) {
      chips.add(_Chip(label: morphology.prefix!.morpheme,
          sub: morphology.prefix!.meaning, color: AppColors.purple));
      chips.add(const _Plus());
    }
    chips.add(_Chip(label: morphology.root.morpheme,
        sub: morphology.root.meaning, color: AppColors.teal));
    if (morphology.suffix != null) {
      chips.add(const _Plus());
      chips.add(_Chip(label: morphology.suffix!.morpheme,
          sub: morphology.suffix!.meaning, color: AppColors.coral));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Morphology', style: AppTypography.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.start,
            children: chips),
        const SizedBox(height: AppSpacing.sm),
        Text(morphology.equation, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _Chip({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: AppTypography.titleSmall.copyWith(color: color)),
          Text(sub, style: AppTypography.caption),
        ]),
      );
}

class _Plus extends StatelessWidget {
  const _Plus();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('+', style: TextStyle(fontSize: 18)),
      );
}
```

- [ ] **Step 2: Build `WordAnalysisCard`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';
import '../../../shared/widgets/clay_card.dart';
import 'morphology_diagram.dart';

class WordAnalysisCard extends StatelessWidget {
  final WordAnalysis analysis;
  const WordAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(analysis.word, style: AppTypography.headingMedium),
          Text(analysis.phonetic, style: AppTypography.bodyMedium.copyWith(color: AppColors.warmLight)),
          const SizedBox(height: 4),
          Text(analysis.translation, style: AppTypography.bodyLarge),
          const Divider(height: 24),
          MorphologyDiagram(morphology: analysis.morphology),
          const Divider(height: 24),
          _ExampleSection(embedding: analysis.contextualEmbedding),
          const Divider(height: 24),
          _DerivativesSection(derivatives: analysis.derivatives),
          const Divider(height: 24),
          _SynAntSection(
              synonyms: analysis.synonyms, antonyms: analysis.antonyms),
        ],
      ),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  final ContextualEmbedding embedding;
  const _ExampleSection({required this.embedding});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Examples', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          _ExampleTile(
              label: 'Positive',
              example: embedding.positiveExample,
              color: AppColors.teal),
          const SizedBox(height: 8),
          _ExampleTile(
              label: 'Negative',
              example: embedding.negativeExample,
              color: AppColors.coral),
          const SizedBox(height: 12),
          Text('Collocations', style: AppTypography.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: embedding.collocations
                .map((c) => Chip(label: Text(c)))
                .toList(),
          ),
        ],
      );
}

class _ExampleTile extends StatelessWidget {
  final String label;
  final EnVnExample example;
  final Color color;
  const _ExampleTile({
    required this.label,
    required this.example,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(example.en, style: AppTypography.bodyMedium),
            Text(example.vn,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.warmLight)),
          ],
        ),
      );
}

class _DerivativesSection extends StatelessWidget {
  final Derivatives derivatives;
  const _DerivativesSection({required this.derivatives});

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String?)>[
      ('Noun', derivatives.noun),
      ('Verb', derivatives.verb),
      ('Adjective', derivatives.adjective),
      ('Adverb', derivatives.adverb),
    ].where((e) => e.$2 != null && e.$2!.isNotEmpty).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Word family', style: AppTypography.titleSmall),
        const SizedBox(height: 8),
        ...entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${e.$1}: ${e.$2}',
                  style: AppTypography.bodySmall),
            )),
      ],
    );
  }
}

class _SynAntSection extends StatelessWidget {
  final List<String> synonyms;
  final List<String> antonyms;
  const _SynAntSection({required this.synonyms, required this.antonyms});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ListBlock(title: 'Synonyms', items: synonyms, color: AppColors.teal)),
          const SizedBox(width: 12),
          Expanded(child: _ListBlock(title: 'Antonyms', items: antonyms, color: AppColors.coral)),
        ],
      );
}

class _ListBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _ListBlock({required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmall.copyWith(color: color)),
          const SizedBox(height: 4),
          ...items.map((s) => Text('• $s', style: AppTypography.bodySmall)),
        ],
      );
}
```

- [ ] **Step 3: Smoke test**

Open `/vocab-hub` → Word Analysis tab → type "ephemeral" → tap Analyze → card renders phonetic, morphology diagram, examples, derivatives, synonyms/antonyms.

- [ ] **Step 4: Commit**

```bash
git add lib/features/vocab_hub/widgets/word_analysis_card.dart \
        lib/features/vocab_hub/widgets/morphology_diagram.dart
git commit -m "feat(vocab-hub): render full word analysis card"
```

---

## Phase C — Mind Map (Pro-only)

### File Structure for Phase C

- Create: `lib/features/vocab_hub/providers/mind_map_provider.dart` — holds current `MindMapNode`, expand state, pan/zoom state.
- Create: `lib/features/vocab_hub/tabs/mind_map_tab.dart` — gate + empty state + canvas host.
- Create: `lib/features/vocab_hub/widgets/mind_map_canvas.dart` — `CustomPainter` + `InteractiveViewer` + hit-test callback.
- Create: `lib/features/vocab_hub/widgets/pro_upgrade_card.dart` — reusable Pro paywall card.
- Modify: `lib/data/datasources/firebase_datasource.dart` — add `saveMindMap/getMindMap/listMindMaps/deleteMindMap`.
- Modify: `firestore.rules` — add `mindMaps` subcollection rule.
- Modify: `lib/app.dart` — register `MindMapProvider`.

### Task C1: Add Firestore CRUD for mind maps

**Files:**
- Modify: `lib/data/datasources/firebase_datasource.dart`
- Modify: `firestore.rules`

- [ ] **Step 1: Append mind-map CRUD methods**

Append before the closing `}` of `FirebaseDatasource`:

```dart
// --- Mind Map persistence ---

Future<List<Map<String, dynamic>>> listMindMaps(String uid) async {
  final snapshot = await _db
      .collection('users').doc(uid)
      .collection('mindMaps')
      .orderBy('updatedAt', descending: true)
      .limit(50)
      .get();
  return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
}

Future<Map<String, dynamic>?> getMindMap(String uid, String mapId) async {
  final doc = await _db
      .collection('users').doc(uid)
      .collection('mindMaps').doc(mapId).get();
  if (!doc.exists) return null;
  return {'id': doc.id, ...doc.data()!};
}

Future<void> saveMindMap({
  required String uid,
  required String mapId,
  required Map<String, dynamic> data,
}) async {
  await _db
      .collection('users').doc(uid)
      .collection('mindMaps').doc(mapId)
      .set({
    ...data,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> deleteMindMap(String uid, String mapId) async {
  await _db
      .collection('users').doc(uid)
      .collection('mindMaps').doc(mapId).delete();
}
```

- [ ] **Step 2: Add the Firestore rule**

In `firestore.rules`, find the `match /users/{uid}` block and add inside it:

```
match /mindMaps/{mapId} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/datasources/firebase_datasource.dart firestore.rules
git commit -m "feat(mindmap): add firestore CRUD + security rule"
```

### Task C2: MindMapProvider + Pro gate

**Files:**
- Create: `lib/features/vocab_hub/providers/mind_map_provider.dart`
- Create: `lib/features/vocab_hub/widgets/pro_upgrade_card.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Build the provider**

```dart
import 'package:flutter/foundation.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';
import '../../../domain/entities/cefr_level.dart';

class MindMapProvider extends ChangeNotifier {
  final GeminiService _gemini;
  final FirebaseDatasource _firebase;

  MindMapProvider({
    required GeminiService gemini,
    required FirebaseDatasource firebase,
  })  : _gemini = gemini,
        _firebase = firebase;

  String? _uid;
  CefrLevel _level = CefrLevel.a2;
  String? _mapId;
  MindMapNode? _root;
  bool _loading = false;
  String? _error;
  final Set<String> _expanding = {};

  MindMapNode? get root => _root;
  bool get loading => _loading;
  String? get error => _error;
  bool isExpanding(String nodeId) => _expanding.contains(nodeId);

  void configure({required String uid, required CefrLevel level}) {
    _uid = uid;
    _level = level;
  }

  Future<void> generateFor(String topic) async {
    if (_uid == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final node = await _gemini
          .generateTopicMindMap(topic: topic, level: _level)
          .timeout(const Duration(seconds: 30));
      _root = node;
      _mapId = 'topic_${DateTime.now().millisecondsSinceEpoch}';
      await _firebase.saveMindMap(
        uid: _uid!,
        mapId: _mapId!,
        data: {'topic': topic, 'root': node.toJson()},
      );
    } catch (e) {
      _error = 'Failed to generate mind map: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> expandNode(String nodeId) async {
    if (_root == null || _uid == null) return;
    final target = _findNode(_root!, nodeId);
    if (target == null || target.children.isNotEmpty) return;
    _expanding.add(nodeId);
    notifyListeners();
    try {
      final children = await _gemini
          .expandMindMapNode(
            nodeLabel: target.label,
            rootTopic: _root!.label,
            level: _level,
          )
          .timeout(const Duration(seconds: 30));
      _root = _replaceChildren(_root!, nodeId, children);
      if (_mapId != null) {
        await _firebase.saveMindMap(
          uid: _uid!,
          mapId: _mapId!,
          data: {'root': _root!.toJson()},
        );
      }
    } catch (e) {
      _error = 'Failed to expand node: $e';
    } finally {
      _expanding.remove(nodeId);
      notifyListeners();
    }
  }

  MindMapNode? _findNode(MindMapNode node, String id) {
    if (node.id == id) return node;
    for (final child in node.children) {
      final hit = _findNode(child, id);
      if (hit != null) return hit;
    }
    return null;
  }

  MindMapNode _replaceChildren(
      MindMapNode node, String id, List<MindMapNode> children) {
    if (node.id == id) {
      return MindMapNode(
        id: node.id,
        label: node.label,
        type: node.type,
        translation: node.translation,
        partOfSpeech: node.partOfSpeech,
        context: node.context,
        children: children,
      );
    }
    return MindMapNode(
      id: node.id,
      label: node.label,
      type: node.type,
      translation: node.translation,
      partOfSpeech: node.partOfSpeech,
      context: node.context,
      children:
          node.children.map((c) => _replaceChildren(c, id, children)).toList(),
    );
  }
}
```

- [ ] **Step 2: Create the upgrade paywall card**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';

class ProUpgradeCard extends StatelessWidget {
  final String title;
  final String description;
  const ProUpgradeCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ClayCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headingSmall),
              const SizedBox(height: 8),
              Text(description, style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              ClayButton(
                label: 'Upgrade to Pro',
                onPressed: () => context.push('/subscription'),
                backgroundColor: AppColors.coral,
              ),
            ],
          ),
        ),
      );
}
```

- [ ] **Step 3: Register the provider in `app.dart`**

Add field + init:

```dart
late final MindMapProvider _mindMapProvider;
// inside initState:
_mindMapProvider = MindMapProvider(
  gemini: _geminiService,
  firebase: _firebaseDatasource,
);
```

Add to `MultiProvider`:

```dart
ChangeNotifierProvider<MindMapProvider>.value(value: _mindMapProvider),
```

And to `dispose`:

```dart
_mindMapProvider.dispose();
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/vocab_hub/providers/mind_map_provider.dart \
        lib/features/vocab_hub/widgets/pro_upgrade_card.dart \
        lib/app.dart
git commit -m "feat(mindmap): provider + pro upgrade card + DI"
```

### Task C3: MindMapCanvas (CustomPainter + InteractiveViewer)

**Files:**
- Create: `lib/features/vocab_hub/widgets/mind_map_canvas.dart`

- [ ] **Step 1: Lay out nodes with a radial tree algorithm**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';

class MindMapCanvas extends StatelessWidget {
  final MindMapNode root;
  final void Function(String nodeId) onNodeTap;
  final Set<String> expandingIds;

  const MindMapCanvas({
    super.key,
    required this.root,
    required this.onNodeTap,
    required this.expandingIds,
  });

  @override
  Widget build(BuildContext context) {
    final layout = _layoutRadial(root);
    return InteractiveViewer(
      constrained: false,
      minScale: 0.5,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(200),
      child: SizedBox(
        width: layout.size.width,
        height: layout.size.height,
        child: Stack(
          children: [
            CustomPaint(
              size: layout.size,
              painter: _EdgePainter(layout.positions, root),
            ),
            ...layout.positions.entries.map((entry) {
              final node = _findNode(root, entry.key)!;
              final pos = entry.value;
              final isExpanding = expandingIds.contains(node.id);
              return Positioned(
                left: pos.dx - 60,
                top: pos.dy - 24,
                child: GestureDetector(
                  onTap: () => onNodeTap(node.id),
                  child: _NodeChip(node: node, isExpanding: isExpanding),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  MindMapNode? _findNode(MindMapNode node, String id) {
    if (node.id == id) return node;
    for (final c in node.children) {
      final hit = _findNode(c, id);
      if (hit != null) return hit;
    }
    return null;
  }
}

class _LayoutResult {
  final Map<String, Offset> positions;
  final Size size;
  _LayoutResult(this.positions, this.size);
}

_LayoutResult _layoutRadial(MindMapNode root) {
  const rootRadius = 0.0;
  const level1Radius = 160.0;
  const level2Radius = 300.0;
  final positions = <String, Offset>{};
  const center = Offset(400, 400);
  positions[root.id] = center;
  final l1Count = root.children.length;
  for (var i = 0; i < l1Count; i++) {
    final angle = (2 * math.pi * i) / math.max(l1Count, 1);
    final p = center +
        Offset(math.cos(angle), math.sin(angle)) * level1Radius;
    final child = root.children[i];
    positions[child.id] = p;
    final l2Count = child.children.length;
    for (var j = 0; j < l2Count; j++) {
      final spread = math.pi / 2; // 90° arc per l1 node
      final a = angle - spread / 2 + spread * j / math.max(l2Count - 1, 1);
      final p2 = center +
          Offset(math.cos(a), math.sin(a)) * level2Radius;
      positions[child.children[j].id] = p2;
    }
  }
  // pad bounding box
  final xs = positions.values.map((p) => p.dx);
  final ys = positions.values.map((p) => p.dy);
  final w = (xs.reduce(math.max) + 120).clamp(800.0, 2000.0);
  final h = (ys.reduce(math.max) + 120).clamp(800.0, 2000.0);
  return _LayoutResult(positions, Size(w, h));
}

class _EdgePainter extends CustomPainter {
  final Map<String, Offset> positions;
  final MindMapNode root;
  _EdgePainter(this.positions, this.root);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.clayBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawEdges(canvas, root, paint);
  }

  void _drawEdges(Canvas canvas, MindMapNode node, Paint paint) {
    final from = positions[node.id];
    if (from == null) return;
    for (final child in node.children) {
      final to = positions[child.id];
      if (to == null) continue;
      canvas.drawLine(from, to, paint);
      _drawEdges(canvas, child, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _NodeChip extends StatelessWidget {
  final MindMapNode node;
  final bool isExpanding;
  const _NodeChip({required this.node, required this.isExpanding});

  @override
  Widget build(BuildContext context) {
    final color = switch (node.type) {
      MindMapNodeType.topic => AppColors.purple,
      MindMapNodeType.category => AppColors.teal,
      MindMapNodeType.word => AppColors.coral,
    };
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(node.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(color: color)),
        if (isExpanding)
          const SizedBox(
            width: 10, height: 10,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
      ]),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/vocab_hub/widgets/mind_map_canvas.dart
git commit -m "feat(mindmap): radial custom-painter canvas with zoom + pan"
```

### Task C4: MindMapTab — topic input + gate + canvas host

**Files:**
- Create: `lib/features/vocab_hub/tabs/mind_map_tab.dart`
- Modify: `lib/features/vocab_hub/screens/vocab_hub_screen.dart`

- [ ] **Step 1: Implement the tab**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/cefr_level.dart';
import '../../../features/home/providers/home_provider.dart';
import '../../../shared/widgets/clay_button.dart';
import '../providers/mind_map_provider.dart';
import '../widgets/mind_map_canvas.dart';
import '../widgets/pro_upgrade_card.dart';

class MindMapTab extends StatefulWidget {
  const MindMapTab({super.key});

  @override
  State<MindMapTab> createState() => _MindMapTabState();
}

class _MindMapTabState extends State<MindMapTab> {
  final TextEditingController _controller = TextEditingController();

  bool _isPro(String tier) => tier == 'pro' || tier == 'premium';

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final profile = home.userProfile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isPro(profile.tier)) {
      return const ProUpgradeCard(
        title: 'Mind Map is a Pro feature',
        description:
            'Visualize how words connect, expand branches on demand, and build your own topic map. Upgrade to unlock.',
      );
    }
    final provider = context.watch<MindMapProvider>();
    final uid = profile.uid;
    provider.configure(uid: uid, level: profile.currentLevel ?? CefrLevel.a2);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter a topic, e.g. Travel',
                  ),
                  onSubmitted: (v) => provider.generateFor(v.trim()),
                ),
              ),
              const SizedBox(width: 8),
              ClayButton(
                label: provider.loading ? '...' : 'Generate',
                onPressed: provider.loading
                    ? null
                    : () => provider.generateFor(_controller.text.trim()),
              ),
            ],
          ),
        ),
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(provider.error!,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.coral)),
          ),
        Expanded(
          child: provider.root == null
              ? const Center(child: Text('Enter a topic to build a mind map'))
              : MindMapCanvas(
                  root: provider.root!,
                  expandingIds: {
                    for (final id in _walkIds(provider.root!))
                      if (provider.isExpanding(id)) id,
                  },
                  onNodeTap: provider.expandNode,
                ),
        ),
      ],
    );
  }

  Iterable<String> _walkIds(node) sync* {
    yield node.id;
    for (final c in node.children) {
      yield* _walkIds(c);
    }
  }
}
```

- [ ] **Step 2: Wire into the screen**

Replace `_ComingSoon('Mind Map')` with `const MindMapTab()` in `vocab_hub_screen.dart`.

- [ ] **Step 3: Smoke test**

As a `free` user → Mind Map tab shows the upgrade card. Flip a test account to `pro` → enter "Travel" → mind map renders with tappable nodes. Tap a category → it expands into 3-5 leaf nodes.

- [ ] **Step 4: Commit**

```bash
git add lib/features/vocab_hub/tabs/mind_map_tab.dart \
        lib/features/vocab_hub/screens/vocab_hub_screen.dart
git commit -m "feat(mindmap): topic-driven mind map with pro gate"
```

---

## Phase D — Flashcards + SM-2

### File Structure for Phase D

- Create: `lib/features/vocab_hub/flashcards/sm2.dart` — pure SM-2 algorithm (no Flutter dep).
- Create: `lib/features/vocab_hub/flashcards/flashcards_provider.dart` — queue builder + rating handler.
- Create: `lib/features/vocab_hub/tabs/flashcards_tab.dart` — tab entry with empty state + card + rating bar.
- Create: `lib/features/vocab_hub/flashcards/flashcard_view.dart` — single card widget with flip animation.
- Create: `lib/features/vocab_hub/flashcards/rating_bar.dart` — 3-button Hard / Good / Easy.

### Task D1: SM-2 core algorithm

**Files:**
- Create: `lib/features/vocab_hub/flashcards/sm2.dart`
- Create: `test/features/vocab_hub/flashcards/sm2_test.dart`

- [ ] **Step 1: Write SM-2 tests first**

```dart
// test/features/vocab_hub/flashcards/sm2_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_coach_ai/features/vocab_hub/flashcards/sm2.dart';

void main() {
  group('Sm2', () {
    test('first correct (Good) sets interval=1 day', () {
      final next = Sm2.next(
          rating: Sm2Rating.good,
          interval: 0,
          easeFactor: 2.5,
          reviewCount: 0);
      expect(next.interval, 1);
      expect(next.reviewCount, 1);
      expect(next.easeFactor, closeTo(2.5, 0.001));
    });

    test('second correct (Good) interval becomes 6 days', () {
      final next = Sm2.next(
          rating: Sm2Rating.good,
          interval: 1,
          easeFactor: 2.5,
          reviewCount: 1);
      expect(next.interval, 6);
    });

    test('subsequent Good multiplies by ease factor', () {
      final next = Sm2.next(
          rating: Sm2Rating.good,
          interval: 6,
          easeFactor: 2.5,
          reviewCount: 2);
      expect(next.interval, 15); // 6 * 2.5 = 15
    });

    test('Hard resets to interval=1 and lowers ease factor', () {
      final next = Sm2.next(
          rating: Sm2Rating.hard,
          interval: 15,
          easeFactor: 2.5,
          reviewCount: 3);
      expect(next.interval, 1);
      expect(next.easeFactor, lessThan(2.5));
      expect(next.easeFactor, greaterThanOrEqualTo(Sm2.minEase));
    });

    test('Easy applies bonus multiplier', () {
      final next = Sm2.next(
          rating: Sm2Rating.easy,
          interval: 6,
          easeFactor: 2.5,
          reviewCount: 2);
      expect(next.interval, 19); // round(6 * 2.5 * 1.3)
      expect(next.easeFactor, greaterThanOrEqualTo(2.5));
    });

    test('ease factor is clamped at minimum 1.3', () {
      var ef = 1.35;
      for (var i = 0; i < 10; i++) {
        final r = Sm2.next(
            rating: Sm2Rating.hard, interval: 1, easeFactor: ef, reviewCount: 1);
        ef = r.easeFactor;
      }
      expect(ef, greaterThanOrEqualTo(Sm2.minEase));
    });
  });
}
```

- [ ] **Step 2: Run tests — expect them to fail**

Run: `flutter test test/features/vocab_hub/flashcards/sm2_test.dart`
Expected: all tests fail with `Sm2 not defined` or similar.

- [ ] **Step 3: Implement `Sm2`**

```dart
// lib/features/vocab_hub/flashcards/sm2.dart
enum Sm2Rating { hard, good, easy }

class Sm2Outcome {
  final int interval;
  final double easeFactor;
  final int reviewCount;
  final double nextReviewDate;

  const Sm2Outcome({
    required this.interval,
    required this.easeFactor,
    required this.reviewCount,
    required this.nextReviewDate,
  });
}

class Sm2 {
  Sm2._();

  static const double minEase = 1.3;
  static const double easyBonus = 1.3;

  /// Applies one SM-2 review. Quality mapping:
  /// - hard  = quality 2 (failed recall) → interval 1, ease -= 0.2
  /// - good  = quality 4 (correct)       → normal interval, ease unchanged
  /// - easy  = quality 5 (effortless)    → interval * easyBonus, ease += 0.1
  static Sm2Outcome next({
    required Sm2Rating rating,
    required int interval,
    required double easeFactor,
    required int reviewCount,
  }) {
    final ef = _nextEase(rating, easeFactor);
    int nextInterval;
    if (rating == Sm2Rating.hard) {
      nextInterval = 1;
    } else if (reviewCount == 0) {
      nextInterval = 1;
    } else if (reviewCount == 1) {
      nextInterval = 6;
    } else {
      nextInterval = (interval * ef).round();
    }
    if (rating == Sm2Rating.easy) {
      nextInterval = (nextInterval * easyBonus).round();
    }
    final next = DateTime.now()
        .add(Duration(days: nextInterval))
        .millisecondsSinceEpoch
        .toDouble();
    return Sm2Outcome(
      interval: nextInterval,
      easeFactor: ef,
      reviewCount: reviewCount + 1,
      nextReviewDate: next,
    );
  }

  static double _nextEase(Sm2Rating rating, double current) {
    final delta = switch (rating) {
      Sm2Rating.hard => -0.20,
      Sm2Rating.good => 0.0,
      Sm2Rating.easy => 0.15,
    };
    final next = current + delta;
    return next < minEase ? minEase : next;
  }
}
```

- [ ] **Step 4: Run tests — all green**

Run: `flutter test test/features/vocab_hub/flashcards/sm2_test.dart`
Expected: 6 passed.

- [ ] **Step 5: Commit**

```bash
git add lib/features/vocab_hub/flashcards/sm2.dart test/features/vocab_hub/flashcards/sm2_test.dart
git commit -m "feat(flashcards): SM-2 algorithm with tests"
```

### Task D2: FlashcardsProvider

**Files:**
- Create: `lib/features/vocab_hub/flashcards/flashcards_provider.dart`
- Modify: `lib/app.dart` — register provider.

- [ ] **Step 1: Build the provider**

```dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../features/my_library/models/saved_item.dart';
import '../../../features/my_library/providers/library_provider.dart';
import 'sm2.dart';

enum QueueMode { dueToday, practice }

class FlashcardsProvider extends ChangeNotifier {
  final LibraryProvider _library;

  FlashcardsProvider({required LibraryProvider library}) : _library = library;

  static const int maxDueCards = 20;
  static const int practiceBatchSize = 10;

  final List<SavedItem> _queue = [];
  int _index = 0;
  QueueMode _mode = QueueMode.dueToday;

  List<SavedItem> get queue => List.unmodifiable(_queue);
  int get currentIndex => _index;
  SavedItem? get currentCard =>
      _index < _queue.length ? _queue[_index] : null;
  QueueMode get mode => _mode;
  bool get hasMore => _index < _queue.length;

  int get dueCount => _library.allItems
      .where((i) => i.type == 'vocabulary' && i.isDueForReview)
      .length;

  void loadDueToday() {
    _mode = QueueMode.dueToday;
    final due = _library.allItems
        .where((i) => i.type == 'vocabulary' && i.isDueForReview)
        .toList();
    due.sort((a, b) =>
        (a.nextReviewDate ?? 0).compareTo(b.nextReviewDate ?? 0));
    _queue
      ..clear()
      ..addAll(due.take(maxDueCards));
    _index = 0;
    notifyListeners();
  }

  void addPracticeBatch() {
    _mode = QueueMode.practice;
    final rng = Random();
    final pool = _library.allItems
        .where((i) =>
            i.type == 'vocabulary' && !_queue.any((q) => q.id == i.id))
        .toList();
    pool.shuffle(rng);
    _queue.addAll(pool.take(practiceBatchSize));
    notifyListeners();
  }

  Future<void> rate(Sm2Rating rating) async {
    final card = currentCard;
    if (card == null) return;
    // Practice-mode cards don't update SM-2 state — only the due queue writes.
    if (_mode == QueueMode.dueToday) {
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
}
```

- [ ] **Step 2: Register in `app.dart`**

```dart
late final FlashcardsProvider _flashcardsProvider;
// initState:
_flashcardsProvider = FlashcardsProvider(library: _libraryProvider);

// providers:
ChangeNotifierProvider<FlashcardsProvider>.value(value: _flashcardsProvider),

// dispose:
_flashcardsProvider.dispose();
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/vocab_hub/flashcards/flashcards_provider.dart lib/app.dart
git commit -m "feat(flashcards): queue provider with due-today + practice modes"
```

### Task D3: Flashcard view + rating bar + tab wiring

**Files:**
- Create: `lib/features/vocab_hub/flashcards/flashcard_view.dart`
- Create: `lib/features/vocab_hub/flashcards/rating_bar.dart`
- Create: `lib/features/vocab_hub/tabs/flashcards_tab.dart`
- Modify: `lib/features/vocab_hub/screens/vocab_hub_screen.dart`

- [ ] **Step 1: Build `FlashcardView`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/my_library/models/saved_item.dart';
import '../../../shared/widgets/clay_card.dart';

class FlashcardView extends StatefulWidget {
  final SavedItem item;
  const FlashcardView({super.key, required this.item});

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  bool _revealed = false;

  @override
  void didUpdateWidget(covariant FlashcardView old) {
    super.didUpdateWidget(old);
    if (old.item.id != widget.item.id) {
      setState(() => _revealed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: ClayCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.item.correction,
                style: AppTypography.headingMedium, textAlign: TextAlign.center),
            if (widget.item.pronunciation != null &&
                widget.item.pronunciation!.isNotEmpty)
              Text(widget.item.pronunciation!,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.warmLight)),
            const SizedBox(height: AppSpacing.md),
            if (!_revealed)
              Text('Tap to reveal meaning',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.warmLight))
            else
              Column(children: [
                Text(widget.item.explanation ?? '',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center),
                if (widget.item.examples != null &&
                    widget.item.examples!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('"${widget.item.examples!.first['en']}"',
                      style: AppTypography.bodySmall),
                  Text(widget.item.examples!.first['vn'] ?? '',
                      style: AppTypography.caption),
                ],
              ]),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Build `RatingBar`**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'sm2.dart';

class RatingBar extends StatelessWidget {
  final ValueChanged<Sm2Rating> onRate;
  final int currentInterval;
  final double currentEase;
  final int reviewCount;

  const RatingBar({
    super.key,
    required this.onRate,
    required this.currentInterval,
    required this.currentEase,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _Btn(
        label: 'Hard',
        intervalDays: _preview(Sm2Rating.hard).interval,
        color: AppColors.coral,
        onTap: () => onRate(Sm2Rating.hard),
      )),
      const SizedBox(width: 8),
      Expanded(
          child: _Btn(
        label: 'Good',
        intervalDays: _preview(Sm2Rating.good).interval,
        color: AppColors.teal,
        onTap: () => onRate(Sm2Rating.good),
      )),
      const SizedBox(width: 8),
      Expanded(
          child: _Btn(
        label: 'Easy',
        intervalDays: _preview(Sm2Rating.easy).interval,
        color: AppColors.purple,
        onTap: () => onRate(Sm2Rating.easy),
      )),
    ]);
  }

  Sm2Outcome _preview(Sm2Rating r) => Sm2.next(
        rating: r,
        interval: currentInterval,
        easeFactor: currentEase,
        reviewCount: reviewCount,
      );
}

class _Btn extends StatelessWidget {
  final String label;
  final int intervalDays;
  final Color color;
  final VoidCallback onTap;
  const _Btn({
    required this.label,
    required this.intervalDays,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: AppTypography.titleSmall.copyWith(color: color)),
          Text(_formatInterval(intervalDays),
              style: AppTypography.caption.copyWith(color: color)),
        ]),
      );

  String _formatInterval(int days) =>
      days < 1 ? '<1d' : (days == 1 ? '1 day' : '$days days');
}
```

- [ ] **Step 3: Build `FlashcardsTab`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_button.dart';
import '../flashcards/flashcard_view.dart';
import '../flashcards/flashcards_provider.dart';
import '../flashcards/rating_bar.dart';

class FlashcardsTab extends StatefulWidget {
  const FlashcardsTab({super.key});

  @override
  State<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardsProvider>().loadDueToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardsProvider>();
    if (provider.queue.isEmpty) {
      return _EmptyState(onStartPractice: provider.addPracticeBatch);
    }
    if (!provider.hasMore) {
      return _DoneState(onStudyMore: provider.addPracticeBatch);
    }
    final card = provider.currentCard!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(children: [
        _ProgressBar(
            index: provider.currentIndex, total: provider.queue.length),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: Center(child: FlashcardView(item: card))),
        const SizedBox(height: AppSpacing.md),
        RatingBar(
          onRate: provider.rate,
          currentInterval: card.interval,
          currentEase: card.easeFactor,
          reviewCount: card.reviewCount,
        ),
      ]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int index;
  final int total;
  const _ProgressBar({required this.index, required this.total});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text('Card ${index + 1} of $total', style: AppTypography.caption),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (index + 1) / total,
          backgroundColor: AppColors.clayBorder,
          valueColor: const AlwaysStoppedAnimation(AppColors.coral),
        ),
      ]);
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStartPractice;
  const _EmptyState({required this.onStartPractice});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('No cards due today',
                style: AppTypography.headingSmall),
            const SizedBox(height: 8),
            Text('Practice 10 random saved words instead.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ClayButton(
                label: 'Practice 10 cards', onPressed: onStartPractice),
          ]),
        ),
      );
}

class _DoneState extends StatelessWidget {
  final VoidCallback onStudyMore;
  const _DoneState({required this.onStudyMore});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Done for today!', style: AppTypography.headingSmall),
            const SizedBox(height: 8),
            Text('Nicely done. Come back tomorrow for more.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ClayButton(label: 'Study 10 more', onPressed: onStudyMore),
          ]),
        ),
      );
}
```

- [ ] **Step 4: Wire into screen**

Replace `_ComingSoon('Flashcards')` with `const FlashcardsTab()` in `vocab_hub_screen.dart`.

- [ ] **Step 5: Smoke test**

- With 0 vocab → empty state shows "Practice 10 cards" (if library empty, button no-ops).
- With >0 vocab → first card renders. Tap card → meaning reveals. Tap Hard → interval=1 next day. Tap Good → interval grows per SM-2.
- Run through all cards → "Done for today! Study 10 more" appears.

- [ ] **Step 6: Commit**

```bash
git add lib/features/vocab_hub/flashcards/flashcard_view.dart \
        lib/features/vocab_hub/flashcards/rating_bar.dart \
        lib/features/vocab_hub/tabs/flashcards_tab.dart \
        lib/features/vocab_hub/screens/vocab_hub_screen.dart
git commit -m "feat(flashcards): review tab with SM-2 rating + due/practice queue"
```

---

## Phase E — Describe a Word (Reverse Dictionary)

### File Structure for Phase E

- Create: `lib/data/prompts/describe_word_prompt.dart` — VN description → list of EN candidates.
- Modify: `lib/data/gemini/schemas.dart` — add `reverseDictionary` schema.
- Modify: `lib/data/gemini/types.dart` — add `ReverseDictionaryResult`, `EnCandidate`.
- Modify: `lib/data/gemini/gemini_service.dart` — add `reverseDictionary` method.
- Create: `lib/features/vocab_hub/tabs/describe_tab.dart` — VN input + candidates list.
- Create: `lib/features/vocab_hub/providers/describe_word_provider.dart` — state for the reverse lookup.

### Task E1: Prompt + types + service method

**Files:**
- Create: `lib/data/prompts/describe_word_prompt.dart`
- Modify: `lib/data/gemini/schemas.dart`
- Modify: `lib/data/gemini/types.dart`
- Modify: `lib/data/gemini/gemini_service.dart`

- [ ] **Step 1: Write the prompt**

```dart
// lib/data/prompts/describe_word_prompt.dart
String buildReverseDictionaryPrompt(String vietnameseDescription) {
  return '''
You are an expert bilingual (Vietnamese → English) lexicographer.
The user is trying to recall an English word. They've described it in Vietnamese.

Description: "$vietnameseDescription"

Return 3 to 5 best-matching English candidates. For each candidate, provide:
- The English word or short phrase.
- Its Vietnamese translation.
- A one-sentence English definition.
- A confidence score from 0.0 to 1.0 (decimal).
- One natural example sentence (English).

Respond with ONLY a JSON object:
{
  "candidates": [
    {
      "en": "ephemeral",
      "vn": "ngắn ngủi",
      "definition": "Lasting for a very short time.",
      "confidence": 0.92,
      "example": "Childhood joys are ephemeral."
    }
  ]
}
''';
}
```

- [ ] **Step 2: Extend types**

Append to `lib/data/gemini/types.dart`:

```dart
class EnCandidate {
  final String en;
  final String vn;
  final String definition;
  final double confidence;
  final String example;

  const EnCandidate({
    required this.en,
    required this.vn,
    required this.definition,
    required this.confidence,
    required this.example,
  });

  factory EnCandidate.fromJson(Map<String, dynamic> json) => EnCandidate(
        en: json['en'] as String? ?? '',
        vn: json['vn'] as String? ?? '',
        definition: json['definition'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
        example: json['example'] as String? ?? '',
      );
}

class ReverseDictionaryResult {
  final List<EnCandidate> candidates;
  const ReverseDictionaryResult({required this.candidates});

  factory ReverseDictionaryResult.fromJson(Map<String, dynamic> json) =>
      ReverseDictionaryResult(
        candidates: (json['candidates'] as List<dynamic>?)
                ?.map((e) => EnCandidate.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
```

- [ ] **Step 3: Add schema + service method**

In `schemas.dart`, add:

```dart
static final Schema reverseDictionary = Schema.object(properties: {
  'candidates': Schema.array(
    items: Schema.object(properties: {
      'en': Schema.string(),
      'vn': Schema.string(),
      'definition': Schema.string(),
      'confidence': Schema.number(),
      'example': Schema.string(),
    }, requiredProperties: ['en', 'vn', 'definition', 'confidence', 'example']),
  ),
}, requiredProperties: ['candidates']);
```

In `gemini_service.dart`, after `generateWordAnalysis`, add:

```dart
Future<ReverseDictionaryResult> reverseDictionary(
    String vietnameseDescription) async {
  final prompt = buildReverseDictionaryPrompt(vietnameseDescription);
  final model = GeminiConfig.flash(
    temperature: 0.3,
    responseSchema: GeminiSchemas.reverseDictionary,
  );
  final raw = await _run(model, prompt);
  return ReverseDictionaryResult.fromJson(parseJsonObject(raw));
}
```

And add the import:

```dart
import '../prompts/describe_word_prompt.dart';
```

- [ ] **Step 4: Commit**

```bash
git add lib/data/prompts/describe_word_prompt.dart \
        lib/data/gemini/schemas.dart \
        lib/data/gemini/types.dart \
        lib/data/gemini/gemini_service.dart
git commit -m "feat(gemini): reverse dictionary (VN description → EN candidates)"
```

### Task E2: DescribeWordProvider + DescribeTab

**Files:**
- Create: `lib/features/vocab_hub/providers/describe_word_provider.dart`
- Create: `lib/features/vocab_hub/tabs/describe_tab.dart`
- Modify: `lib/app.dart`
- Modify: `lib/features/vocab_hub/screens/vocab_hub_screen.dart`

- [ ] **Step 1: Build the provider**

```dart
import 'package:flutter/foundation.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';

class DescribeWordProvider extends ChangeNotifier {
  final GeminiService _gemini;
  DescribeWordProvider({required GeminiService gemini}) : _gemini = gemini;

  bool _loading = false;
  String? _error;
  ReverseDictionaryResult? _result;

  bool get loading => _loading;
  String? get error => _error;
  ReverseDictionaryResult? get result => _result;

  Future<void> lookup(String vietnameseDescription) async {
    if (vietnameseDescription.trim().isEmpty) return;
    _loading = true;
    _error = null;
    _result = null;
    notifyListeners();
    try {
      final r = await _gemini
          .reverseDictionary(vietnameseDescription.trim())
          .timeout(const Duration(seconds: 30));
      _result = r;
    } catch (e) {
      _error = 'Lookup failed: $e';
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
```

- [ ] **Step 2: Build `DescribeTab`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';
import '../providers/describe_word_provider.dart';

class DescribeTab extends StatefulWidget {
  const DescribeTab({super.key});

  @override
  State<DescribeTab> createState() => _DescribeTabState();
}

class _DescribeTabState extends State<DescribeTab> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DescribeWordProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mô tả từ bạn đang tìm (bằng tiếng Việt)',
              style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: cảm giác buồn nhẹ khi nhớ chuyện cũ',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClayButton(
            label: provider.loading ? 'Đang tìm...' : 'Tìm từ',
            onPressed: provider.loading
                ? null
                : () => provider.lookup(_controller.text),
          ),
          const SizedBox(height: AppSpacing.md),
          if (provider.error != null)
            Text(provider.error!,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.coral)),
          if (provider.result != null)
            ...provider.result!.candidates
                .map((c) => _CandidateTile(candidate: c)),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final EnCandidate candidate;
  const _CandidateTile({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final confidencePct = (candidate.confidence * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClayCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(candidate.en,
                        style: AppTypography.headingSmall)),
                _ConfidenceBadge(pct: confidencePct),
              ],
            ),
            Text(candidate.vn,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.warmLight)),
            const SizedBox(height: 8),
            Text(candidate.definition, style: AppTypography.bodySmall),
            const SizedBox(height: 4),
            Text('"${candidate.example}"',
                style: AppTypography.caption
                    .copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final int pct;
  const _ConfidenceBadge({required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = pct >= 80
        ? AppColors.teal
        : pct >= 50
            ? AppColors.gold
            : AppColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$pct%',
          style: AppTypography.caption.copyWith(color: color)),
    );
  }
}
```

- [ ] **Step 3: Register provider in `app.dart`**

```dart
late final DescribeWordProvider _describeWordProvider;
_describeWordProvider = DescribeWordProvider(gemini: _geminiService);

// providers:
ChangeNotifierProvider<DescribeWordProvider>.value(
    value: _describeWordProvider),
// dispose:
_describeWordProvider.dispose();
```

- [ ] **Step 4: Wire tab**

Replace `_ComingSoon('Describe')` with `const DescribeTab()`.

- [ ] **Step 5: Smoke test**

- Type: "cảm giác buồn nhẹ khi nhớ chuyện cũ" → receive 3-5 English candidates with confidence badges (nostalgic, wistful, bittersweet, melancholic, …).
- Empty input → Tìm từ button no-ops.
- Kill wifi → shows error message cleanly.

- [ ] **Step 6: Commit**

```bash
git add lib/features/vocab_hub/providers/describe_word_provider.dart \
        lib/features/vocab_hub/tabs/describe_tab.dart \
        lib/app.dart \
        lib/features/vocab_hub/screens/vocab_hub_screen.dart
git commit -m "feat(vocab-hub): describe-a-word reverse dictionary tab"
```

---

## Phase F — Overview Tab Wiring (close the loop)

### Task F1: Reuse MyLibraryScreen body as the Overview tab

**Files:**
- Modify: `lib/features/my_library/screens/my_library_screen.dart` — extract the body widget into a reusable widget, keep `MyLibraryScreen` as a thin wrapper.
- Modify: `lib/features/vocab_hub/screens/vocab_hub_screen.dart` — use the body widget as the Overview tab.

- [ ] **Step 1: Extract `MyLibraryBody` from `MyLibraryScreen`**

Keep `MyLibraryScreen` as-is (it's still reachable via `/my-library`), but introduce:

```dart
// At bottom of my_library_screen.dart
class MyLibraryBody extends StatefulWidget {
  const MyLibraryBody({super.key});

  @override
  State<MyLibraryBody> createState() => _MyLibraryBodyState();
}
```

Move all stateful search/filter/list logic from `_MyLibraryScreenState` into `_MyLibraryBodyState`. Have `_MyLibraryScreenState.build` return `Scaffold(body: const MyLibraryBody())`.

(If the screen is > 800 LOC and the refactor is risky, introduce `MyLibraryBody` as a wrapper that composes the existing `_body()` method — whatever minimises diff.)

- [ ] **Step 2: Use it in Overview tab**

In `vocab_hub_screen.dart`:

```dart
import '../../my_library/screens/my_library_screen.dart';

// replace the first _ComingSoon:
const MyLibraryBody(),
```

- [ ] **Step 3: Smoke test**

- Vocab Hub → Overview → same item list + filters as old /my-library.
- /my-library (old route) still works (reached from Insight tab later).

- [ ] **Step 4: Fix "Practice" button stub**

In `MyLibraryBody`, find the `SnackBar('Practice mode coming soon')` and replace the onPressed with:

```dart
DefaultTabController.of(context).animateTo(3); // jump to Flashcards tab
```

If `DefaultTabController.of` returns null (old route), fall back to `context.push('/vocab-hub')`.

- [ ] **Step 5: Commit**

```bash
git add lib/features/my_library/screens/my_library_screen.dart \
        lib/features/vocab_hub/screens/vocab_hub_screen.dart
git commit -m "feat(vocab-hub): overview tab reuses MyLibrary body + wire Practice button"
```

---

## Phase G — Final Verification

### Task G1: End-to-end verification

- [ ] **Step 1: Static checks**

Run: `flutter analyze`
Expected: zero new errors or warnings.

- [ ] **Step 2: Unit tests**

Run: `flutter test`
Expected: all green (SM-2 tests + any other existing tests).

- [ ] **Step 3: Manual smoke test matrix**

On a free test account:
1. Save 5 words from Scenario chat → 6th save shows SnackBar + Upgrade button.
2. Home → Vocab Hub → Overview tab → list renders with filters + search working.
3. Word Analysis tab → type "ephemeral" → full card renders.
4. Mind Map tab → shows Pro upgrade card. Tap Upgrade → `/subscription`.
5. Flashcards tab → first load shows empty state ("No cards due today"). Tap Practice 10 cards → 10 random cards queued.
6. Describe tab → type Vietnamese description → 3-5 EN candidates with confidence badges.

On a pro test account:
7. Mind Map tab → enter "Travel" → canvas renders with pan/zoom. Tap a category → expands.
8. Flashcards tab due-today → rate Good → interval grows per SM-2 → item disappears from today's queue.

- [ ] **Step 4: Firestore check**

Verify documents exist:
- `users/{uid}/savedItems/{id}` → includes `pronunciation`, `synonyms`, `contextUsage` on items saved after Phase A.
- `users/{uid}/mindMaps/{mapId}` → created after Phase C mind map generation.
- `users/{uid}/usage/{YYYY-MM-DD}.dictionaryCount` → increments on each save.

- [ ] **Step 5: Commit any final docs**

```bash
git add docs/superpowers/plans/2026-04-20-vocab-hub-mvp.md
git commit -m "docs(vocab-hub): plan for MVP implementation"
```

---

## Self-Review Checklist

Each phase must produce a working, testable slice independently:

- [x] Phase A — quota + SM-2 fix + richer dictionary payload (doesn't require any Vocab Hub UI)
- [x] Phase B — word analysis tab stands alone once /vocab-hub route exists
- [x] Phase C — mind map tab works for pro users, pro gate for free users
- [x] Phase D — flashcards work against existing library data
- [x] Phase E — describe-word is independent
- [x] Phase F — ties Overview tab to the existing MyLibrary body
- [x] Phase G — E2E verification

**Spec coverage from audit:**
- D1 fix (richer dictionary prompt) → Task A2
- D2/D4 (save enriched fields) → Tasks A1, A3
- D3 (quota enforcement) → Task A4
- D6 (backfill retry storm) → Task A3 Step 2
- O4 (SM-2 nextReviewDate bug) → Task A1 Step 2
- Word Analysis UI → Phase B
- Mind Map (Pro-only, CustomPainter, persistence) → Phase C
- Flashcards + SM-2 (Variant C queue + 3-button Variant B) → Phase D
- Describe-word (reverse dictionary) → Phase E
- Overview tab wiring → Phase F

**Deferred (out of scope, user confirmed):**
- BottomNav 4→5 tab restructure (Home/Insight/AI Agent/Notifications/Profile)
- AI Agent tab
- Notifications tab
- Compare vocabulary feature
- Firebase Storage migration for illustrations (keep base64 data URI for this MVP; document as tech debt)

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-20-vocab-hub-mvp.md`. Two execution options:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between phases
2. **Inline Execution** — execute tasks in this session using executing-plans

Which approach?
