import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../data/gemini/types.dart';
import '../../../features/my_library/models/saved_item.dart';
import '../../../features/my_library/providers/library_provider.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../providers/mind_map_provider.dart';

/// Bottom sheet shown when the learner taps a node on the mind-map canvas.
/// Presents the node's metadata (label, type badge, translation, POS,
/// context) and the full action set: expand via Gemini, add a custom related
/// word, save the node to the personal library, collapse/expand the branch,
/// and delete the subtree (with undo).
///
/// The sheet defers all mutations to [MindMapProvider] and [LibraryProvider]
/// so it can be re-used from any future surface that exposes a node.
Future<void> showMindMapNodeSheet({
  required BuildContext context,
  required String nodeId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: context.clay.text.withValues(alpha: 0.45),
    builder: (sheetCtx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: _MindMapNodeSheet(nodeId: nodeId),
      );
    },
  );
}

class _MindMapNodeSheet extends StatefulWidget {
  final String nodeId;
  const _MindMapNodeSheet({required this.nodeId});

  @override
  State<_MindMapNodeSheet> createState() => _MindMapNodeSheetState();
}

class _MindMapNodeSheetState extends State<_MindMapNodeSheet> {
  bool _addingWord = false;
  bool _addingInFlight = false;
  final TextEditingController _wordController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MindMapProvider>();
    final node = _findNode(provider.root, widget.nodeId);
    if (node == null) {
      // The node was deleted (e.g. parent collapsed/removed) — close the sheet
      // immediately so we never render against stale state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }

    final isCollapsed = provider.isCollapsed(node.id);
    final isRoot = provider.root?.id == node.id;
    final canExpand = node.children.isEmpty && !provider.isExpanding(node.id);

    return Container(
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: context.clay.text, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.clay.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _Header(node: node),
            const SizedBox(height: AppSpacing.sm),
            _Metadata(node: node),
            if (_addingWord) ...[
              const SizedBox(height: AppSpacing.md),
              _AddWordForm(
                parentLabel: node.label,
                controller: _wordController,
                inFlight: _addingInFlight,
                onCancel: () {
                  setState(() {
                    _addingWord = false;
                    _wordController.clear();
                  });
                },
                onSubmit: () => _submitCustomWord(provider, node.id),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              _ActionGrid(
                canExpand: canExpand,
                isCollapsed: isCollapsed,
                hasChildren: node.children.isNotEmpty,
                isRoot: isRoot,
                showSaveToLibrary: node.type == MindMapNodeType.word,
                onExpand: () => _runExpand(provider, node.id),
                onAddWord: () => setState(() => _addingWord = true),
                onSaveToLibrary: () => _saveToLibrary(node),
                onToggleCollapse: () => provider.toggleCollapse(node.id),
                onDelete: isRoot ? null : () => _confirmDelete(provider, node),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runExpand(MindMapProvider provider, String id) async {
    Navigator.of(context).maybePop();
    await provider.expandNode(id);
  }

  Future<void> _submitCustomWord(
    MindMapProvider provider,
    String parentId,
  ) async {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;
    setState(() => _addingInFlight = true);
    final newId = await provider.addCustomChild(parentId: parentId, word: word);
    if (!mounted) return;
    setState(() {
      _addingInFlight = false;
      _addingWord = false;
      _wordController.clear();
    });
    if (newId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.vocabMindMapNodeAddedSnack(word)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _saveToLibrary(MindMapNode node) async {
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
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
        sourceTag: 'vocab-hub:mind-map',
      ),
    );
    if (!mounted) return;
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Saved "${node.label}" to your library'
              : '"${node.label}" is already in your library',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(
    MindMapProvider provider,
    MindMapNode node,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).maybePop();
    provider.deleteNode(node.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.loc.vocabMindMapNodeDeletedSnack(node.label)),
        action: SnackBarAction(
          label: context.loc.vocabMindMapUndo,
          textColor: AppColors.coral,
          onPressed: provider.undo,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  MindMapNode? _findNode(MindMapNode? root, String id) {
    if (root == null) return null;
    if (root.id == id) return root;
    for (final child in root.children) {
      final hit = _findNode(child, id);
      if (hit != null) return hit;
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  final MindMapNode node;
  const _Header({required this.node});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(node.type);
    final hasPhonetic =
        node.phonetic != null && node.phonetic!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                node.label,
                style: AppTypography.h3.copyWith(
                  color: context.clay.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (node.type == MindMapNodeType.word)
              _ListenButton(text: node.label, color: color),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Text(
                _typeLabel(node.type, node.partOfSpeech),
                style: AppTypography.labelSm.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (hasPhonetic) ...[
          const SizedBox(height: 2),
          Text(
            node.phonetic!,
            style: AppTypography.bodySm.copyWith(
              color: context.clay.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  String _typeLabel(MindMapNodeType type, String? pos) {
    final base = switch (type) {
      MindMapNodeType.topic => 'topic',
      MindMapNodeType.category => 'category',
      MindMapNodeType.word => 'word',
    };
    if (pos != null && pos.isNotEmpty) return '$base · ${pos.toLowerCase()}';
    return base;
  }

  Color _typeColor(MindMapNodeType type) => switch (type) {
        MindMapNodeType.topic => AppColors.purple,
        MindMapNodeType.category => AppColors.teal,
        MindMapNodeType.word => AppColors.coral,
      };
}

class _Metadata extends StatelessWidget {
  final MindMapNode node;
  const _Metadata({required this.node});

  @override
  Widget build(BuildContext context) {
    final hasTranslation =
        node.translation != null && node.translation!.isNotEmpty;
    final hasContext = node.context != null && node.context!.isNotEmpty;
    if (!hasTranslation && !hasContext) {
      return Text(
        'No metadata yet — expand to fetch related words.',
        style: AppTypography.bodySm.copyWith(color: context.clay.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTranslation)
          Text(
            node.translation!,
            style: AppTypography.bodyMd.copyWith(color: context.clay.text),
          ),
        if (hasTranslation && hasContext) const SizedBox(height: 4),
        if (hasContext)
          Text(
            '"${node.context}"',
            style: AppTypography.bodySm.copyWith(
              color: context.clay.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final bool canExpand;
  final bool isCollapsed;
  final bool hasChildren;
  final bool isRoot;
  final bool showSaveToLibrary;
  final VoidCallback onExpand;
  final VoidCallback onAddWord;
  final VoidCallback onSaveToLibrary;
  final VoidCallback onToggleCollapse;
  final VoidCallback? onDelete;

  const _ActionGrid({
    required this.canExpand,
    required this.isCollapsed,
    required this.hasChildren,
    required this.isRoot,
    required this.showSaveToLibrary,
    required this.onExpand,
    required this.onAddWord,
    required this.onSaveToLibrary,
    required this.onToggleCollapse,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _ActionButton(
        label: context.loc.vocabMindMapExpandViaAi,
        variant: ClayButtonVariant.accentCoral,
        enabled: canExpand,
        onTap: canExpand ? onExpand : null,
      ),
      _ActionButton(
        label: context.loc.vocabMindMapAddWord,
        onTap: onAddWord,
      ),
      if (showSaveToLibrary)
        _ActionButton(
          label: context.loc.vocabMindMapSaveToLibrary,
          onTap: onSaveToLibrary,
        ),
      if (hasChildren)
        _ActionButton(
          label: isCollapsed ? 'Expand branch' : 'Collapse branch',
          onTap: onToggleCollapse,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: actions[i]),
                if (i + 1 < actions.length) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: actions[i + 1]),
                ] else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        if (onDelete != null) ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.coral),
            label: Text(
              'Delete node + subtree',
              style: AppTypography.labelMd.copyWith(color: AppColors.coral),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: AppColors.coral.withValues(alpha: 0.55),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final ClayButtonVariant variant;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.variant = ClayButtonVariant.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return ClayButton(
      text: label,
      variant: variant,
      isFullWidth: true,
      onTap: enabled ? onTap : null,
    );
  }
}

class _AddWordForm extends StatelessWidget {
  final String parentLabel;
  final TextEditingController controller;
  final bool inFlight;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _AddWordForm({
    required this.parentLabel,
    required this.controller,
    required this.inFlight,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Adding a related word under',
          style: AppTypography.caption.copyWith(color: context.clay.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          '$parentLabel →',
          style: AppTypography.bodyMd.copyWith(
            color: context.clay.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClayTextInput(
          controller: controller,
          hintText: context.loc.vocabMindMapAddWordHint,
          accentColor: AppColors.coral,
          autofocus: true,
          enabled: !inFlight,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: ClayButton(
                text: 'Cancel',
                variant: ClayButtonVariant.secondary,
                isFullWidth: true,
                onTap: inFlight ? null : onCancel,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ClayButton(
                text: 'Add to map',
                variant: ClayButtonVariant.accentCoral,
                isLoading: inFlight,
                isFullWidth: true,
                onTap: inFlight ? null : onSubmit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Gemini will fetch translation, POS & context · ~2s',
          style: AppTypography.caption.copyWith(
            color: context.clay.textFaint,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Inline pronunciation playback for a word node. Tapping kicks off TTS via
/// the shared [TtsService] — fire-and-forget, no rebuild needed.
class _ListenButton extends StatelessWidget {
  final String text;
  final Color color;
  const _ListenButton({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => TtsService().speakEnglish(text),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(Icons.volume_up_rounded, size: 18, color: color),
      ),
    );
  }
}
