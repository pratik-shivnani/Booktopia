class EpubData {
  final int? id;
  final int bookId;
  final String filePath;
  final int currentChapterIndex;
  final double scrollPosition;
  final DateTime? lastReadAt;

  const EpubData({
    this.id,
    required this.bookId,
    required this.filePath,
    this.currentChapterIndex = 0,
    this.scrollPosition = 0.0,
    this.lastReadAt,
  });

  EpubData copyWith({
    int? id,
    int? bookId,
    String? filePath,
    int? currentChapterIndex,
    double? scrollPosition,
    DateTime? lastReadAt,
  }) {
    return EpubData(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      filePath: filePath ?? this.filePath,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}
