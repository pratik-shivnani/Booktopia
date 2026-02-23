import 'package:drift/drift.dart';

import '../../domain/models/epub_data.dart' as domain;
import '../database/app_database.dart';
import '../database/daos/epub_file_dao.dart';

class EpubRepository {
  final EpubFileDao _dao;

  EpubRepository(this._dao);

  Future<domain.EpubData?> getByBookId(int bookId) async {
    final row = await _dao.getByBookId(bookId);
    return row == null ? null : _toDomain(row);
  }

  Stream<domain.EpubData?> watchByBookId(int bookId) {
    return _dao.watchByBookId(bookId).map((row) => row == null ? null : _toDomain(row));
  }

  Future<int> addEpubFile(domain.EpubData data) {
    return _dao.insertEpubFile(_toCompanion(data));
  }

  Future<void> updateReadingPosition(int id, int chapterIndex, double scrollPos) {
    return _dao.updateReadingPosition(id, chapterIndex, scrollPos);
  }

  Future<void> deleteByBookId(int bookId) {
    return _dao.deleteByBookId(bookId);
  }

  domain.EpubData _toDomain(EpubFile row) {
    return domain.EpubData(
      id: row.id,
      bookId: row.bookId,
      filePath: row.filePath,
      currentChapterIndex: row.currentChapterIndex,
      scrollPosition: row.scrollPosition,
      lastReadAt: row.lastReadAt,
    );
  }

  EpubFilesCompanion _toCompanion(domain.EpubData d) {
    return EpubFilesCompanion(
      bookId: Value(d.bookId),
      filePath: Value(d.filePath),
      currentChapterIndex: Value(d.currentChapterIndex),
      scrollPosition: Value(d.scrollPosition),
      lastReadAt: Value(d.lastReadAt),
    );
  }
}
