import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'mindmap_dao.g.dart';

@DriftAccessor(tables: [MindmapNodes, MindmapEdges])
class MindmapDao extends DatabaseAccessor<AppDatabase> with _$MindmapDaoMixin {
  MindmapDao(super.db);

  Stream<List<MindmapNode>> watchNodesByBook(int bookId) {
    return (select(mindmapNodes)..where((n) => n.bookId.equals(bookId)))
        .watch();
  }

  Stream<List<MindmapEdge>> watchEdgesByBook(int bookId) {
    return (select(mindmapEdges)..where((e) => e.bookId.equals(bookId)))
        .watch();
  }

  Future<int> insertNode(MindmapNodesCompanion node) {
    return into(mindmapNodes).insert(node);
  }

  Future<bool> updateNode(MindmapNodesCompanion node) {
    return update(mindmapNodes).replace(node);
  }

  Future<int> deleteNode(int id) {
    return (delete(mindmapNodes)..where((n) => n.id.equals(id))).go();
  }

  Future<int> insertEdge(MindmapEdgesCompanion edge) {
    return into(mindmapEdges).insert(edge);
  }

  Future<int> deleteEdge(int id) {
    return (delete(mindmapEdges)..where((e) => e.id.equals(id))).go();
  }

  Future<void> updateNodePosition(int id, double x, double y) {
    return (update(mindmapNodes)..where((n) => n.id.equals(id))).write(
      MindmapNodesCompanion(
        positionX: Value(x),
        positionY: Value(y),
      ),
    );
  }
}
