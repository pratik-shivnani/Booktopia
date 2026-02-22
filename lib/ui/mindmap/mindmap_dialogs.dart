import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/mindmap_node.dart';
import '../../domain/models/mindmap_edge.dart';
import '../../providers/providers.dart';

// --- Add Node Dialog ---

class AddNodeDialog extends ConsumerStatefulWidget {
  final int bookId;
  final Future<void> Function(MindmapNode) onSave;

  const AddNodeDialog({super.key, required this.bookId, required this.onSave});

  @override
  ConsumerState<AddNodeDialog> createState() => _AddNodeDialogState();
}

class _EntityOption {
  final int id;
  final String label;

  const _EntityOption({required this.id, required this.label});
}

class _AddNodeDialogState extends ConsumerState<AddNodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  MindmapEntityType _type = MindmapEntityType.custom;
  int _selectedColor = 0xFF6750A4;
  bool _saving = false;
  int? _selectedEntityId;

  static const _colorOptions = [
    0xFF6750A4, // Purple
    0xFF2E7D32, // Green
    0xFFC62828, // Red
    0xFF1565C0, // Blue
    0xFFEF6C00, // Orange
    0xFF6A1B9A, // Deep Purple
    0xFF00838F, // Teal
    0xFF4E342E, // Brown
  ];

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final random = Random();
    final node = MindmapNode(
      bookId: widget.bookId,
      entityType: _type,
      entityId: _selectedEntityId,
      label: _labelController.text.trim(),
      positionX: 2000.0 + random.nextDouble() * 200 - 100,
      positionY: 2000.0 + random.nextDouble() * 200 - 100,
      color: _selectedColor,
    );

    await widget.onSave(node);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildLabelField({List<_EntityOption>? options}) {
      if (options == null) {
        return TextFormField(
          controller: _labelController,
          decoration: const InputDecoration(labelText: 'Label *', prefixIcon: Icon(Icons.label)),
          textCapitalization: TextCapitalization.words,
          validator: (v) => v == null || v.trim().isEmpty ? 'Label is required' : null,
          onChanged: (_) {
            if (_selectedEntityId != null) {
              setState(() => _selectedEntityId = null);
            }
          },
        );
      }

      return Autocomplete<_EntityOption>(
        displayStringForOption: (o) => o.label,
        optionsBuilder: (value) {
          final q = value.text.trim().toLowerCase();
          if (q.isEmpty) return options;
          return options.where((o) => o.label.toLowerCase().contains(q));
        },
        onSelected: (o) {
          setState(() {
            _selectedEntityId = o.id;
            _labelController.text = o.label;
          });
        },
        fieldViewBuilder: (context, _, focusNode, __) {
          return TextFormField(
            controller: _labelController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'Label *',
              prefixIcon: Icon(_type == MindmapEntityType.character ? Icons.person : Icons.public),
              suffixIcon: _selectedEntityId != null
                  ? IconButton(
                      onPressed: () => setState(() => _selectedEntityId = null),
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear selection',
                    )
                  : null,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) => v == null || v.trim().isEmpty ? 'Label is required' : null,
            onChanged: (_) {
              if (_selectedEntityId != null) {
                setState(() => _selectedEntityId = null);
              }
            },
          );
        },
      );
    }

    Widget labelField;
    if (_type == MindmapEntityType.character) {
      final charsAsync = ref.watch(charactersByBookProvider(widget.bookId));
      labelField = charsAsync.when(
        data: (chars) => buildLabelField(
          options: chars
              .where((c) => c.id != null)
              .map((c) => _EntityOption(id: c.id!, label: c.name))
              .toList(),
        ),
        loading: () => buildLabelField(),
        error: (_, __) => buildLabelField(),
      );
    } else if (_type == MindmapEntityType.worldArea) {
      final areasAsync = ref.watch(worldAreasByBookProvider(widget.bookId));
      labelField = areasAsync.when(
        data: (areas) => buildLabelField(
          options: areas
              .where((a) => a.id != null)
              .map((a) => _EntityOption(id: a.id!, label: a.name))
              .toList(),
        ),
        loading: () => buildLabelField(),
        error: (_, __) => buildLabelField(),
      );
    } else {
      labelField = buildLabelField();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Add Node', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              labelField,
              const SizedBox(height: 16),

              Text('Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: MindmapEntityType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) {
                      setState(() {
                        _type = type;
                        _selectedEntityId = null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Text('Color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((c) {
                  final isSelected = _selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: colorScheme.onSurface, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add Node'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Add Edge Dialog ---

class AddEdgeDialog extends StatefulWidget {
  final int bookId;
  final int fromNodeId;
  final int toNodeId;
  final String fromLabel;
  final String toLabel;
  final Future<void> Function(MindmapEdge) onSave;

  const AddEdgeDialog({
    super.key,
    required this.bookId,
    required this.fromNodeId,
    required this.toNodeId,
    required this.fromLabel,
    required this.toLabel,
    required this.onSave,
  });

  @override
  State<AddEdgeDialog> createState() => _AddEdgeDialogState();
}

class _AddEdgeDialogState extends State<AddEdgeDialog> {
  final _labelController = TextEditingController();
  bool _saving = false;

  static const _suggestions = [
    'allies with',
    'enemies with',
    'lives in',
    'rules over',
    'reports to',
    'parent of',
    'sibling of',
    'loves',
    'mentors',
    'betrayed',
    'travels to',
    'guards',
  ];

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final edge = MindmapEdge(
      bookId: widget.bookId,
      fromNodeId: widget.fromNodeId,
      toNodeId: widget.toNodeId,
      label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
    );

    await widget.onSave(edge);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Connect Nodes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(widget.fromLabel)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 20),
                ),
                Chip(label: Text(widget.toLabel)),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Relationship (optional)',
                hintText: 'e.g. allies with, lives in...',
                prefixIcon: Icon(Icons.link),
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestions.map((s) {
                return ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _labelController.text = s,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Node Detail Sheet ---

class NodeDetailSheet extends StatelessWidget {
  final MindmapNode node;
  final List<MindmapEdge> edges;
  final List<MindmapNode> allNodes;
  final VoidCallback onDelete;
  final Future<void> Function(int edgeId) onDeleteEdge;

  const NodeDetailSheet({
    super.key,
    required this.node,
    required this.edges,
    required this.allNodes,
    required this.onDelete,
    required this.onDeleteEdge,
  });

  String _nodeLabel(int nodeId) {
    return allNodes.where((n) => n.id == nodeId).firstOrNull?.label ?? '?';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(node.color),
                radius: 20,
                child: Icon(
                  node.entityType == MindmapEntityType.character
                      ? Icons.person
                      : node.entityType == MindmapEntityType.worldArea
                          ? Icons.public
                          : Icons.circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.label, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(node.entityType.label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (edges.isNotEmpty) ...[
            Text('Connections', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            ...edges.map((edge) {
              final isFrom = edge.fromNodeId == node.id;
              final otherLabel = isFrom ? _nodeLabel(edge.toNodeId) : _nodeLabel(edge.fromNodeId);

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isFrom ? Icons.arrow_forward : Icons.arrow_back,
                  size: 18,
                  color: colorScheme.primary,
                ),
                title: Text(
                  isFrom
                      ? '${edge.label ?? "→"} $otherLabel'
                      : '$otherLabel ${edge.label ?? "→"}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.link_off, size: 18, color: colorScheme.error),
                  onPressed: () => onDeleteEdge(edge.id!),
                ),
              );
            }),
          ] else
            Text(
              'No connections yet',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
