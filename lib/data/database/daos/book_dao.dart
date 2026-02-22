import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [Books])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Stream<List<Book>> watchBooksByStatus(int status) {
    return (select(books)..where((b) => b.status.equals(status))).watch();
  }

  Future<Book> getBookById(int id) {
    return (select(books)..where((b) => b.id.equals(id))).getSingle();
  }

  Stream<Book> watchBookById(int id) {
    return (select(books)..where((b) => b.id.equals(id))).watchSingle();
  }

  Future<int> insertBook(BooksCompanion book) {
    return into(books).insert(book);
  }

  Future<bool> updateBook(BooksCompanion book) {
    return update(books).replace(book);
  }

  Future<int> deleteBook(int id) {
    return (delete(books)..where((b) => b.id.equals(id))).go();
  }

  Stream<List<Book>> searchBooks(String query) {
    return (select(books)
          ..where((b) =>
              b.title.like('%$query%') | b.author.like('%$query%')))
        .watch();
  }
}
