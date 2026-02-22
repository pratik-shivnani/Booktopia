import 'package:drift/drift.dart';

import '../../domain/models/character.dart' as domain;
import '../database/app_database.dart';
import '../database/daos/character_dao.dart';

class CharacterRepository {
  final CharacterDao _dao;

  CharacterRepository(this._dao);

  Stream<List<domain.Character>> watchCharactersByBook(int bookId) {
    return _dao.watchCharactersByBook(bookId).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Future<domain.Character> getCharacterById(int id) async {
    final row = await _dao.getCharacterById(id);
    return _toDomain(row);
  }

  Future<int> addCharacter(domain.Character character) {
    return _dao.insertCharacter(_toCompanion(character));
  }

  Future<void> updateCharacter(domain.Character character) {
    return _dao.updateCharacter(_toCompanionWithId(character));
  }

  Future<void> deleteCharacter(int id) {
    return _dao.deleteCharacter(id);
  }

  domain.Character _toDomain(Character row) {
    return domain.Character(
      id: row.id,
      bookId: row.bookId,
      name: row.name,
      description: row.description,
      imagePath: row.imagePath,
      role: domain.CharacterRole.values[row.role],
    );
  }

  CharactersCompanion _toCompanion(domain.Character c) {
    return CharactersCompanion(
      bookId: Value(c.bookId),
      name: Value(c.name),
      description: Value(c.description),
      imagePath: Value(c.imagePath),
      role: Value(c.role.index),
    );
  }

  CharactersCompanion _toCompanionWithId(domain.Character c) {
    return CharactersCompanion(
      id: Value(c.id!),
      bookId: Value(c.bookId),
      name: Value(c.name),
      description: Value(c.description),
      imagePath: Value(c.imagePath),
      role: Value(c.role.index),
    );
  }
}
