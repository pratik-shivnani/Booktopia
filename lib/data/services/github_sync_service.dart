import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'sync_serializer.dart';

/// Sync status for UI feedback.
enum SyncStatus { idle, syncing, success, error }

/// Handles all GitHub API communication for cloud sync.
///
/// Uses the GitHub Contents API to read/write files in the user's
/// private data repo. EPUBs are synced as binary blobs.
class GitHubSyncService {
  static const _apiBase = 'https://api.github.com';
  static const _storageKeyPat = 'github_pat';
  static const _storageKeyRepo = 'github_sync_repo';
  static const _storageKeyOwner = 'github_sync_owner';
  static const _storageKeyAutoSync = 'github_auto_sync';
  static const _storageKeyLastSync = 'github_last_sync';

  final AppDatabase _db;
  final FlutterSecureStorage _storage;
  late final SyncSerializer _serializer;

  String? _pat;
  String? _owner;
  String? _repo;

  GitHubSyncService(this._db, [FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage() {
    _serializer = SyncSerializer(_db);
  }

  // ─── Configuration ─────────────────────────────────────────────────

  Future<void> loadConfig() async {
    _pat = await _storage.read(key: _storageKeyPat);
    _owner = await _storage.read(key: _storageKeyOwner);
    _repo = await _storage.read(key: _storageKeyRepo);
  }

  Future<void> saveConfig({
    required String pat,
    required String owner,
    required String repo,
  }) async {
    await _storage.write(key: _storageKeyPat, value: pat);
    await _storage.write(key: _storageKeyOwner, value: owner);
    await _storage.write(key: _storageKeyRepo, value: repo);
    _pat = pat;
    _owner = owner;
    _repo = repo;
  }

  Future<bool> get isConfigured async {
    await loadConfig();
    return _pat != null &&
        _pat!.isNotEmpty &&
        _owner != null &&
        _owner!.isNotEmpty &&
        _repo != null &&
        _repo!.isNotEmpty;
  }

  Future<String?> get pat async => _pat ?? await _storage.read(key: _storageKeyPat);
  Future<String?> get owner async => _owner ?? await _storage.read(key: _storageKeyOwner);
  Future<String?> get repo async => _repo ?? await _storage.read(key: _storageKeyRepo);

  Future<bool> get autoSyncEnabled async {
    final val = await _storage.read(key: _storageKeyAutoSync);
    return val == 'true';
  }

  Future<void> setAutoSync(bool enabled) async {
    await _storage.write(key: _storageKeyAutoSync, value: enabled.toString());
  }

  Future<DateTime?> get lastSyncTime async {
    final val = await _storage.read(key: _storageKeyLastSync);
    return val != null ? DateTime.tryParse(val) : null;
  }

  Future<void> _updateLastSyncTime() async {
    await _storage.write(
      key: _storageKeyLastSync,
      value: DateTime.now().toIso8601String(),
    );
  }

  // ─── Validation ────────────────────────────────────────────────────

  /// Test the PAT and repo access. Returns null on success, error message on failure.
  Future<String?> testConnection() async {
    await loadConfig();
    if (_pat == null || _owner == null || _repo == null) {
      return 'Sync not configured. Please set PAT, owner, and repo name.';
    }
    try {
      final response = await _apiGet('/repos/$_owner/$_repo');
      if (response.statusCode == 200) return null;
      if (response.statusCode == 404) return 'Repository not found. Check owner/repo name.';
      if (response.statusCode == 401) return 'Invalid token. Check your PAT.';
      return 'GitHub API error: ${response.statusCode}';
    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  // ─── Push (Export → GitHub) ────────────────────────────────────────

  /// Push all book data to GitHub.
  Future<void> pushAll() async {
    await loadConfig();
    _ensureConfigured();

    final books = await _db.select(_db.books).get();

    // Push manifest
    final manifest = {
      'version': 1,
      'lastSyncedAt': DateTime.now().toIso8601String(),
      'bookCount': books.length,
      'deviceInfo': Platform.operatingSystem,
    };
    await _putFile('manifest.json', SyncSerializer.toJsonString(manifest));

    // Push each book's data as separate files
    for (final book in books) {
      await pushBookData(book.id);
    }

    await _updateLastSyncTime();
  }

  /// Push a single book's data to GitHub.
  Future<void> pushBookData(int bookId) async {
    await loadConfig();
    _ensureConfigured();

    final book = await ((_db.select(_db.books))
          ..where((b) => b.id.equals(bookId)))
        .getSingle();

    final prefix = 'books/${book.id}';

    // Push individual data files
    await _putFile(
      '$prefix/book.json',
      SyncSerializer.toJsonString(await _serializer.exportBook(book)),
    );
    await _putFile(
      '$prefix/characters.json',
      SyncSerializer.toJsonString(await _serializer.exportCharacters(bookId)),
    );
    await _putFile(
      '$prefix/notes.json',
      SyncSerializer.toJsonString(await _serializer.exportNotes(bookId)),
    );
    await _putFile(
      '$prefix/world_areas.json',
      SyncSerializer.toJsonString(await _serializer.exportWorldAreas(bookId)),
    );
    await _putFile(
      '$prefix/book_images.json',
      SyncSerializer.toJsonString(await _serializer.exportBookImages(bookId)),
    );
    await _putFile(
      '$prefix/mindmap.json',
      SyncSerializer.toJsonString(await _serializer.exportMindmap(bookId)),
    );
    await _putFile(
      '$prefix/bookmarks.json',
      SyncSerializer.toJsonString(await _serializer.exportBookmarks(bookId)),
    );
    await _putFile(
      '$prefix/highlights.json',
      SyncSerializer.toJsonString(await _serializer.exportHighlights(bookId)),
    );
    await _putFile(
      '$prefix/character_sheets.json',
      SyncSerializer.toJsonString(await _serializer.exportCharacterSheets(bookId)),
    );

    // Push epub file metadata + binary
    final epubData = await _serializer.exportEpubFile(bookId);
    if (epubData != null) {
      await _putFile(
        '$prefix/epub_file.json',
        SyncSerializer.toJsonString(epubData),
      );

      // Push the actual EPUB binary if the file exists on device
      final localPath = epubData['filePath'] as String?;
      if (localPath != null && await File(localPath).exists()) {
        await pushEpub(bookId, localPath);
      }
    }
  }

  /// Push an EPUB binary file to GitHub.
  Future<void> pushEpub(int bookId, String localEpubPath) async {
    await loadConfig();
    _ensureConfigured();

    final file = File(localEpubPath);
    if (!await file.exists()) return;

    final bytes = await file.readAsBytes();
    final base64Content = base64Encode(bytes);
    final remotePath = 'epubs/book_$bookId.epub';

    // Get existing file SHA if it exists
    final sha = await _getFileSha(remotePath);

    final body = <String, dynamic>{
      'message': 'Sync EPUB for book $bookId',
      'content': base64Content,
    };
    if (sha != null) body['sha'] = sha;

    final response = await _apiPut('/repos/$_owner/$_repo/contents/$remotePath', body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw SyncException('Failed to push EPUB: ${response.statusCode} ${response.body}');
    }
  }

  // ─── Pull (GitHub → Import) ────────────────────────────────────────

  /// Pull all book data from GitHub and merge into local DB.
  Future<void> pullAll() async {
    await loadConfig();
    _ensureConfigured();

    // List books directory
    final bookDirs = await _listDirectory('books');
    if (bookDirs == null) return;

    for (final dir in bookDirs) {
      if (dir['type'] != 'dir') continue;
      final dirName = dir['name'] as String;
      await _pullBookFromDir(dirName);
    }

    // Check for agent pending updates
    await pullPendingAgentUpdates();

    await _updateLastSyncTime();
  }

  /// Pull a single book's data from a GitHub directory.
  Future<void> _pullBookFromDir(String dirName) async {
    // Read book.json first
    final bookJson = await _getFileContent('books/$dirName/book.json');
    if (bookJson == null) return;

    final bookData = jsonDecode(bookJson) as Map<String, dynamic>;

    // Read all associated data files
    final characters = await _getFileContent('books/$dirName/characters.json');
    final notes = await _getFileContent('books/$dirName/notes.json');
    final worldAreas = await _getFileContent('books/$dirName/world_areas.json');
    final bookImages = await _getFileContent('books/$dirName/book_images.json');
    final mindmap = await _getFileContent('books/$dirName/mindmap.json');
    final bookmarks = await _getFileContent('books/$dirName/bookmarks.json');
    final highlights = await _getFileContent('books/$dirName/highlights.json');
    final characterSheets = await _getFileContent('books/$dirName/character_sheets.json');
    final epubFile = await _getFileContent('books/$dirName/epub_file.json');

    // Build the full book data structure
    final fullBookData = <String, dynamic>{
      'book': bookData,
      'characters': characters != null ? jsonDecode(characters) : [],
      'notes': notes != null ? jsonDecode(notes) : [],
      'worldAreas': worldAreas != null ? jsonDecode(worldAreas) : [],
      'bookImages': bookImages != null ? jsonDecode(bookImages) : [],
      'mindmap': mindmap != null ? jsonDecode(mindmap) : {'nodes': [], 'edges': []},
      'bookmarks': bookmarks != null ? jsonDecode(bookmarks) : [],
      'highlights': highlights != null ? jsonDecode(highlights) : [],
      'characterSheets': characterSheets != null ? jsonDecode(characterSheets) : [],
      'epubFile': epubFile != null ? jsonDecode(epubFile) : null,
    };

    await _serializer.importFullBook(fullBookData);
  }

  /// Pull an EPUB file from GitHub to local storage.
  Future<String?> pullEpub(int bookId) async {
    await loadConfig();
    _ensureConfigured();

    final remotePath = 'epubs/book_$bookId.epub';
    final response = await _apiGet('/repos/$_owner/$_repo/contents/$remotePath');
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as String;
    final bytes = base64Decode(content.replaceAll('\n', ''));

    final appDir = await getApplicationDocumentsDirectory();
    final epubDir = Directory(p.join(appDir.path, 'epubs'));
    if (!await epubDir.exists()) {
      await epubDir.create(recursive: true);
    }

    final destPath = p.join(epubDir.path, 'book_$bookId.epub');
    await File(destPath).writeAsBytes(bytes);
    return destPath;
  }

  /// Check for and apply pending updates from the helper agent.
  Future<int> pullPendingAgentUpdates() async {
    await loadConfig();
    _ensureConfigured();

    final files = await _listDirectory('agent/pending_updates');
    if (files == null || files.isEmpty) return 0;

    int applied = 0;
    for (final file in files) {
      if (file['type'] != 'file') continue;
      final name = file['name'] as String;
      if (!name.endsWith('.json')) continue;

      final content = await _getFileContent('agent/pending_updates/$name');
      if (content == null) continue;

      try {
        final updateData = jsonDecode(content) as Map<String, dynamic>;
        await _applyAgentUpdate(updateData);
        // Delete the processed file
        await _deleteFile('agent/pending_updates/$name');
        applied++;
      } catch (e) {
        // Skip malformed updates
        continue;
      }
    }
    return applied;
  }

  /// Apply a single agent update to the local DB.
  Future<void> _applyAgentUpdate(Map<String, dynamic> update) async {
    final bookId = update['bookId'] as int?;
    if (bookId == null) return;

    // Find local book by ID — agent uses the synced IDs
    final book = await ((_db.select(_db.books))
          ..where((b) => b.id.equals(bookId)))
        .getSingleOrNull();
    if (book == null) return;

    // Apply character sheet updates
    final sheets = (update['character_sheets'] as List?)?.cast<Map<String, dynamic>>();
    if (sheets != null) {
      for (final sheetJson in sheets) {
        await _applySheetUpdate(bookId, sheetJson);
      }
    }

    // Apply world area updates
    final areas = (update['world_areas'] as List?)?.cast<Map<String, dynamic>>();
    if (areas != null) {
      for (final areaJson in areas) {
        await _applyWorldAreaUpdate(bookId, areaJson);
      }
    }
  }

  Future<void> _applySheetUpdate(int bookId, Map<String, dynamic> sheetJson) async {
    final name = sheetJson['name'] as String;

    // Find or create character sheet
    var sheet = await ((_db.select(_db.characterSheets))
          ..where((s) => s.bookId.equals(bookId) & s.name.equals(name)))
        .getSingleOrNull();

    int sheetId;
    if (sheet != null) {
      sheetId = sheet.id;
      // Update level/class
      await (_db.update(_db.characterSheets)
            ..where((s) => s.id.equals(sheetId)))
          .write(CharacterSheetsCompanion(
        level: sheetJson['level'] != null
            ? Value(sheetJson['level'] as int)
            : const Value.absent(),
        className: sheetJson['className'] != null
            ? Value(sheetJson['className'] as String)
            : const Value.absent(),
        lastUpdatedAt: Value(DateTime.now()),
      ));
    } else {
      sheetId = await _db.into(_db.characterSheets).insert(
            CharacterSheetsCompanion(
              bookId: Value(bookId),
              name: Value(name),
              level: Value(sheetJson['level'] as int?),
              className: Value(sheetJson['className'] as String?),
              lastUpdatedAt: Value(DateTime.now()),
            ),
          );
    }

    // Upsert entries
    final entries = (sheetJson['entries'] as List?)?.cast<Map<String, dynamic>>();
    if (entries != null) {
      for (final entry in entries) {
        final category = entry['category'] as int? ?? 0;
        final key = entry['key'] as String;
        final value = entry['value'] as String;

        final existing = await ((_db.select(_db.characterSheetEntries))
              ..where((e) =>
                  e.sheetId.equals(sheetId) &
                  e.category.equals(category) &
                  e.entryKey.equals(key)))
            .getSingleOrNull();

        if (existing != null) {
          await (_db.update(_db.characterSheetEntries)
                ..where((e) => e.id.equals(existing.id)))
              .write(CharacterSheetEntriesCompanion(
            entryValue: Value(value),
          ));
        } else {
          await _db.into(_db.characterSheetEntries).insert(
                CharacterSheetEntriesCompanion(
                  sheetId: Value(sheetId),
                  category: Value(category),
                  entryKey: Value(key),
                  entryValue: Value(value),
                  sortOrder: Value(0),
                ),
              );
        }
      }
    }
  }

  Future<void> _applyWorldAreaUpdate(int bookId, Map<String, dynamic> areaJson) async {
    final name = areaJson['name'] as String;
    final description = areaJson['description'] as String?;

    final existing = await ((_db.select(_db.worldAreas))
          ..where((w) => w.bookId.equals(bookId) & w.name.equals(name)))
        .getSingleOrNull();

    if (existing != null) {
      if (description != null) {
        await (_db.update(_db.worldAreas)
              ..where((w) => w.id.equals(existing.id)))
            .write(WorldAreasCompanion(
          description: Value(description),
        ));
      }
    } else {
      await _db.into(_db.worldAreas).insert(WorldAreasCompanion(
        bookId: Value(bookId),
        name: Value(name),
        description: Value(description),
      ));
    }
  }

  // ─── GitHub API helpers ────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_pat',
        'Accept': 'application/vnd.github.v3+json',
        'X-GitHub-Api-Version': '2022-11-28',
      };

  Future<http.Response> _apiGet(String path) {
    return http.get(Uri.parse('$_apiBase$path'), headers: _headers);
  }

  Future<http.Response> _apiPut(String path, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$_apiBase$path'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<http.Response> _apiDelete(String path, Map<String, dynamic> body) {
    return http.delete(
      Uri.parse('$_apiBase$path'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  /// Put a UTF-8 text file to the repo.
  Future<void> _putFile(String path, String content) async {
    final sha = await _getFileSha(path);
    final body = <String, dynamic>{
      'message': 'Sync: $path',
      'content': base64Encode(utf8.encode(content)),
    };
    if (sha != null) body['sha'] = sha;

    final response = await _apiPut(
      '/repos/$_owner/$_repo/contents/$path',
      body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw SyncException('Failed to write $path: ${response.statusCode}');
    }
  }

  /// Get the SHA of an existing file (needed for updates).
  Future<String?> _getFileSha(String path) async {
    final response = await _apiGet('/repos/$_owner/$_repo/contents/$path');
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) return data['sha'] as String?;
    return null;
  }

  /// Get the decoded text content of a file.
  Future<String?> _getFileContent(String path) async {
    final response = await _apiGet('/repos/$_owner/$_repo/contents/$path');
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as String?;
    if (content == null) return null;
    return utf8.decode(base64Decode(content.replaceAll('\n', '')));
  }

  /// List contents of a directory.
  Future<List<Map<String, dynamic>>?> _listDirectory(String path) async {
    final response = await _apiGet('/repos/$_owner/$_repo/contents/$path');
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    return null;
  }

  /// Delete a file from the repo.
  Future<void> _deleteFile(String path) async {
    final sha = await _getFileSha(path);
    if (sha == null) return;

    await _apiDelete('/repos/$_owner/$_repo/contents/$path', {
      'message': 'Processed: $path',
      'sha': sha,
    });
  }

  void _ensureConfigured() {
    if (_pat == null || _owner == null || _repo == null) {
      throw SyncException('GitHub sync not configured.');
    }
  }
}

class SyncException implements Exception {
  final String message;
  const SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}
