enum CharacterRole {
  protagonist,
  antagonist,
  supporting,
  mentor,
  narrator,
  other;

  String get label {
    switch (this) {
      case CharacterRole.protagonist:
        return 'Protagonist';
      case CharacterRole.antagonist:
        return 'Antagonist';
      case CharacterRole.supporting:
        return 'Supporting';
      case CharacterRole.mentor:
        return 'Mentor';
      case CharacterRole.narrator:
        return 'Narrator';
      case CharacterRole.other:
        return 'Other';
    }
  }
}

class Character {
  final int? id;
  final int bookId;
  final String name;
  final String? description;
  final String? imagePath;
  final CharacterRole role;

  const Character({
    this.id,
    required this.bookId,
    required this.name,
    this.description,
    this.imagePath,
    this.role = CharacterRole.supporting,
  });

  Character copyWith({
    int? id,
    int? bookId,
    String? name,
    String? description,
    String? imagePath,
    CharacterRole? role,
  }) {
    return Character(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      role: role ?? this.role,
    );
  }
}
