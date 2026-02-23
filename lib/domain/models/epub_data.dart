enum ReaderTheme {
  light,
  dark,
  sepia;

  String get label {
    switch (this) {
      case ReaderTheme.light:
        return 'Light';
      case ReaderTheme.dark:
        return 'Dark';
      case ReaderTheme.sepia:
        return 'Sepia';
    }
  }
}

class EpubData {
  final int? id;
  final int bookId;
  final String filePath;
  final int currentChapterIndex;
  final double scrollPosition;
  final DateTime? lastReadAt;
  final int fontSize;
  final String fontFamily;
  final ReaderTheme readerTheme;
  final double lineHeight;

  const EpubData({
    this.id,
    required this.bookId,
    required this.filePath,
    this.currentChapterIndex = 0,
    this.scrollPosition = 0.0,
    this.lastReadAt,
    this.fontSize = 18,
    this.fontFamily = 'serif',
    this.readerTheme = ReaderTheme.light,
    this.lineHeight = 1.7,
  });

  EpubData copyWith({
    int? id,
    int? bookId,
    String? filePath,
    int? currentChapterIndex,
    double? scrollPosition,
    DateTime? lastReadAt,
    int? fontSize,
    String? fontFamily,
    ReaderTheme? readerTheme,
    double? lineHeight,
  }) {
    return EpubData(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      filePath: filePath ?? this.filePath,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      readerTheme: readerTheme ?? this.readerTheme,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

class ReaderBookmarkData {
  final int? id;
  final int bookId;
  final int chapterIndex;
  final double scrollPosition;
  final String? label;
  final String? chapterTitle;
  final DateTime createdAt;

  const ReaderBookmarkData({
    this.id,
    required this.bookId,
    required this.chapterIndex,
    this.scrollPosition = 0.0,
    this.label,
    this.chapterTitle,
    required this.createdAt,
  });
}
