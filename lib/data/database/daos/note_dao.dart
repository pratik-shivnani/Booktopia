import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  Stream<List<Note>> watchNotesByBook(int bookId) {
    return (select(notes)
          ..where((n) => n.bookId.equals(bookId))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .watch();
  }

  Future<int> insertNote(NotesCompanion note) {
    return into(notes).insert(note);
  }

  Future<bool> updateNote(NotesCompanion note) {
    return update(notes).replace(note);
  }

  Future<int> deleteNote(int id) {
    return (delete(notes)..where((n) => n.id.equals(id))).go();
  }
}
