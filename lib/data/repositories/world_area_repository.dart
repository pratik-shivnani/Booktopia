import 'package:drift/drift.dart';

import '../../domain/models/world_area.dart' as domain;
import '../database/app_database.dart';
import '../database/daos/world_area_dao.dart';

class WorldAreaRepository {
  final WorldAreaDao _dao;

  WorldAreaRepository(this._dao);

  Stream<List<domain.WorldArea>> watchWorldAreasByBook(int bookId) {
    return _dao.watchWorldAreasByBook(bookId).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Future<domain.WorldArea> getWorldAreaById(int id) async {
    final row = await _dao.getWorldAreaById(id);
    return _toDomain(row);
  }

  Future<int> addWorldArea(domain.WorldArea area) {
    return _dao.insertWorldArea(_toCompanion(area));
  }

  Future<void> updateWorldArea(domain.WorldArea area) {
    return _dao.updateWorldArea(_toCompanionWithId(area));
  }

  Future<void> deleteWorldArea(int id) {
    return _dao.deleteWorldArea(id);
  }

  domain.WorldArea _toDomain(WorldArea row) {
    return domain.WorldArea(
      id: row.id,
      bookId: row.bookId,
      name: row.name,
      description: row.description,
      imagePath: row.imagePath,
    );
  }

  WorldAreasCompanion _toCompanion(domain.WorldArea a) {
    return WorldAreasCompanion(
      bookId: Value(a.bookId),
      name: Value(a.name),
      description: Value(a.description),
      imagePath: Value(a.imagePath),
    );
  }

  WorldAreasCompanion _toCompanionWithId(domain.WorldArea a) {
    return WorldAreasCompanion(
      id: Value(a.id!),
      bookId: Value(a.bookId),
      name: Value(a.name),
      description: Value(a.description),
      imagePath: Value(a.imagePath),
    );
  }
}
