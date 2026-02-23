import 'package:drift/drift.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get author => text().withLength(min: 1, max: 500)();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  IntColumn get status => integer().withDefault(const Constant(2))();
  RealColumn get rating => real().nullable()();
  IntColumn get sourceApp => integer().withDefault(const Constant(0))();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get dateFinished => dateTime().nullable()();
}

class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  TextColumn get name => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get role => integer().withDefault(const Constant(2))();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  TextColumn get content => text()();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get chapter => text().nullable()();
  IntColumn get sourceApp => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

class WorldAreas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  TextColumn get name => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
}

class BookImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  TextColumn get path => text()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class MindmapNodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get entityType => integer().withDefault(const Constant(2))();
  IntColumn get entityId => integer().nullable()();
  TextColumn get label => text().withLength(min: 1, max: 300)();
  RealColumn get positionX => real().withDefault(const Constant(0.0))();
  RealColumn get positionY => real().withDefault(const Constant(0.0))();
  IntColumn get color => integer().withDefault(const Constant(0xFF6750A4))();
}

class EpubFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  TextColumn get filePath => text()();
  IntColumn get currentChapterIndex => integer().withDefault(const Constant(0))();
  RealColumn get scrollPosition => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastReadAt => dateTime().nullable()();
  IntColumn get fontSize => integer().withDefault(const Constant(18))();
  TextColumn get fontFamily => text().withDefault(const Constant('serif'))();
  IntColumn get readerTheme => integer().withDefault(const Constant(0))();
  RealColumn get lineHeight => real().withDefault(const Constant(1.7))();
}

class ReaderBookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapterIndex => integer()();
  RealColumn get scrollPosition => real().withDefault(const Constant(0.0))();
  TextColumn get label => text().nullable()();
  TextColumn get chapterTitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class ReaderHighlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapterIndex => integer()();
  TextColumn get highlightText => text()();
  TextColumn get rangeStart => text()();
  TextColumn get rangeEnd => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFFFFEB3B))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class MindmapEdges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  @ReferenceName('edgesFrom')
  IntColumn get fromNodeId => integer().references(MindmapNodes, #id)();
  @ReferenceName('edgesTo')
  IntColumn get toNodeId => integer().references(MindmapNodes, #id)();
  TextColumn get label => text().nullable()();
}
