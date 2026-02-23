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
  EpubFiles,
  ReaderBookmarks,
  ReaderHighlights,
  CharacterSheets,
  CharacterSheetEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(epubFiles);
        }
        if (from < 3) {
          await m.createTable(readerBookmarks);
          await m.addColumn(epubFiles, epubFiles.fontSize);
          await m.addColumn(epubFiles, epubFiles.fontFamily);
          await m.addColumn(epubFiles, epubFiles.readerTheme);
          await m.addColumn(epubFiles, epubFiles.lineHeight);
        }
        if (from < 4) {
          await m.createTable(readerHighlights);
        }
        if (from < 5) {
          await m.createTable(characterSheets);
          await m.createTable(characterSheetEntries);
        }
      },
    );
  }
}
