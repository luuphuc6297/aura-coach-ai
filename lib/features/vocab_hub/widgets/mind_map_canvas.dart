import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../data/gemini/types.dart';
import '../../../shared/widgets/app_icon.dart';

/// Pan/zoom mind-map canvas with hand-tuned visuals: radial cream→clay
/// gradient backdrop, twinkling sparkle layer, dot-grid texture, curved
/// bezier edges colored by child node type, and node chips that match the
/// rest of the app's clay design language (gradient root with mode icon,
/// type-tinted bordered category & word chips with offset clay shadow,
/// selected/drag halo, elastic entrance animation per new node).
///
/// Nodes are positioned from [positions]; tapping fires [onNodeTap]
/// (typically opens the detail sheet) and long-press initiates a drag where
/// the learner can reposition the node freely. While a drag is in flight the
/// new offset is held in widget state and committed via [onNodeMove] once
/// the gesture ends, so the provider isn't notified mid-gesture (avoids
/// debounced Firestore writes spamming on every pixel of movement).
///
/// The canvas owns a [TransformationController] so it can convert
/// long-press-screen-deltas into scene-space deltas — without this, a drag
/// while zoomed in/out would track at the wrong speed.
class MindMapCanvas extends StatefulWidget {
  final MindMapNode root;
  final Map<String, Offset> positions;
  final Set<String> expandingIds;
  final Set<String> collapsedIds;
  final Set<String> savedLabels;
  final String? selectedNodeId;
  final void Function(String nodeId) onNodeTap;
  final void Function(String nodeId, Offset newPos) onNodeMove;
  final void Function(String nodeId) onNodeDoubleTap;

  const MindMapCanvas({
    super.key,
    required this.root,
    required this.positions,
    required this.expandingIds,
    required this.collapsedIds,
    required this.savedLabels,
    required this.onNodeTap,
    required this.onNodeMove,
    required this.onNodeDoubleTap,
    this.selectedNodeId,
  });

  static const double _rootWidth = 168;
  static const double _rootHeight = 76;
  static const double _categoryWidth = 132;
  static const double _categoryHeight = 48;
  static const double _wordWidth = 130;
  static const double _wordHeight = 58;

  /// Stable per-node accent color so siblings on the same level no longer
  /// look identical. Topic always stays purple (mode brand). Categories and
  /// words pick from a 5-color palette using a hash of the node id.
  static const List<Color> _nodePalette = [
    AppColors.tealDeep,
    AppColors.purpleDeep,
    AppColors.coral,
    AppColors.goldDeep,
    AppColors.success,
  ];

  static Color accentForNode(MindMapNode node) {
    if (node.type == MindMapNodeType.topic) return AppColors.purpleDeep;
    final idx = node.id.hashCode.abs() % _nodePalette.length;
    return _nodePalette[idx];
  }
  static const double _canvasWidth = 3000;
  static const double _canvasHeight = 3000;

  static Size _chipSize(MindMapNodeType type) {
    switch (type) {
      case MindMapNodeType.topic:
        return const Size(_rootWidth, _rootHeight);
      case MindMapNodeType.category:
        return const Size(_categoryWidth, _categoryHeight);
      case MindMapNodeType.word:
        return const Size(_wordWidth, _wordHeight);
    }
  }

  @override
  State<MindMapCanvas> createState() => _MindMapCanvasState();
}

class _MindMapCanvasState extends State<MindMapCanvas> {
  final TransformationController _viewer = TransformationController();

  String? _draggingId;
  Offset _dragDelta = Offset.zero;
  String? _centeredRootId;

