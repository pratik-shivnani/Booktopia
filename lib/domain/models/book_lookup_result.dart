class BookLookupResult {
  final String title;
  final String author;
  final String? genre;
  final int? pageCount;
  final String? coverUrl;
  final String? description;
  final double? rating;
  final String source;

  const BookLookupResult({
    required this.title,
    required this.author,
    this.genre,
    this.pageCount,
    this.coverUrl,
    this.description,
    this.rating,
    required this.source,
  });
}
