enum MindmapEntityType {
  character,
  worldArea,
  custom;

  String get label {
    switch (this) {
      case MindmapEntityType.character:
        return 'Character';
      case MindmapEntityType.worldArea:
        return 'World Area';
      case MindmapEntityType.custom:
        return 'Custom';
    }
  }
}

class MindmapNode {
  final int? id;
  final int bookId;
  final MindmapEntityType entityType;
  final int? entityId;
  final String label;
  final double positionX;
  final double positionY;
  final int color;

  const MindmapNode({
    this.id,
    required this.bookId,
    required this.entityType,
    this.entityId,
    required this.label,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.color = 0xFF6750A4,
  });

  MindmapNode copyWith({
    int? id,
    int? bookId,
    MindmapEntityType? entityType,
    int? entityId,
    String? label,
    double? positionX,
    double? positionY,
    int? color,
  }) {
    return MindmapNode(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      label: label ?? this.label,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      color: color ?? this.color,
    );
  }
}
