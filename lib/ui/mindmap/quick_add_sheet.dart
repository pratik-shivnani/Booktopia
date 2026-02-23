import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/character.dart';
import '../../domain/models/world_area.dart';
import '../../domain/models/mindmap_node.dart';
import '../../domain/models/mindmap_edge.dart';
import '../../providers/providers.dart';
import 'quick_add_parser.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  final int bookId;

  const QuickAddSheet({super.key, required this.bookId});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _textController = TextEditingController();
  QuickAddResult? _result;
  bool _saving = false;
  bool _showPreview = false;

  // Track which parsed items the user wants to keep
  late Set<int> _enabledEntities;
  late Set<int> _enabledConnections;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parse() {
    final characters = ref.read(charactersByBookProvider(widget.bookId)).valueOrNull ?? [];
    final areas = ref.read(worldAreasByBookProvider(widget.bookId)).valueOrNull ?? [];

    final parser = QuickAddParser(
      existingCharacters: characters,
      existingWorldAreas: areas,
    );

    final result = parser.parse(_textController.text);
    setState(() {
      _result = result;
      _showPreview = true;
      _enabledEntities = Set.from(List.generate(result.entities.length, (i) => i));
      _enabledConnections = Set.from(List.generate(result.connections.length, (i) => i));
    });
  }

  Future<void> _save() async {
    if (_result == null) return;
    setState(() => _saving = true);

    try {
      final mindmapRepo = ref.read(mindmapRepositoryProvider);
      final charRepo = ref.read(characterRepositoryProvider);
      final areaRepo = ref.read(worldAreaRepositoryProvider);

      // Get existing mindmap nodes to avoid duplicates and find positions
      final existingNodes = await mindmapRepo.watchNodesByBook(widget.bookId).first;

      // Map: entity name (lowercase) -> node id (for connections later)
      final nodeIdMap = <String, int>{};

      // Register existing nodes
      for (final n in existingNodes) {
        nodeIdMap[n.label.toLowerCase()] = n.id!;
      }

      // Calculate center for new nodes
      double sumX = 0, sumY = 0;
      if (existingNodes.isNotEmpty) {
        for (final n in existingNodes) {
          sumX += n.positionX;
          sumY += n.positionY;
        }
        sumX /= existingNodes.length;
        sumY /= existingNodes.length;
      } else {
        sumX = 2000;
        sumY = 2000;
      }

      final allNodeRects = existingNodes
          .map((n) => Rect.fromCenter(center: Offset(n.positionX, n.positionY), width: 110, height: 80))
          .toList();

      Offset findFreeSpot(Offset center) {
        bool overlaps(Offset c) {
          final r = Rect.fromCenter(center: c, width: 110, height: 80);
          return allNodeRects.any((existing) => existing.overlaps(r));
        }
        if (!overlaps(center)) return center;
        const ringStep = 100.0;
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

      // 1. Create new entities and mindmap nodes
      for (var i = 0; i < _result!.entities.length; i++) {
        if (!_enabledEntities.contains(i)) continue;
        final entity = _result!.entities[i];
        final key = entity.name.toLowerCase();

        // Skip if a node already exists for this name
        if (nodeIdMap.containsKey(key)) continue;

        int? entityId = entity.existingId;
        final entityType = entity.type == ParsedEntityType.character
            ? MindmapEntityType.character
            : MindmapEntityType.worldArea;

        // Create DB entity if new
        if (entity.isNew) {
          if (entity.type == ParsedEntityType.character) {
            entityId = await charRepo.addCharacter(Character(
              bookId: widget.bookId,
              name: entity.name,
              description: entity.description,
            ));
          } else {
            entityId = await areaRepo.addWorldArea(WorldArea(
              bookId: widget.bookId,
              name: entity.name,
              description: entity.description,
            ));
          }
        }

        // Create mindmap node
        final color = entity.type == ParsedEntityType.character ? 0xFF6750A4 : 0xFF2E7D32;
        final spot = findFreeSpot(Offset(sumX, sumY));
        allNodeRects.add(Rect.fromCenter(center: spot, width: 110, height: 80));

        final nodeId = await mindmapRepo.addNode(MindmapNode(
          bookId: widget.bookId,
          entityType: entityType,
          entityId: entityId,
          label: entity.name,
          positionX: spot.dx,
          positionY: spot.dy,
          color: color,
        ));

        nodeIdMap[key] = nodeId;
      }

      // 2. Create edges
      for (var i = 0; i < _result!.connections.length; i++) {
        if (!_enabledConnections.contains(i)) continue;
        final conn = _result!.connections[i];
        final fromId = nodeIdMap[conn.fromName.toLowerCase()];
        final toId = nodeIdMap[conn.toName.toLowerCase()];

        if (fromId != null && toId != null && fromId != toId) {
          await mindmapRepo.addEdge(MindmapEdge(
            bookId: widget.bookId,
            fromNodeId: fromId,
            toNodeId: toId,
            label: conn.label,
          ));
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${_enabledEntities.length} entities & ${_enabledConnections.length} connections',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              Icon(Icons.auto_fix_high, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Quick Add', style: textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Describe what happens. Tag new entities like: Name (new char) or Name (new wa)',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          if (!_showPreview) ...[
            // Input phase
            TextField(
              controller: _textController,
              maxLines: 6,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'e.g. Sylver visits the Adventure Guild (new wa) and meets Shera (new char)\n\nTom (new char - shade) is servant of Sylver',
                hintMaxLines: 4,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _textController.text.trim().isEmpty ? null : _parse,
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
            ),
          ] else ...[
            // Preview phase
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warnings
                    if (_result!.warnings.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _result!.warnings
                              .map((w) => Text(w, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 12)))
                              .toList(),
                        ),
                      ),

                    // Entities
                    if (_result!.entities.isNotEmpty) ...[
                      Text('Entities', style: textTheme.titleSmall),
                      const SizedBox(height: 4),
                      ..._result!.entities.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final enabled = _enabledEntities.contains(i);
                        final isChar = e.type == ParsedEntityType.character;

                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: enabled,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _enabledEntities.add(i);
                              } else {
                                _enabledEntities.remove(i);
                              }
                            });
                          },
                          secondary: CircleAvatar(
                            radius: 14,
                            backgroundColor: isChar
                                ? const Color(0xFF6750A4).withValues(alpha: 0.15)
                                : const Color(0xFF2E7D32).withValues(alpha: 0.15),
                            child: Icon(
                              isChar ? Icons.person : Icons.public,
                              size: 16,
                              color: isChar ? const Color(0xFF6750A4) : const Color(0xFF2E7D32),
                            ),
                          ),
                          title: Text(
                            e.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: enabled ? null : TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Text(
                            '${e.isNew ? "New" : "Existing"} ${isChar ? "Character" : "World Area"}'
                            '${e.description != null ? " · ${e.description}" : ""}',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    // Connections
                    if (_result!.connections.isNotEmpty) ...[
                      Text('Connections', style: textTheme.titleSmall),
                      const SizedBox(height: 4),
                      ..._result!.connections.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        final enabled = _enabledConnections.contains(i);

                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: enabled,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _enabledConnections.add(i);
                              } else {
                                _enabledConnections.remove(i);
                              }
                            });
                          },
                          secondary: CircleAvatar(
                            radius: 14,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.arrow_forward, size: 14, color: colorScheme.onPrimaryContainer),
                          ),
                          title: Text(
                            '${c.fromName} → ${c.toName}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: enabled ? null : TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Text(
                            c.label,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }),
                    ],

                    if (_result!.entities.isEmpty && _result!.connections.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.warning_amber, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'No entities or connections found.\nMake sure to tag new items like: Name (new char) or Name (new wa)',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _showPreview = false;
                              _result = null;
                            }),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: (_saving || (_enabledEntities.isEmpty && _enabledConnections.isEmpty))
                        ? null
                        : _save,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_saving ? 'Saving...' : 'Add to Mindmap'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
