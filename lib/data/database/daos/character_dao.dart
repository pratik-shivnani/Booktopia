import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'character_dao.g.dart';

@DriftAccessor(tables: [Characters])
class CharacterDao extends DatabaseAccessor<AppDatabase>
    with _$CharacterDaoMixin {
  CharacterDao(super.db);

  Stream<List<Character>> watchCharactersByBook(int bookId) {
    return (select(characters)..where((c) => c.bookId.equals(bookId))).watch();
  }

  Future<Character> getCharacterById(int id) {
    return (select(characters)..where((c) => c.id.equals(id))).getSingle();
  }

  Future<int> insertCharacter(CharactersCompanion character) {
    return into(characters).insert(character);
  }

  Future<bool> updateCharacter(CharactersCompanion character) {
    return update(characters).replace(character);
  }

  Future<int> deleteCharacter(int id) {
    return (delete(characters)..where((c) => c.id.equals(id))).go();
  }
}
