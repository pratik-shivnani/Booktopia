import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'reader_highlight_dao.g.dart';

@DriftAccessor(tables: [ReaderHighlights])
class ReaderHighlightDao extends DatabaseAccessor<AppDatabase> with _$ReaderHighlightDaoMixin {
  ReaderHighlightDao(super.db);

  Stream<List<ReaderHighlight>> watchByBookAndChapter(int bookId, int chapterIndex) {
    return (select(readerHighlights)
          ..where((h) => h.bookId.equals(bookId) & h.chapterIndex.equals(chapterIndex))
          ..orderBy([(h) => OrderingTerm.asc(h.createdAt)]))
        .watch();
  }

  Stream<List<ReaderHighlight>> watchByBook(int bookId) {
    return (select(readerHighlights)
          ..where((h) => h.bookId.equals(bookId))
          ..orderBy([(h) => OrderingTerm.desc(h.createdAt)]))
        .watch();
  }

  Future<int> insertHighlight(ReaderHighlightsCompanion entry) {
    return into(readerHighlights).insert(entry);
  }

  Future<void> updateNote(int id, String? note) {
    return (update(readerHighlights)..where((h) => h.id.equals(id))).write(
      ReaderHighlightsCompanion(note: Value(note)),
    );
  }

  Future<void> updateColor(int id, int color) {
    return (update(readerHighlights)..where((h) => h.id.equals(id))).write(
      ReaderHighlightsCompanion(color: Value(color)),
    );
  }

  Future<int> deleteHighlight(int id) {
    return (delete(readerHighlights)..where((h) => h.id.equals(id))).go();
  }

  Future<int> deleteByBookId(int bookId) {
    return (delete(readerHighlights)..where((h) => h.bookId.equals(bookId))).go();
  }
}
