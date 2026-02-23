import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'reader_bookmark_dao.g.dart';

@DriftAccessor(tables: [ReaderBookmarks])
class ReaderBookmarkDao extends DatabaseAccessor<AppDatabase> with _$ReaderBookmarkDaoMixin {
  ReaderBookmarkDao(super.db);

  Stream<List<ReaderBookmark>> watchByBookId(int bookId) {
    return (select(readerBookmarks)
          ..where((b) => b.bookId.equals(bookId))
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
        .watch();
  }

  Future<int> insertBookmark(ReaderBookmarksCompanion entry) {
    return into(readerBookmarks).insert(entry);
  }

  Future<int> deleteBookmark(int id) {
    return (delete(readerBookmarks)..where((b) => b.id.equals(id))).go();
  }

  Future<int> deleteByBookId(int bookId) {
    return (delete(readerBookmarks)..where((b) => b.bookId.equals(bookId))).go();
  }
}