  @override
  void initState() {
    super.initState();
    // First mount: viewport defaults to (0,0) but our root sits at the
    // canvas centre (~1500,1500), so without an initial translate the user
    // sees empty space. Recenter once the layout box is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _centerOnRoot();
    });
  }

  @override
  void didUpdateWidget(MindMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-center when the user opens a different map (root id changed).
    // Don't recenter on every position tweak — that would fight drags.
    if (oldWidget.root.id != widget.root.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerOnRoot();
      });
    }
  }

  /// Translates the [InteractiveViewer] so the root chip lands in the middle
  /// of the visible viewport. Idempotent per root id — flips
  /// `_centeredRootId` so a rebuild that happens to fire before the
  /// post-frame callback completes doesn't queue a second translate.
  void _centerOnRoot() {
    if (_centeredRootId == widget.root.id) return;
    final rootPos = widget.positions[widget.root.id];
    if (rootPos == null) return;
    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox || !renderBox.hasSize) return;
    final size = renderBox.size;
    if (size.width <= 0 || size.height <= 0) return;
    final tx = -rootPos.dx + size.width / 2;
    final ty = -rootPos.dy + size.height / 2;
    _viewer.value = Matrix4.identity()..translate(tx, ty);
    _centeredRootId = widget.root.id;
  }

  @override
  void dispose() {
    _viewer.dispose();
    super.dispose();
  }

  /// Returns the [InteractiveViewer] zoom factor so a screen-space gesture
  /// delta can be converted to scene-space (canvas coordinate) delta.
  double get _scale => _viewer.value.getMaxScaleOnAxis().abs().clamp(0.1, 10);

  @override
  Widget build(BuildContext context) {
    final visible = _collectVisibleNodes();
    final visibleIds = visible.map((n) => n.id).toSet();
    final positions = _projectedPositions();
    return InteractiveViewer(
      transformationController: _viewer,
      panEnabled: _draggingId == null,
      scaleEnabled: _draggingId == null,
      constrained: false,
      minScale: 0.3,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(240),
      child: SizedBox(
        width: MindMapCanvas._canvasWidth,
        height: MindMapCanvas._canvasHeight,
        child: Stack(
          children: [
            const _RadialBackdrop(),
            _DotGrid(color: context.clay.text.withValues(alpha: 0.06)),
            const _SparkleLayer(),
            CustomPaint(
              size: const Size(
                MindMapCanvas._canvasWidth,
                MindMapCanvas._canvasHeight,
              ),
              painter: _EdgePainter(
                positions: positions,
                edges: _collectEdges(visibleIds),
                nodeAccents: _accentMap(),
                highlightedIds: _highlightedEdgeIds(),
                fallbackColor: context.clay.border,
              ),
            ),
            for (final node in visible)
              if (positions.containsKey(node.id))
                _PositionedNode(
                  key: ValueKey(node.id),
                  node: node,
                  basePosition: positions[node.id]!,
                  isExpanding: widget.expandingIds.contains(node.id),
                  isCollapsed: widget.collapsedIds.contains(node.id),
                  isSelected: widget.selectedNodeId == node.id,
                  isDragging: _draggingId == node.id,
                  isSaved: node.type == MindMapNodeType.word &&
                      widget.savedLabels
                          .contains(node.label.trim().toLowerCase()),
                  hiddenChildCount: widget.collapsedIds.contains(node.id)
                      ? node.children.length
                      : 0,
                  onTap: () => widget.onNodeTap(node.id),
                  onDoubleTap: () => widget.onNodeDoubleTap(node.id),
                  onLongPressStart: () =>
                      setState(() => _draggingId = node.id),
                  onLongPressUpdate: (delta) =>
                      setState(() => _dragDelta = delta / _scale),
                  onLongPressEnd: () {
                    final committed =
                        widget.positions[node.id]! + _dragDelta;
                    widget.onNodeMove(node.id, committed);
                    setState(() {
                      _draggingId = null;
                      _dragDelta = Offset.zero;
                    });
                  },
                ),
          ],
        ),
      ),
    );
  }

  Set<String> _highlightedEdgeIds() {
    final id = widget.selectedNodeId ?? _draggingId;
    return id == null ? const {} : {id};
  }

  // Edges should follow the node mid-drag so the line tracks the chip.
  Map<String, Offset> _projectedPositions() {
    if (_draggingId == null) return widget.positions;
    return {
      for (final entry in widget.positions.entries)
        entry.key: entry.key == _draggingId
            ? entry.value + _dragDelta
            : entry.value,
    };
  }

  Map<String, Color> _accentMap() {
    final out = <String, Color>{};
    void walk(MindMapNode n) {
      out[n.id] = MindMapCanvas.accentForNode(n);
      for (final c in n.children) {
        walk(c);
      }
    }

    walk(widget.root);
    return out;
  }

  List<MindMapNode> _collectVisibleNodes() {
    final out = <MindMapNode>[];
    void walk(MindMapNode node) {
      out.add(node);
      if (widget.collapsedIds.contains(node.id)) return;
      for (final child in node.children) {
        walk(child);
      }
    }

    walk(widget.root);
    return out;
  }

  List<_Edge> _collectEdges(Set<String> visibleIds) {
    final edges = <_Edge>[];
    void walk(MindMapNode node, int depth) {
      if (widget.collapsedIds.contains(node.id)) return;
      for (final child in node.children) {
        if (visibleIds.contains(child.id)) {
          edges.add(
            _Edge(
              from: node.id,
              to: child.id,
              depth: depth,
            ),
          );
        }
        walk(child, depth + 1);
      }
    }

    walk(widget.root, 0);
    return edges;
  }
}

