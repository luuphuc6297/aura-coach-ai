import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/gemini/gemini_service.dart';
import '../../../data/gemini/types.dart';
import '../../../data/prompts/prompt_constants.dart';

/// Drives the Mind Map screen end-to-end: generates the root tree from a
/// topic (or a seed word), lazy-expands and deletes nodes, lets the learner
/// add their own related word per node, and mirrors the canonical tree + the
/// per-node layout positions to Firestore so every edit survives restart.
///
/// Arbitrary-depth trees are laid out via [_autoLayoutRadial]: each branch
/// receives an angular slice of its parent's slice and the radius grows per
/// depth. Any position the user drags (or any override a caller passes to
/// [moveNode]) wins over the auto-layout and is persisted verbatim.
///
/// Pro gating is enforced at the UI tier, not here — see [MindMapScreen].
class MindMapProvider extends ChangeNotifier {
  final GeminiService _gemini;
  final FirebaseDatasource _firebase;

  MindMapProvider({
    required GeminiService gemini,
    required FirebaseDatasource firebase,
  })  : _gemini = gemini,
        _firebase = firebase;

  String? _uid;
  CefrLevel _level = CefrLevel.a1a2;
  String? _mapId;
  String? _topic;
  MindMapNode? _root;
  bool _loading = false;
  String? _error;
  final Set<String> _expanding = {};
  final Set<String> _collapsed = {};
  final Map<String, Offset> _positions = {};
  Timer? _saveDebounce;

  // Undo stack for destructive node operations. Each entry captures the full
  // tree state so we can restore perfectly after a delete/collapse.
  final List<_MindMapSnapshot> _undoStack = [];
  static const int _undoLimit = 20;

  MindMapNode? get root => _root;
  String? get topic => _topic;
  String? get mapId => _mapId;
  bool get loading => _loading;
  String? get error => _error;
  bool isExpanding(String nodeId) => _expanding.contains(nodeId);
  bool isCollapsed(String nodeId) => _collapsed.contains(nodeId);
  Map<String, Offset> get positions => Map.unmodifiable(_positions);
  bool get canUndo => _undoStack.isNotEmpty;

  /// Keeps [uid] and [level] in sync with the currently signed-in profile.
  /// Safe to call on every rebuild.
  void configure({required String uid, required CefrLevel level}) {
    _uid = uid;
    _level = level;
  }

