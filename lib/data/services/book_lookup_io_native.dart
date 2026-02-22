import 'dart:io';
import 'dart:typed_data';

import 'package:epubx/epubx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/models/book_lookup_result.dart';

Future<BookLookupResult> parseEpubFile(String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  final book = await EpubReader.readBook(bytes);

  final title = book.Title ?? 'Untitled';
  final author = book.Author ?? 'Unknown';

  // Try to extract cover image
  String? coverUrl;
  final coverImage = book.CoverImage;
  if (coverImage != null) {
    final appDir = await getApplicationDocumentsDirectory();
    final coverDir = Directory(p.join(appDir.path, 'covers'));
    if (!coverDir.existsSync()) {
      coverDir.createSync(recursive: true);
    }
    final coverPath = p.join(
      coverDir.path,
      '${DateTime.now().millisecondsSinceEpoch}_epub_cover.png',
    );
    final imageBytes = coverImage.getBytes();
    await File(coverPath).writeAsBytes(imageBytes);
    coverUrl = coverPath;
  }

  // Try to count chapters as a rough "page" estimate
  int? pageCount;
  final chapters = book.Chapters;
  if (chapters != null && chapters.isNotEmpty) {
    pageCount = chapters.length * 20; // rough estimate
  }

  String? genre;
  final schema = book.Schema;
  if (schema?.Package?.Metadata?.Subjects != null) {
    final subjects = schema!.Package!.Metadata!.Subjects!;
    if (subjects.isNotEmpty) {
      genre = subjects.take(2).join(', ');
    }
  }

  return BookLookupResult(
    title: title,
    author: author,
    genre: genre,
    pageCount: pageCount,
    coverUrl: coverUrl,
    source: 'EPUB',
  );
}

Future<String?> saveCoverBytes(Uint8List bytes, String ext) async {
  final appDir = await getApplicationDocumentsDirectory();
  final coverDir = Directory(p.join(appDir.path, 'covers'));
  if (!coverDir.existsSync()) {
    coverDir.createSync(recursive: true);
  }
  final filePath = p.join(
    coverDir.path,
    '${DateTime.now().millisecondsSinceEpoch}_dl$ext',
  );
  await File(filePath).writeAsBytes(bytes);
  return filePath;
}
