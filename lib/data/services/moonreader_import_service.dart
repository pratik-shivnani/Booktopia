import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql3;

import '../database/app_database.dart';

/// Parsed data from a Moon+ Reader Pro backup (.mrpro).
class MoonReaderBackup {
  final List<MoonReaderBook> books;
  final List<MoonReaderNote> notes;
  final Map<String, MoonReaderStats> statistics;
  final Map<String, MoonReaderPosition> positions;

  const MoonReaderBackup({
    required this.books,
    required this.notes,
    required this.statistics,
    required this.positions,
  });
}

class MoonReaderBook {
  final String title;
  final String author;
  final String? description;
  final String? category;
  final String filename;
  final String? coverTagIndex;
  final String? epubTagIndex;
  final int? addTime;

  const MoonReaderBook({
    required this.title,
    required this.author,
    this.description,
    this.category,
    required this.filename,
    this.coverTagIndex,
    this.epubTagIndex,
    this.addTime,
  });
}

class MoonReaderNote {
  final String bookTitle;
  final String filename;
  final String? bookmark;
  final String? note;
  final String? original;
  final int? highlightColor;
  final int? lastChapter;
  final int? lastPosition;
  final int? time;

  const MoonReaderNote({
    required this.bookTitle,
    required this.filename,
    this.bookmark,
    this.note,
    this.original,
    this.highlightColor,
    this.lastChapter,
    this.lastPosition,
    this.time,
  });

  bool get isHighlight => original != null && original!.isNotEmpty;
  bool get isBookmark => bookmark != null && bookmark!.isNotEmpty && !isHighlight;
}

class MoonReaderStats {
  final int usedTimeMs;
  final int readWords;

  const MoonReaderStats({required this.usedTimeMs, required this.readWords});
}

class MoonReaderPosition {
  final double progressPercent;
  final String raw;

  const MoonReaderPosition({required this.progressPercent, required this.raw});
}

/// Result of an import operation.
class ImportResult {
  final int booksImported;
  final int notesImported;
  final int highlightsImported;
  final int epubsCopied;
  final List<String> warnings;

  const ImportResult({
    this.booksImported = 0,
    this.notesImported = 0,
    this.highlightsImported = 0,
    this.epubsCopied = 0,
    this.warnings = const [],
  });
}

/// Service for importing Moon+ Reader Pro backups (.mrpro files).
///
/// Backup format:
/// - ZIP archive with numbered `.tag` files
/// - `_names.list` maps tag numbers to original file paths
/// - One tag is `databases/mrbooks.db` (SQLite with books, notes, statistics)
/// - Other tags are EPUB files, cover images, and shared_prefs XMLs
/// - `positions10.xml` contains reading positions
class MoonReaderImportService {
  final AppDatabase _db;

  MoonReaderImportService(this._db);

  /// Parse a .mrpro backup file and return structured data.
  Future<MoonReaderBackup> parseBackup(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find and parse _names.list
    final namesFile = archive.findFile('com.flyersoft.moonreaderp/_names.list');
    if (namesFile == null) {
      throw Exception('Invalid Moon+ Reader backup: _names.list not found');
    }

    final namesList = String.fromCharCodes(namesFile.content as List<int>);
    final tagMap = _parseNamesList(namesList);

    // Find the mrbooks.db tag
    int? dbTagIndex;
    for (final entry in tagMap.entries) {
      if (entry.value.endsWith('mrbooks.db')) {
        dbTagIndex = entry.key;
        break;
      }
    }

    if (dbTagIndex == null) {
      throw Exception('Invalid Moon+ Reader backup: mrbooks.db not found');
    }

    // Extract mrbooks.db to temp
    final dbFile = archive.findFile('com.flyersoft.moonreaderp/$dbTagIndex.tag');
    if (dbFile == null) {
      throw Exception('Could not extract mrbooks.db from backup');
    }

    final tempDir = await getTemporaryDirectory();
    final dbPath = p.join(tempDir.path, 'mrbooks_import.db');
    await File(dbPath).writeAsBytes(dbFile.content as List<int>);

    // Read the SQLite database
    final mrDb = sql3.sqlite3.open(dbPath);

    try {
      final books = _readBooks(mrDb, tagMap);
      final notes = _readNotes(mrDb);
      final statistics = _readStatistics(mrDb);

      // Parse positions from XML tag
      int? positionsTagIndex;
      for (final entry in tagMap.entries) {
        if (entry.value.endsWith('positions10.xml')) {
          positionsTagIndex = entry.key;
          break;
        }
      }

      final positions = <String, MoonReaderPosition>{};
      if (positionsTagIndex != null) {
        final posFile = archive.findFile(
            'com.flyersoft.moonreaderp/$positionsTagIndex.tag');
        if (posFile != null) {
          final xml = String.fromCharCodes(posFile.content as List<int>);
          positions.addAll(_parsePositionsXml(xml));
        }
      }

      return MoonReaderBackup(
        books: books,
        notes: notes,
        statistics: statistics,
        positions: positions,
      );
    } finally {
      mrDb.dispose();
      try {
        await File(dbPath).delete();
      } catch (_) {}
    }
  }

