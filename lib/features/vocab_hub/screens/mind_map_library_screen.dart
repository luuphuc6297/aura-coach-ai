import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../../../features/home/providers/home_provider.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../providers/mind_map_provider.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// "My Mind Maps" list screen — every saved map for the current user, ordered
/// most recently updated first. Renders a clay-card per map with topic,
/// node count, depth, and updated-at. Tap loads the map back into
/// [MindMapProvider] and pops to the canvas; swipe-left dismisses with an
/// undo snackbar.
///
/// Visual language strictly follows the Clay design mockup (Screen 4): warm
/// cream background, clay-bordered cards with `3px 3px 0` shadow on the
/// most-recent map, lighter `2px 2px 0` shadow on the rest, pill metadata,
/// coral "+ New" affordance in the header.
class MindMapLibraryScreen extends StatefulWidget {
  const MindMapLibraryScreen({super.key});

  @override
  State<MindMapLibraryScreen> createState() => _MindMapLibraryScreenState();
}

class _MindMapLibraryScreenState extends State<MindMapLibraryScreen> {
  late Future<List<MindMapSummary>> _mapsFuture;

  @override
  void initState() {
    super.initState();
    // Direct assignment — `initState` runs before the first build, so a
    // setState here is unnecessary (and risky: assigning a Future inside an
    // arrow setState makes the closure itself return a Future, which Flutter
    // flags as an asynchronous-callback violation).
    _mapsFuture = _loadMaps();
  }

  Future<List<MindMapSummary>> _loadMaps() {
    final provider = context.read<MindMapProvider>();
    final profile = context.read<HomeProvider>().userProfile;
    if (profile != null) {
      provider.configure(
        uid: profile.uid,
        level: CefrLevel.fromProficiencyId(profile.proficiencyLevel),
      );
    }
    return provider.listMaps();
  }

  /// Re-runs the listMaps query and rebuilds the future-builder so the list
  /// re-renders with the latest Firestore state. Wrapped in a block-body
  /// setState (not an arrow) on purpose — see [initState].
  void _refresh() {
    setState(() {
      _mapsFuture = _loadMaps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VocabHubScaffold(
      title: context.loc.vocabMindMapMyMapsTitle,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: _NewMapButton(onTap: _onNewMap),
        ),
      ],
      body: FutureBuilder<List<MindMapSummary>>(
        future: _mapsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.coral),
              ),
            );
          }
          final maps = snapshot.data ?? const <MindMapSummary>[];
          if (maps.isEmpty) return const _EmptyState();
          return _MapList(maps: maps, onTap: _onOpenMap, onDelete: _onDelete);
        },
      ),
    );
  }

  Future<void> _onOpenMap(MindMapSummary summary) async {
    final provider = context.read<MindMapProvider>();
    await provider.loadMap(summary.id);
    if (!mounted) return;
    context.pop();
  }

  void _onNewMap() {
    final provider = context.read<MindMapProvider>();
    provider.clear();
    context.pop();
  }

  Future<void> _onDelete(MindMapSummary summary) async {
    final provider = context.read<MindMapProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await provider.deleteMap(summary.id);
    if (!mounted) return;
    _refresh();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.loc.vocabMindMapDeleteSnack(summary.topic)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _MapList extends StatelessWidget {
  final List<MindMapSummary> maps;
  final void Function(MindMapSummary) onTap;
  final void Function(MindMapSummary) onDelete;

  const _MapList({
    required this.maps,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalNodes =
        maps.fold<int>(0, (sum, summary) => sum + summary.nodeCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            '${maps.length} ${maps.length == 1 ? "map" : "maps"} · '
            '$totalNodes nodes total',
            style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            itemCount: maps.length + 1,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.smd),
            itemBuilder: (context, index) {
              if (index == maps.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'Swipe a card left to delete',
                    style: AppTypography.caption
                        .copyWith(color: context.clay.textFaint),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final summary = maps[index];
              return Dismissible(
                key: ValueKey(summary.id),
                direction: DismissDirection.endToStart,
                background: _SwipeDeleteBackground(),
                confirmDismiss: (_) async => true,
                onDismissed: (_) => onDelete(summary),
                child: _MapRow(
                  summary: summary,
                  isMostRecent: index == 0,
                  onTap: () => onTap(summary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MapRow extends StatelessWidget {
  final MindMapSummary summary;
  final bool isMostRecent;
  final VoidCallback onTap;

  const _MapRow({
    required this.summary,
    required this.isMostRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isMostRecent ? context.clay.text : context.clay.border,
            width: isMostRecent ? 2 : 1.5,
          ),
          boxShadow: isMostRecent ? AppShadows.clayBold(context) : AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    summary.topic,
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.clay.text,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _relativeTime(summary.updatedAt),
                  style: AppTypography.caption
                      .copyWith(color: context.clay.textFaint),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MetaPill(
                  label: context.loc.vocabMindMapNodesCount(summary.nodeCount) + ' '
                      '${summary.nodeCount == 1 ? "node" : "nodes"}',
                ),
                _MetaPill(label: context.loc.vocabMindMapDepth(summary.depth)),
                if (_isSeededFromWord(summary.id))
                  _MetaPill(
                    label: context.loc.vocabMindMapFromLibrary,
                    background: AppColors.purple,
                    foreground: context.clay.surface,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Maps seeded from a saved word use the `word_<label>_<ts>` id pattern set
  /// by the seed-from-library entry point (M5). Detecting it here keeps the
  /// summary free of an extra "source" field.
  bool _isSeededFromWord(String id) => id.startsWith('word_');

  String _relativeTime(DateTime? at) {
    if (at == null) return '';
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '${weeks}w ago';
    final months = (diff.inDays / 30).floor();
    return '${months}mo ago';
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final Color? background;
  final Color? foreground;

  const _MetaPill({
    required this.label,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background ?? context.clay.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: foreground ?? context.clay.text,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _NewMapButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewMapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.clay.text, width: 2),
          boxShadow: [
            BoxShadow(
              color: context.clay.text,
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 14, color: context.clay.surface),
            const SizedBox(width: 4),
            Text(
              'New',
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.clay.surface,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.85),
        borderRadius: AppRadius.lgBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_outline_rounded,
              color: context.clay.surface, size: 22),
          const SizedBox(width: 6),
          Text(
            'Delete',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.clay.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 56,
              color: context.clay.textFaint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No saved maps yet',
              style: AppTypography.h3.copyWith(color: context.clay.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate a topic map or seed one from a saved word in your '
              'library to see it appear here.',
              style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
