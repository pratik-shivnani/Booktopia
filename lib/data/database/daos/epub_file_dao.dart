import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'epub_file_dao.g.dart';

@DriftAccessor(tables: [EpubFiles])
class EpubFileDao extends DatabaseAccessor<AppDatabase> with _$EpubFileDaoMixin {
  EpubFileDao(super.db);

  Future<EpubFile?> getByBookId(int bookId) {
    return (select(epubFiles)..where((e) => e.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  Stream<EpubFile?> watchByBookId(int bookId) {
    return (select(epubFiles)..where((e) => e.bookId.equals(bookId)))
        .watchSingleOrNull();
  }

  Future<int> insertEpubFile(EpubFilesCompanion entry) {
    return into(epubFiles).insert(entry);
  }

  Future<bool> updateEpubFile(EpubFilesCompanion entry) {
    return update(epubFiles).replace(entry);
  }

  Future<void> updateReadingPosition(int id, int chapterIndex, double scrollPos) {
    return (update(epubFiles)..where((e) => e.id.equals(id))).write(
      EpubFilesCompanion(
        currentChapterIndex: Value(chapterIndex),
        scrollPosition: Value(scrollPos),
        lastReadAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateReaderSettings(int id, {int? fontSize, String? fontFamily, int? readerTheme, double? lineHeight}) {
    final companion = EpubFilesCompanion(
      fontSize: fontSize != null ? Value(fontSize) : const Value.absent(),
      fontFamily: fontFamily != null ? Value(fontFamily) : const Value.absent(),
      readerTheme: readerTheme != null ? Value(readerTheme) : const Value.absent(),
      lineHeight: lineHeight != null ? Value(lineHeight) : const Value.absent(),
    );
    return (update(epubFiles)..where((e) => e.id.equals(id))).write(companion);
  }

  Future<int> deleteByBookId(int bookId) {
    return (delete(epubFiles)..where((e) => e.bookId.equals(bookId))).go();
  }

  Stream<EpubFile?> watchMostRecentlyRead() {
    return (select(epubFiles)
          ..where((e) => e.lastReadAt.isNotNull())
          ..orderBy([(e) => OrderingTerm.desc(e.lastReadAt)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
