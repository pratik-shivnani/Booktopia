import 'package:drift/drift.dart';

import '../../domain/models/book.dart' show SourceApp;
import '../../domain/models/note.dart' as domain;
import '../database/app_database.dart';
import '../database/daos/note_dao.dart';

class NoteRepository {
  final NoteDao _dao;

  NoteRepository(this._dao);

  Stream<List<domain.Note>> watchNotesByBook(int bookId) {
    return _dao.watchNotesByBook(bookId).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Future<int> addNote(domain.Note note) {
    return _dao.insertNote(_toCompanion(note));
  }

  Future<void> updateNote(domain.Note note) {
    return _dao.updateNote(_toCompanionWithId(note));
  }

  Future<void> deleteNote(int id) {
    return _dao.deleteNote(id);
  }

  domain.Note _toDomain(Note row) {
    return domain.Note(
      id: row.id,
      bookId: row.bookId,
      content: row.content,
      pageNumber: row.pageNumber,
      chapter: row.chapter,
      sourceApp: SourceApp.values[row.sourceApp],
      createdAt: row.createdAt,
    );
  }

  NotesCompanion _toCompanion(domain.Note n) {
    return NotesCompanion(
      bookId: Value(n.bookId),
      content: Value(n.content),
      pageNumber: Value(n.pageNumber),
      chapter: Value(n.chapter),
      sourceApp: Value(n.sourceApp.index),
      createdAt: Value(n.createdAt),
    );
  }

  NotesCompanion _toCompanionWithId(domain.Note n) {
    return NotesCompanion(
      id: Value(n.id!),
      bookId: Value(n.bookId),
      content: Value(n.content),
      pageNumber: Value(n.pageNumber),
      chapter: Value(n.chapter),
      sourceApp: Value(n.sourceApp.index),
      createdAt: Value(n.createdAt),
    );
  }
}
