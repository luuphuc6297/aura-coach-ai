import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';
import '../../../data/prompts/prompt_constants.dart';
import '../../../features/home/providers/home_provider.dart';
import '../../../features/my_library/models/saved_item.dart';
import '../../../features/my_library/providers/library_provider.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../providers/mind_map_provider.dart';
import '../widgets/mind_map_canvas.dart';
import '../widgets/mind_map_node_sheet.dart';
import '../widgets/pro_upgrade_card.dart';

/// Mind Map deep-dive tab. Pro/Premium users can generate topic maps and
/// lazy-expand nodes. Debug builds bypass the Pro gate so the feature is
/// usable during development without manually flipping tiers.
class MindMapTab extends StatefulWidget {
  const MindMapTab({super.key});

  @override
  State<MindMapTab> createState() => _MindMapTabState();
}

class _MindMapTabState extends State<MindMapTab> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedNodeId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Debug builds auto-unlock Mind Maps so the team can QA the feature
  /// without spinning up a Pro account. Release builds fall back to the
  /// actual subscription check.
  bool _isPro(String tier) {
    if (kDebugMode) return true;
    return tier == 'pro' || tier == 'premium';
  }

  void _generate(MindMapProvider provider) {
    final topic = _controller.text.trim();
    if (topic.isEmpty || provider.loading) return;
    FocusScope.of(context).unfocus();
    provider.generateFor(topic);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<HomeProvider>().userProfile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isPro(profile.tier)) {
      return SingleChildScrollView(
        child: ProUpgradeCard(
          title: context.loc.vocabMindMapProTitle,
          description:
              'Visualize how words connect, expand any branch on demand, and build your own topic map. Upgrade to unlock.',
        ),
      );
    }

    final provider = context.watch<MindMapProvider>();
    provider.configure(
      uid: profile.uid,
      level: CefrLevel.fromProficiencyId(profile.proficiencyLevel),
    );

    return Column(
      children: [
        _Toolbar(
          controller: _controller,
          onGenerate: () => _generate(provider),
          loading: provider.loading,
          canUndo: provider.canUndo,
          onUndo: provider.undo,
          onOpenLibrary: () => context.push('/vocab-hub/mind-map/library'),
        ),
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.error!,
                    style:
                        AppTypography.bodySm.copyWith(color: AppColors.coral),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 18, color: AppColors.coral),
                  onPressed: provider.clearError,
                ),
              ],
            ),
          ),
        Expanded(
          child: provider.root == null
              ? _EmptyState(topicHint: provider.topic)
              : Selector<LibraryProvider, Set<String>>(
                  selector: (_, lib) => lib.savedVocabLabels,
                  builder: (_, savedLabels, __) => MindMapCanvas(
                    root: provider.root!,
                    positions: provider.positions,
                    savedLabels: savedLabels,
                    expandingIds: _collectIds(
                      provider.root!,
                      (id) => provider.isExpanding(id),
                    ),
                    collapsedIds: _collectIds(
                      provider.root!,
                      (id) => provider.isCollapsed(id),
                    ),
                    selectedNodeId: _selectedNodeId,
                    onNodeTap: _onNodeTap,
                    onNodeMove: provider.moveNode,
                    onNodeDoubleTap: _onNodeDoubleTap,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _onNodeTap(String nodeId) async {
    setState(() => _selectedNodeId = nodeId);
    await showMindMapNodeSheet(context: context, nodeId: nodeId);
    if (!mounted) return;
    setState(() => _selectedNodeId = null);
  }

  /// Quick-action shortcut on word nodes: toggles the node in the user's
  /// library so the learner can save without opening the detail sheet.
  /// No-ops for topic and category nodes (they're not real vocabulary).
  Future<void> _onNodeDoubleTap(String nodeId) async {
    final provider = context.read<MindMapProvider>();
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final node = _findNode(provider.root, nodeId);
    if (node == null || node.type != MindMapNodeType.word) return;

    final existing = library.findVocabByLabel(node.label);
    if (existing != null) {
      await library.deleteItem(existing.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.loc.vocabMindMapNodeRemovedSnack(node.label)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final added = await library.addItem(
      SavedItem(
        id: 'mm-${node.id}-$now',
        original: node.label,
        correction: node.label,
        type: 'vocabulary',
        context: node.context ?? '',
        timestamp: now,
        explanation: node.translation,
        partOfSpeech: node.partOfSpeech,
        pronunciation: node.phonetic,
        sourceTag: 'vocab-hub:mind-map',
      ),
    );
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Saved "${node.label}" to library'
              : '"${node.label}" already in library',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  MindMapNode? _findNode(MindMapNode? root, String id) {
    if (root == null) return null;
    if (root.id == id) return root;
    for (final c in root.children) {
      final hit = _findNode(c, id);
      if (hit != null) return hit;
    }
    return null;
  }

  Set<String> _collectIds(
    MindMapNode node,
    bool Function(String id) match,
  ) {
    final out = <String>{};
    void walk(MindMapNode n) {
      if (match(n.id)) out.add(n.id);
      for (final c in n.children) {
        walk(c);
      }
    }

    walk(node);
    return out;
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onGenerate;
  final bool loading;
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onOpenLibrary;

  const _Toolbar({
    required this.controller,
    required this.onGenerate,
    required this.loading,
    required this.canUndo,
    required this.onUndo,
    required this.onOpenLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClayTextInput(
                  controller: controller,
                  hintText: context.loc.vocabMindMapHint,
                  accentColor: AppColors.coral,
                  textStyle: AppTypography.bodyMd,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onGenerate(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 110,
                child: ClayButton(
                  text: context.loc.vocabMindMapGenerate,
                  variant: ClayButtonVariant.accentCoral,
                  isLoading: loading,
                  isFullWidth: false,
                  onTap: loading ? null : onGenerate,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ToolbarChip(
                icon: Icons.collections_bookmark_outlined,
                label: context.loc.vocabMindMapMyMaps,
                onTap: onOpenLibrary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ToolbarChip(
                icon: Icons.undo,
                label: context.loc.vocabMindMapUndo,
                enabled: canUndo,
                onTap: canUndo ? onUndo : null,
              ),
              const Spacer(),
              Text(
                'Long-press a node to drag',
                style: AppTypography.caption
                    .copyWith(color: context.clay.textFaint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _ToolbarChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? context.clay.text : context.clay.textFaint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: enabled ? context.clay.text : context.clay.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? topicHint;
  const _EmptyState({this.topicHint});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hub_outlined,
                size: 48,
                color: context.clay.textFaint,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                topicHint == null
                    ? 'Enter a topic to build a mind map'
                    : 'Ready when you are',
                style:
                    AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tap node → details · Long-press → drag · + Add words to grow your map',
                style:
                    AppTypography.caption.copyWith(color: context.clay.textFaint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