  /// Builds a fresh topic-rooted map. Any unsaved edits on the current map
  /// are discarded by the caller before invoking this. When [fromLibrary] is
  /// true the resulting map id is prefixed with `word_` so the My Mind Maps
  /// list can render the "from Library" badge without an extra column.
  Future<void> generateFor(String topic, {bool fromLibrary = false}) async {
    if (_uid == null) return;
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return;
    _loading = true;
    _error = null;
    _topic = trimmed;
    _resetEphemeralState();
    notifyListeners();
    try {
      final node = await _gemini
          .generateTopicMindMap(topic: trimmed, level: _level)
          .timeout(const Duration(seconds: 30));
      _root = node;
      final prefix = fromLibrary ? 'word' : 'map';
      _mapId = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
      _autoLayout();
      _persist(); // fire-and-forget; surfaces errors via debugPrint only
    } on TimeoutException {
      debugPrint('MindMapProvider.generateFor timed out');
      _error =
          'The request is taking longer than usual. Please try again.';
    } catch (e, st) {
      debugPrint('MindMapProvider.generateFor failed: $e\n$st');
      _error = kDebugMode
          ? 'Failed to generate mind map: $e'
          : 'Failed to generate mind map. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Returns a metadata list of every saved map for the signed-in user. Each
  /// entry carries `{id, topic, nodeCount, depth, updatedAt}` so the list
  /// screen can render rows without hydrating the whole tree.
  Future<List<MindMapSummary>> listMaps() async {
    if (_uid == null) return const [];
    try {
      final docs = await _firebase.listMindMaps(_uid!);
      return docs
          .map((doc) {
            final root = doc['root'] is Map<String, dynamic>
                ? MindMapNode.fromJson(doc['root'] as Map<String, dynamic>)
                : null;
            final updatedAt = doc['updatedAt'];
            DateTime? updated;
            if (updatedAt is DateTime) {
              updated = updatedAt;
            } else if (updatedAt is int) {
              updated = DateTime.fromMillisecondsSinceEpoch(updatedAt);
            } else {
              try {
                updated = (updatedAt as dynamic)?.toDate() as DateTime?;
              } catch (_) {
                updated = null;
              }
            }
            return MindMapSummary(
              id: (doc['id'] as String?) ?? '',
              topic: (doc['topic'] as String?) ?? 'Untitled map',
              nodeCount: root == null ? 0 : _countNodes(root),
              depth: root == null ? 0 : _treeDepth(root),
              updatedAt: updated,
            );
          })
          .where((s) => s.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('MindMapProvider.listMaps failed: $e');
      return const [];
    }
  }

  /// Removes a saved map from Firestore. If the deleted map is the one
  /// currently open, the in-memory state is cleared too.
  Future<void> deleteMap(String mapId) async {
    if (_uid == null) return;
    try {
      await _firebase.deleteMindMap(_uid!, mapId);
      if (_mapId == mapId) clear();
    } catch (e) {
      debugPrint('MindMapProvider.deleteMap failed: $e');
    }
  }

  int _countNodes(MindMapNode node) {
    var n = 1;
    for (final c in node.children) {
      n += _countNodes(c);
    }
    return n;
  }

  int _treeDepth(MindMapNode node) {
    if (node.children.isEmpty) return 1;
    var deepest = 0;
    for (final c in node.children) {
      deepest = math.max(deepest, _treeDepth(c));
    }
    return deepest + 1;
  }

  /// Loads a previously saved map from Firestore into the provider.
  Future<void> loadMap(String mapId) async {
    if (_uid == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final doc = await _firebase.getMindMap(_uid!, mapId);
      if (doc == null) {
        _error = 'Mind map not found.';
        return;
      }
      _topic = doc['topic'] as String?;
      _mapId = mapId;
      _root = doc['root'] is Map<String, dynamic>
          ? MindMapNode.fromJson(doc['root'] as Map<String, dynamic>)
          : null;
      _collapsed
        ..clear()
        ..addAll(List<String>.from(doc['collapsed'] as List? ?? const []));
      _positions
        ..clear()
        ..addAll(_decodePositions(doc['positions']));
      // Fill in positions for any nodes missing one (e.g. tree from before
      // the position migration) so nothing collapses to 0,0.
      if (_root != null) _autoLayout(overwrite: false);
    } catch (e) {
      debugPrint('MindMapProvider.loadMap failed: $e');
      _error = 'Failed to open mind map.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetches children for [nodeId] via Gemini and splices them into the tree.
  /// No-ops if the node already has children (use [addCustomChild] instead).
  Future<void> expandNode(String nodeId) async {
    if (_root == null || _uid == null) return;
    final target = _findNode(_root!, nodeId);
    if (target == null || target.children.isNotEmpty) return;
    _expanding.add(nodeId);
    _collapsed.remove(nodeId);
    notifyListeners();
    try {
      final children = await _gemini
          .expandMindMapNode(
            nodeLabel: target.label,
            rootTopic: _root!.label,
            level: _level,
          )
          .timeout(const Duration(seconds: 30));
      _pushUndo();
      _root = _replaceChildren(_root!, nodeId, children);
      _layoutNewChildren(nodeId, children);
      _persist();
    } on TimeoutException {
      debugPrint('MindMapProvider.expandNode timed out');
      _error = 'Expanding took too long. Please try again.';
    } catch (e, st) {
      debugPrint('MindMapProvider.expandNode failed: $e\n$st');
      _error = kDebugMode
          ? 'Failed to expand node: $e'
          : 'Failed to expand node. Please try again.';
    } finally {
      _expanding.remove(nodeId);
      notifyListeners();
    }
  }

  /// Adds a user-authored word under [parentId]. Runs [GeminiService.analyzeCustomNode]
  /// to get translation/POS/context so the new node renders fully.
  /// Returns the created node id, or null on failure.
  Future<String?> addCustomChild({
    required String parentId,
    required String word,
  }) async {
    if (_root == null || _uid == null) return null;
    final clean = word.trim();
    if (clean.isEmpty) return null;
    final parent = _findNode(_root!, parentId);
    if (parent == null) return null;
    try {
      // Collect a flat list of existing node labels so Gemini can consider
      // context when producing metadata. We intentionally ignore the
      // suggested parentNodeId — the user has already picked the parent by
      // tapping "+ Add word" on a specific node.
      final existing = <Map<String, String>>[];
      void walk(MindMapNode n) {
        existing.add({'id': n.id, 'label': n.label, 'type': n.type.value});
        for (final c in n.children) {
          walk(c);
        }
      }
      walk(_root!);
      final result = await _gemini
          .analyzeCustomNode(customWord: clean, existingNodes: existing)
          .timeout(const Duration(seconds: 30));
      final id = 'n_${DateTime.now().millisecondsSinceEpoch}';
      final newNode = MindMapNode(
        id: id,
        label: clean,
        type: MindMapNodeType.word,
        translation: result.translation,
        partOfSpeech: result.partOfSpeech,
        phonetic: result.phonetic,
        context: result.context,
      );
      _pushUndo();
      _root = _appendChild(_root!, parentId, newNode);
      _layoutNewChildren(parentId, [newNode]);
      _persist();
      notifyListeners();
      return id;
    } on TimeoutException {
      debugPrint('MindMapProvider.addCustomChild timed out');
      _error = 'Adding "$word" took too long. Please try again.';
      notifyListeners();
      return null;
    } catch (e, st) {
      debugPrint('MindMapProvider.addCustomChild failed: $e\n$st');
      _error = kDebugMode
          ? 'Could not add "$word": $e'
          : 'Could not add "$word". Please try again.';
      notifyListeners();
      return null;
    }
  }

  /// Deletes [nodeId] and its entire subtree. Root cannot be deleted.
  /// Pushes an undo snapshot so the caller can wire an undo snackbar.
  void deleteNode(String nodeId) {
    if (_root == null || _root!.id == nodeId) return;
    _pushUndo();
    _root = _removeNode(_root!, nodeId);
    _positions.removeWhere((id, _) => !_existsInTree(id));
    _collapsed.removeWhere((id) => !_existsInTree(id));
    _persist();
    notifyListeners();
  }

  /// Toggles whether [nodeId]'s children are visible on the canvas. Does not
  /// modify the tree itself — just a rendering hint.
  void toggleCollapse(String nodeId) {
    if (_root == null) return;
    if (_collapsed.contains(nodeId)) {
      _collapsed.remove(nodeId);
    } else {
      _collapsed.add(nodeId);
    }
    _persist();
    notifyListeners();
  }

  /// Writes a user-controlled position for [nodeId]. Callers typically invoke
  /// this from a drag handler — the position overrides auto-layout.
  void moveNode(String nodeId, Offset pos) {
    _positions[nodeId] = pos;
    _persist();
    notifyListeners();
  }

  /// Rewinds the tree to the last snapshot. Does nothing when the stack is
  /// empty. Useful for "Undo" affordances after destructive actions.
  void undo() {
    if (_undoStack.isEmpty) return;
    final snap = _undoStack.removeLast();
    _root = snap.root;
    _positions
      ..clear()
      ..addAll(snap.positions);
    _collapsed
      ..clear()
      ..addAll(snap.collapsed);
    _persist();
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Resets provider state so the caller can start a new map from scratch.
  void clear() {
    _root = null;
    _mapId = null;
    _topic = null;
    _resetEphemeralState();
    _undoStack.clear();
    _saveDebounce?.cancel();
    notifyListeners();
  }

  void _resetEphemeralState() {
    _positions.clear();
    _collapsed.clear();
    _expanding.clear();
    _error = null;
  }

  // ---------- layout ----------

  /// Recomputes positions for every node using a recursive radial slice
  /// algorithm. When [overwrite] is false, only nodes without an existing
  /// position get one — so user-dragged positions survive.
  void _autoLayout({bool overwrite = true}) {
    if (_root == null) return;
    const center = Offset(1500, 1500);
    if (overwrite || !_positions.containsKey(_root!.id)) {
      _positions[_root!.id] = center;
    }
    _layoutSubtree(
      _root!,
      center: center,
      startAngle: 0,
      endAngle: 2 * math.pi,
      depth: 0,
      overwrite: overwrite,
    );
  }

  void _layoutSubtree(
    MindMapNode node, {
    required Offset center,
    required double startAngle,
    required double endAngle,
    required int depth,
    required bool overwrite,
  }) {
    final children = node.children;
    if (children.isEmpty) return;
    const baseRadius = 220.0;
    const radiusStep = 200.0;
    final radius = baseRadius + depth * radiusStep;
    final slice = (endAngle - startAngle) / children.length;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final cStart = startAngle + i * slice;
      final cEnd = cStart + slice;
      final mid = (cStart + cEnd) / 2;
      // Root's children anchor to the literal center; deeper children anchor
      // to the canvas center so angular math stays consistent.
      final pos = center + Offset(math.cos(mid), math.sin(mid)) * radius;
      if (overwrite || !_positions.containsKey(child.id)) {
        _positions[child.id] = pos;
      }
      _layoutSubtree(
        child,
        center: center,
        startAngle: cStart,
        endAngle: cEnd,
        depth: depth + 1,
        overwrite: overwrite,
      );
    }
  }

  /// Places [newChildren] around [parentId] without disturbing other nodes.
  ///
  /// Strategy:
  /// 1. Compute the "outward" direction = from parent's parent toward
  ///    [parentId] (or straight down when [parentId] is the root). This
  ///    biases the fan AWAY from the rest of the tree so new nodes don't
  ///    immediately collide with siblings sitting between root and parent.
  /// 2. Spread the children across a 100° arc centred on that outward
  ///    direction.
  /// 3. Run a cheap collision-avoidance pass on each candidate position —
  ///    rotate around the parent until the spot is clear of every other
  ///    node by at least one chip width.
  void _layoutNewChildren(String parentId, List<MindMapNode> newChildren) {
    final parentPos = _positions[parentId];
    if (parentPos == null || newChildren.isEmpty) return;
    const radius = 230.0;
    final outwardAngle = _outwardAngle(parentId, parentPos);
    final span = newChildren.length == 1 ? 0.0 : math.pi * 5 / 9; // ~100°
    for (var i = 0; i < newChildren.length; i++) {
      final t = newChildren.length == 1
          ? 0.5
          : i / (newChildren.length - 1);
      final angle = outwardAngle - span / 2 + span * t;
      var pos = parentPos +
          Offset(math.cos(angle), math.sin(angle)) * radius;
      pos = _avoidCollisions(pos, parentPos, radius);
      _positions[newChildren[i].id] = pos;
    }
  }

  /// Direction (radians) pointing FROM the grandparent TO [parentId]. Falls
  /// back to π/2 (downward) when the parent is the root or the grandparent
  /// position is unknown.
  double _outwardAngle(String parentId, Offset parentPos) {
    final grandParent = _findParentId(parentId);
    if (grandParent == null) return math.pi / 2;
    final gpPos = _positions[grandParent];
    if (gpPos == null) return math.pi / 2;
    final delta = parentPos - gpPos;
    if (delta.distance == 0) return math.pi / 2;
    return delta.direction;
  }

  /// Pushes [pos] away from any existing node that's closer than one chip
  /// width by rotating it around [pivot] in 30° steps. Caps at 12 attempts
  /// — beyond that we accept some overlap rather than spinning forever.
  Offset _avoidCollisions(Offset pos, Offset pivot, double radius) {
    const minDist = 150.0;
    var attempt = 0;
    var current = pos;
    while (attempt < 12) {
      var clear = true;
      for (final entry in _positions.entries) {
        if ((entry.value - current).distance < minDist) {
          clear = false;
          break;
        }
      }
      if (clear) return current;
      // Rotate the candidate around the parent by +30° each retry.
      final relative = current - pivot;
      final newAngle = relative.direction + math.pi / 6;
      current = pivot +
          Offset(math.cos(newAngle), math.sin(newAngle)) * radius;
      attempt++;
    }
    return current;
  }

  /// Walks the tree to find the parent id of [childId]. Returns null when
  /// [childId] is the root or doesn't exist in the tree.
  String? _findParentId(String childId) {
    if (_root == null) return null;
    String? hit;
    bool walk(MindMapNode node) {
      for (final c in node.children) {
        if (c.id == childId) {
          hit = node.id;
          return true;
        }
        if (walk(c)) return true;
      }
      return false;
    }

    walk(_root!);
    return hit;
  }

  // ---------- persistence ----------

  void _persist() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), _writeToFirestore);
  }

  Future<void> _writeToFirestore() async {
    if (_uid == null || _mapId == null || _root == null) return;
    try {
      await _firebase.saveMindMap(
        uid: _uid!,
        mapId: _mapId!,
        data: {
          'topic': _topic,
          'level': _level.code,
          'root': _root!.toJson(),
          'positions': _encodePositions(_positions),
          'collapsed': _collapsed.toList(),
        },
      );
    } catch (e) {
      debugPrint('MindMapProvider.persist failed: $e');
    }
  }

  Map<String, List<double>> _encodePositions(Map<String, Offset> src) {
    return {
      for (final entry in src.entries) entry.key: [entry.value.dx, entry.value.dy],
    };
  }

  Map<String, Offset> _decodePositions(dynamic raw) {
    if (raw is! Map) return {};
    final out = <String, Offset>{};
    raw.forEach((key, value) {
      if (key is! String) return;
      if (value is List && value.length >= 2) {
        final dx = (value[0] as num?)?.toDouble();
        final dy = (value[1] as num?)?.toDouble();
        if (dx != null && dy != null) out[key] = Offset(dx, dy);
      }
    });
    return out;
  }

  // ---------- tree helpers ----------

  void _pushUndo() {
    if (_root == null) return;
    _undoStack.add(
      _MindMapSnapshot(
        root: _root!,
        positions: Map.of(_positions),
        collapsed: Set.of(_collapsed),
      ),
    );
    if (_undoStack.length > _undoLimit) {
      _undoStack.removeAt(0);
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

  bool _existsInTree(String id) {
    if (_root == null) return false;
    return _findNode(_root!, id) != null;
  }

  MindMapNode _replaceChildren(
    MindMapNode node,
    String id,
    List<MindMapNode> children,
  ) {
    if (node.id == id) {
      return node.copyWith(children: children);
    }
    return node.copyWith(
      children:
          node.children.map((c) => _replaceChildren(c, id, children)).toList(),
    );
  }

  MindMapNode _appendChild(
    MindMapNode node,
    String parentId,
    MindMapNode child,
  ) {
    if (node.id == parentId) {
      return node.copyWith(children: [...node.children, child]);
    }
    return node.copyWith(
      children:
          node.children.map((c) => _appendChild(c, parentId, child)).toList(),
    );
  }

  MindMapNode _removeNode(MindMapNode node, String id) {
    final filtered = <MindMapNode>[];
    for (final child in node.children) {
      if (child.id == id) continue;
      filtered.add(_removeNode(child, id));
    }
    return node.copyWith(children: filtered);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}

class _MindMapSnapshot {
  final MindMapNode root;
  final Map<String, Offset> positions;
  final Set<String> collapsed;

  const _MindMapSnapshot({
    required this.root,
    required this.positions,
    required this.collapsed,
  });
}

/// Lightweight metadata about a saved mind-map. Used by the My Mind Maps
/// list screen to render rows without hydrating the whole tree.
class MindMapSummary {
  final String id;
  final String topic;
  final int nodeCount;
  final int depth;
  final DateTime? updatedAt;

  const MindMapSummary({
    required this.id,
    required this.topic,
    required this.nodeCount,
    required this.depth,
    required this.updatedAt,
  });
}
