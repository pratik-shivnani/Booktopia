class MindmapEdge {
  final int? id;
  final int bookId;
  final int fromNodeId;
  final int toNodeId;
  final String? label;

  const MindmapEdge({
    this.id,
    required this.bookId,
    required this.fromNodeId,
    required this.toNodeId,
    this.label,
  });

  MindmapEdge copyWith({
    int? id,
    int? bookId,
    int? fromNodeId,
    int? toNodeId,
    String? label,
  }) {
    return MindmapEdge(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      label: label ?? this.label,
    );
  }
}
