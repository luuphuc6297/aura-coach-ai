import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_dialog.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../home/providers/home_provider.dart';
import '../models/saved_item.dart';
import '../providers/library_provider.dart';

class MyLibraryScreen extends StatefulWidget {
  /// `true` when the screen is hosted inside the HomeScreen tab bar — hides
  /// the AppBar back button and renders without its own Scaffold so it docks
  /// cleanly above the shared bottom nav.
  final bool embedded;

  const MyLibraryScreen({super.key, this.embedded = false});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  final _searchController = TextEditingController();
  final _tts = TtsService();

  static const _typeFilters = ['all', 'grammar', 'vocabulary'];
  static const _typeLabels = {
    'all': 'All',
    'grammar': 'Grammar',
    'vocabulary': 'Vocabulary'
  };

  static const Map<String, Color> _typeAccents = {
    'all': AppColors.teal,
    'grammar': AppColors.coral,
    'vocabulary': AppColors.purple,
  };

  static const _posFilters = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'phrasal verb',
    'idiom'
  ];
  static const _posLabels = {
    'noun': 'Noun',
    'verb': 'Verb',
    'adjective': 'Adjective',
    'adverb': 'Adverb',
    'phrasal verb': 'Phrasal Verb',
    'idiom': 'Idiom',
  };

  static const Map<String, Color> _posAccents = {
    'noun': AppColors.teal,
    'verb': AppColors.purple,
    'adjective': AppColors.gold,
    'adverb': AppColors.coral,
    'phrasal verb': AppColors.formalTone,
    'idiom': AppColors.neutralTone,
  };

  static const List<Color> _categoryPalette = [
    AppColors.teal,
    AppColors.gold,
    AppColors.purple,
    AppColors.coral,
    AppColors.formalTone,
    AppColors.neutralTone,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Consumer<LibraryProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            if (widget.embedded) _buildEmbeddedHeader(),
            _buildSearchBar(provider),
            _buildTypeFilters(provider),
            if (provider.filterType == 'vocabulary') _buildPosFilters(provider),
            _buildCategoryFilters(provider),
            _buildStatsRow(provider),
            Expanded(child: _buildBody(provider)),
          ],
        );
      },
    );

    if (widget.embedded) {
      // Hosted inside HomeScreen tabs — host already provides the Scaffold,
      // SafeArea, and BottomNavBar.
      return body;
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: ClayBackButton(),
        ),
        title: Text(
          'My Learning Library',
          style: AppTypography.title,
        ),
        centerTitle: false,
      ),
      body: body,
    );
  }

  Widget _buildEmbeddedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'My Learning Library',
          style: AppTypography.h1,
        ),
      ),
    );
  }

  Widget _buildSearchBar(LibraryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgBorder,
          boxShadow: AppShadows.clay,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: provider.setSearch,
          style: AppTypography.input,
          cursorColor: AppColors.teal,
          decoration: InputDecoration(
            hintText: 'Search saved items...',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.warmMuted,
              size: 22,
            ),
            suffixIcon: provider.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.warmMuted,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearch('');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilters(LibraryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        children: _typeFilters.map((type) {
          final isSelected = provider.filterType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: _typeLabels[type]!,
              isSelected: isSelected,
              accentColor: _typeAccents[type] ?? AppColors.teal,
              onTap: () => provider.setFilterType(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPosFilters(LibraryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _posFilters.length,
          itemBuilder: (context, index) {
            final pos = _posFilters[index];
            final isSelected = provider.filterPos == pos;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: _posLabels[pos]!,
                isSelected: isSelected,
                accentColor: _posAccents[pos] ?? AppColors.purple,
                compact: true,
                onTap: () => provider.setFilterPos(isSelected ? 'all' : pos),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(LibraryProvider provider) {
    final cats = provider.categories;
    if (cats.isEmpty) return const SizedBox.shrink();
    final allCats = ['all', ...cats];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: allCats.length,
          itemBuilder: (context, index) {
            final cat = allCats[index];
            final isSelected = provider.filterCategory == cat;
            final label = cat == 'all' ? 'All Categories' : cat;
            final accent = cat == 'all'
                ? AppColors.teal
                : _categoryPalette[(index - 1).abs() % _categoryPalette.length];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: label,
                isSelected: isSelected,
                accentColor: accent,
                compact: true,
                onTap: () => provider.setFilterCategory(cat),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(LibraryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            '${provider.totalCount} items',
            style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(width: 4),
          Text('·',
              style:
                  AppTypography.caption.copyWith(color: AppColors.warmLight)),
          const SizedBox(width: 4),
          Text(
            '${provider.dueCount} due',
            style: AppTypography.caption.copyWith(color: AppColors.gold),
          ),
          const SizedBox(width: 4),
          Text('·',
              style:
                  AppTypography.caption.copyWith(color: AppColors.warmLight)),
          const SizedBox(width: 4),
          Text(
            '${provider.categoryCount} categories',
            style: AppTypography.caption.copyWith(color: AppColors.warmMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LibraryProvider provider) {
    return AnimatedSwitcher(
      duration: AppAnimations.durationNormal,
      child: _buildBodyContent(provider),
    );
  }

  Widget _buildBodyContent(LibraryProvider provider) {
    if (provider.isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(iconId: AppIcons.error, size: 40),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style:
                    AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
              ),
              const SizedBox(height: 16),
              ClayPressable(
                onTap: () => provider.loadItems(),
                scaleDown: 0.95,
                builder: (context, isPressed) {
                  return Text(
                    'Try Again',
                    style:
                        AppTypography.labelMd.copyWith(color: AppColors.teal),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    final items = provider.items;
    if (items.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(iconId: AppIcons.myLearning, size: 48),
              const SizedBox(height: 16),
              Text(
                'Your library is empty',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              Text(
                'Save words and grammar corrections during practice to build your personal learning library.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('content'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SavedItemCard(
            item: items[index],
            onDelete: () => provider.deleteItem(items[index].id),
            onListen: () => _tts.speakEnglish(items[index].correction),
          ),
        );
      },
    );
  }
}

class _SavedItemCard extends StatefulWidget {
  final SavedItem item;
  final VoidCallback onDelete;
  final VoidCallback onListen;

  const _SavedItemCard({
    required this.item,
    required this.onDelete,
    required this.onListen,
  });

  @override
  State<_SavedItemCard> createState() => _SavedItemCardState();
}

class _SavedItemCardState extends State<_SavedItemCard> {
  bool _explanationExpanded = false;

  SavedItem get item => widget.item;
  VoidCallback get onDelete => widget.onDelete;
  VoidCallback get onListen => widget.onListen;

  @override
  Widget build(BuildContext context) {
    final isGrammar = item.type == 'grammar';
    final badgeColor = isGrammar ? AppColors.error : AppColors.formalTone;
    final badgeLabel = isGrammar ? 'GRAMMAR' : 'VOCAB';
    final isDue = item.isDueForReview;
    final daysUntil = item.daysUntilReview;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _typeBadge(badgeLabel, badgeColor),
                if (item.partOfSpeech != null) ...[
                  const SizedBox(width: 6),
                  _posBadge(item.partOfSpeech!),
                ],
                const Spacer(),
                _reviewBadge(isDue, daysUntil),
              ],
            ),
            if (item.type == 'vocabulary') ...[
              const SizedBox(height: 12),
              _VocabularyIllustration(item: item),
            ],
            const SizedBox(height: 12),
            if (item.original != item.correction) ...[
              Text(
                item.original,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.error,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              item.correction,
              style: AppTypography.sectionTitle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.warmDark,
                height: 1.25,
              ),
            ),
            if (item.explanation != null) ...[
              const SizedBox(height: 8),
              Text(
                item.explanation!,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 13,
                  height: 1.45,
                ),
                maxLines: _explanationExpanded ? null : 3,
                overflow: _explanationExpanded ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              ClayPressable(
                onTap: () => setState(() {
                  _explanationExpanded = !_explanationExpanded;
                }),
                scaleDown: 0.95,
                builder: (context, isPressed) {
                  return Text(
                    _explanationExpanded ? 'Show less' : 'Show more',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ] else if (item.type == 'vocabulary') ...[
              const SizedBox(height: 8),
              Text(
                'Loading explanation...',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (item.examples != null && item.examples!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Examples',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              ...item.examples!.take(2).map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.warmLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex['en'] ?? '',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.warmDark,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              if (ex['vn'] != null && ex['vn']!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    ex['vn']!,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.warmLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: AppColors.clayBorder.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _masteryIndicator(item.masteryScore),
                const Spacer(),
                ClayPressable(
                  onTap: onListen,
                  scaleDown: 0.85,
                  builder: (context, isPressed) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.clayBeige,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.clayBorder, width: 1.5),
                      ),
                      child: const Center(
                        child: AppIcon(
                          iconId: AppIcons.listen,
                          size: 18,
                          color: AppColors.warmDark,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                ClayPressable(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Practice mode coming soon',
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.warmDark),
                        ),
                        backgroundColor: AppColors.teal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  scaleDown: 0.95,
                  builder: (context, isPressed) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.teal,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(
                            iconId: AppIcons.practice,
                            size: 14,
                            color: AppColors.warmDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Practice',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.warmDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                ClayPressable(
                  onTap: () => _confirmDelete(context),
                  scaleDown: 0.85,
                  builder: (context, isPressed) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: AppIcon(
                          iconId: AppIcons.delete,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showClayDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.clayWhite,
        title: Text('Remove Item?', style: AppTypography.title),
        content: Text(
          'This will permanently remove "${item.correction}" from your library.',
          style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.warmMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _posBadge(String pos) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: AppColors.purple.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        pos,
        style: AppTypography.caption.copyWith(
          color: AppColors.purple,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _reviewBadge(bool isDue, int daysUntil) {
    final color = isDue ? AppColors.gold : AppColors.success;
    final text = isDue ? 'Due for review' : 'Review in $daysUntil days';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _masteryIndicator(int score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < (score / 20).ceil();
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.teal : AppColors.clayBorder,
          ),
        );
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;
  final bool compact;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return AnimatedContainer(
          duration: AppAnimations.durationFast,
          curve: AppAnimations.easeClay,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.22)
                : AppColors.clayWhite,
            borderRadius: AppRadius.fullBorder,
            border: Border.all(
              color: isSelected ? accentColor : AppColors.clayBorder,
              width: 2,
            ),
            boxShadow: isSelected
                ? AppShadows.colored(accentColor, alpha: 0.45)
                : AppShadows.card,
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.warmDark,
              fontSize: compact ? 12 : 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

/// Illustration surface for vocabulary items. Three states:
///   1. Has `imageUrl` → render the base64 PNG.
///   2. Provider is currently generating → animated shimmer placeholder.
///   3. No image yet → neutral background with a tappable "Generate" CTA.
///      Tapping checks the user's subscription tier; free users are shown a
///      paywall hint, paid tiers trigger generation.
class _VocabularyIllustration extends StatelessWidget {
  final SavedItem item;

  const _VocabularyIllustration({required this.item});

  static const _paidTiers = {'pro', 'premium'};

  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryProvider, HomeProvider>(
      builder: (context, library, home, _) {
        final bytes = _decodeDataUri(item.imageUrl);
        final isGenerating = library.isGeneratingImage(item.id);
        final tier = home.userProfile?.tier ?? 'free';
        final isPaid = _paidTiers.contains(tier);

        return ClipRRect(
          borderRadius: AppRadius.mdBorder,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.clayBeige,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: AppColors.clayBorder, width: 1.5),
            ),
            child: bytes != null
                ? Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) =>
                        _generatePlaceholder(context, library, isPaid),
                  )
                : isGenerating
                    ? _shimmerPlaceholder()
                    : _generatePlaceholder(context, library, isPaid),
          ),
        );
      },
    );
  }

  Widget _shimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.clayBeige,
      highlightColor: AppColors.clayWhite,
      period: const Duration(milliseconds: 1400),
      child: Container(
        color: AppColors.clayBeige,
        child: Center(
          child: AppIcon(
            iconId: AppIcons.vocabulary,
            size: 32,
            color: AppColors.warmLight.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _generatePlaceholder(
    BuildContext context,
    LibraryProvider library,
    bool isPaid,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.clayBeige,
                AppColors.clayBeige.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Center(
            child: AppIcon(
              iconId: AppIcons.vocabulary,
              size: 32,
              color: AppColors.warmLight.withValues(alpha: 0.7),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: _GenerateCtaButton(
            isPaid: isPaid,
            onTap: () => _handleGenerate(context, library, isPaid),
          ),
        ),
      ],
    );
  }

  void _handleGenerate(
    BuildContext context,
    LibraryProvider library,
    bool isPaid,
  ) {
    if (!isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'AI illustrations are part of the Pro plan. Upgrade to unlock.'),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
      );
      return;
    }
    library.generateIllustrationForItem(item.id);
  }

  Uint8List? _decodeDataUri(String? value) {
    if (value == null || value.isEmpty) return null;
    final comma = value.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(value.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }
}

class _GenerateCtaButton extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onTap;

  const _GenerateCtaButton({required this.isPaid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.teal : AppColors.gold;
    final label = isPaid ? 'Generate' : 'Generate (Pro)';
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.clayWhite,
            borderRadius: AppRadius.fullBorder,
            border: Border.all(color: color, width: 1.5),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPaid
                    ? Icons.auto_awesome_rounded
                    : Icons.lock_outline_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
