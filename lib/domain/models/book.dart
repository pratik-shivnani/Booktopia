enum BookStatus {
  reading,
  completed,
  wishlist,
  dropped;

  String get label {
    switch (this) {
      case BookStatus.reading:
        return 'Reading';
      case BookStatus.completed:
        return 'Completed';
      case BookStatus.wishlist:
        return 'Wishlist';
      case BookStatus.dropped:
        return 'Dropped';
    }
  }
}

enum SourceApp {
  manual,
  moonReader;

  String get label {
    switch (this) {
      case SourceApp.manual:
        return 'Manual';
      case SourceApp.moonReader:
        return 'Moon+ Reader';
    }
  }
}

class Book {
  final int? id;
  final String title;
  final String author;
  final String? coverImagePath;
  final String? genre;
  final int totalPages;
  final int currentPage;
  final BookStatus status;
  final double? rating;
  final SourceApp sourceApp;
  final DateTime dateAdded;
  final DateTime? dateFinished;

  const Book({
    this.id,
    required this.title,
    required this.author,
    this.coverImagePath,
    this.genre,
    this.totalPages = 0,
    this.currentPage = 0,
    this.status = BookStatus.wishlist,
    this.rating,
    this.sourceApp = SourceApp.manual,
    required this.dateAdded,
    this.dateFinished,
  });

  double get progress =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? coverImagePath,
    String? genre,
    int? totalPages,
    int? currentPage,
    BookStatus? status,
    double? rating,
    SourceApp? sourceApp,
    DateTime? dateAdded,
    DateTime? dateFinished,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      genre: genre ?? this.genre,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      sourceApp: sourceApp ?? this.sourceApp,
      dateAdded: dateAdded ?? this.dateAdded,
      dateFinished: dateFinished ?? this.dateFinished,
    );
  }
}
