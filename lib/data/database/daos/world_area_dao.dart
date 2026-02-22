import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'world_area_dao.g.dart';

@DriftAccessor(tables: [WorldAreas])
class WorldAreaDao extends DatabaseAccessor<AppDatabase>
    with _$WorldAreaDaoMixin {
  WorldAreaDao(super.db);

  Stream<List<WorldArea>> watchWorldAreasByBook(int bookId) {
    return (select(worldAreas)..where((w) => w.bookId.equals(bookId))).watch();
  }

  Future<WorldArea> getWorldAreaById(int id) {
    return (select(worldAreas)..where((w) => w.id.equals(id))).getSingle();
  }

  Future<int> insertWorldArea(WorldAreasCompanion area) {
    return into(worldAreas).insert(area);
  }

  Future<bool> updateWorldArea(WorldAreasCompanion area) {
    return update(worldAreas).replace(area);
  }

  Future<int> deleteWorldArea(int id) {
    return (delete(worldAreas)..where((w) => w.id.equals(id))).go();
  }
}