class _Edge {
  final String from;
  final String to;
  final int depth;
  const _Edge({required this.from, required this.to, required this.depth});
}

// ─── backdrop layers ─────────────────────────────────────────────────────

class _RadialBackdrop extends StatelessWidget {
  const _RadialBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [
              Color(0xFFFFF8F0), // cream center
              Color(0xFFF5EDE3), // clay beige edges
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _DotGrid extends StatelessWidget {
  final Color color;
  const _DotGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _DotGridPainter(color: color)),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  static const double _spacing = 18;
  static const double _radius = 0.95;

  final Color color;

  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += _spacing) {
      for (var y = 0.0; y < size.height; y += _spacing) {
        canvas.drawCircle(Offset(x, y), _radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Five gold sparkle stars at fixed canvas positions, twinkling on a slow
/// loop. Decorative only — never absorbs taps.
class _SparkleLayer extends StatefulWidget {
  const _SparkleLayer();

  @override
  State<_SparkleLayer> createState() => _SparkleLayerState();
}

class _SparkleLayerState extends State<_SparkleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Hand-placed positions roughly around the central root anchor (1500,1500)
  // with a varied offset so they feel scattered rather than gridded. Each
  // entry is [x, y, baseSize, phase] where phase staggers the twinkle.
  static const List<List<double>> _spots = [
    [1300, 1240, 18, 0.0],
    [1720, 1280, 14, 0.35],
    [1240, 1640, 16, 0.65],
    [1780, 1660, 20, 0.15],
    [1500, 1180, 12, 0.85],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            size: const Size(
              MindMapCanvas._canvasWidth,
              MindMapCanvas._canvasHeight,
            ),
            painter: _SparklePainter(t: _controller.value, spots: _spots),
          );
        },
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  final List<List<double>> spots;
  _SparklePainter({required this.t, required this.spots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final spot in spots) {
      final x = spot[0];
      final y = spot[1];
      final base = spot[2];
      final phase = spot[3];
      final phased = ((t + phase) % 1.0);
      // Triangle wave 0→1→0 so each sparkle pulses smoothly.
      final pulse = phased < 0.5 ? phased * 2 : (1 - phased) * 2;
      final alpha = 0.10 + pulse * 0.30;
      final scale = 0.7 + pulse * 0.5;
      paint.color = AppColors.gold.withValues(alpha: alpha);
      _drawStar(canvas, Offset(x, y), base * scale, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 4;
    final innerRadius = radius * 0.32;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * math.pi) / points - math.pi / 2;
      final p = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.t != t;
}

// ─── edges ───────────────────────────────────────────────────────────────

class _EdgePainter extends CustomPainter {
  final Map<String, Offset> positions;
  final List<_Edge> edges;
  final Map<String, Color> nodeAccents;
  final Set<String> highlightedIds;
  final Color fallbackColor;

  const _EdgePainter({
    required this.positions,
    required this.edges,
    required this.nodeAccents,
    required this.highlightedIds,
    required this.fallbackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final from = positions[edge.from];
      final to = positions[edge.to];
      if (from == null || to == null) continue;
      final isHot = highlightedIds.contains(edge.from) ||
          highlightedIds.contains(edge.to);
      final color = nodeAccents[edge.to] ?? fallbackColor;
      final stroke = _edgeWidth(edge.depth, isHot);
      final paint = Paint()
        ..color = color.withValues(alpha: isHot ? 0.85 : 0.45)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(_curvedPath(from, to), paint);
    }
  }

  /// Returns a quadratic bezier between [a] and [b] whose control point sits
  /// on the perpendicular of the chord at a fixed offset, so every edge has
  /// a gentle organic arc instead of a hard straight line. Arc magnitude
  /// scales with chord length so short edges stay nearly straight.
  Path _curvedPath(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final length = (dx * dx + dy * dy);
    final path = Path()..moveTo(a.dx, a.dy);
    if (length == 0) {
      path.lineTo(b.dx, b.dy);
      return path;
    }
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final perp = Offset(-dy, dx);
    final norm = perp / perp.distance;
    final arc = (perp.distance * 0.12).clamp(8.0, 32.0);
    final control = mid + norm * arc;
    path.quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
    return path;
  }

  double _edgeWidth(int depth, bool isHot) {
    final base = depth == 0 ? 2.6 : (depth == 1 ? 2.0 : 1.6);
    return isHot ? base + 1.2 : base;
  }

  @override
  bool shouldRepaint(covariant _EdgePainter oldDelegate) =>
      oldDelegate.positions != positions ||
      oldDelegate.highlightedIds != highlightedIds ||
      oldDelegate.edges.length != edges.length;
}

// ─── nodes ───────────────────────────────────────────────────────────────

class _PositionedNode extends StatefulWidget {
  final MindMapNode node;
  final Offset basePosition;
  final bool isExpanding;
  final bool isCollapsed;
  final bool isSelected;
  final bool isDragging;
  final bool isSaved;
  final int hiddenChildCount;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPressStart;
  final void Function(Offset delta) onLongPressUpdate;
  final VoidCallback onLongPressEnd;

  const _PositionedNode({
    super.key,
    required this.node,
    required this.basePosition,
    required this.isExpanding,
    required this.isCollapsed,
    required this.isSelected,
    required this.isDragging,
    required this.isSaved,
    required this.hiddenChildCount,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPressStart,
    required this.onLongPressUpdate,
    required this.onLongPressEnd,
  });

  @override
  State<_PositionedNode> createState() => _PositionedNodeState();
}

class _PositionedNodeState extends State<_PositionedNode> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    final size = MindMapCanvas._chipSize(widget.node.type);
    // Chip core + selected halo are stacked centered on the same point.
    // Halo extends past chip bounds by 22px in every direction.
    const haloPad = 22.0;
    final outerW = size.width + haloPad * 2;
    final outerH = size.height + haloPad * 2;
    final highlighted = widget.isSelected || widget.isDragging;

    return Positioned(
      left: widget.basePosition.dx - outerW / 2,
      top: widget.basePosition.dy - outerH / 2,
      width: outerW,
      height: outerH,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.elasticOut,
        builder: (context, t, child) {
          // Clamp so elastic overshoot doesn't make the node huge briefly.
          final scale = t.clamp(0.0, 1.08);
          return Transform.scale(scale: scale, child: child);
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (highlighted) _HaloRing(size: size, color: _accentColor()),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onDoubleTap: widget.onDoubleTap,
              onTapDown: (_) => setState(() => _pressing = true),
              onTapUp: (_) => setState(() => _pressing = false),
              onTapCancel: () => setState(() => _pressing = false),
              onLongPressStart: (_) {
                setState(() => _pressing = false);
                widget.onLongPressStart();
              },
              onLongPressMoveUpdate: (d) =>
                  widget.onLongPressUpdate(d.offsetFromOrigin),
              onLongPressEnd: (_) => widget.onLongPressEnd(),
              onLongPressCancel: widget.onLongPressEnd,
              child: AnimatedScale(
                scale: widget.isDragging
                    ? 1.07
                    : (_pressing ? 0.96 : 1.0),
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                child: _NodeChip(
                  node: widget.node,
                  width: size.width,
                  height: size.height,
                  isExpanding: widget.isExpanding,
                  isCollapsed: widget.isCollapsed,
                  isHighlighted: highlighted,
                  isSaved: widget.isSaved,
                  hiddenChildCount: widget.hiddenChildCount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor() => MindMapCanvas.accentForNode(widget.node);
}

class _HaloRing extends StatelessWidget {
  final Size size;
  final Color color;
  const _HaloRing({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size.width + 36,
        height: size.height + 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((size.height + 36) / 2),
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.32),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.4, 1.0],
          ),
        ),
      ),
    );
  }
}

class _NodeChip extends StatelessWidget {
  final MindMapNode node;
  final double width;
  final double height;
  final bool isExpanding;
  final bool isCollapsed;
  final bool isHighlighted;
  final bool isSaved;
  final int hiddenChildCount;

  const _NodeChip({
    required this.node,
    required this.width,
    required this.height,
    required this.isExpanding,
    required this.isCollapsed,
    required this.isHighlighted,
    required this.isSaved,
    required this.hiddenChildCount,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width,
          height: height,
          decoration: _decoration(context).copyWith(borderRadius: radius),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: _Content(node: node),
        ),
        if (isSaved)
          const Positioned(top: -5, right: -2, child: _SavedStar()),
        if (isCollapsed && hiddenChildCount > 0)
          Positioned(
            top: -6,
            right: -4,
            child: _CountBadge(count: hiddenChildCount, color: _typeColor()),
          ),
        if (isExpanding)
          Positioned(
            bottom: -14,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  valueColor: AlwaysStoppedAnimation(_typeColor()),
                ),
              ),
            ),
          ),
      ],
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    final shadow = _shadow(context);
    final accent = MindMapCanvas.accentForNode(node);
    final surface = context.clay.surface;
    final text = context.clay.text;
    switch (node.type) {
      case MindMapNodeType.topic:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple, AppColors.purpleDeep],
          ),
          border: Border.all(color: text, width: 2),
          boxShadow: shadow,
        );
      case MindMapNodeType.category:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              surface,
              accent.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(
            color: isHighlighted ? text : accent,
            width: 2,
          ),
          boxShadow: shadow,
        );
      case MindMapNodeType.word:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              surface,
              accent.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: isHighlighted ? text : accent,
            width: isHighlighted ? 2 : 1.5,
          ),
          boxShadow: shadow,
        );
    }
  }

  List<BoxShadow> _shadow(BuildContext context) {
    final text = context.clay.text;
    if (isHighlighted) {
      return [
        BoxShadow(
          color: text,
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ];
    }
    return [
      BoxShadow(
        color: text.withValues(alpha: 0.20),
        offset: const Offset(2, 2),
        blurRadius: 0,
      ),
    ];
  }

  Color _typeColor() => MindMapCanvas.accentForNode(node);
}

