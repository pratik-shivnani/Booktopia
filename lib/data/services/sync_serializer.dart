import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Serializes and deserializes all Drift table data to/from JSON
/// for GitHub cloud sync. Data is organized per-book.
class SyncSerializer {
  final AppDatabase _db;

  SyncSerializer(this._db);

  // ─── Export ────────────────────────────────────────────────────────

  /// Export a single book's metadata as JSON map.
  Future<Map<String, dynamic>> exportBook(Book book) async {
    return {
      'id': book.id,
      'title': book.title,
      'author': book.author,
      'coverImagePath': book.coverImagePath,
      'genre': book.genre,
      'totalPages': book.totalPages,
      'currentPage': book.currentPage,
      'status': book.status,
      'rating': book.rating,
      'sourceApp': book.sourceApp,
      'dateAdded': book.dateAdded.toIso8601String(),
      'dateFinished': book.dateFinished?.toIso8601String(),
    };
  }

  /// Export all characters for a book.
  Future<List<Map<String, dynamic>>> exportCharacters(int bookId) async {
    final rows = await ((_db.select(_db.characters))
          ..where((c) => c.bookId.equals(bookId)))
        .get();
    return rows.map((c) => {
      'id': c.id,
      'bookId': c.bookId,
      'name': c.name,
      'description': c.description,
      'imagePath': c.imagePath,
      'role': c.role,
    }).toList();
  }

  /// Export all notes for a book.
  Future<List<Map<String, dynamic>>> exportNotes(int bookId) async {
    final rows = await ((_db.select(_db.notes))
          ..where((n) => n.bookId.equals(bookId)))
        .get();
    return rows.map((n) => {
      'id': n.id,
      'bookId': n.bookId,
      'content': n.content,
      'pageNumber': n.pageNumber,
      'chapter': n.chapter,
      'sourceApp': n.sourceApp,
      'createdAt': n.createdAt.toIso8601String(),
    }).toList();
  }

  /// Export all world areas for a book.
  Future<List<Map<String, dynamic>>> exportWorldAreas(int bookId) async {
    final rows = await ((_db.select(_db.worldAreas))
          ..where((w) => w.bookId.equals(bookId)))
        .get();
    return rows.map((w) => {
      'id': w.id,
      'bookId': w.bookId,
      'name': w.name,
      'description': w.description,
      'imagePath': w.imagePath,
    }).toList();
  }

  /// Export all book images for a book.
  Future<List<Map<String, dynamic>>> exportBookImages(int bookId) async {
    final rows = await ((_db.select(_db.bookImages))
          ..where((i) => i.bookId.equals(bookId)))
        .get();
    return rows.map((i) => {
      'id': i.id,
      'bookId': i.bookId,
      'path': i.path,
      'caption': i.caption,
      'createdAt': i.createdAt.toIso8601String(),
    }).toList();
  }

  /// Export mindmap nodes and edges for a book.
  Future<Map<String, dynamic>> exportMindmap(int bookId) async {
    final nodes = await ((_db.select(_db.mindmapNodes))
          ..where((n) => n.bookId.equals(bookId)))
        .get();
    final edges = await ((_db.select(_db.mindmapEdges))
          ..where((e) => e.bookId.equals(bookId)))
        .get();
    return {
      'nodes': nodes.map((n) => {
        'id': n.id,
        'bookId': n.bookId,
        'entityType': n.entityType,
        'entityId': n.entityId,
        'label': n.label,
        'positionX': n.positionX,
        'positionY': n.positionY,
        'color': n.color,
      }).toList(),
      'edges': edges.map((e) => {
        'id': e.id,
        'bookId': e.bookId,
        'fromNodeId': e.fromNodeId,
        'toNodeId': e.toNodeId,
        'label': e.label,
      }).toList(),
    };
  }

