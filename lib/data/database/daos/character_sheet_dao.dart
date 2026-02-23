import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'character_sheet_dao.g.dart';

@DriftAccessor(tables: [CharacterSheets, CharacterSheetEntries])
class CharacterSheetDao extends DatabaseAccessor<AppDatabase> with _$CharacterSheetDaoMixin {
  CharacterSheetDao(super.db);

  // --- Sheets ---

  Stream<List<CharacterSheet>> watchSheetsByBook(int bookId) {
    return (select(characterSheets)
          ..where((s) => s.bookId.equals(bookId))
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  Future<CharacterSheet?> getSheetById(int id) {
    return (select(characterSheets)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<CharacterSheet?> getSheetByCharacterId(int bookId, int characterId) {
    return (select(characterSheets)
          ..where((s) => s.bookId.equals(bookId) & s.characterId.equals(characterId)))
        .getSingleOrNull();
  }

  Future<int> insertSheet(CharacterSheetsCompanion sheet) {
    return into(characterSheets).insert(sheet);
  }

  Future<void> updateSheet(CharacterSheetsCompanion sheet) {
    return update(characterSheets).replace(sheet);
  }

  Future<void> updateSheetMeta(int id, {int? level, String? className}) {
    return (update(characterSheets)..where((s) => s.id.equals(id))).write(
      CharacterSheetsCompanion(
        level: level != null ? Value(level) : const Value.absent(),
        className: className != null ? Value(className) : const Value.absent(),
        lastUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteSheet(int id) {
    return (delete(characterSheets)..where((s) => s.id.equals(id))).go();
  }

  // --- Entries ---

  Stream<List<CharacterSheetEntry>> watchEntriesBySheet(int sheetId) {
    return (select(characterSheetEntries)
          ..where((e) => e.sheetId.equals(sheetId))
          ..orderBy([
            (e) => OrderingTerm.asc(e.category),
            (e) => OrderingTerm.asc(e.sortOrder),
          ]))
        .watch();
  }

  Future<List<CharacterSheetEntry>> getEntriesBySheet(int sheetId) {
    return (select(characterSheetEntries)
          ..where((e) => e.sheetId.equals(sheetId))
          ..orderBy([
            (e) => OrderingTerm.asc(e.category),
            (e) => OrderingTerm.asc(e.sortOrder),
          ]))
        .get();
  }

  Future<int> insertEntry(CharacterSheetEntriesCompanion entry) {
    return into(characterSheetEntries).insert(entry);
  }

  Future<void> updateEntry(CharacterSheetEntriesCompanion entry) {
    return update(characterSheetEntries).replace(entry);
  }

  Future<void> upsertEntry(int sheetId, int category, String key, String value) async {
    final existing = await (select(characterSheetEntries)
          ..where((e) => e.sheetId.equals(sheetId) & e.category.equals(category) & e.entryKey.equals(key)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(characterSheetEntries)..where((e) => e.id.equals(existing.id))).write(
        CharacterSheetEntriesCompanion(entryValue: Value(value)),
      );
    } else {
      final maxOrder = await _maxSortOrder(sheetId, category);
      await into(characterSheetEntries).insert(CharacterSheetEntriesCompanion(
        sheetId: Value(sheetId),
        category: Value(category),
        entryKey: Value(key),
        entryValue: Value(value),
        sortOrder: Value(maxOrder + 1),
      ));
    }

    // Update sheet timestamp
    await (update(characterSheets)..where((s) => s.id.equals(sheetId))).write(
      CharacterSheetsCompanion(lastUpdatedAt: Value(DateTime.now())),
    );
  }

  Future<int> _maxSortOrder(int sheetId, int category) async {
    final entries = await (select(characterSheetEntries)
          ..where((e) => e.sheetId.equals(sheetId) & e.category.equals(category))
          ..orderBy([(e) => OrderingTerm.desc(e.sortOrder)])
          ..limit(1))
        .get();
    return entries.isEmpty ? 0 : entries.first.sortOrder;
  }

  Future<int> deleteEntry(int id) {
    return (delete(characterSheetEntries)..where((e) => e.id.equals(id))).go();
  }

  Future<void> deleteEntriesBySheet(int sheetId) {
    return (delete(characterSheetEntries)..where((e) => e.sheetId.equals(sheetId))).go();
  }
}
