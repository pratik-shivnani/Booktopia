import 'package:drift/drift.dart';

import '../../domain/models/mindmap_node.dart' as domain;
import '../../domain/models/mindmap_edge.dart' as domain_edge;
import '../database/app_database.dart';
import '../database/daos/mindmap_dao.dart';

class MindmapRepository {
  final MindmapDao _dao;

  MindmapRepository(this._dao);

  Stream<List<domain.MindmapNode>> watchNodesByBook(int bookId) {
    return _dao.watchNodesByBook(bookId).map(
          (rows) => rows.map(_nodeToDomain).toList(),
        );
  }

  Stream<List<domain_edge.MindmapEdge>> watchEdgesByBook(int bookId) {
    return _dao.watchEdgesByBook(bookId).map(
          (rows) => rows.map(_edgeToDomain).toList(),
        );
  }

  Future<int> addNode(domain.MindmapNode node) {
    return _dao.insertNode(_nodeToCompanion(node));
  }

  Future<void> updateNode(domain.MindmapNode node) {
    return _dao.updateNode(_nodeToCompanionWithId(node));
  }

  Future<void> updateNodePosition(int id, double x, double y) {
    return _dao.updateNodePosition(id, x, y);
  }

  Future<void> deleteNode(int id) {
    return _dao.deleteNode(id);
  }

  Future<int> addEdge(domain_edge.MindmapEdge edge) {
    return _dao.insertEdge(_edgeToCompanion(edge));
  }

  Future<void> deleteEdge(int id) {
    return _dao.deleteEdge(id);
  }

  domain.MindmapNode _nodeToDomain(MindmapNode row) {
    return domain.MindmapNode(
      id: row.id,
      bookId: row.bookId,
      entityType: domain.MindmapEntityType.values[row.entityType],
      entityId: row.entityId,
      label: row.label,
      positionX: row.positionX,
      positionY: row.positionY,
      color: row.color,
    );
  }

  domain_edge.MindmapEdge _edgeToDomain(MindmapEdge row) {
    return domain_edge.MindmapEdge(
      id: row.id,
      bookId: row.bookId,
      fromNodeId: row.fromNodeId,
      toNodeId: row.toNodeId,
      label: row.label,
    );
  }

  MindmapNodesCompanion _nodeToCompanion(domain.MindmapNode n) {
    return MindmapNodesCompanion(
      bookId: Value(n.bookId),
      entityType: Value(n.entityType.index),
      entityId: Value(n.entityId),
      label: Value(n.label),
      positionX: Value(n.positionX),
      positionY: Value(n.positionY),
      color: Value(n.color),
    );
  }

  MindmapNodesCompanion _nodeToCompanionWithId(domain.MindmapNode n) {
    return MindmapNodesCompanion(
      id: Value(n.id!),
      bookId: Value(n.bookId),
      entityType: Value(n.entityType.index),
      entityId: Value(n.entityId),
      label: Value(n.label),
      positionX: Value(n.positionX),
      positionY: Value(n.positionY),
      color: Value(n.color),
    );
  }

  MindmapEdgesCompanion _edgeToCompanion(domain_edge.MindmapEdge e) {
    return MindmapEdgesCompanion(
      bookId: Value(e.bookId),
      fromNodeId: Value(e.fromNodeId),
      toNodeId: Value(e.toNodeId),
      label: Value(e.label),
    );
  }
}
