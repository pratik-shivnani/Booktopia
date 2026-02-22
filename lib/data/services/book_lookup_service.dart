import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/book_lookup_result.dart';
import 'book_lookup_io.dart'
    if (dart.library.io) 'book_lookup_io_native.dart';

enum LookupSource {
  googleBooks('Google Books'),
  openLibrary('Goodreads / Open Library'),
  epub('EPUB File');

  const LookupSource(this.label);
  final String label;
}

class BookLookupService {
  // ─── Google Books API ───────────────────────────────────────────
  Future<List<BookLookupResult>> searchGoogleBooks(String query) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=15',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Google Books API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return [];

    return items.map((item) {
      final info = item['volumeInfo'] as Map<String, dynamic>? ?? {};
      final authors = (info['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown';
      final categories = (info['categories'] as List<dynamic>?)?.join(', ');
      final imageLinks = info['imageLinks'] as Map<String, dynamic>?;
      String? coverUrl = imageLinks?['thumbnail'] as String?;
      // Upgrade to higher-res if available
      coverUrl ??= imageLinks?['smallThumbnail'] as String?;
      // Force https
      coverUrl = coverUrl?.replaceFirst('http://', 'https://');

      double? rating;
      if (info['averageRating'] != null) {
        rating = (info['averageRating'] as num).toDouble();
      }

      return BookLookupResult(
        title: info['title'] as String? ?? 'Untitled',
        author: authors,
        genre: categories,
        pageCount: info['pageCount'] as int?,
        coverUrl: coverUrl,
        description: info['description'] as String?,
        rating: rating,
        source: 'Google Books',
      );
    }).toList();
  }

  // ─── Open Library API (Goodreads alternative) ───────────────────
  Future<List<BookLookupResult>> searchOpenLibrary(String query) async {
    final uri = Uri.parse(
      'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=15',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Open Library API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = json['docs'] as List<dynamic>?;
    if (docs == null || docs.isEmpty) return [];

    return docs.map((doc) {
      final d = doc as Map<String, dynamic>;
      final authors = (d['author_name'] as List<dynamic>?)?.join(', ') ?? 'Unknown';
      final subjects = (d['subject'] as List<dynamic>?)?.take(2).join(', ');
      final coverId = d['cover_i'];
      String? coverUrl;
      if (coverId != null) {
        coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
      }

      double? rating;
      if (d['ratings_average'] != null) {
        rating = (d['ratings_average'] as num).toDouble();
        rating = double.parse(rating.toStringAsFixed(1));
      }

      int? pageCount;
      if (d['number_of_pages_median'] != null) {
        pageCount = d['number_of_pages_median'] as int;
      }

      return BookLookupResult(
        title: d['title'] as String? ?? 'Untitled',
        author: authors,
        genre: subjects,
        pageCount: pageCount,
        coverUrl: coverUrl,
        rating: rating,
        source: 'Open Library',
      );
    }).toList();
  }

  // ─── EPUB Parser (delegates to platform-specific implementation) ─
  Future<BookLookupResult> parseEpubFromPath(String filePath) {
    return parseEpubFile(filePath);
  }

  // ─── Download cover image to local storage ──────────────────────
  Future<String?> downloadCover(String url) async {
    // If it's already a local path (from EPUB), return as-is
    if (!url.startsWith('http')) return url;

    // On web, just return the URL directly (no local file storage)
    if (kIsWeb) return url;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      return saveCoverBytes(response.bodyBytes, url.contains('.png') ? '.png' : '.jpg');
    } catch (_) {
      return null;
    }
  }
}
