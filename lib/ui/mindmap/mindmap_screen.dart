import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/mindmap_node.dart';
import '../../domain/models/mindmap_edge.dart';
import '../../domain/models/character.dart';
import '../../domain/models/world_area.dart';
import '../../providers/providers.dart';
import 'mindmap_painter.dart';
import 'mindmap_dialogs.dart';
import 'quick_add_sheet.dart';

enum MindmapMode { view, connect }

class MindmapScreen extends ConsumerStatefulWidget {
  final int bookId;

  const MindmapScreen({super.key, required this.bookId});

  @override
  ConsumerState<MindmapScreen> createState() => _MindmapScreenState();
}

class _MindmapScreenState extends ConsumerState<MindmapScreen> {
  final TransformationController _transformController = TransformationController();
  MindmapMode _mode = MindmapMode.view;
  int? _connectFromNodeId;
  int? _draggingNodeId;

  // Local mutable copy of nodes for smooth dragging
  List<MindmapNode> _localNodes = [];
  bool _hasPendingDrag = false;
  bool _hasInitiallyScrolled = false;

  static const double _nodeWidth = 90;
  static const double _nodeHeight = 60;

  Offset _suggestedNewNodeCenter() {
    if (_localNodes.isEmpty) return const Offset(2000, 2000);
    var sumX = 0.0;
    var sumY = 0.0;
    for (final n in _localNodes) {
      sumX += n.positionX;
      sumY += n.positionY;
    }
    return Offset(sumX / _localNodes.length, sumY / _localNodes.length);
  }

