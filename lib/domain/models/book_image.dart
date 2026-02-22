class BookImage {
  final int? id;
  final int bookId;
  final String path;
  final String? caption;
  final DateTime createdAt;

  const BookImage({
    this.id,
    required this.bookId,
    required this.path,
    this.caption,
    required this.createdAt,
  });

  BookImage copyWith({
    int? id,
    int? bookId,
    String? path,
    String? caption,
    DateTime? createdAt,
  }) {
    return BookImage(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      path: path ?? this.path,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