  /// Export epub file metadata for a book.
  Future<Map<String, dynamic>?> exportEpubFile(int bookId) async {
    final row = await ((_db.select(_db.epubFiles))
          ..where((e) => e.bookId.equals(bookId)))
        .getSingleOrNull();
    if (row == null) return null;
    return {
      'id': row.id,
      'bookId': row.bookId,
      'filePath': row.filePath,
      'currentChapterIndex': row.currentChapterIndex,
      'scrollPosition': row.scrollPosition,
      'lastReadAt': row.lastReadAt?.toIso8601String(),
      'fontSize': row.fontSize,
      'fontFamily': row.fontFamily,
      'readerTheme': row.readerTheme,
      'lineHeight': row.lineHeight,
    };
  }

  /// Export reader bookmarks for a book.
  Future<List<Map<String, dynamic>>> exportBookmarks(int bookId) async {
    final rows = await ((_db.select(_db.readerBookmarks))
          ..where((b) => b.bookId.equals(bookId)))
        .get();
    return rows.map((b) => {
      'id': b.id,
      'bookId': b.bookId,
      'chapterIndex': b.chapterIndex,
      'scrollPosition': b.scrollPosition,
      'label': b.label,
      'chapterTitle': b.chapterTitle,
      'createdAt': b.createdAt.toIso8601String(),
    }).toList();
  }

  /// Export reader highlights for a book.
  Future<List<Map<String, dynamic>>> exportHighlights(int bookId) async {
    final rows = await ((_db.select(_db.readerHighlights))
          ..where((h) => h.bookId.equals(bookId)))
        .get();
    return rows.map((h) => {
      'id': h.id,
      'bookId': h.bookId,
      'chapterIndex': h.chapterIndex,
      'highlightText': h.highlightText,
      'rangeStart': h.rangeStart,
      'rangeEnd': h.rangeEnd,
      'color': h.color,
      'note': h.note,
      'createdAt': h.createdAt.toIso8601String(),
    }).toList();
  }

  /// Export character sheets and their entries for a book.
  Future<List<Map<String, dynamic>>> exportCharacterSheets(int bookId) async {
    final sheets = await ((_db.select(_db.characterSheets))
          ..where((s) => s.bookId.equals(bookId)))
        .get();
    final result = <Map<String, dynamic>>[];
    for (final sheet in sheets) {
      final entries = await ((_db.select(_db.characterSheetEntries))
            ..where((e) => e.sheetId.equals(sheet.id)))
          .get();
      result.add({
        'id': sheet.id,
        'bookId': sheet.bookId,
        'characterId': sheet.characterId,
        'name': sheet.name,
        'level': sheet.level,
        'className': sheet.className,
        'lastUpdatedAt': sheet.lastUpdatedAt.toIso8601String(),
        'entries': entries.map((e) => {
          'id': e.id,
          'sheetId': e.sheetId,
          'category': e.category,
          'entryKey': e.entryKey,
          'entryValue': e.entryValue,
          'sortOrder': e.sortOrder,
        }).toList(),
      });
    }
    return result;
  }

