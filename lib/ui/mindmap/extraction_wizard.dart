import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/epub_service.dart';
import '../../data/services/heuristic_extractor.dart';
import '../../domain/models/character.dart' as domain_char;
import '../../domain/models/mindmap_edge.dart' as domain_edge;
import '../../domain/models/mindmap_node.dart' as domain_node;
import '../../domain/models/world_area.dart' as domain_area;
import '../../providers/providers.dart';

enum _WizardStep { scanning, characters, worldAreas, connections, applying, done }

class ExtractionWizardScreen extends ConsumerStatefulWidget {
  final int bookId;

  const ExtractionWizardScreen({super.key, required this.bookId});

  @override
  ConsumerState<ExtractionWizardScreen> createState() => _ExtractionWizardScreenState();
}

class _ExtractionWizardScreenState extends ConsumerState<ExtractionWizardScreen> {
  _WizardStep _step = _WizardStep.scanning;
  String _scanStatus = 'Preparing...';
  double _scanProgress = 0.0;

  List<String> _chapterTexts = [];
  List<ExtractedEntity> _characters = [];
  List<ExtractedEntity> _worldAreas = [];
  List<ExtractedConnection> _connections = [];

  int _charsAdded = 0;
  int _areasAdded = 0;
  int _nodesAdded = 0;
  int _edgesAdded = 0;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        _scanStatus = 'Loading EPUB...';
        _scanProgress = 0.05;
      });

      final epubData = await ref.read(epubRepositoryProvider).getByBookId(widget.bookId);
      if (epubData == null) {
        setState(() => _scanStatus = 'No EPUB file found for this book.');
        return;
      }

      final service = ref.read(epubServiceProvider);
      final parsed = await service.parseAndExtract(epubData.filePath);

      setState(() {
        _scanStatus = 'Reading chapters...';
        _scanProgress = 0.1;
      });

      // Read all chapters as HTML then strip to plain text
      final htmlChapters = <String>[];
      for (var i = 0; i < parsed.totalChapters; i++) {
        htmlChapters.add(await service.getChapterHtml(parsed, i));
        if (mounted) {
          setState(() {
            _scanProgress = 0.1 + (i / parsed.totalChapters) * 0.4;
            _scanStatus = 'Reading chapter ${i + 1} of ${parsed.totalChapters}...';
          });
        }
      }

      final extractor = HeuristicExtractor();
      _chapterTexts = extractor.chaptersToPlainText(htmlChapters);

      setState(() {
        _scanStatus = 'Extracting characters...';
        _scanProgress = 0.6;
      });

      _characters = extractor.extractCharacters(_chapterTexts);

      setState(() {
        _scanStatus = 'Extracting locations...';
        _scanProgress = 0.8;
      });

      final selectedCharNames = _characters
          .where((c) => c.selected)
          .map((c) => c.name)
          .toList();
      _worldAreas = extractor.extractWorldAreas(
        _chapterTexts,
        knownCharacterNames: selectedCharNames,
      );

      setState(() {
        _scanStatus = 'Done!';
        _scanProgress = 1.0;
        _step = _WizardStep.characters;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _scanStatus = 'Error: $e');
      }
    }
  }

  void _proceedToWorldAreas() {
    // Re-extract world areas excluding selected characters
    final extractor = HeuristicExtractor();
    final selectedCharNames = _characters
        .where((c) => c.selected)
        .map((c) => c.name)
        .toList();
    _worldAreas = extractor.extractWorldAreas(
      _chapterTexts,
      knownCharacterNames: selectedCharNames,
    );

    setState(() => _step = _WizardStep.worldAreas);
  }

  void _proceedToConnections() {
    final extractor = HeuristicExtractor();
    final charNames = _characters.where((c) => c.selected).map((c) => c.name).toList();
    final areaNames = _worldAreas.where((a) => a.selected).map((a) => a.name).toList();
    _connections = extractor.extractConnections(_chapterTexts, charNames, areaNames);

    setState(() => _step = _WizardStep.connections);
  }

  Future<void> _applyResults() async {
    setState(() => _step = _WizardStep.applying);

    try {
      final charRepo = ref.read(characterRepositoryProvider);
      final areaRepo = ref.read(worldAreaRepositoryProvider);
      final mindmapRepo = ref.read(mindmapRepositoryProvider);

      // Get existing data to avoid duplicates
      final existingChars = await charRepo.watchCharactersByBook(widget.bookId).first;
      final existingAreas = await areaRepo.watchWorldAreasByBook(widget.bookId).first;
      final existingNodes = await mindmapRepo.watchNodesByBook(widget.bookId).first;
      final existingEdges = await mindmapRepo.watchEdgesByBook(widget.bookId).first;

      final existingCharNames = existingChars.map((c) => c.name.toLowerCase()).toSet();
      final existingAreaNames = existingAreas.map((a) => a.name.toLowerCase()).toSet();

      // 1. Add characters
      final selectedChars = _characters.where((c) => c.selected).toList();
      final charNameToId = <String, int>{};

      // Map existing characters
      for (final c in existingChars) {
        charNameToId[c.name.toLowerCase()] = c.id!;
      }

      for (final char in selectedChars) {
        if (!existingCharNames.contains(char.name.toLowerCase())) {
          final id = await charRepo.addCharacter(
            domain_char.Character(bookId: widget.bookId, name: char.name),
          );
          charNameToId[char.name.toLowerCase()] = id;
          _charsAdded++;
        }
      }

      // 2. Add world areas
      final selectedAreas = _worldAreas.where((a) => a.selected).toList();
      final areaNameToId = <String, int>{};

      for (final a in existingAreas) {
        areaNameToId[a.name.toLowerCase()] = a.id!;
      }

      for (final area in selectedAreas) {
        if (!existingAreaNames.contains(area.name.toLowerCase())) {
          final id = await areaRepo.addWorldArea(
            domain_area.WorldArea(bookId: widget.bookId, name: area.name),
          );
          areaNameToId[area.name.toLowerCase()] = id;
          _areasAdded++;
        }
      }

      // 3. Create mindmap nodes for all selected entities
      final existingNodeLabels = existingNodes.map((n) => n.label.toLowerCase()).toSet();
      final labelToNodeId = <String, int>{};

      for (final n in existingNodes) {
        labelToNodeId[n.label.toLowerCase()] = n.id!;
      }

      final allSelected = [
        ...selectedChars.map((c) => (c.name, domain_node.MindmapEntityType.character, charNameToId[c.name.toLowerCase()])),
        ...selectedAreas.map((a) => (a.name, domain_node.MindmapEntityType.worldArea, areaNameToId[a.name.toLowerCase()])),
      ];

      for (var i = 0; i < allSelected.length; i++) {
        final (name, entityType, entityId) = allSelected[i];
        if (!existingNodeLabels.contains(name.toLowerCase())) {
          final row = i ~/ 5;
          final col = i % 5;
          final jitter = Random().nextDouble() * 30 - 15;
          final id = await mindmapRepo.addNode(domain_node.MindmapNode(
            bookId: widget.bookId,
            entityType: entityType,
            entityId: entityId,
            label: name,
            positionX: 80.0 + col * 180.0 + jitter,
            positionY: 80.0 + row * 180.0 + jitter,
            color: entityType == domain_node.MindmapEntityType.character
                ? 0xFF6750A4
                : 0xFF4CAF50,
          ));
          labelToNodeId[name.toLowerCase()] = id;
          _nodesAdded++;
        }
      }

      // 4. Create edges for selected connections
      final existingEdgeSet = <String>{};
      for (final e in existingEdges) {
        final a = min(e.fromNodeId, e.toNodeId);
        final b = max(e.fromNodeId, e.toNodeId);
        existingEdgeSet.add('${a}_$b');
      }

      final selectedConns = _connections.where((c) => c.selected).toList();
      for (final conn in selectedConns) {
        final nodeA = labelToNodeId[conn.entityA.toLowerCase()];
        final nodeB = labelToNodeId[conn.entityB.toLowerCase()];
        if (nodeA != null && nodeB != null && nodeA != nodeB) {
          final a = min(nodeA, nodeB);
          final b = max(nodeA, nodeB);
          final key = '${a}_$b';
          if (!existingEdgeSet.contains(key)) {
            await mindmapRepo.addEdge(domain_edge.MindmapEdge(
              bookId: widget.bookId,
              fromNodeId: nodeA,
              toNodeId: nodeB,
              label: conn.chapters.take(3).join(', '),
            ));
            existingEdgeSet.add(key);
            _edgesAdded++;
          }
        }
      }

      if (mounted) setState(() => _step = _WizardStep.done);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying results: $e')),
        );
        setState(() => _step = _WizardStep.connections);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: _step == _WizardStep.done
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: switch (_step) {
        _WizardStep.scanning => _buildScanningView(colorScheme),
        _WizardStep.characters => _buildCharactersView(colorScheme),
        _WizardStep.worldAreas => _buildWorldAreasView(colorScheme),
        _WizardStep.connections => _buildConnectionsView(colorScheme),
        _WizardStep.applying => _buildApplyingView(colorScheme),
        _WizardStep.done => _buildDoneView(colorScheme),
      },
    );
  }

  String get _stepTitle => switch (_step) {
    _WizardStep.scanning => 'Scanning Book...',
    _WizardStep.characters => 'Step 1: Characters',
    _WizardStep.worldAreas => 'Step 2: World Areas',
    _WizardStep.connections => 'Step 3: Connections',
    _WizardStep.applying => 'Applying...',
    _WizardStep.done => 'Complete',
  };

  // ─── Scanning ──────────────────────────────────────────────────

  Widget _buildScanningView(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            CircularProgressIndicator(value: _scanProgress > 0 ? _scanProgress : null),
            const SizedBox(height: 24),
            Text(_scanStatus, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('${(_scanProgress * 100).round()}%', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  // ─── Characters ────────────────────────────────────────────────

  Widget _buildCharactersView(ColorScheme cs) {
    final selected = _characters.where((c) => c.selected).length;
    return Column(
      children: [
        _StepHeader(
          icon: Icons.people,
          title: 'Found ${_characters.length} potential characters',
          subtitle: '$selected selected. Deselect any that aren\'t actual characters.',
          color: cs.primary,
        ),
        _SelectControls(
          onSelectAll: () => setState(() {
            for (final c in _characters) { c.selected = true; }
          }),
          onDeselectAll: () => setState(() {
            for (final c in _characters) { c.selected = false; }
          }),
        ),
        Expanded(
          child: _characters.isEmpty
              ? Center(child: Text('No characters detected', style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  itemCount: _characters.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, i) => _EntityTile(
                    entity: _characters[i],
                    entityType: 'character',
                    onChanged: (v) => setState(() => _characters[i].selected = v),
                  ),
                ),
        ),
        _WizardBottomBar(
          onBack: null,
          onNext: _proceedToWorldAreas,
          nextLabel: 'Next: World Areas',
          selectedCount: selected,
        ),
      ],
    );
  }

  // ─── World Areas ───────────────────────────────────────────────

  Widget _buildWorldAreasView(ColorScheme cs) {
    final selected = _worldAreas.where((a) => a.selected).length;
    return Column(
      children: [
        _StepHeader(
          icon: Icons.map,
          title: 'Found ${_worldAreas.length} potential locations',
          subtitle: '$selected selected. Deselect any that aren\'t real places in the book.',
          color: Colors.green,
        ),
        _SelectControls(
          onSelectAll: () => setState(() {
            for (final a in _worldAreas) { a.selected = true; }
          }),
          onDeselectAll: () => setState(() {
            for (final a in _worldAreas) { a.selected = false; }
          }),
        ),
        Expanded(
          child: _worldAreas.isEmpty
              ? Center(child: Text('No locations detected', style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  itemCount: _worldAreas.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, i) => _EntityTile(
                    entity: _worldAreas[i],
                    entityType: 'location',
                    onChanged: (v) => setState(() => _worldAreas[i].selected = v),
                  ),
                ),
        ),
        _WizardBottomBar(
          onBack: () => setState(() => _step = _WizardStep.characters),
          onNext: _proceedToConnections,
          nextLabel: 'Next: Connections',
          selectedCount: selected,
        ),
      ],
    );
  }

  // ─── Connections ───────────────────────────────────────────────

  Widget _buildConnectionsView(ColorScheme cs) {
    final selected = _connections.where((c) => c.selected).length;
    return Column(
      children: [
        _StepHeader(
          icon: Icons.share,
          title: 'Found ${_connections.length} connections',
          subtitle: '$selected selected. These are entities that appear together in the same paragraphs.',
          color: Colors.orange,
        ),
        _SelectControls(
          onSelectAll: () => setState(() {
            for (final c in _connections) { c.selected = true; }
          }),
          onDeselectAll: () => setState(() {
            for (final c in _connections) { c.selected = false; }
          }),
        ),
        Expanded(
          child: _connections.isEmpty
              ? Center(child: Text('No connections detected', style: TextStyle(color: cs.onSurfaceVariant)))
              : ListView.builder(
                  itemCount: _connections.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, i) => _ConnectionTile(
                    connection: _connections[i],
                    onChanged: (v) => setState(() => _connections[i].selected = v),
                  ),
                ),
        ),
        _WizardBottomBar(
          onBack: () => setState(() => _step = _WizardStep.worldAreas),
          onNext: _applyResults,
          nextLabel: 'Apply to Mindmap',
          selectedCount: selected,
          isFinish: true,
        ),
      ],
    );
  }

  // ─── Applying ──────────────────────────────────────────────────

  Widget _buildApplyingView(ColorScheme cs) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Creating characters, locations, and mindmap...'),
        ],
      ),
    );
  }

  // ─── Done ──────────────────────────────────────────────────────

  Widget _buildDoneView(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 72, color: cs.primary),
            const SizedBox(height: 24),
            Text('Extraction Complete!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _SummaryRow(Icons.people, '$_charsAdded characters added', cs.primary),
            const SizedBox(height: 8),
            _SummaryRow(Icons.map, '$_areasAdded world areas added', Colors.green),
            const SizedBox(height: 8),
            _SummaryRow(Icons.hub, '$_nodesAdded mindmap nodes created', cs.tertiary),
            const SizedBox(height: 8),
            _SummaryRow(Icons.share, '$_edgesAdded connections created', Colors.orange),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.hub),
              label: const Text('View Mindmap'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

}

