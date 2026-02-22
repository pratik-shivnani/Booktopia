import 'package:drift/drift.dart';

import '../../domain/models/book.dart' as domain;
import '../database/app_database.dart';
import '../database/daos/book_dao.dart';

class BookRepository {
  final BookDao _bookDao;

  BookRepository(this._bookDao);

  Stream<List<domain.Book>> watchAllBooks() {
    return _bookDao.watchAllBooks().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Stream<List<domain.Book>> watchBooksByStatus(domain.BookStatus status) {
    return _bookDao.watchBooksByStatus(status.index).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Stream<domain.Book> watchBookById(int id) {
    return _bookDao.watchBookById(id).map(_toDomain);
  }

  Future<domain.Book> getBookById(int id) async {
    final row = await _bookDao.getBookById(id);
    return _toDomain(row);
  }

  Future<int> addBook(domain.Book book) {
    return _bookDao.insertBook(_toCompanion(book));
  }

  Future<void> updateBook(domain.Book book) {
    return _bookDao.updateBook(_toCompanionWithId(book));
  }

  Future<void> deleteBook(int id) {
    return _bookDao.deleteBook(id);
  }

  Stream<List<domain.Book>> searchBooks(String query) {
    return _bookDao.searchBooks(query).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  domain.Book _toDomain(Book row) {
    return domain.Book(
      id: row.id,
      title: row.title,
      author: row.author,
      coverImagePath: row.coverImagePath,
      genre: row.genre,
      totalPages: row.totalPages,
      currentPage: row.currentPage,
      status: domain.BookStatus.values[row.status],
      rating: row.rating,
      sourceApp: domain.SourceApp.values[row.sourceApp],
      dateAdded: row.dateAdded,
      dateFinished: row.dateFinished,
    );
  }

  BooksCompanion _toCompanion(domain.Book book) {
    return BooksCompanion(
      title: Value(book.title),
      author: Value(book.author),
      coverImagePath: Value(book.coverImagePath),
      genre: Value(book.genre),
      totalPages: Value(book.totalPages),
      currentPage: Value(book.currentPage),
      status: Value(book.status.index),
      rating: Value(book.rating),
      sourceApp: Value(book.sourceApp.index),
      dateAdded: Value(book.dateAdded),
      dateFinished: Value(book.dateFinished),
    );
  }

  BooksCompanion _toCompanionWithId(domain.Book book) {
    return BooksCompanion(
      id: Value(book.id!),
      title: Value(book.title),
      author: Value(book.author),
      coverImagePath: Value(book.coverImagePath),
      genre: Value(book.genre),
      totalPages: Value(book.totalPages),
      currentPage: Value(book.currentPage),
      status: Value(book.status.index),
      rating: Value(book.rating),
      sourceApp: Value(book.sourceApp.index),
      dateAdded: Value(book.dateAdded),
      dateFinished: Value(book.dateFinished),
    );
  }
}