  Offset _findFreeSpotNear(Offset center) {
    bool overlaps(Offset candidate) {
      final candRect = Rect.fromCenter(center: candidate, width: _nodeWidth + 20, height: _nodeHeight + 20);
      for (final n in _localNodes) {
        final r = Rect.fromCenter(center: Offset(n.positionX, n.positionY), width: _nodeWidth + 20, height: _nodeHeight + 20);
        if (candRect.overlaps(r)) return true;
      }
      return false;
    }

    if (!overlaps(center)) return center;

    const ringStep = 90.0;
    const angleStep = pi / 6;
    for (var ring = 1; ring <= 14; ring++) {
      final radius = ring * ringStep;
      for (var a = 0.0; a < 2 * pi; a += angleStep) {
        final candidate = center + Offset(cos(a) * radius, sin(a) * radius);
        if (!overlaps(candidate)) return candidate;
      }
    }

    return center;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _centerOnNodes(List<MindmapNode> nodes) {
    if (nodes.isEmpty || _hasInitiallyScrolled) return;
    _hasInitiallyScrolled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;

      // Find bounding box of all nodes
      double minX = double.infinity, minY = double.infinity;
      double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
      for (final n in nodes) {
        if (n.positionX < minX) minX = n.positionX;
        if (n.positionY < minY) minY = n.positionY;
        if (n.positionX > maxX) maxX = n.positionX;
        if (n.positionY > maxY) maxY = n.positionY;
      }

      // Center of all nodes
      final centerX = (minX + maxX) / 2;
      final centerY = (minY + maxY) / 2;

      // Calculate scale to fit all nodes with some padding
      final nodesWidth = (maxX - minX) + 200;
      final nodesHeight = (maxY - minY) + 200;
      final scaleX = size.width / nodesWidth;
      final scaleY = (size.height - 150) / nodesHeight; // account for app bar
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final clampedScale = scale.clamp(0.3, 1.5);

      // Translate so the center of nodes is at center of screen
      final tx = size.width / 2 - centerX * clampedScale;
      final ty = (size.height - 150) / 2 - centerY * clampedScale;

      final matrix = Matrix4.identity();
      matrix.storage[0] = clampedScale;  // scaleX
      matrix.storage[5] = clampedScale;  // scaleY
      matrix.storage[10] = 1.0;          // scaleZ
      matrix.storage[12] = tx;           // translateX
      matrix.storage[13] = ty;           // translateY
      _transformController.value = matrix;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nodesAsync = ref.watch(mindmapNodesByBookProvider(widget.bookId));
    final edgesAsync = ref.watch(mindmapEdgesByBookProvider(widget.bookId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindmap'),
        actions: [
          // Mode toggle
          IconButton(
            icon: Icon(
              _mode == MindmapMode.connect ? Icons.link : Icons.link_off,
              color: _mode == MindmapMode.connect ? colorScheme.primary : null,
            ),
            tooltip: _mode == MindmapMode.connect ? 'Cancel connecting' : 'Connect nodes',
            onPressed: () {
              setState(() {
                if (_mode == MindmapMode.connect) {
                  _mode = MindmapMode.view;
                  _connectFromNodeId = null;
                } else {
                  _mode = MindmapMode.connect;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Fit to content',
            onPressed: () {
              _hasInitiallyScrolled = false;
              _centerOnNodes(_localNodes);
            },
          ),
        ],
      ),
      body: nodesAsync.when(
        data: (nodes) {
          // Update local nodes from DB unless we're mid-drag
          if (!_hasPendingDrag) {
            _localNodes = List.of(nodes);
          }

          // Auto-center on first load
          _centerOnNodes(_localNodes);

          return edgesAsync.when(
            data: (edges) => _buildCanvas(context, _localNodes, edges),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'quickAdd',
            onPressed: () => _showQuickAddSheet(context),
            tooltip: 'Quick Add (natural language)',
            child: const Icon(Icons.auto_fix_high),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'addNode',
            onPressed: () => _showAddNodeDialog(context),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          if (_mode == MindmapMode.connect && _connectFromNodeId != null)
            FloatingActionButton.small(
              heroTag: 'cancelConnect',
              backgroundColor: colorScheme.errorContainer,
              onPressed: () {
                setState(() {
                  _mode = MindmapMode.view;
                  _connectFromNodeId = null;
                });
              },
              child: Icon(Icons.close, color: colorScheme.onErrorContainer),
            ),
        ],
      ),
      bottomNavigationBar: _mode == MindmapMode.connect
          ? Container(
              color: colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                child: Text(
                  _connectFromNodeId == null
                      ? 'Tap a node to start connecting'
                      : 'Tap another node to create a connection',
                  style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCanvas(BuildContext context, List<MindmapNode> nodes, List<MindmapEdge> edges) {
    final colorScheme = Theme.of(context).colorScheme;

    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Empty mindmap', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Tap + to add your first node', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _autoCreateFromEntities(context),
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto-create from characters & areas'),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      transformationController: _transformController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 4.0,
      constrained: false,
      // Disable InteractiveViewer pan when dragging a node
      panEnabled: _draggingNodeId == null,
      child: SizedBox(
        width: 4000,
        height: 4000,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Edge painter
            CustomPaint(
              size: const Size(4000, 4000),
              painter: EdgePainter(
                nodes: nodes,
                edges: edges,
                textDirection: Directionality.of(context),
                edgeColor: colorScheme.outline,
                labelColor: colorScheme.onSurface,
                labelBackgroundColor: colorScheme.surface.withValues(alpha: 0.9),
              ),
            ),
            // Nodes
            ...nodes.map((node) => _buildNodeWidget(context, node, edges)),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, MindmapNode node, List<MindmapEdge> edges) {
    final colorScheme = Theme.of(context).colorScheme;
    final isConnectSource = _connectFromNodeId == node.id;
    final isDragging = _draggingNodeId == node.id;
    final nodeColor = Color(node.color);

    final canDrag = _mode == MindmapMode.view;

    return Positioned(
      left: node.positionX - 45,
      top: node.positionY - 30,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Tap for node details / connect selection
        onTap: () => _handleNodeTap(context, node, edges),
        onPanStart: !canDrag
            ? null
            : (_) {
                setState(() {
                  _draggingNodeId = node.id;
                  _hasPendingDrag = true;
                });
              },
        onPanUpdate: !canDrag
            ? null
            : (details) {
                if (_draggingNodeId == node.id) {
                  final scale = _transformController.value.getMaxScaleOnAxis();
                  setState(() {
                    final idx = _localNodes.indexWhere((n) => n.id == node.id);
                    if (idx != -1) {
                      _localNodes[idx] = _localNodes[idx].copyWith(
                        positionX: _localNodes[idx].positionX + details.delta.dx / scale,
                        positionY: _localNodes[idx].positionY + details.delta.dy / scale,
                      );
                    }
                  });
                }
              },
        onPanEnd: !canDrag
            ? null
            : (_) {
                if (_draggingNodeId == node.id) {
                  final movedNode = _localNodes.firstWhere((n) => n.id == node.id);
                  ref.read(mindmapRepositoryProvider).updateNodePosition(
                        node.id!,
                        movedNode.positionX,
                        movedNode.positionY,
                      );
                  setState(() {
                    _draggingNodeId = null;
                    _hasPendingDrag = false;
                  });
                }
              },
        // Long press to enter connect mode
        onLongPress: () {
          if (_mode == MindmapMode.view) {
            setState(() {
              _mode = MindmapMode.connect;
              _connectFromNodeId = node.id;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 90,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isConnectSource
                ? colorScheme.primary
                : isDragging
                    ? nodeColor.withValues(alpha: 0.3)
                    : nodeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConnectSource ? colorScheme.primary : nodeColor,
              width: isConnectSource ? 3 : 2,
            ),
            boxShadow: isDragging
                ? [BoxShadow(color: nodeColor.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 3)]
                : [BoxShadow(color: nodeColor.withValues(alpha: 0.15), blurRadius: 4, spreadRadius: 1)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.drag_indicator,
                size: 14,
                color: (isConnectSource ? colorScheme.onPrimary : colorScheme.onSurfaceVariant).withValues(alpha: 0.6),
              ),
              Icon(
                _iconForEntityType(node.entityType),
                size: 18,
                color: isConnectSource ? colorScheme.onPrimary : nodeColor,
              ),
              const SizedBox(height: 4),
              Text(
                node.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isConnectSource ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForEntityType(MindmapEntityType type) {
    switch (type) {
      case MindmapEntityType.character:
        return Icons.person;
      case MindmapEntityType.worldArea:
        return Icons.public;
      case MindmapEntityType.custom:
        return Icons.circle;
    }
  }

  void _handleNodeTap(BuildContext context, MindmapNode node, List<MindmapEdge> edges) {
    if (_mode == MindmapMode.connect) {
      if (_connectFromNodeId == null) {
        setState(() => _connectFromNodeId = node.id);
      } else if (_connectFromNodeId != node.id) {
        _showAddEdgeDialog(context, _connectFromNodeId!, node.id!);
        setState(() {
          _connectFromNodeId = null;
          _mode = MindmapMode.view;
        });
      }
    } else {
      _showNodeDetails(context, node, edges);
    }
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => QuickAddSheet(bookId: widget.bookId),
    ).then((result) {
      if (result == true) {
        // Re-center on nodes after quick add
        _hasInitiallyScrolled = false;
      }
    });
  }

  void _showAddNodeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddNodeDialog(
        bookId: widget.bookId,
        onSave: (node) async {
          final mindmapRepo = ref.read(mindmapRepositoryProvider);
          var nodeToInsert = node;
          final normalizedLabel = node.label.trim().toLowerCase();

          if (node.entityType == MindmapEntityType.character) {
            final characterRepo = ref.read(characterRepositoryProvider);
            final characters = await characterRepo.watchCharactersByBook(widget.bookId).first;
            final existing = characters.where((c) => c.name.trim().toLowerCase() == normalizedLabel).firstOrNull;

            if (existing != null) {
              nodeToInsert = node.copyWith(entityId: existing.id, label: existing.name);
            } else {
              final newId = await characterRepo.addCharacter(
                Character(
                  bookId: widget.bookId,
                  name: node.label.trim(),
                ),
              );
              nodeToInsert = node.copyWith(entityId: newId);
            }
          } else if (node.entityType == MindmapEntityType.worldArea) {
            final areaRepo = ref.read(worldAreaRepositoryProvider);
            final areas = await areaRepo.watchWorldAreasByBook(widget.bookId).first;
            final existing = areas.where((a) => a.name.trim().toLowerCase() == normalizedLabel).firstOrNull;

            if (existing != null) {
              nodeToInsert = node.copyWith(entityId: existing.id, label: existing.name);
            } else {
              final newId = await areaRepo.addWorldArea(
                WorldArea(
                  bookId: widget.bookId,
                  name: node.label.trim(),
                ),
              );
              nodeToInsert = node.copyWith(entityId: newId);
            }
          }

          final suggested = _findFreeSpotNear(_suggestedNewNodeCenter());
          nodeToInsert = nodeToInsert.copyWith(positionX: suggested.dx, positionY: suggested.dy);

          await mindmapRepo.addNode(nodeToInsert);
          // Re-center after adding first node
          if (_localNodes.isEmpty) {
            _hasInitiallyScrolled = false;
          }
        },
      ),
    );
  }

  void _showAddEdgeDialog(BuildContext context, int fromId, int toId) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (_) => AddEdgeDialog(
        bookId: widget.bookId,
        fromNodeId: fromId,
        toNodeId: toId,
        fromLabel: _localNodes.firstWhere((n) => n.id == fromId).label,
        toLabel: _localNodes.firstWhere((n) => n.id == toId).label,
        onSave: (edge) async {
          await ref.read(mindmapRepositoryProvider).addEdge(edge);
        },
      ),
    );
  }

  void _showNodeDetails(BuildContext context, MindmapNode node, List<MindmapEdge> edges) {
    final nodeEdges = edges.where((e) => e.fromNodeId == node.id || e.toNodeId == node.id).toList();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (_) => NodeDetailSheet(
        node: node,
        edges: nodeEdges,
        allNodes: _localNodes,
        onDelete: () async {
          Navigator.pop(context);
          for (final edge in nodeEdges) {
            await ref.read(mindmapRepositoryProvider).deleteEdge(edge.id!);
          }
          await ref.read(mindmapRepositoryProvider).deleteNode(node.id!);
        },
        onDeleteEdge: (edgeId) async {
          await ref.read(mindmapRepositoryProvider).deleteEdge(edgeId);
        },
      ),
    );
  }

  Future<void> _autoCreateFromEntities(BuildContext context) async {
    final repo = ref.read(mindmapRepositoryProvider);
    final charRepo = ref.read(characterRepositoryProvider);
    final areaRepo = ref.read(worldAreaRepositoryProvider);

    final characters = await charRepo.watchCharactersByBook(widget.bookId).first;
    final areas = await areaRepo.watchWorldAreasByBook(widget.bookId).first;

    if (characters.isEmpty && areas.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No characters or world areas to import')),
        );
      }
      return;
    }

    final random = Random();
    const centerX = 2000.0;
    const centerY = 2000.0;
    const radius = 300.0;
    final total = characters.length + areas.length;

    for (var i = 0; i < characters.length; i++) {
      final angle = (2 * pi * i) / total;
      await repo.addNode(MindmapNode(
        bookId: widget.bookId,
        entityType: MindmapEntityType.character,
        entityId: characters[i].id,
        label: characters[i].name,
        positionX: centerX + radius * cos(angle) + random.nextDouble() * 40 - 20,
        positionY: centerY + radius * sin(angle) + random.nextDouble() * 40 - 20,
        color: 0xFF6750A4,
      ));
    }

    for (var i = 0; i < areas.length; i++) {
      final angle = (2 * pi * (characters.length + i)) / total;
      await repo.addNode(MindmapNode(
        bookId: widget.bookId,
        entityType: MindmapEntityType.worldArea,
        entityId: areas[i].id,
        label: areas[i].name,
        positionX: centerX + radius * cos(angle) + random.nextDouble() * 40 - 20,
        positionY: centerY + radius * sin(angle) + random.nextDouble() * 40 - 20,
        color: 0xFF2E7D32,
      ));
    }

    // Center on newly created nodes
    _hasInitiallyScrolled = false;
  }
}