// ─── Shared Widgets ──────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _StepHeader({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: color.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectControls extends StatelessWidget {
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;

  const _SelectControls({required this.onSelectAll, required this.onDeselectAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          TextButton(onPressed: onSelectAll, child: const Text('Select All')),
          const SizedBox(width: 8),
          TextButton(onPressed: onDeselectAll, child: const Text('Deselect All')),
        ],
      ),
    );
  }
}

class _EntityTile extends StatelessWidget {
  final ExtractedEntity entity;
  final String entityType;
  final ValueChanged<bool> onChanged;

  const _EntityTile({required this.entity, required this.entityType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final confidenceColor = entity.confidence >= 0.6
        ? Colors.green
        : entity.confidence >= 0.3
            ? Colors.orange
            : Colors.red;

    return CheckboxListTile(
      value: entity.selected,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Row(
        children: [
          Expanded(child: Text(entity.name, style: const TextStyle(fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: confidenceColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(entity.confidence * 100).round()}%',
              style: TextStyle(fontSize: 11, color: confidenceColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text('${entity.mentionCount}x', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
      subtitle: entity.evidence.isNotEmpty
          ? Text(
              entity.evidence.first,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      dense: true,
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  final ExtractedConnection connection;
  final ValueChanged<bool> onChanged;

  const _ConnectionTile({required this.connection, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CheckboxListTile(
      value: connection.selected,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: connection.entityA, style: const TextStyle(fontWeight: FontWeight.w600)),
                const TextSpan(text: '  ↔  '),
                TextSpan(text: connection.entityB, style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          Text('${connection.coOccurrenceCount}x', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
      subtitle: Text(
        connection.chapters.take(5).join(', '),
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
      ),
      dense: true,
    );
  }
}

class _WizardBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final int selectedCount;
  final bool isFinish;

  const _WizardBottomBar({
    this.onBack,
    required this.onNext,
    required this.nextLabel,
    required this.selectedCount,
    this.isFinish = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            OutlinedButton(onPressed: onBack, child: const Text('Back')),
          const Spacer(),
          FilledButton.icon(
            onPressed: onNext,
            icon: Icon(isFinish ? Icons.check : Icons.arrow_forward),
            label: Text(nextLabel),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SummaryRow(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
