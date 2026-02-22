import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'book_image_dao.g.dart';

@DriftAccessor(tables: [BookImages])
class BookImageDao extends DatabaseAccessor<AppDatabase>
    with _$BookImageDaoMixin {
  BookImageDao(super.db);

  Stream<List<BookImage>> watchImagesByBook(int bookId) {
    return (select(bookImages)
          ..where((i) => i.bookId.equals(bookId))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
        .watch();
  }

  Future<int> insertImage(BookImagesCompanion image) {
    return into(bookImages).insert(image);
  }

  Future<int> deleteImage(int id) {
    return (delete(bookImages)..where((i) => i.id.equals(id))).go();
  }
}