  /// Export everything for a single book as one JSON structure.
  Future<Map<String, dynamic>> exportFullBook(int bookId) async {
    final book = await ((_db.select(_db.books))
          ..where((b) => b.id.equals(bookId)))
        .getSingle();
    return {
      'book': await exportBook(book),
      'characters': await exportCharacters(bookId),
      'notes': await exportNotes(bookId),
      'worldAreas': await exportWorldAreas(bookId),
      'bookImages': await exportBookImages(bookId),
      'mindmap': await exportMindmap(bookId),
      'epubFile': await exportEpubFile(bookId),
      'bookmarks': await exportBookmarks(bookId),
      'highlights': await exportHighlights(bookId),
      'characterSheets': await exportCharacterSheets(bookId),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Export all books with all associated data.
  Future<Map<String, dynamic>> exportAll() async {
    final books = await _db.select(_db.books).get();
    final booksData = <int, Map<String, dynamic>>{};
    for (final book in books) {
      booksData[book.id] = await exportFullBook(book.id);
    }
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'books': booksData.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  // ─── Import ────────────────────────────────────────────────────────

  /// Import a full book from JSON. Uses an ID mapping to handle
  /// auto-increment IDs that may differ between devices.
  ///
  /// Returns the new local book ID.
  Future<int> importFullBook(Map<String, dynamic> data) async {
    return _db.transaction(() async {
      final bookJson = data['book'] as Map<String, dynamic>;

      // Check if book already exists by title+author (natural key)
      final existing = await ((_db.select(_db.books))
            ..where((b) =>
                b.title.equals(bookJson['title'] as String) &
                b.author.equals(bookJson['author'] as String)))
          .getSingleOrNull();

      int localBookId;
      if (existing != null) {
        localBookId = existing.id;
        // Update existing book metadata
        await (_db.update(_db.books)..where((b) => b.id.equals(localBookId)))
            .write(_bookCompanion(bookJson));
      } else {
        localBookId = await _db.into(_db.books).insert(
              _bookCompanion(bookJson),
            );
      }

      // Import characters (merge by name within book)
      final oldCharIdToNew = <int, int>{};
      final charList = (data['characters'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final cJson in charList) {
        final oldId = cJson['id'] as int;
        final existingChar = await ((_db.select(_db.characters))
              ..where((c) =>
                  c.bookId.equals(localBookId) &
                  c.name.equals(cJson['name'] as String)))
            .getSingleOrNull();
        if (existingChar != null) {
          oldCharIdToNew[oldId] = existingChar.id;
          await (_db.update(_db.characters)
                ..where((c) => c.id.equals(existingChar.id)))
              .write(_characterCompanion(cJson, localBookId));
        } else {
          final newId = await _db.into(_db.characters).insert(
                _characterCompanion(cJson, localBookId),
              );
          oldCharIdToNew[oldId] = newId;
        }
      }

      // Import notes
      final noteList = (data['notes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final nJson in noteList) {
        final existingNote = await ((_db.select(_db.notes))
              ..where((n) =>
                  n.bookId.equals(localBookId) &
                  n.content.equals(nJson['content'] as String) &
                  n.createdAt.equals(DateTime.parse(nJson['createdAt'] as String))))
            .getSingleOrNull();
        if (existingNote == null) {
          await _db.into(_db.notes).insert(_noteCompanion(nJson, localBookId));
        }
      }

      // Import world areas (merge by name)
      final oldAreaIdToNew = <int, int>{};
      final areaList = (data['worldAreas'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final aJson in areaList) {
        final oldId = aJson['id'] as int;
        final existingArea = await ((_db.select(_db.worldAreas))
              ..where((w) =>
                  w.bookId.equals(localBookId) &
                  w.name.equals(aJson['name'] as String)))
            .getSingleOrNull();
        if (existingArea != null) {
          oldAreaIdToNew[oldId] = existingArea.id;
          await (_db.update(_db.worldAreas)
                ..where((w) => w.id.equals(existingArea.id)))
              .write(_worldAreaCompanion(aJson, localBookId));
        } else {
          final newId = await _db.into(_db.worldAreas).insert(
                _worldAreaCompanion(aJson, localBookId),
              );
          oldAreaIdToNew[oldId] = newId;
        }
      }

      // Import book images
      final imgList = (data['bookImages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final iJson in imgList) {
        final existingImg = await ((_db.select(_db.bookImages))
              ..where((i) =>
                  i.bookId.equals(localBookId) &
                  i.path.equals(iJson['path'] as String)))
            .getSingleOrNull();
        if (existingImg == null) {
          await _db.into(_db.bookImages).insert(
                _bookImageCompanion(iJson, localBookId),
              );
        }
      }

      // Import mindmap nodes + edges
      final mindmapJson = data['mindmap'] as Map<String, dynamic>?;
      final oldNodeIdToNew = <int, int>{};
      if (mindmapJson != null) {
        final nodeList = (mindmapJson['nodes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (final nJson in nodeList) {
          final oldId = nJson['id'] as int;
          final existingNode = await ((_db.select(_db.mindmapNodes))
                ..where((n) =>
                    n.bookId.equals(localBookId) &
                    n.label.equals(nJson['label'] as String)))
              .getSingleOrNull();
          if (existingNode != null) {
            oldNodeIdToNew[oldId] = existingNode.id;
          } else {
            final newId = await _db.into(_db.mindmapNodes).insert(
                  _mindmapNodeCompanion(nJson, localBookId),
                );
            oldNodeIdToNew[oldId] = newId;
          }
        }

        final edgeList = (mindmapJson['edges'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (final eJson in edgeList) {
          final fromId = oldNodeIdToNew[eJson['fromNodeId'] as int];
          final toId = oldNodeIdToNew[eJson['toNodeId'] as int];
          if (fromId == null || toId == null) continue;

          final existingEdge = await ((_db.select(_db.mindmapEdges))
                ..where((e) =>
                    e.bookId.equals(localBookId) &
                    e.fromNodeId.equals(fromId) &
                    e.toNodeId.equals(toId)))
              .getSingleOrNull();
          if (existingEdge == null) {
            await _db.into(_db.mindmapEdges).insert(
                  _mindmapEdgeCompanion(eJson, localBookId, fromId, toId),
                );
          }
        }
      }

      // Import epub file metadata
      final epubJson = data['epubFile'] as Map<String, dynamic>?;
      if (epubJson != null) {
        final existingEpub = await ((_db.select(_db.epubFiles))
              ..where((e) => e.bookId.equals(localBookId)))
            .getSingleOrNull();
        if (existingEpub != null) {
          await (_db.update(_db.epubFiles)
                ..where((e) => e.id.equals(existingEpub.id)))
              .write(_epubFileCompanion(epubJson, localBookId));
        } else {
          await _db.into(_db.epubFiles).insert(
                _epubFileCompanion(epubJson, localBookId),
              );
        }
      }

      // Import bookmarks
      final bmList = (data['bookmarks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final bJson in bmList) {
        final existingBm = await ((_db.select(_db.readerBookmarks))
              ..where((b) =>
                  b.bookId.equals(localBookId) &
                  b.chapterIndex.equals(bJson['chapterIndex'] as int) &
                  b.createdAt.equals(DateTime.parse(bJson['createdAt'] as String))))
            .getSingleOrNull();
        if (existingBm == null) {
          await _db.into(_db.readerBookmarks).insert(
                _bookmarkCompanion(bJson, localBookId),
              );
        }
      }

      // Import highlights
      final hlList = (data['highlights'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final hJson in hlList) {
        final existingHl = await ((_db.select(_db.readerHighlights))
              ..where((h) =>
                  h.bookId.equals(localBookId) &
                  h.chapterIndex.equals(hJson['chapterIndex'] as int) &
                  h.rangeStart.equals(hJson['rangeStart'] as String) &
                  h.rangeEnd.equals(hJson['rangeEnd'] as String)))
            .getSingleOrNull();
        if (existingHl == null) {
          await _db.into(_db.readerHighlights).insert(
                _highlightCompanion(hJson, localBookId),
              );
        }
      }

      // Import character sheets + entries
      final sheetList = (data['characterSheets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final sJson in sheetList) {
        final existingSheet = await ((_db.select(_db.characterSheets))
              ..where((s) =>
                  s.bookId.equals(localBookId) &
                  s.name.equals(sJson['name'] as String)))
            .getSingleOrNull();

        int localSheetId;
        if (existingSheet != null) {
          localSheetId = existingSheet.id;
          // Update sheet metadata if remote is newer
          final remoteUpdated = DateTime.parse(sJson['lastUpdatedAt'] as String);
          if (remoteUpdated.isAfter(existingSheet.lastUpdatedAt)) {
            final charId = sJson['characterId'] as int?;
            final mappedCharId = charId != null ? oldCharIdToNew[charId] : null;
            await (_db.update(_db.characterSheets)
                  ..where((s) => s.id.equals(localSheetId)))
                .write(_sheetCompanion(sJson, localBookId, mappedCharId));
          }
        } else {
          final charId = sJson['characterId'] as int?;
          final mappedCharId = charId != null ? oldCharIdToNew[charId] : null;
          localSheetId = await _db.into(_db.characterSheets).insert(
                _sheetCompanion(sJson, localBookId, mappedCharId),
              );
        }

        // Import entries (upsert by key+category)
        final entryList = (sJson['entries'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (final eJson in entryList) {
          final existingEntry = await ((_db.select(_db.characterSheetEntries))
                ..where((e) =>
                    e.sheetId.equals(localSheetId) &
                    e.category.equals(eJson['category'] as int) &
                    e.entryKey.equals(eJson['entryKey'] as String)))
              .getSingleOrNull();
          if (existingEntry != null) {
            await (_db.update(_db.characterSheetEntries)
                  ..where((e) => e.id.equals(existingEntry.id)))
                .write(CharacterSheetEntriesCompanion(
              entryValue: Value(eJson['entryValue'] as String),
              sortOrder: Value(eJson['sortOrder'] as int? ?? 0),
            ));
          } else {
            await _db.into(_db.characterSheetEntries).insert(
                  _sheetEntryCompanion(eJson, localSheetId),
                );
          }
        }
      }

      return localBookId;
    });
  }

  /// Import all books from a full export.
  Future<void> importAll(Map<String, dynamic> data) async {
    final booksMap = data['books'] as Map<String, dynamic>? ?? {};
    for (final entry in booksMap.entries) {
      await importFullBook(entry.value as Map<String, dynamic>);
    }
  }

  // ─── Companion builders ────────────────────────────────────────────

  BooksCompanion _bookCompanion(Map<String, dynamic> j) {
    return BooksCompanion(
      title: Value(j['title'] as String),
      author: Value(j['author'] as String),
      coverImagePath: Value(j['coverImagePath'] as String?),
      genre: Value(j['genre'] as String?),
      totalPages: Value(j['totalPages'] as int? ?? 0),
      currentPage: Value(j['currentPage'] as int? ?? 0),
      status: Value(j['status'] as int? ?? 2),
      rating: Value(j['rating'] != null ? (j['rating'] as num).toDouble() : null),
      sourceApp: Value(j['sourceApp'] as int? ?? 0),
      dateAdded: Value(DateTime.parse(j['dateAdded'] as String)),
      dateFinished: Value(j['dateFinished'] != null
          ? DateTime.parse(j['dateFinished'] as String)
          : null),
    );
  }

  CharactersCompanion _characterCompanion(Map<String, dynamic> j, int bookId) {
    return CharactersCompanion(
      bookId: Value(bookId),
      name: Value(j['name'] as String),
      description: Value(j['description'] as String?),
      imagePath: Value(j['imagePath'] as String?),
      role: Value(j['role'] as int? ?? 2),
    );
  }

  NotesCompanion _noteCompanion(Map<String, dynamic> j, int bookId) {
    return NotesCompanion(
      bookId: Value(bookId),
      content: Value(j['content'] as String),
      pageNumber: Value(j['pageNumber'] as int?),
      chapter: Value(j['chapter'] as String?),
      sourceApp: Value(j['sourceApp'] as int? ?? 0),
      createdAt: Value(DateTime.parse(j['createdAt'] as String)),
    );
  }

  WorldAreasCompanion _worldAreaCompanion(Map<String, dynamic> j, int bookId) {
    return WorldAreasCompanion(
      bookId: Value(bookId),
      name: Value(j['name'] as String),
      description: Value(j['description'] as String?),
      imagePath: Value(j['imagePath'] as String?),
    );
  }

  BookImagesCompanion _bookImageCompanion(Map<String, dynamic> j, int bookId) {
    return BookImagesCompanion(
      bookId: Value(bookId),
      path: Value(j['path'] as String),
      caption: Value(j['caption'] as String?),
      createdAt: Value(DateTime.parse(j['createdAt'] as String)),
    );
  }

  MindmapNodesCompanion _mindmapNodeCompanion(Map<String, dynamic> j, int bookId) {
    return MindmapNodesCompanion(
      bookId: Value(bookId),
      entityType: Value(j['entityType'] as int? ?? 2),
      entityId: Value(j['entityId'] as int?),
      label: Value(j['label'] as String),
      positionX: Value((j['positionX'] as num?)?.toDouble() ?? 0.0),
      positionY: Value((j['positionY'] as num?)?.toDouble() ?? 0.0),
      color: Value(j['color'] as int? ?? 0xFF6750A4),
    );
  }

  MindmapEdgesCompanion _mindmapEdgeCompanion(
    Map<String, dynamic> j,
    int bookId,
    int fromNodeId,
    int toNodeId,
  ) {
    return MindmapEdgesCompanion(
      bookId: Value(bookId),
      fromNodeId: Value(fromNodeId),
      toNodeId: Value(toNodeId),
      label: Value(j['label'] as String?),
    );
  }

  EpubFilesCompanion _epubFileCompanion(Map<String, dynamic> j, int bookId) {
    return EpubFilesCompanion(
      bookId: Value(bookId),
      filePath: Value(j['filePath'] as String),
      currentChapterIndex: Value(j['currentChapterIndex'] as int? ?? 0),
      scrollPosition: Value((j['scrollPosition'] as num?)?.toDouble() ?? 0.0),
      lastReadAt: Value(j['lastReadAt'] != null
          ? DateTime.parse(j['lastReadAt'] as String)
          : null),
      fontSize: Value(j['fontSize'] as int? ?? 18),
      fontFamily: Value(j['fontFamily'] as String? ?? 'serif'),
      readerTheme: Value(j['readerTheme'] as int? ?? 0),
      lineHeight: Value((j['lineHeight'] as num?)?.toDouble() ?? 1.7),
    );
  }

  ReaderBookmarksCompanion _bookmarkCompanion(Map<String, dynamic> j, int bookId) {
    return ReaderBookmarksCompanion(
      bookId: Value(bookId),
      chapterIndex: Value(j['chapterIndex'] as int),
      scrollPosition: Value((j['scrollPosition'] as num?)?.toDouble() ?? 0.0),
      label: Value(j['label'] as String?),
      chapterTitle: Value(j['chapterTitle'] as String?),
      createdAt: Value(DateTime.parse(j['createdAt'] as String)),
    );
  }

  ReaderHighlightsCompanion _highlightCompanion(Map<String, dynamic> j, int bookId) {
    return ReaderHighlightsCompanion(
      bookId: Value(bookId),
      chapterIndex: Value(j['chapterIndex'] as int),
      highlightText: Value(j['highlightText'] as String),
      rangeStart: Value(j['rangeStart'] as String),
      rangeEnd: Value(j['rangeEnd'] as String),
      color: Value(j['color'] as int? ?? 0xFFFFEB3B),
      note: Value(j['note'] as String?),
      createdAt: Value(DateTime.parse(j['createdAt'] as String)),
    );
  }

  CharacterSheetsCompanion _sheetCompanion(
    Map<String, dynamic> j,
    int bookId,
    int? mappedCharId,
  ) {
    return CharacterSheetsCompanion(
      bookId: Value(bookId),
      characterId: Value(mappedCharId),
      name: Value(j['name'] as String),
      level: Value(j['level'] as int?),
      className: Value(j['className'] as String?),
      lastUpdatedAt: Value(DateTime.parse(j['lastUpdatedAt'] as String)),
    );
  }

  CharacterSheetEntriesCompanion _sheetEntryCompanion(
    Map<String, dynamic> j,
    int sheetId,
  ) {
    return CharacterSheetEntriesCompanion(
      sheetId: Value(sheetId),
      category: Value(j['category'] as int? ?? 0),
      entryKey: Value(j['entryKey'] as String),
      entryValue: Value(j['entryValue'] as String),
      sortOrder: Value(j['sortOrder'] as int? ?? 0),
    );
  }

  // ─── Helpers for per-file export (used by GitHub sync) ─────────────

  /// Encode a value to a pretty-printed JSON string.
  static String toJsonString(dynamic value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  /// Decode a JSON string.
  static dynamic fromJsonString(String json) {
    return jsonDecode(json);
  }
}
