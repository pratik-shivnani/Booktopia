import 'package:booktopia/domain/models/book.dart';

class Note {
  final int? id;
  final int bookId;
  final String content;
  final int? pageNumber;
  final String? chapter;
  final SourceApp sourceApp;
  final DateTime createdAt;

  const Note({
    this.id,
    required this.bookId,
    required this.content,
    this.pageNumber,
    this.chapter,
    this.sourceApp = SourceApp.manual,
    required this.createdAt,
  });

  Note copyWith({
    int? id,
    int? bookId,
    String? content,
    int? pageNumber,
    String? chapter,
    SourceApp? sourceApp,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      pageNumber: pageNumber ?? this.pageNumber,
      chapter: chapter ?? this.chapter,
      sourceApp: sourceApp ?? this.sourceApp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