  /// Import parsed backup data into the app database.
  /// [backupPath] is needed to extract EPUBs and covers from the ZIP.
  Future<ImportResult> importBackup(
    String backupPath,
    MoonReaderBackup backup, {
    Set<int>? selectedBookIndices,
  }) async {
    final bytes = await File(backupPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    int booksImported = 0;
    int notesImported = 0;
    int highlightsImported = 0;
    int epubsCopied = 0;
    final warnings = <String>[];

    final appDir = await getApplicationDocumentsDirectory();
    final epubDir = Directory(p.join(appDir.path, 'epubs'));
    final coverDir = Directory(p.join(appDir.path, 'covers'));
    if (!await epubDir.exists()) await epubDir.create(recursive: true);
    if (!await coverDir.exists()) await coverDir.create(recursive: true);

    for (int i = 0; i < backup.books.length; i++) {
      if (selectedBookIndices != null && !selectedBookIndices.contains(i)) {
        continue;
      }

      final mrBook = backup.books[i];

      // Check if book already exists
      final existing = await ((_db.select(_db.books))
            ..where((b) =>
                b.title.equals(mrBook.title) &
                b.author.equals(mrBook.author)))
          .getSingleOrNull();

      if (existing != null) {
        warnings.add('Skipped "${mrBook.title}" — already exists');
        continue;
      }

      // Determine reading progress from positions
      final lowerFilename = mrBook.filename.toLowerCase();
      double progress = 0;
      for (final entry in backup.positions.entries) {
        if (entry.key == lowerFilename ||
            lowerFilename.endsWith(entry.key) ||
            entry.key.endsWith(lowerFilename.split('/').last)) {
          progress = entry.value.progressPercent;
          break;
        }
      }

      // Extract cover image if available
      String? coverPath;
      if (mrBook.coverTagIndex != null) {
        final coverTag = archive.findFile(
            'com.flyersoft.moonreaderp/${mrBook.coverTagIndex}.tag');
        if (coverTag != null) {
          final ext = '.png';
          final coverFileName =
              'mr_${mrBook.title.replaceAll(RegExp(r'[^\w]'), '_')}$ext';
          coverPath = p.join(coverDir.path, coverFileName);
          await File(coverPath).writeAsBytes(coverTag.content as List<int>);
        }
      }

      // Determine status from progress
      int statusIndex;
      if (progress >= 0.99) {
        statusIndex = 1; // completed
      } else if (progress > 0) {
        statusIndex = 0; // reading
      } else {
        statusIndex = 2; // wishlist
      }

      // Insert book
      final bookId = await _db.into(_db.books).insert(BooksCompanion(
        title: Value(mrBook.title),
        author: Value(mrBook.author),
        coverImagePath: Value(coverPath),
        genre: Value(mrBook.category),
        totalPages: const Value(0),
        currentPage: const Value(0),
        status: Value(statusIndex),
        sourceApp: const Value(1), // moonReader
        dateAdded: Value(mrBook.addTime != null
            ? DateTime.fromMillisecondsSinceEpoch(mrBook.addTime!)
            : DateTime.now()),
      ));

      booksImported++;

      // Copy EPUB if available
      if (mrBook.epubTagIndex != null) {
        final epubTag = archive.findFile(
            'com.flyersoft.moonreaderp/${mrBook.epubTagIndex}.tag');
        if (epubTag != null) {
          final epubFileName = p.basename(mrBook.filename);
          final destPath = p.join(epubDir.path, epubFileName);
          await File(destPath).writeAsBytes(epubTag.content as List<int>);

          // Create EpubFile entry
          await _db.into(_db.epubFiles).insert(EpubFilesCompanion(
            bookId: Value(bookId),
            filePath: Value(destPath),
            currentChapterIndex: const Value(0),
            scrollPosition: const Value(0.0),
          ));

          epubsCopied++;
        }
      }

      // Import notes and highlights for this book
      final bookNotes =
          backup.notes.where((n) => n.bookTitle == mrBook.title ||
              n.filename.toLowerCase() == mrBook.filename.toLowerCase());

      for (final mrNote in bookNotes) {
        if (mrNote.isHighlight) {
          // Import as a note with the highlighted text
          final content = mrNote.note != null && mrNote.note!.isNotEmpty
              ? '${mrNote.original}\n\n---\n${mrNote.note}'
              : mrNote.original ?? '';

          await _db.into(_db.notes).insert(NotesCompanion(
            bookId: Value(bookId),
            content: Value(content),
            chapter: Value(mrNote.bookmark),
            sourceApp: const Value(1),
            createdAt: Value(mrNote.time != null
                ? DateTime.fromMillisecondsSinceEpoch(mrNote.time!)
                : DateTime.now()),
          ));
          highlightsImported++;
        } else if (mrNote.isBookmark) {
          // Import bookmark as a note
          await _db.into(_db.notes).insert(NotesCompanion(
            bookId: Value(bookId),
            content: Value('📌 Bookmark: ${mrNote.bookmark}'),
            sourceApp: const Value(1),
            createdAt: Value(mrNote.time != null
                ? DateTime.fromMillisecondsSinceEpoch(mrNote.time!)
                : DateTime.now()),
          ));
          notesImported++;
        }
      }
    }

    return ImportResult(
      booksImported: booksImported,
      notesImported: notesImported,
      highlightsImported: highlightsImported,
      epubsCopied: epubsCopied,
      warnings: warnings,
    );
  }

  // ─── Parsing helpers ───────────────────────────────────────────────

  /// Parse _names.list: line N maps to tag N+1
  /// Lines are actual file paths; tag index = line number (1-based)
  Map<int, String> _parseNamesList(String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final map = <int, String>{};
    for (int i = 0; i < lines.length; i++) {
      map[i + 1] = lines[i].trim();
    }
    return map;
  }

  List<MoonReaderBook> _readBooks(sql3.Database db, Map<int, String> tagMap) {
    final results = db.select('SELECT * FROM books');
    final books = <MoonReaderBook>[];

    // Build reverse lookup: original path → tag index
    final pathToTag = <String, int>{};
    for (final entry in tagMap.entries) {
      pathToTag[entry.value] = entry.key;
    }

    for (final row in results) {
      final filename = row['filename'] as String? ?? '';
      final coverFile = row['coverFile'] as String?;
      final title = row['book'] as String? ?? p.basenameWithoutExtension(filename);
      final rawAuthor = row['author'] as String? ?? '';
      final author = rawAuthor.trim().isEmpty ? 'Unknown' : rawAuthor;
      final addTimeStr = row['addTime'] as String?;

      // Find EPUB tag by matching filename prefix
      String? epubTagIndex;
      String? coverTagIndex;

      // Match by checking if the tag path starts with ? (external files)
      for (final entry in tagMap.entries) {
        final tagPath = entry.value;
        if (tagPath.startsWith('?')) {
          final actualPath = tagPath.substring(1);
          if (actualPath == filename) {
            epubTagIndex = entry.key.toString();
          }
          if (coverFile != null && actualPath == coverFile) {
            coverTagIndex = entry.key.toString();
          }
        }
      }

      books.add(MoonReaderBook(
        title: title,
        author: author,
        description: row['description'] as String?,
        category: row['category'] as String?,
        filename: filename,
        coverTagIndex: coverTagIndex,
        epubTagIndex: epubTagIndex,
        addTime: addTimeStr != null ? int.tryParse(addTimeStr) : null,
      ));
    }

    return books;
  }

  List<MoonReaderNote> _readNotes(sql3.Database db) {
    final results = db.select('SELECT * FROM notes');
    return results.map((row) {
      return MoonReaderNote(
        bookTitle: row['book'] as String? ?? '',
        filename: row['filename'] as String? ?? '',
        bookmark: row['bookmark'] as String?,
        note: row['note'] as String?,
        original: row['original'] as String?,
        highlightColor: row['highlightColor'] as int?,
        lastChapter: row['lastChapter'] as int?,
        lastPosition: row['lastPosition'] as int?,
        time: row['time'] as int?,
      );
    }).toList();
  }

  Map<String, MoonReaderStats> _readStatistics(sql3.Database db) {
    final results = db.select('SELECT * FROM statistics');
    final map = <String, MoonReaderStats>{};
    for (final row in results) {
      final filename = row['filename'] as String? ?? '';
      map[filename.toLowerCase()] = MoonReaderStats(
        usedTimeMs: row['usedTime'] as int? ?? 0,
        readWords: row['readWords'] as int? ?? 0,
      );
    }
    return map;
  }

  Map<String, MoonReaderPosition> _parsePositionsXml(String xml) {
    final positions = <String, MoonReaderPosition>{};
    // Parse simple XML: <string name="path">chapter@offset#totalChars:percent%</string>
    final pattern = RegExp(
      r'<string name="([^"]+)">([^<]+)</string>',
    );

    for (final match in pattern.allMatches(xml)) {
      final path = match.group(1)!;
      final value = match.group(2)!;

      // Extract percentage from end: ...:#:percent%
      final percentMatch = RegExp(r':(\d+\.?\d*)%').firstMatch(value);
      if (percentMatch != null) {
        final percent = double.tryParse(percentMatch.group(1)!) ?? 0;
        positions[path] = MoonReaderPosition(
          progressPercent: percent / 100.0,
          raw: value,
        );
      }
    }

    return positions;
  }
}
