class WorldArea {
  final int? id;
  final int bookId;
  final String name;
  final String? description;
  final String? imagePath;

  const WorldArea({
    this.id,
    required this.bookId,
    required this.name,
    this.description,
    this.imagePath,
  });

  WorldArea copyWith({
    int? id,
    int? bookId,
    String? name,
    String? description,
    String? imagePath,
  }) {
    return WorldArea(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
