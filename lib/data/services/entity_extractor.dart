import 'dart:math';

import '../../domain/models/character.dart';
import '../../domain/models/world_area.dart';
import '../../domain/models/mindmap_node.dart';
import '../../domain/models/mindmap_edge.dart';

/// Result of entity extraction from chapter text.
class ExtractionResult {
  final List<EntityMention> mentions;
  final List<CoOccurrence> coOccurrences;

  const ExtractionResult({required this.mentions, required this.coOccurrences});
}

class EntityMention {
  final String name;
  final MindmapEntityType entityType;
  final int? entityId;
  final int count;

  const EntityMention({
    required this.name,
    required this.entityType,
    this.entityId,
    required this.count,
  });
}

class CoOccurrence {
  final EntityMention entityA;
  final EntityMention entityB;
  final String chapterLabel;

  const CoOccurrence({
    required this.entityA,
    required this.entityB,
    required this.chapterLabel,
  });
}

class EntityExtractor {
  /// Extract entity mentions and co-occurrences from chapter text.
  ///
  /// [text] - The plain text content of the chapter.
  /// [characters] - Known characters for this book.
  /// [worldAreas] - Known world areas for this book.
  /// [chapterLabel] - Label like "Ch. 5" for edge annotations.
  ExtractionResult extract({
    required String text,
    required List<Character> characters,
    required List<WorldArea> worldAreas,
    required String chapterLabel,
  }) {
    final mentions = <EntityMention>[];
    final textLower = text.toLowerCase();

    // Find character mentions
    for (final char in characters) {
      final count = _countMentions(textLower, char.name.toLowerCase());
      if (count > 0) {
        mentions.add(EntityMention(
          name: char.name,
          entityType: MindmapEntityType.character,
          entityId: char.id,
          count: count,
        ));
      }
    }

    // Find world area mentions
    for (final area in worldAreas) {
      final count = _countMentions(textLower, area.name.toLowerCase());
      if (count > 0) {
        mentions.add(EntityMention(
          name: area.name,
          entityType: MindmapEntityType.worldArea,
          entityId: area.id,
          count: count,
        ));
      }
    }

    // Build co-occurrences: entities that appear in the same chapter
    final coOccurrences = <CoOccurrence>[];
    for (var i = 0; i < mentions.length; i++) {
      for (var j = i + 1; j < mentions.length; j++) {
        coOccurrences.add(CoOccurrence(
          entityA: mentions[i],
          entityB: mentions[j],
          chapterLabel: chapterLabel,
        ));
      }
    }

    return ExtractionResult(mentions: mentions, coOccurrences: coOccurrences);
  }

  int _countMentions(String textLower, String nameLower) {
    if (nameLower.length < 2) return 0;
    int count = 0;
    int index = 0;
    while (true) {
      index = textLower.indexOf(nameLower, index);
      if (index == -1) break;
      // Check word boundaries
      final before = index > 0 ? textLower[index - 1] : ' ';
      final after = index + nameLower.length < textLower.length
          ? textLower[index + nameLower.length]
          : ' ';
      if (!_isWordChar(before) && !_isWordChar(after)) {
        count++;
      }
      index += nameLower.length;
    }
    return count;
  }

  bool _isWordChar(String ch) {
    return RegExp(r'[a-zA-Z0-9]').hasMatch(ch);
  }
}

/// Service that applies extraction results to the mindmap.
class MindmapAutoUpdater {
  /// Given extraction results and current mindmap state, returns new nodes and edges to create.
  MindmapUpdatePlan planUpdate({
    required ExtractionResult extraction,
    required List<MindmapNode> existingNodes,
    required List<MindmapEdge> existingEdges,
    required int bookId,
  }) {
    final newNodes = <MindmapNode>[];
    final newEdges = <MindmapEdge>[];

    // Build a map of entityType+entityId -> nodeId
    final entityToNode = <String, int>{};
    for (final node in existingNodes) {
      if (node.entityId != null) {
        entityToNode['${node.entityType.index}_${node.entityId}'] = node.id!;
      }
    }

    // Also map by label for nodes without entityId
    final labelToNode = <String, int>{};
    for (final node in existingNodes) {
      labelToNode[node.label.toLowerCase()] = node.id!;
    }

    // For each mentioned entity, ensure a node exists
    final mentionToNodeId = <String, int?>{};
    for (final mention in extraction.mentions) {
      final key = '${mention.entityType.index}_${mention.entityId}';
      var nodeId = entityToNode[key] ?? labelToNode[mention.name.toLowerCase()];

      if (nodeId == null) {
        // Need to create a new node - mark as pending
        final baseX = 100.0 + (newNodes.length % 5) * 160.0;
        final baseY = 100.0 + (newNodes.length ~/ 5) * 160.0;
        final jitter = Random().nextDouble() * 40 - 20;
        newNodes.add(MindmapNode(
          bookId: bookId,
          entityType: mention.entityType,
          entityId: mention.entityId,
          label: mention.name,
          positionX: baseX + jitter,
          positionY: baseY + jitter,
          color: mention.entityType == MindmapEntityType.character
              ? 0xFF6750A4
              : 0xFF4CAF50,
        ));
        // nodeId will be assigned after creation - use a sentinel
        mentionToNodeId[mention.name] = null; // will resolve later
      } else {
        mentionToNodeId[mention.name] = nodeId;
      }
    }

    // Build edge set from existing edges for dedup
    final existingEdgeSet = <String>{};
    for (final edge in existingEdges) {
      final a = min(edge.fromNodeId, edge.toNodeId);
      final b = max(edge.fromNodeId, edge.toNodeId);
      existingEdgeSet.add('${a}_$b');
    }

    // For co-occurrences where both nodes already exist, create edges if missing
    for (final co in extraction.coOccurrences) {
      final nodeA = mentionToNodeId[co.entityA.name];
      final nodeB = mentionToNodeId[co.entityB.name];
      if (nodeA != null && nodeB != null && nodeA != nodeB) {
        final a = min(nodeA, nodeB);
        final b = max(nodeA, nodeB);
        final edgeKey = '${a}_$b';
        if (!existingEdgeSet.contains(edgeKey)) {
          newEdges.add(MindmapEdge(
            bookId: bookId,
            fromNodeId: nodeA,
            toNodeId: nodeB,
            label: co.chapterLabel,
          ));
          existingEdgeSet.add(edgeKey); // prevent duplicates in same batch
        }
      }
    }

    return MindmapUpdatePlan(
      newNodes: newNodes,
      newEdges: newEdges,
      coOccurrences: extraction.coOccurrences,
      mentionToNodeId: mentionToNodeId,
    );
  }
}

class MindmapUpdatePlan {
  final List<MindmapNode> newNodes;
  final List<MindmapEdge> newEdges;
  final List<CoOccurrence> coOccurrences;
  final Map<String, int?> mentionToNodeId;

  const MindmapUpdatePlan({
    required this.newNodes,
    required this.newEdges,
    required this.coOccurrences,
    required this.mentionToNodeId,
  });

  int get totalChanges => newNodes.length + newEdges.length;
}
