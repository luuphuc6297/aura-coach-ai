import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../../home/providers/home_provider.dart';
import '../data/grammar_catalog.dart';
import '../models/grammar_progress.dart';
import '../models/grammar_topic.dart';
import '../providers/grammar_provider.dart';

/// Grammar Coach Hub. Lists all 55 catalog topics with mastery rings,
/// filtered by CEFR level + category + search. Lays the groundwork for
/// Topic Detail (`/grammar/:topicId`) and Practice navigation.
///
/// Provider lifecycle:
/// - [GrammarProvider.configure] runs every build (idempotent) so theme
///   shifts and profile-level updates re-flow.
/// - [GrammarProvider.initFilterIfNeeded] defaults the level filter to
///   the user's profile CEFR on first mount.
/// - [GrammarProvider.hydrateProgress] runs once after the first build
///   via post-frame callback. Subsequent re-mounts hit the cache.
class GrammarHubScreen extends StatefulWidget {
  const GrammarHubScreen({super.key});

  @override
  State<GrammarHubScreen> createState() => _GrammarHubScreenState();
}

class _GrammarHubScreenState extends State<GrammarHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<HomeProvider>().userProfile;
    final grammar = context.watch<GrammarProvider>();
    final loc = context.loc;

    if (profile != null) {
      grammar.configure(
        uid: profile.uid,
        userLevel: CefrLevelLabel.fromProficiencyId(profile.proficiencyLevel),
      );
    }
    grammar.initFilterIfNeeded();

    // First-build hydrate kick-off. Idempotent inside the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      grammar.hydrateProgress();
    });

    final topics = grammar.filteredTopics;

    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.grammarHubTitle,
              style: AppTypography.title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              loc.grammarHubMasteredCounter(
                grammar.masteredCount,
                GrammarCatalog.totalCount,
              ),
              style: AppTypography.caption.copyWith(
                color: context.clay.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: context.clay.text,
            ),
            onPressed: () => setState(() {
              _searchOpen = !_searchOpen;
              if (!_searchOpen) {
                _searchController.clear();
                grammar.setSearch('');
              }
            }),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          if (_searchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: ClayTextInput(
                controller: _searchController,
                hintText: loc.grammarHubSearchHint,
                prefixIcon: Icons.search_rounded,
                onChanged: grammar.setSearch,
              ),
            ),
          _LevelFilterRow(
            current: grammar.filterLevel,
            onSelect: grammar.setFilterLevel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CategoryFilterRow(
            current: grammar.filterCategory,
            onSelect: grammar.setFilterCategory,
          ),
          if (topics.isEmpty)
            Expanded(child: _EmptyState())
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                itemCount: topics.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.smd),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.smd),
                      child: _GrammarHeroBanner(),
                    );
                  }
                  final topic = topics[index - 1];
                  return _GrammarTopicCard(
                    topic: topic,
                    progress: grammar.progressFor(topic.id),
                    onTap: () => context.push('/grammar/${topic.id}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

}

// ── hero banner ─────────────────────────────────────────────────────────

class _GrammarHeroBanner extends StatelessWidget {
  const _GrammarHeroBanner();

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [AppColors.gold, AppColors.goldDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.warmDark, width: 2),
        boxShadow: [
          const BoxShadow(
            color: AppColors.warmDark,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.warmDark,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.grammarHubHeroTitle,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.warmDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc.grammarHubHeroTagline,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmDark.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── level filter row ────────────────────────────────────────────────────

class _LevelFilterRow extends StatelessWidget {
  final CefrLevel? current;
  final ValueChanged<CefrLevel?> onSelect;

  const _LevelFilterRow({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    // Horizontal scroll matches the system pattern used by My Library
    // and Conversation History filter rows. Trailing padding gives the
    // active chip's drop-shadow room so it's not clipped at the right
    // edge when C2 is selected.
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg + 4,
          0,
        ),
        children: [
          _LevelChip(
            label: loc.grammarHubFilterAll,
            isActive: current == null,
            onTap: () => onSelect(null),
          ),
          for (final level in CefrLevel.values) ...[
            const SizedBox(width: AppSpacing.xs),
            _LevelChip(
              label: level.label,
              isActive: current == level,
              onTap: () => onSelect(level),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LevelChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.94,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.gold.withValues(alpha: 0.32)
              : context.clay.surface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isActive ? AppColors.goldDeep : context.clay.border,
            width: isActive ? 2 : 1.5,
          ),
          boxShadow: isActive
              ? [const BoxShadow(color: AppColors.goldDeep, offset: Offset(2, 2))]
              : AppShadows.card(context),
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isActive ? AppColors.goldDark : context.clay.text,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── category filter row ─────────────────────────────────────────────────

class _CategoryFilterRow extends StatelessWidget {
  final GrammarCategory? current;
  final ValueChanged<GrammarCategory?> onSelect;

  const _CategoryFilterRow({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg + 4,
          0,
        ),
        children: [
          _CategoryChip(
            label: context.loc.grammarHubCategoryAll,
            isActive: current == null,
            onTap: () => onSelect(null),
          ),
          for (final cat in GrammarCategory.values) ...[
            const SizedBox(width: AppSpacing.xs),
            _CategoryChip(
              label: _categoryLabel(context, cat),
              isActive: current == cat,
              onTap: () => onSelect(cat),
            ),
          ],
        ],
      ),
    );
  }

  String _categoryLabel(BuildContext context, GrammarCategory cat) {
    final loc = context.loc;
    return switch (cat) {
      GrammarCategory.tense => loc.grammarHubCategoryTense,
      GrammarCategory.modal => loc.grammarHubCategoryModal,
      GrammarCategory.conditional => loc.grammarHubCategoryConditional,
      GrammarCategory.passive => loc.grammarHubCategoryPassive,
      GrammarCategory.reported => loc.grammarHubCategoryReported,
      GrammarCategory.articleQuantifier =>
        loc.grammarHubCategoryArticleQuantifier,
      GrammarCategory.clause => loc.grammarHubCategoryClause,
      GrammarCategory.comparison => loc.grammarHubCategoryComparison,
      GrammarCategory.linkingInversion =>
        loc.grammarHubCategoryLinkingInversion,
      GrammarCategory.other => loc.grammarHubCategoryOther,
    };
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? context.clay.text : context.clay.surface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isActive ? context.clay.text : context.clay.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isActive
                ? context.clay.background
                : context.clay.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ── topic card ──────────────────────────────────────────────────────────

class _GrammarTopicCard extends StatelessWidget {
  final GrammarTopic topic;
  final UserGrammarProgress progress;
  final VoidCallback onTap;

  const _GrammarTopicCard({
    required this.topic,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.98,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.mdd),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: context.clay.border, width: 1.5),
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          children: [
            _GrammarMasteryRing(progress: progress),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _TopicBody(topic: topic, progress: progress)),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: context.clay.textFaint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicBody extends StatelessWidget {
  final GrammarTopic topic;
  final UserGrammarProgress progress;

  const _TopicBody({required this.topic, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          topic.title,
          style: AppTypography.labelLg.copyWith(
            color: context.clay.text,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _Pill(
              label: topic.level.label,
              color: AppColors.gold,
              filled: 0.22,
            ),
            _Pill(
              label: _categoryShort(context, topic.category),
              color: context.clay.textMuted,
              filled: 0,
              border: context.clay.border,
            ),
            _StatusPill(label: progress.masteryLabel),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _metaLine(context, progress),
          style: AppTypography.caption.copyWith(
            color: context.clay.textMuted,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _metaLine(BuildContext context, UserGrammarProgress p) {
    final loc = context.loc;
    if (p.attemptCount == 0) return loc.grammarHubTopicMetaNew;
    final accuracyPct = (p.accuracy * 100).round();
    return loc.grammarHubTopicMetaProgress(p.attemptCount, accuracyPct);
  }

  String _categoryShort(BuildContext context, GrammarCategory cat) {
    final loc = context.loc;
    return switch (cat) {
      GrammarCategory.tense => loc.grammarHubCategoryTense,
      GrammarCategory.modal => loc.grammarHubCategoryModal,
      GrammarCategory.conditional => loc.grammarHubCategoryConditional,
      GrammarCategory.passive => loc.grammarHubCategoryPassive,
      GrammarCategory.reported => loc.grammarHubCategoryReported,
      GrammarCategory.articleQuantifier =>
        loc.grammarHubCategoryArticleQuantifier,
      GrammarCategory.clause => loc.grammarHubCategoryClause,
      GrammarCategory.comparison => loc.grammarHubCategoryComparison,
      GrammarCategory.linkingInversion =>
        loc.grammarHubCategoryLinkingInversion,
      GrammarCategory.other => loc.grammarHubCategoryOther,
    };
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final double filled;
  final Color? border;

  const _Pill({
    required this.label,
    required this.color,
    required this.filled,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color:
            filled > 0 ? color.withValues(alpha: filled) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: border ?? color.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          // When `filled` is set we tint the chip with [color] at low alpha;
          // for legibility we darken the text using [color]'s "deep"
          // sibling when callers pass `AppColors.gold`. For other colors
          // (e.g. neutral muted) we keep the original.
          color: filled > 0 && color == AppColors.gold
              ? AppColors.goldDark
              : color,
          fontWeight: FontWeight.w800,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final GrammarMasteryLabel label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final (text, color) = switch (label) {
      GrammarMasteryLabel.notStarted => (
        loc.grammarHubMasteryNotStarted,
        context.clay.textMuted
      ),
      GrammarMasteryLabel.learning => (
        loc.grammarHubMasteryLearning,
        AppColors.goldDark
      ),
      GrammarMasteryLabel.mastered => (
        loc.grammarHubMasteryMastered,
        AppColors.success
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }
}

// ── mastery ring ────────────────────────────────────────────────────────

class _GrammarMasteryRing extends StatelessWidget {
  static const double _size = 42;
  static const double _stroke = 3;

  final UserGrammarProgress progress;

  const _GrammarMasteryRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress.masteryFraction * 100).round();
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(_size),
            painter: _MasteryRingPainter(
              fraction: progress.masteryFraction,
              backgroundColor: context.clay.border,
              foregroundColor: AppColors.goldDeep,
              stroke: _stroke,
            ),
          ),
          Text(
            '$pct%',
            style: AppTypography.caption.copyWith(
              color: context.clay.text,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  final double fraction;
  final Color backgroundColor;
  final Color foregroundColor;
  final double stroke;

  _MasteryRingPainter({
    required this.fraction,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = backgroundColor;
    canvas.drawCircle(center, radius, bg);

    if (fraction <= 0) return;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = foregroundColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      fraction.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _MasteryRingPainter old) =>
      old.fraction != fraction ||
      old.backgroundColor != backgroundColor ||
      old.foregroundColor != foregroundColor ||
      old.stroke != stroke;
}

// ── empty state ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: context.clay.textFaint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              loc.grammarHubEmptyTitle,
              style: AppTypography.title.copyWith(
                color: context.clay.text,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              loc.grammarHubEmptyBody,
              style: AppTypography.bodySm.copyWith(
                color: context.clay.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
