import 'package:drift/drift.dart';

import 'connection/connection.dart'
    if (dart.library.io) 'connection/connection_native.dart'
    if (dart.library.js) 'connection/connection_web.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Books,
  Characters,
  Notes,
  WorldAreas,
  BookImages,
  MindmapNodes,
  MindmapEdges,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }
}
