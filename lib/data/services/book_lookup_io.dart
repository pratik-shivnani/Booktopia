import 'dart:typed_data';

import '../../domain/models/book_lookup_result.dart';

/// Stub — EPUB parsing and file saving not available on web.

Future<BookLookupResult> parseEpubFile(String filePath) {
  throw UnsupportedError('EPUB parsing is not supported on web');
}

Future<String?> saveCoverBytes(Uint8List bytes, String ext) async {
  // On web, we can't save to local file system
  return null;
}
