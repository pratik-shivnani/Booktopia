import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/database/daos/book_dao.dart';
import '../data/database/daos/character_dao.dart';
import '../data/database/daos/note_dao.dart';
import '../data/database/daos/world_area_dao.dart';
import '../data/database/daos/book_image_dao.dart';
import '../data/database/daos/mindmap_dao.dart';
import '../data/database/daos/epub_file_dao.dart';
import '../data/database/daos/reader_bookmark_dao.dart';
import '../data/database/daos/reader_highlight_dao.dart';
import '../data/database/daos/character_sheet_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/world_area_repository.dart';
import '../data/repositories/book_image_repository.dart';
import '../data/repositories/mindmap_repository.dart';
import '../data/repositories/epub_repository.dart';
import '../data/services/epub_service.dart';
import '../domain/models/book.dart' as domain;
import '../domain/models/character.dart' as domain_char;
import '../domain/models/note.dart' as domain_note;
import '../domain/models/world_area.dart' as domain_area;
import '../domain/models/book_image.dart' as domain_img;
import '../domain/models/mindmap_node.dart' as domain_node;
import '../domain/models/mindmap_edge.dart' as domain_edge;
import '../domain/models/epub_data.dart' as domain_epub;
import '../domain/models/epub_data.dart' show ReaderBookmarkData;

// Database
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// DAOs
final bookDaoProvider = Provider<BookDao>((ref) {
  return BookDao(ref.watch(databaseProvider));
});

final characterDaoProvider = Provider<CharacterDao>((ref) {
  return CharacterDao(ref.watch(databaseProvider));
});

final noteDaoProvider = Provider<NoteDao>((ref) {
  return NoteDao(ref.watch(databaseProvider));
});

final worldAreaDaoProvider = Provider<WorldAreaDao>((ref) {
  return WorldAreaDao(ref.watch(databaseProvider));
});

final bookImageDaoProvider = Provider<BookImageDao>((ref) {
  return BookImageDao(ref.watch(databaseProvider));
});

final mindmapDaoProvider = Provider<MindmapDao>((ref) {
  return MindmapDao(ref.watch(databaseProvider));
});

final epubFileDaoProvider = Provider<EpubFileDao>((ref) {
  return EpubFileDao(ref.watch(databaseProvider));
});

final readerBookmarkDaoProvider = Provider<ReaderBookmarkDao>((ref) {
  return ReaderBookmarkDao(ref.watch(databaseProvider));
});

final readerHighlightDaoProvider = Provider<ReaderHighlightDao>((ref) {
  return ReaderHighlightDao(ref.watch(databaseProvider));
});

final characterSheetDaoProvider = Provider<CharacterSheetDao>((ref) {
  return CharacterSheetDao(ref.watch(databaseProvider));
});

// Repositories
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(bookDaoProvider));
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.watch(characterDaoProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(noteDaoProvider));
});

final worldAreaRepositoryProvider = Provider<WorldAreaRepository>((ref) {
  return WorldAreaRepository(ref.watch(worldAreaDaoProvider));
});

final bookImageRepositoryProvider = Provider<BookImageRepository>((ref) {
  return BookImageRepository(ref.watch(bookImageDaoProvider));
});

final mindmapRepositoryProvider = Provider<MindmapRepository>((ref) {
  return MindmapRepository(ref.watch(mindmapDaoProvider));
});

final epubRepositoryProvider = Provider<EpubRepository>((ref) {
  return EpubRepository(ref.watch(epubFileDaoProvider));
});

final epubServiceProvider = Provider<EpubService>((ref) {
  return EpubService();
});

// Stream providers
final allBooksProvider = StreamProvider<List<domain.Book>>((ref) {
  return ref.watch(bookRepositoryProvider).watchAllBooks();
});

final booksByStatusProvider =
    StreamProvider.family<List<domain.Book>, domain.BookStatus>((ref, status) {
  return ref.watch(bookRepositoryProvider).watchBooksByStatus(status);
});

final bookByIdProvider = StreamProvider.family<domain.Book, int>((ref, id) {
  return ref.watch(bookRepositoryProvider).watchBookById(id);
});

final bookSearchProvider =
    StreamProvider.family<List<domain.Book>, String>((ref, query) {
  if (query.isEmpty) {
    return ref.watch(bookRepositoryProvider).watchAllBooks();
  }
  return ref.watch(bookRepositoryProvider).searchBooks(query);
});

// Character stream providers
final charactersByBookProvider =
    StreamProvider.family<List<domain_char.Character>, int>((ref, bookId) {
  return ref.watch(characterRepositoryProvider).watchCharactersByBook(bookId);
});

// Note stream providers
final notesByBookProvider =
    StreamProvider.family<List<domain_note.Note>, int>((ref, bookId) {
  return ref.watch(noteRepositoryProvider).watchNotesByBook(bookId);
});

// World area stream providers
final worldAreasByBookProvider =
    StreamProvider.family<List<domain_area.WorldArea>, int>((ref, bookId) {
  return ref.watch(worldAreaRepositoryProvider).watchWorldAreasByBook(bookId);
});

// Book image stream providers
final imagesByBookProvider =
    StreamProvider.family<List<domain_img.BookImage>, int>((ref, bookId) {
  return ref.watch(bookImageRepositoryProvider).watchImagesByBook(bookId);
});

// Mindmap stream providers
final mindmapNodesByBookProvider =
    StreamProvider.family<List<domain_node.MindmapNode>, int>((ref, bookId) {
  return ref.watch(mindmapRepositoryProvider).watchNodesByBook(bookId);
});

final mindmapEdgesByBookProvider =
    StreamProvider.family<List<domain_edge.MindmapEdge>, int>((ref, bookId) {
  return ref.watch(mindmapRepositoryProvider).watchEdgesByBook(bookId);
});

// Epub stream providers
final epubByBookProvider =
    StreamProvider.family<domain_epub.EpubData?, int>((ref, bookId) {
  return ref.watch(epubRepositoryProvider).watchByBookId(bookId);
});

// Reader bookmark stream providers
final readerBookmarksByBookProvider =
    StreamProvider.family<List<ReaderBookmarkData>, int>((ref, bookId) {
  final dao = ref.watch(readerBookmarkDaoProvider);
  return dao.watchByBookId(bookId).map(
    (rows) => rows.map((r) => ReaderBookmarkData(
      id: r.id,
      bookId: r.bookId,
      chapterIndex: r.chapterIndex,
      scrollPosition: r.scrollPosition,
      label: r.label,
      chapterTitle: r.chapterTitle,
      createdAt: r.createdAt,
    )).toList(),
  );
});