class _Content extends StatelessWidget {
  final MindMapNode node;
  const _Content({required this.node});

  @override
  Widget build(BuildContext context) {
    switch (node.type) {
      case MindMapNodeType.topic:
        final hasPhonetic =
            node.phonetic != null && node.phonetic!.isNotEmpty;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(iconId: 'vocabHub', size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    node.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
            if (hasPhonetic) ...[
              const SizedBox(height: 3),
              Text(
                node.phonetic!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1,
                ),
              ),
            ],
          ],
        );
      case MindMapNodeType.category:
        return Text(
          node.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.clay.text,
            height: 1.15,
          ),
        );
      case MindMapNodeType.word:
        return _WordContent(node: node);
    }
  }
}

/// Word-node content stack: bold label on top, IPA + POS abbreviation row
/// underneath. POS abbreviation is a compact coral pill (e.g. `n.`, `v.`,
/// `adj.`) so the learner can scan the canvas and instantly know what
/// grammatical role each word plays without opening the detail sheet.
class _WordContent extends StatelessWidget {
  final MindMapNode node;
  const _WordContent({required this.node});

  @override
  Widget build(BuildContext context) {
    final hasPhonetic = node.phonetic != null && node.phonetic!.isNotEmpty;
    final pos = _posAbbrev(node.partOfSpeech);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          node.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.clay.text,
            height: 1.1,
          ),
        ),
        if (hasPhonetic || pos != null) ...[
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasPhonetic)
                Flexible(
                  child: Text(
                    node.phonetic!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: context.clay.textMuted,
                      height: 1,
                    ),
                  ),
                ),
              if (hasPhonetic && pos != null) const SizedBox(width: 5),
              if (pos != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pos,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coral,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String? _posAbbrev(String? raw) {
    if (raw == null) return null;
    final lower = raw.toLowerCase();
    if (lower.contains('phrasal verb')) return 'pv.';
    if (lower.contains('idiom')) return 'idm.';
    if (lower.contains('expression')) return 'expr.';
    if (lower.contains('noun')) return 'n.';
    if (lower.contains('verb')) return 'v.';
    if (lower.contains('adverb')) return 'adv.';
    if (lower.contains('adjective')) return 'adj.';
    return null;
  }
}

/// Tiny gold star marking a word node that is already saved in the learner's
/// library. Hangs off the top-right corner of the chip; pure visual
/// indicator (the GestureDetector underneath still owns hit testing).
class _SavedStar extends StatelessWidget {
  const _SavedStar();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.gold,
          shape: BoxShape.circle,
          border: Border.all(color: context.clay.surface, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: context.clay.text,
              offset: const Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.clay.surface, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.clay.text,
            offset: const Offset(1, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        '+$count',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
