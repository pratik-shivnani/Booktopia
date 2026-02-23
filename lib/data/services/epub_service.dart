import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:epubx/epubx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EpubChapter {
  final String title;
  final String htmlFileName;
  final List<EpubChapter> subChapters;

  const EpubChapter({
    required this.title,
    required this.htmlFileName,
    this.subChapters = const [],
  });
}

class ParsedEpub {
  final String title;
  final String author;
  final List<EpubChapter> tableOfContents;
  final List<String> spineFiles;
  final String extractionDir;

  const ParsedEpub({
    required this.title,
    required this.author,
    required this.tableOfContents,
    required this.spineFiles,
    required this.extractionDir,
  });

  int get totalChapters => spineFiles.length;
}

class EpubService {
  /// Copy an EPUB file to the app's documents directory.
  /// Returns the destination path.
  Future<String> importEpub(String sourcePath, int bookId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final epubDir = Directory(p.join(appDir.path, 'epubs'));
    if (!await epubDir.exists()) {
      await epubDir.create(recursive: true);
    }

    final fileName = 'book_$bookId.epub';
    final destPath = p.join(epubDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  /// Extract EPUB to a temp directory and parse its structure.
  Future<ParsedEpub> parseAndExtract(String epubFilePath) async {
    final bytes = await File(epubFilePath).readAsBytes();

    // Parse with epubx for metadata and TOC
    final epubBook = await EpubReader.readBook(bytes);

    // Extract zip to a directory
    final extractionDir = await _extractToDir(bytes, epubFilePath);

    // Build spine (reading order)
    final spineFiles = _buildSpine(epubBook);

    // Build TOC
    final toc = _buildToc(epubBook);

    final author = epubBook.AuthorList?.isNotEmpty == true
        ? epubBook.AuthorList!.join(', ')
        : epubBook.Author ?? 'Unknown';

    return ParsedEpub(
      title: epubBook.Title ?? 'Untitled',
      author: author,
      tableOfContents: toc,
      spineFiles: spineFiles,
      extractionDir: extractionDir,
    );
  }

  /// Get the file:// URL for a chapter at the given spine index.
  String getChapterFileUrl(ParsedEpub epub, int index) {
    if (index < 0 || index >= epub.spineFiles.length) return '';
    final chapterFile = epub.spineFiles[index];

    // Find the actual file in the extraction directory
    final fullPath = _findFile(epub.extractionDir, chapterFile);
    return 'file://$fullPath';
  }

  /// Build a complete HTML string for a chapter (fallback if file:// URLs don't work).
  Future<String> getChapterHtml(ParsedEpub epub, int index) async {
    if (index < 0 || index >= epub.spineFiles.length) return '<html><body><p>Chapter not found.</p></body></html>';
    final chapterFile = epub.spineFiles[index];
    final fullPath = _findFile(epub.extractionDir, chapterFile);

    final file = File(fullPath);
    if (!await file.exists()) {
      return '<html><body><p>Chapter file not found.</p></body></html>';
    }

    var html = await file.readAsString();

    // Inject base tag so relative CSS/image references resolve
    final baseDir = p.dirname(fullPath);
    final baseUrl = 'file://$baseDir/';
    if (!html.contains('<base')) {
      html = html.replaceFirst(
        RegExp(r'<head[^>]*>', caseSensitive: false),
        '<head><base href="$baseUrl">',
      );
    }

    return html;
  }

  Future<String> _extractToDir(Uint8List bytes, String epubPath) async {
    final cacheDir = await getTemporaryDirectory();
    final hash = epubPath.hashCode.abs();
    final extractDir = Directory(p.join(cacheDir.path, 'epub_$hash'));

    // Skip extraction if already done
    if (await extractDir.exists()) {
      final marker = File(p.join(extractDir.path, '.extracted'));
      if (await marker.exists()) {
        return extractDir.path;
      }
    }

    await extractDir.create(recursive: true);

    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filePath = p.join(extractDir.path, file.name);
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }

    // Write marker file
    await File(p.join(extractDir.path, '.extracted')).writeAsString('done');

    return extractDir.path;
  }

  List<String> _buildSpine(EpubBook book) {
    final spine = <String>[];

    // Use the spine from the book's schema if available
    if (book.Schema?.Package?.Spine?.Items != null) {
      final manifest = book.Schema?.Package?.Manifest?.Items;
      if (manifest != null) {
        for (final spineItem in book.Schema!.Package!.Spine!.Items!) {
          final manifestItem = manifest.firstWhere(
            (m) => m.Id == spineItem.IdRef,
            orElse: () => EpubManifestItem(),
          );
          if (manifestItem.Href != null) {
            spine.add(manifestItem.Href!);
          }
        }
      }
    }

    // Fallback: use content HTML files in order
    if (spine.isEmpty && book.Content?.Html != null) {
      spine.addAll(book.Content!.Html!.keys);
    }

    return spine;
  }

  List<EpubChapter> _buildToc(EpubBook book) {
    if (book.Chapters == null || book.Chapters!.isEmpty) return [];

    return book.Chapters!.map((ch) {
      return EpubChapter(
        title: ch.Title ?? 'Untitled',
        htmlFileName: ch.ContentFileName ?? '',
        subChapters: ch.SubChapters?.map((sub) {
          return EpubChapter(
            title: sub.Title ?? 'Untitled',
            htmlFileName: sub.ContentFileName ?? '',
          );
        }).toList() ?? [],
      );
    }).toList();
  }

  String _findFile(String extractionDir, String relativePath) {
    // Try direct path first
    var fullPath = p.join(extractionDir, relativePath);
    if (File(fullPath).existsSync()) return fullPath;

    // Try inside OEBPS or OPS directories (common EPUB structures)
    for (final prefix in ['OEBPS', 'OPS', 'content', 'Content']) {
      fullPath = p.join(extractionDir, prefix, relativePath);
      if (File(fullPath).existsSync()) return fullPath;
    }

    // Search recursively for the file by name
    final fileName = p.basename(relativePath);
    final found = _findFileRecursive(Directory(extractionDir), fileName);
    if (found != null) return found;

    return p.join(extractionDir, relativePath);
  }

  String? _findFileRecursive(Directory dir, String fileName) {
    try {
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File && p.basename(entity.path) == fileName) {
          return entity.path;
        }
      }
    } catch (_) {}
    return null;
  }
}
