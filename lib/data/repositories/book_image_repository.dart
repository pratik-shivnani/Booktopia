import 'package:drift/drift.dart';

import '../../domain/models/book_image.dart' as domain;
import '../database/app_database.dart';
import '../database/daos/book_image_dao.dart';

class BookImageRepository {
  final BookImageDao _dao;

  BookImageRepository(this._dao);

  Stream<List<domain.BookImage>> watchImagesByBook(int bookId) {
    return _dao.watchImagesByBook(bookId).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Future<int> addImage(domain.BookImage image) {
    return _dao.insertImage(_toCompanion(image));
  }

  Future<void> deleteImage(int id) {
    return _dao.deleteImage(id);
  }

  domain.BookImage _toDomain(BookImage row) {
    return domain.BookImage(
      id: row.id,
      bookId: row.bookId,
      path: row.path,
      caption: row.caption,
      createdAt: row.createdAt,
    );
  }

  BookImagesCompanion _toCompanion(domain.BookImage img) {
    return BookImagesCompanion(
      bookId: Value(img.bookId),
      path: Value(img.path),
      caption: Value(img.caption),
      createdAt: Value(img.createdAt),
    );
  }
}
