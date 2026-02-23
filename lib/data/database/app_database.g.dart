// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceAppMeta = const VerificationMeta(
    'sourceApp',
  );
  @override
  late final GeneratedColumn<int> sourceApp = GeneratedColumn<int>(
    'source_app',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateFinishedMeta = const VerificationMeta(
    'dateFinished',
  );
  @override
  late final GeneratedColumn<DateTime> dateFinished = GeneratedColumn<DateTime>(
    'date_finished',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    coverImagePath,
    genre,
    totalPages,
    currentPage,
    status,
    rating,
    sourceApp,
    dateAdded,
    dateFinished,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('source_app')) {
      context.handle(
        _sourceAppMeta,
        sourceApp.isAcceptableOrUnknown(data['source_app']!, _sourceAppMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('date_finished')) {
      context.handle(
        _dateFinishedMeta,
        dateFinished.isAcceptableOrUnknown(
          data['date_finished']!,
          _dateFinishedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      sourceApp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_app'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      dateFinished: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_finished'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String author;
  final String? coverImagePath;
  final String? genre;
  final int totalPages;
  final int currentPage;
  final int status;
  final double? rating;
  final int sourceApp;
  final DateTime dateAdded;
  final DateTime? dateFinished;
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverImagePath,
    this.genre,
    required this.totalPages,
    required this.currentPage,
    required this.status,
    this.rating,
    required this.sourceApp,
    required this.dateAdded,
    this.dateFinished,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['total_pages'] = Variable<int>(totalPages);
    map['current_page'] = Variable<int>(currentPage);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    map['source_app'] = Variable<int>(sourceApp);
    map['date_added'] = Variable<DateTime>(dateAdded);
    if (!nullToAbsent || dateFinished != null) {
      map['date_finished'] = Variable<DateTime>(dateFinished);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      totalPages: Value(totalPages),
      currentPage: Value(currentPage),
      status: Value(status),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      sourceApp: Value(sourceApp),
      dateAdded: Value(dateAdded),
      dateFinished: dateFinished == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFinished),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      genre: serializer.fromJson<String?>(json['genre']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      status: serializer.fromJson<int>(json['status']),
      rating: serializer.fromJson<double?>(json['rating']),
      sourceApp: serializer.fromJson<int>(json['sourceApp']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      dateFinished: serializer.fromJson<DateTime?>(json['dateFinished']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'genre': serializer.toJson<String?>(genre),
      'totalPages': serializer.toJson<int>(totalPages),
      'currentPage': serializer.toJson<int>(currentPage),
      'status': serializer.toJson<int>(status),
      'rating': serializer.toJson<double?>(rating),
      'sourceApp': serializer.toJson<int>(sourceApp),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'dateFinished': serializer.toJson<DateTime?>(dateFinished),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    Value<String?> coverImagePath = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    int? totalPages,
    int? currentPage,
    int? status,
    Value<double?> rating = const Value.absent(),
    int? sourceApp,
    DateTime? dateAdded,
    Value<DateTime?> dateFinished = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
    genre: genre.present ? genre.value : this.genre,
    totalPages: totalPages ?? this.totalPages,
    currentPage: currentPage ?? this.currentPage,
    status: status ?? this.status,
    rating: rating.present ? rating.value : this.rating,
    sourceApp: sourceApp ?? this.sourceApp,
    dateAdded: dateAdded ?? this.dateAdded,
    dateFinished: dateFinished.present ? dateFinished.value : this.dateFinished,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      genre: data.genre.present ? data.genre.value : this.genre,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      sourceApp: data.sourceApp.present ? data.sourceApp.value : this.sourceApp,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateFinished: data.dateFinished.present
          ? data.dateFinished.value
          : this.dateFinished,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('genre: $genre, ')
          ..write('totalPages: $totalPages, ')
          ..write('currentPage: $currentPage, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateFinished: $dateFinished')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    coverImagePath,
    genre,
    totalPages,
    currentPage,
    status,
    rating,
    sourceApp,
    dateAdded,
    dateFinished,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.coverImagePath == this.coverImagePath &&
          other.genre == this.genre &&
          other.totalPages == this.totalPages &&
          other.currentPage == this.currentPage &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.sourceApp == this.sourceApp &&
          other.dateAdded == this.dateAdded &&
          other.dateFinished == this.dateFinished);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String?> coverImagePath;
  final Value<String?> genre;
  final Value<int> totalPages;
  final Value<int> currentPage;
  final Value<int> status;
  final Value<double?> rating;
  final Value<int> sourceApp;
  final Value<DateTime> dateAdded;
  final Value<DateTime?> dateFinished;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.genre = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateFinished = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String author,
    this.coverImagePath = const Value.absent(),
    this.genre = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.sourceApp = const Value.absent(),
    required DateTime dateAdded,
    this.dateFinished = const Value.absent(),
  }) : title = Value(title),
       author = Value(author),
       dateAdded = Value(dateAdded);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? coverImagePath,
    Expression<String>? genre,
    Expression<int>? totalPages,
    Expression<int>? currentPage,
    Expression<int>? status,
    Expression<double>? rating,
    Expression<int>? sourceApp,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? dateFinished,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (genre != null) 'genre': genre,
      if (totalPages != null) 'total_pages': totalPages,
      if (currentPage != null) 'current_page': currentPage,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (sourceApp != null) 'source_app': sourceApp,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateFinished != null) 'date_finished': dateFinished,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? author,
    Value<String?>? coverImagePath,
    Value<String?>? genre,
    Value<int>? totalPages,
    Value<int>? currentPage,
    Value<int>? status,
    Value<double?>? rating,
    Value<int>? sourceApp,
    Value<DateTime>? dateAdded,
    Value<DateTime?>? dateFinished,
  }) {
    return BooksCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (sourceApp.present) {
      map['source_app'] = Variable<int>(sourceApp.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (dateFinished.present) {
      map['date_finished'] = Variable<DateTime>(dateFinished.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('genre: $genre, ')
          ..write('totalPages: $totalPages, ')
          ..write('currentPage: $currentPage, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateFinished: $dateFinished')
          ..write(')'))
        .toString();
  }
}

class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, Character> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    description,
    imagePath,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Character> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Character map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Character(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class Character extends DataClass implements Insertable<Character> {
  final int id;
  final int bookId;
  final String name;
  final String? description;
  final String? imagePath;
  final int role;
  const Character({
    required this.id,
    required this.bookId,
    required this.name,
    this.description,
    this.imagePath,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['role'] = Variable<int>(role);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      role: Value(role),
    );
  }

  factory Character.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Character(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      role: serializer.fromJson<int>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'role': serializer.toJson<int>(role),
    };
  }

  Character copyWith({
    int? id,
    int? bookId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    int? role,
  }) => Character(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    role: role ?? this.role,
  );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Character(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, name, description, imagePath, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Character &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.role == this.role);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> imagePath;
  final Value<int> role;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.role = const Value.absent(),
  });
  CharactersCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String name,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.role = const Value.absent(),
  }) : bookId = Value(bookId),
       name = Value(name);
  static Insertable<Character> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<int>? role,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (role != null) 'role': role,
    });
  }

  CharactersCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? imagePath,
    Value<int>? role,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      role: role ?? this.role,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<String> chapter = GeneratedColumn<String>(
    'chapter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceAppMeta = const VerificationMeta(
    'sourceApp',
  );
  @override
  late final GeneratedColumn<int> sourceApp = GeneratedColumn<int>(
    'source_app',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    content,
    pageNumber,
    chapter,
    sourceApp,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    }
    if (data.containsKey('source_app')) {
      context.handle(
        _sourceAppMeta,
        sourceApp.isAcceptableOrUnknown(data['source_app']!, _sourceAppMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      ),
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter'],
      ),
      sourceApp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_app'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final int bookId;
  final String content;
  final int? pageNumber;
  final String? chapter;
  final int sourceApp;
  final DateTime createdAt;
  const Note({
    required this.id,
    required this.bookId,
    required this.content,
    this.pageNumber,
    this.chapter,
    required this.sourceApp,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || pageNumber != null) {
      map['page_number'] = Variable<int>(pageNumber);
    }
    if (!nullToAbsent || chapter != null) {
      map['chapter'] = Variable<String>(chapter);
    }
    map['source_app'] = Variable<int>(sourceApp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      content: Value(content),
      pageNumber: pageNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pageNumber),
      chapter: chapter == null && nullToAbsent
          ? const Value.absent()
          : Value(chapter),
      sourceApp: Value(sourceApp),
      createdAt: Value(createdAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      content: serializer.fromJson<String>(json['content']),
      pageNumber: serializer.fromJson<int?>(json['pageNumber']),
      chapter: serializer.fromJson<String?>(json['chapter']),
      sourceApp: serializer.fromJson<int>(json['sourceApp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'content': serializer.toJson<String>(content),
      'pageNumber': serializer.toJson<int?>(pageNumber),
      'chapter': serializer.toJson<String?>(chapter),
      'sourceApp': serializer.toJson<int>(sourceApp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Note copyWith({
    int? id,
    int? bookId,
    String? content,
    Value<int?> pageNumber = const Value.absent(),
    Value<String?> chapter = const Value.absent(),
    int? sourceApp,
    DateTime? createdAt,
  }) => Note(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    content: content ?? this.content,
    pageNumber: pageNumber.present ? pageNumber.value : this.pageNumber,
    chapter: chapter.present ? chapter.value : this.chapter,
    sourceApp: sourceApp ?? this.sourceApp,
    createdAt: createdAt ?? this.createdAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      content: data.content.present ? data.content.value : this.content,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      sourceApp: data.sourceApp.present ? data.sourceApp.value : this.sourceApp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('content: $content, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('chapter: $chapter, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    content,
    pageNumber,
    chapter,
    sourceApp,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.content == this.content &&
          other.pageNumber == this.pageNumber &&
          other.chapter == this.chapter &&
          other.sourceApp == this.sourceApp &&
          other.createdAt == this.createdAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> content;
  final Value<int?> pageNumber;
  final Value<String?> chapter;
  final Value<int> sourceApp;
  final Value<DateTime> createdAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.content = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.chapter = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String content,
    this.pageNumber = const Value.absent(),
    this.chapter = const Value.absent(),
    this.sourceApp = const Value.absent(),
    required DateTime createdAt,
  }) : bookId = Value(bookId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? content,
    Expression<int>? pageNumber,
    Expression<String>? chapter,
    Expression<int>? sourceApp,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (content != null) 'content': content,
      if (pageNumber != null) 'page_number': pageNumber,
      if (chapter != null) 'chapter': chapter,
      if (sourceApp != null) 'source_app': sourceApp,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? content,
    Value<int?>? pageNumber,
    Value<String?>? chapter,
    Value<int>? sourceApp,
    Value<DateTime>? createdAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      pageNumber: pageNumber ?? this.pageNumber,
      chapter: chapter ?? this.chapter,
      sourceApp: sourceApp ?? this.sourceApp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<String>(chapter.value);
    }
    if (sourceApp.present) {
      map['source_app'] = Variable<int>(sourceApp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('content: $content, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('chapter: $chapter, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorldAreasTable extends WorldAreas
    with TableInfo<$WorldAreasTable, WorldArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorldAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    description,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'world_areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorldArea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorldArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorldArea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $WorldAreasTable createAlias(String alias) {
    return $WorldAreasTable(attachedDatabase, alias);
  }
}

class WorldArea extends DataClass implements Insertable<WorldArea> {
  final int id;
  final int bookId;
  final String name;
  final String? description;
  final String? imagePath;
  const WorldArea({
    required this.id,
    required this.bookId,
    required this.name,
    this.description,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  WorldAreasCompanion toCompanion(bool nullToAbsent) {
    return WorldAreasCompanion(
      id: Value(id),
      bookId: Value(bookId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory WorldArea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorldArea(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  WorldArea copyWith({
    int? id,
    int? bookId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
  }) => WorldArea(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  WorldArea copyWithCompanion(WorldAreasCompanion data) {
    return WorldArea(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorldArea(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, name, description, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorldArea &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.description == this.description &&
          other.imagePath == this.imagePath);
}

class WorldAreasCompanion extends UpdateCompanion<WorldArea> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> imagePath;
  const WorldAreasCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
  });
  WorldAreasCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String name,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
  }) : bookId = Value(bookId),
       name = Value(name);
  static Insertable<WorldArea> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
    });
  }

  WorldAreasCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? imagePath,
  }) {
    return WorldAreasCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorldAreasCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }
}

class $BookImagesTable extends BookImages
    with TableInfo<$BookImagesTable, BookImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookId, path, caption, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookImagesTable createAlias(String alias) {
    return $BookImagesTable(attachedDatabase, alias);
  }
}

class BookImage extends DataClass implements Insertable<BookImage> {
  final int id;
  final int bookId;
  final String path;
  final String? caption;
  final DateTime createdAt;
  const BookImage({
    required this.id,
    required this.bookId,
    required this.path,
    this.caption,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookImagesCompanion toCompanion(bool nullToAbsent) {
    return BookImagesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      path: Value(path),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
    );
  }

  factory BookImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookImage(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      path: serializer.fromJson<String>(json['path']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'path': serializer.toJson<String>(path),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookImage copyWith({
    int? id,
    int? bookId,
    String? path,
    Value<String?> caption = const Value.absent(),
    DateTime? createdAt,
  }) => BookImage(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    path: path ?? this.path,
    caption: caption.present ? caption.value : this.caption,
    createdAt: createdAt ?? this.createdAt,
  );
  BookImage copyWithCompanion(BookImagesCompanion data) {
    return BookImage(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      path: data.path.present ? data.path.value : this.path,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookImage(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('path: $path, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, path, caption, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookImage &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.path == this.path &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt);
}

class BookImagesCompanion extends UpdateCompanion<BookImage> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> path;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  const BookImagesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.path = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookImagesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String path,
    this.caption = const Value.absent(),
    required DateTime createdAt,
  }) : bookId = Value(bookId),
       path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<BookImage> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? path,
    Expression<String>? caption,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (path != null) 'path': path,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookImagesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? path,
    Value<String?>? caption,
    Value<DateTime>? createdAt,
  }) {
    return BookImagesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      path: path ?? this.path,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookImagesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('path: $path, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MindmapNodesTable extends MindmapNodes
    with TableInfo<$MindmapNodesTable, MindmapNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MindmapNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<int> entityType = GeneratedColumn<int>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionXMeta = const VerificationMeta(
    'positionX',
  );
  @override
  late final GeneratedColumn<double> positionX = GeneratedColumn<double>(
    'position_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _positionYMeta = const VerificationMeta(
    'positionY',
  );
  @override
  late final GeneratedColumn<double> positionY = GeneratedColumn<double>(
    'position_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF6750A4),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    entityType,
    entityId,
    label,
    positionX,
    positionY,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mindmap_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MindmapNode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('position_x')) {
      context.handle(
        _positionXMeta,
        positionX.isAcceptableOrUnknown(data['position_x']!, _positionXMeta),
      );
    }
    if (data.containsKey('position_y')) {
      context.handle(
        _positionYMeta,
        positionY.isAcceptableOrUnknown(data['position_y']!, _positionYMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MindmapNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MindmapNode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      positionX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_x'],
      )!,
      positionY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_y'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $MindmapNodesTable createAlias(String alias) {
    return $MindmapNodesTable(attachedDatabase, alias);
  }
}

class MindmapNode extends DataClass implements Insertable<MindmapNode> {
  final int id;
  final int bookId;
  final int entityType;
  final int? entityId;
  final String label;
  final double positionX;
  final double positionY;
  final int color;
  const MindmapNode({
    required this.id,
    required this.bookId,
    required this.entityType,
    this.entityId,
    required this.label,
    required this.positionX,
    required this.positionY,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['entity_type'] = Variable<int>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['label'] = Variable<String>(label);
    map['position_x'] = Variable<double>(positionX);
    map['position_y'] = Variable<double>(positionY);
    map['color'] = Variable<int>(color);
    return map;
  }

  MindmapNodesCompanion toCompanion(bool nullToAbsent) {
    return MindmapNodesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      label: Value(label),
      positionX: Value(positionX),
      positionY: Value(positionY),
      color: Value(color),
    );
  }

  factory MindmapNode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MindmapNode(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      entityType: serializer.fromJson<int>(json['entityType']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      label: serializer.fromJson<String>(json['label']),
      positionX: serializer.fromJson<double>(json['positionX']),
      positionY: serializer.fromJson<double>(json['positionY']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'entityType': serializer.toJson<int>(entityType),
      'entityId': serializer.toJson<int?>(entityId),
      'label': serializer.toJson<String>(label),
      'positionX': serializer.toJson<double>(positionX),
      'positionY': serializer.toJson<double>(positionY),
      'color': serializer.toJson<int>(color),
    };
  }

  MindmapNode copyWith({
    int? id,
    int? bookId,
    int? entityType,
    Value<int?> entityId = const Value.absent(),
    String? label,
    double? positionX,
    double? positionY,
    int? color,
  }) => MindmapNode(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    label: label ?? this.label,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    color: color ?? this.color,
  );
  MindmapNode copyWithCompanion(MindmapNodesCompanion data) {
    return MindmapNode(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      label: data.label.present ? data.label.value : this.label,
      positionX: data.positionX.present ? data.positionX.value : this.positionX,
      positionY: data.positionY.present ? data.positionY.value : this.positionY,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MindmapNode(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('label: $label, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    entityType,
    entityId,
    label,
    positionX,
    positionY,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MindmapNode &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.label == this.label &&
          other.positionX == this.positionX &&
          other.positionY == this.positionY &&
          other.color == this.color);
}

class MindmapNodesCompanion extends UpdateCompanion<MindmapNode> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> entityType;
  final Value<int?> entityId;
  final Value<String> label;
  final Value<double> positionX;
  final Value<double> positionY;
  final Value<int> color;
  const MindmapNodesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.label = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.color = const Value.absent(),
  });
  MindmapNodesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    required String label,
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.color = const Value.absent(),
  }) : bookId = Value(bookId),
       label = Value(label);
  static Insertable<MindmapNode> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? entityType,
    Expression<int>? entityId,
    Expression<String>? label,
    Expression<double>? positionX,
    Expression<double>? positionY,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (label != null) 'label': label,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (color != null) 'color': color,
    });
  }

  MindmapNodesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? entityType,
    Value<int?>? entityId,
    Value<String>? label,
    Value<double>? positionX,
    Value<double>? positionY,
    Value<int>? color,
  }) {
    return MindmapNodesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<int>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (positionX.present) {
      map['position_x'] = Variable<double>(positionX.value);
    }
    if (positionY.present) {
      map['position_y'] = Variable<double>(positionY.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MindmapNodesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('label: $label, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $MindmapEdgesTable extends MindmapEdges
    with TableInfo<$MindmapEdgesTable, MindmapEdge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MindmapEdgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _fromNodeIdMeta = const VerificationMeta(
    'fromNodeId',
  );
  @override
  late final GeneratedColumn<int> fromNodeId = GeneratedColumn<int>(
    'from_node_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mindmap_nodes (id)',
    ),
  );
  static const VerificationMeta _toNodeIdMeta = const VerificationMeta(
    'toNodeId',
  );
  @override
  late final GeneratedColumn<int> toNodeId = GeneratedColumn<int>(
    'to_node_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mindmap_nodes (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    fromNodeId,
    toNodeId,
    label,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mindmap_edges';
  @override
  VerificationContext validateIntegrity(
    Insertable<MindmapEdge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('from_node_id')) {
      context.handle(
        _fromNodeIdMeta,
        fromNodeId.isAcceptableOrUnknown(
          data['from_node_id']!,
          _fromNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromNodeIdMeta);
    }
    if (data.containsKey('to_node_id')) {
      context.handle(
        _toNodeIdMeta,
        toNodeId.isAcceptableOrUnknown(data['to_node_id']!, _toNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toNodeIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MindmapEdge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MindmapEdge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      fromNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_node_id'],
      )!,
      toNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_node_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $MindmapEdgesTable createAlias(String alias) {
    return $MindmapEdgesTable(attachedDatabase, alias);
  }
}

class MindmapEdge extends DataClass implements Insertable<MindmapEdge> {
  final int id;
  final int bookId;
  final int fromNodeId;
  final int toNodeId;
  final String? label;
  const MindmapEdge({
    required this.id,
    required this.bookId,
    required this.fromNodeId,
    required this.toNodeId,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['from_node_id'] = Variable<int>(fromNodeId);
    map['to_node_id'] = Variable<int>(toNodeId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  MindmapEdgesCompanion toCompanion(bool nullToAbsent) {
    return MindmapEdgesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      fromNodeId: Value(fromNodeId),
      toNodeId: Value(toNodeId),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory MindmapEdge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MindmapEdge(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      fromNodeId: serializer.fromJson<int>(json['fromNodeId']),
      toNodeId: serializer.fromJson<int>(json['toNodeId']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'fromNodeId': serializer.toJson<int>(fromNodeId),
      'toNodeId': serializer.toJson<int>(toNodeId),
      'label': serializer.toJson<String?>(label),
    };
  }

  MindmapEdge copyWith({
    int? id,
    int? bookId,
    int? fromNodeId,
    int? toNodeId,
    Value<String?> label = const Value.absent(),
  }) => MindmapEdge(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    fromNodeId: fromNodeId ?? this.fromNodeId,
    toNodeId: toNodeId ?? this.toNodeId,
    label: label.present ? label.value : this.label,
  );
  MindmapEdge copyWithCompanion(MindmapEdgesCompanion data) {
    return MindmapEdge(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      fromNodeId: data.fromNodeId.present
          ? data.fromNodeId.value
          : this.fromNodeId,
      toNodeId: data.toNodeId.present ? data.toNodeId.value : this.toNodeId,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MindmapEdge(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, fromNodeId, toNodeId, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MindmapEdge &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.fromNodeId == this.fromNodeId &&
          other.toNodeId == this.toNodeId &&
          other.label == this.label);
}

class MindmapEdgesCompanion extends UpdateCompanion<MindmapEdge> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> fromNodeId;
  final Value<int> toNodeId;
  final Value<String?> label;
  const MindmapEdgesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.fromNodeId = const Value.absent(),
    this.toNodeId = const Value.absent(),
    this.label = const Value.absent(),
  });
  MindmapEdgesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int fromNodeId,
    required int toNodeId,
    this.label = const Value.absent(),
  }) : bookId = Value(bookId),
       fromNodeId = Value(fromNodeId),
       toNodeId = Value(toNodeId);
  static Insertable<MindmapEdge> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? fromNodeId,
    Expression<int>? toNodeId,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (fromNodeId != null) 'from_node_id': fromNodeId,
      if (toNodeId != null) 'to_node_id': toNodeId,
      if (label != null) 'label': label,
    });
  }

  MindmapEdgesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? fromNodeId,
    Value<int>? toNodeId,
    Value<String?>? label,
  }) {
    return MindmapEdgesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (fromNodeId.present) {
      map['from_node_id'] = Variable<int>(fromNodeId.value);
    }
    if (toNodeId.present) {
      map['to_node_id'] = Variable<int>(toNodeId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MindmapEdgesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $EpubFilesTable extends EpubFiles
    with TableInfo<$EpubFilesTable, EpubFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpubFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentChapterIndexMeta =
      const VerificationMeta('currentChapterIndex');
  @override
  late final GeneratedColumn<int> currentChapterIndex = GeneratedColumn<int>(
    'current_chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scrollPositionMeta = const VerificationMeta(
    'scrollPosition',
  );
  @override
  late final GeneratedColumn<double> scrollPosition = GeneratedColumn<double>(
    'scroll_position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastReadAtMeta = const VerificationMeta(
    'lastReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
    'last_read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fontSizeMeta = const VerificationMeta(
    'fontSize',
  );
  @override
  late final GeneratedColumn<int> fontSize = GeneratedColumn<int>(
    'font_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(18),
  );
  static const VerificationMeta _fontFamilyMeta = const VerificationMeta(
    'fontFamily',
  );
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
    'font_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('serif'),
  );
  static const VerificationMeta _readerThemeMeta = const VerificationMeta(
    'readerTheme',
  );
  @override
  late final GeneratedColumn<int> readerTheme = GeneratedColumn<int>(
    'reader_theme',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lineHeightMeta = const VerificationMeta(
    'lineHeight',
  );
  @override
  late final GeneratedColumn<double> lineHeight = GeneratedColumn<double>(
    'line_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.7),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    filePath,
    currentChapterIndex,
    scrollPosition,
    lastReadAt,
    fontSize,
    fontFamily,
    readerTheme,
    lineHeight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epub_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpubFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('current_chapter_index')) {
      context.handle(
        _currentChapterIndexMeta,
        currentChapterIndex.isAcceptableOrUnknown(
          data['current_chapter_index']!,
          _currentChapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('scroll_position')) {
      context.handle(
        _scrollPositionMeta,
        scrollPosition.isAcceptableOrUnknown(
          data['scroll_position']!,
          _scrollPositionMeta,
        ),
      );
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
        _lastReadAtMeta,
        lastReadAt.isAcceptableOrUnknown(
          data['last_read_at']!,
          _lastReadAtMeta,
        ),
      );
    }
    if (data.containsKey('font_size')) {
      context.handle(
        _fontSizeMeta,
        fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta),
      );
    }
    if (data.containsKey('font_family')) {
      context.handle(
        _fontFamilyMeta,
        fontFamily.isAcceptableOrUnknown(data['font_family']!, _fontFamilyMeta),
      );
    }
    if (data.containsKey('reader_theme')) {
      context.handle(
        _readerThemeMeta,
        readerTheme.isAcceptableOrUnknown(
          data['reader_theme']!,
          _readerThemeMeta,
        ),
      );
    }
    if (data.containsKey('line_height')) {
      context.handle(
        _lineHeightMeta,
        lineHeight.isAcceptableOrUnknown(data['line_height']!, _lineHeightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EpubFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpubFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      currentChapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_chapter_index'],
      )!,
      scrollPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_position'],
      )!,
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_at'],
      ),
      fontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}font_size'],
      )!,
      fontFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}font_family'],
      )!,
      readerTheme: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reader_theme'],
      )!,
      lineHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_height'],
      )!,
    );
  }

  @override
  $EpubFilesTable createAlias(String alias) {
    return $EpubFilesTable(attachedDatabase, alias);
  }
}

class EpubFile extends DataClass implements Insertable<EpubFile> {
  final int id;
  final int bookId;
  final String filePath;
  final int currentChapterIndex;
  final double scrollPosition;
  final DateTime? lastReadAt;
  final int fontSize;
  final String fontFamily;
  final int readerTheme;
  final double lineHeight;
  const EpubFile({
    required this.id,
    required this.bookId,
    required this.filePath,
    required this.currentChapterIndex,
    required this.scrollPosition,
    this.lastReadAt,
    required this.fontSize,
    required this.fontFamily,
    required this.readerTheme,
    required this.lineHeight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['file_path'] = Variable<String>(filePath);
    map['current_chapter_index'] = Variable<int>(currentChapterIndex);
    map['scroll_position'] = Variable<double>(scrollPosition);
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
    }
    map['font_size'] = Variable<int>(fontSize);
    map['font_family'] = Variable<String>(fontFamily);
    map['reader_theme'] = Variable<int>(readerTheme);
    map['line_height'] = Variable<double>(lineHeight);
    return map;
  }

  EpubFilesCompanion toCompanion(bool nullToAbsent) {
    return EpubFilesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      filePath: Value(filePath),
      currentChapterIndex: Value(currentChapterIndex),
      scrollPosition: Value(scrollPosition),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      fontSize: Value(fontSize),
      fontFamily: Value(fontFamily),
      readerTheme: Value(readerTheme),
      lineHeight: Value(lineHeight),
    );
  }

  factory EpubFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpubFile(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      currentChapterIndex: serializer.fromJson<int>(
        json['currentChapterIndex'],
      ),
      scrollPosition: serializer.fromJson<double>(json['scrollPosition']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
      fontSize: serializer.fromJson<int>(json['fontSize']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      readerTheme: serializer.fromJson<int>(json['readerTheme']),
      lineHeight: serializer.fromJson<double>(json['lineHeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'filePath': serializer.toJson<String>(filePath),
      'currentChapterIndex': serializer.toJson<int>(currentChapterIndex),
      'scrollPosition': serializer.toJson<double>(scrollPosition),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
      'fontSize': serializer.toJson<int>(fontSize),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'readerTheme': serializer.toJson<int>(readerTheme),
      'lineHeight': serializer.toJson<double>(lineHeight),
    };
  }

  EpubFile copyWith({
    int? id,
    int? bookId,
    String? filePath,
    int? currentChapterIndex,
    double? scrollPosition,
    Value<DateTime?> lastReadAt = const Value.absent(),
    int? fontSize,
    String? fontFamily,
    int? readerTheme,
    double? lineHeight,
  }) => EpubFile(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    filePath: filePath ?? this.filePath,
    currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
    scrollPosition: scrollPosition ?? this.scrollPosition,
    lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
    fontSize: fontSize ?? this.fontSize,
    fontFamily: fontFamily ?? this.fontFamily,
    readerTheme: readerTheme ?? this.readerTheme,
    lineHeight: lineHeight ?? this.lineHeight,
  );
  EpubFile copyWithCompanion(EpubFilesCompanion data) {
    return EpubFile(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      currentChapterIndex: data.currentChapterIndex.present
          ? data.currentChapterIndex.value
          : this.currentChapterIndex,
      scrollPosition: data.scrollPosition.present
          ? data.scrollPosition.value
          : this.scrollPosition,
      lastReadAt: data.lastReadAt.present
          ? data.lastReadAt.value
          : this.lastReadAt,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      fontFamily: data.fontFamily.present
          ? data.fontFamily.value
          : this.fontFamily,
      readerTheme: data.readerTheme.present
          ? data.readerTheme.value
          : this.readerTheme,
      lineHeight: data.lineHeight.present
          ? data.lineHeight.value
          : this.lineHeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpubFile(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('filePath: $filePath, ')
          ..write('currentChapterIndex: $currentChapterIndex, ')
          ..write('scrollPosition: $scrollPosition, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('fontSize: $fontSize, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('readerTheme: $readerTheme, ')
          ..write('lineHeight: $lineHeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    filePath,
    currentChapterIndex,
    scrollPosition,
    lastReadAt,
    fontSize,
    fontFamily,
    readerTheme,
    lineHeight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpubFile &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.filePath == this.filePath &&
          other.currentChapterIndex == this.currentChapterIndex &&
          other.scrollPosition == this.scrollPosition &&
          other.lastReadAt == this.lastReadAt &&
          other.fontSize == this.fontSize &&
          other.fontFamily == this.fontFamily &&
          other.readerTheme == this.readerTheme &&
          other.lineHeight == this.lineHeight);
}

class EpubFilesCompanion extends UpdateCompanion<EpubFile> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> filePath;
  final Value<int> currentChapterIndex;
  final Value<double> scrollPosition;
  final Value<DateTime?> lastReadAt;
  final Value<int> fontSize;
  final Value<String> fontFamily;
  final Value<int> readerTheme;
  final Value<double> lineHeight;
  const EpubFilesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.currentChapterIndex = const Value.absent(),
    this.scrollPosition = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.readerTheme = const Value.absent(),
    this.lineHeight = const Value.absent(),
  });
  EpubFilesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String filePath,
    this.currentChapterIndex = const Value.absent(),
    this.scrollPosition = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.readerTheme = const Value.absent(),
    this.lineHeight = const Value.absent(),
  }) : bookId = Value(bookId),
       filePath = Value(filePath);
  static Insertable<EpubFile> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? filePath,
    Expression<int>? currentChapterIndex,
    Expression<double>? scrollPosition,
    Expression<DateTime>? lastReadAt,
    Expression<int>? fontSize,
    Expression<String>? fontFamily,
    Expression<int>? readerTheme,
    Expression<double>? lineHeight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (filePath != null) 'file_path': filePath,
      if (currentChapterIndex != null)
        'current_chapter_index': currentChapterIndex,
      if (scrollPosition != null) 'scroll_position': scrollPosition,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (fontSize != null) 'font_size': fontSize,
      if (fontFamily != null) 'font_family': fontFamily,
      if (readerTheme != null) 'reader_theme': readerTheme,
      if (lineHeight != null) 'line_height': lineHeight,
    });
  }

  EpubFilesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? filePath,
    Value<int>? currentChapterIndex,
    Value<double>? scrollPosition,
    Value<DateTime?>? lastReadAt,
    Value<int>? fontSize,
    Value<String>? fontFamily,
    Value<int>? readerTheme,
    Value<double>? lineHeight,
  }) {
    return EpubFilesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (currentChapterIndex.present) {
      map['current_chapter_index'] = Variable<int>(currentChapterIndex.value);
    }
    if (scrollPosition.present) {
      map['scroll_position'] = Variable<double>(scrollPosition.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<int>(fontSize.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (readerTheme.present) {
      map['reader_theme'] = Variable<int>(readerTheme.value);
    }
    if (lineHeight.present) {
      map['line_height'] = Variable<double>(lineHeight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpubFilesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('filePath: $filePath, ')
          ..write('currentChapterIndex: $currentChapterIndex, ')
          ..write('scrollPosition: $scrollPosition, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('fontSize: $fontSize, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('readerTheme: $readerTheme, ')
          ..write('lineHeight: $lineHeight')
          ..write(')'))
        .toString();
  }
}

class $ReaderBookmarksTable extends ReaderBookmarks
    with TableInfo<$ReaderBookmarksTable, ReaderBookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scrollPositionMeta = const VerificationMeta(
    'scrollPosition',
  );
  @override
  late final GeneratedColumn<double> scrollPosition = GeneratedColumn<double>(
    'scroll_position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterTitleMeta = const VerificationMeta(
    'chapterTitle',
  );
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
    'chapter_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterIndex,
    scrollPosition,
    label,
    chapterTitle,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderBookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('scroll_position')) {
      context.handle(
        _scrollPositionMeta,
        scrollPosition.isAcceptableOrUnknown(
          data['scroll_position']!,
          _scrollPositionMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
        _chapterTitleMeta,
        chapterTitle.isAcceptableOrUnknown(
          data['chapter_title']!,
          _chapterTitleMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderBookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderBookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      scrollPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_position'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      chapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_title'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReaderBookmarksTable createAlias(String alias) {
    return $ReaderBookmarksTable(attachedDatabase, alias);
  }
}

class ReaderBookmark extends DataClass implements Insertable<ReaderBookmark> {
  final int id;
  final int bookId;
  final int chapterIndex;
  final double scrollPosition;
  final String? label;
  final String? chapterTitle;
  final DateTime createdAt;
  const ReaderBookmark({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.scrollPosition,
    this.label,
    this.chapterTitle,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['scroll_position'] = Variable<double>(scrollPosition);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || chapterTitle != null) {
      map['chapter_title'] = Variable<String>(chapterTitle);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReaderBookmarksCompanion toCompanion(bool nullToAbsent) {
    return ReaderBookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      scrollPosition: Value(scrollPosition),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      chapterTitle: chapterTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterTitle),
      createdAt: Value(createdAt),
    );
  }

  factory ReaderBookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderBookmark(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      scrollPosition: serializer.fromJson<double>(json['scrollPosition']),
      label: serializer.fromJson<String?>(json['label']),
      chapterTitle: serializer.fromJson<String?>(json['chapterTitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'scrollPosition': serializer.toJson<double>(scrollPosition),
      'label': serializer.toJson<String?>(label),
      'chapterTitle': serializer.toJson<String?>(chapterTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReaderBookmark copyWith({
    int? id,
    int? bookId,
    int? chapterIndex,
    double? scrollPosition,
    Value<String?> label = const Value.absent(),
    Value<String?> chapterTitle = const Value.absent(),
    DateTime? createdAt,
  }) => ReaderBookmark(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    scrollPosition: scrollPosition ?? this.scrollPosition,
    label: label.present ? label.value : this.label,
    chapterTitle: chapterTitle.present ? chapterTitle.value : this.chapterTitle,
    createdAt: createdAt ?? this.createdAt,
  );
  ReaderBookmark copyWithCompanion(ReaderBookmarksCompanion data) {
    return ReaderBookmark(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      scrollPosition: data.scrollPosition.present
          ? data.scrollPosition.value
          : this.scrollPosition,
      label: data.label.present ? data.label.value : this.label,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderBookmark(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('scrollPosition: $scrollPosition, ')
          ..write('label: $label, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterIndex,
    scrollPosition,
    label,
    chapterTitle,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderBookmark &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.scrollPosition == this.scrollPosition &&
          other.label == this.label &&
          other.chapterTitle == this.chapterTitle &&
          other.createdAt == this.createdAt);
}

class ReaderBookmarksCompanion extends UpdateCompanion<ReaderBookmark> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapterIndex;
  final Value<double> scrollPosition;
  final Value<String?> label;
  final Value<String?> chapterTitle;
  final Value<DateTime> createdAt;
  const ReaderBookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.scrollPosition = const Value.absent(),
    this.label = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReaderBookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapterIndex,
    this.scrollPosition = const Value.absent(),
    this.label = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    required DateTime createdAt,
  }) : bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       createdAt = Value(createdAt);
  static Insertable<ReaderBookmark> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapterIndex,
    Expression<double>? scrollPosition,
    Expression<String>? label,
    Expression<String>? chapterTitle,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (scrollPosition != null) 'scroll_position': scrollPosition,
      if (label != null) 'label': label,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReaderBookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? chapterIndex,
    Value<double>? scrollPosition,
    Value<String?>? label,
    Value<String?>? chapterTitle,
    Value<DateTime>? createdAt,
  }) {
    return ReaderBookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      label: label ?? this.label,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (scrollPosition.present) {
      map['scroll_position'] = Variable<double>(scrollPosition.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderBookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('scrollPosition: $scrollPosition, ')
          ..write('label: $label, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReaderHighlightsTable extends ReaderHighlights
    with TableInfo<$ReaderHighlightsTable, ReaderHighlight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderHighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highlightTextMeta = const VerificationMeta(
    'highlightText',
  );
  @override
  late final GeneratedColumn<String> highlightText = GeneratedColumn<String>(
    'highlight_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeStartMeta = const VerificationMeta(
    'rangeStart',
  );
  @override
  late final GeneratedColumn<String> rangeStart = GeneratedColumn<String>(
    'range_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeEndMeta = const VerificationMeta(
    'rangeEnd',
  );
  @override
  late final GeneratedColumn<String> rangeEnd = GeneratedColumn<String>(
    'range_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFFFFEB3B),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterIndex,
    highlightText,
    rangeStart,
    rangeEnd,
    color,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_highlights';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderHighlight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('highlight_text')) {
      context.handle(
        _highlightTextMeta,
        highlightText.isAcceptableOrUnknown(
          data['highlight_text']!,
          _highlightTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_highlightTextMeta);
    }
    if (data.containsKey('range_start')) {
      context.handle(
        _rangeStartMeta,
        rangeStart.isAcceptableOrUnknown(data['range_start']!, _rangeStartMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeStartMeta);
    }
    if (data.containsKey('range_end')) {
      context.handle(
        _rangeEndMeta,
        rangeEnd.isAcceptableOrUnknown(data['range_end']!, _rangeEndMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeEndMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderHighlight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderHighlight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      highlightText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}highlight_text'],
      )!,
      rangeStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range_start'],
      )!,
      rangeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}range_end'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReaderHighlightsTable createAlias(String alias) {
    return $ReaderHighlightsTable(attachedDatabase, alias);
  }
}

class ReaderHighlight extends DataClass implements Insertable<ReaderHighlight> {
  final int id;
  final int bookId;
  final int chapterIndex;
  final String highlightText;
  final String rangeStart;
  final String rangeEnd;
  final int color;
  final String? note;
  final DateTime createdAt;
  const ReaderHighlight({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.highlightText,
    required this.rangeStart,
    required this.rangeEnd,
    required this.color,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['highlight_text'] = Variable<String>(highlightText);
    map['range_start'] = Variable<String>(rangeStart);
    map['range_end'] = Variable<String>(rangeEnd);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReaderHighlightsCompanion toCompanion(bool nullToAbsent) {
    return ReaderHighlightsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      highlightText: Value(highlightText),
      rangeStart: Value(rangeStart),
      rangeEnd: Value(rangeEnd),
      color: Value(color),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory ReaderHighlight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderHighlight(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      highlightText: serializer.fromJson<String>(json['highlightText']),
      rangeStart: serializer.fromJson<String>(json['rangeStart']),
      rangeEnd: serializer.fromJson<String>(json['rangeEnd']),
      color: serializer.fromJson<int>(json['color']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'highlightText': serializer.toJson<String>(highlightText),
      'rangeStart': serializer.toJson<String>(rangeStart),
      'rangeEnd': serializer.toJson<String>(rangeEnd),
      'color': serializer.toJson<int>(color),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReaderHighlight copyWith({
    int? id,
    int? bookId,
    int? chapterIndex,
    String? highlightText,
    String? rangeStart,
    String? rangeEnd,
    int? color,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => ReaderHighlight(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    highlightText: highlightText ?? this.highlightText,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
    color: color ?? this.color,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  ReaderHighlight copyWithCompanion(ReaderHighlightsCompanion data) {
    return ReaderHighlight(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      highlightText: data.highlightText.present
          ? data.highlightText.value
          : this.highlightText,
      rangeStart: data.rangeStart.present
          ? data.rangeStart.value
          : this.rangeStart,
      rangeEnd: data.rangeEnd.present ? data.rangeEnd.value : this.rangeEnd,
      color: data.color.present ? data.color.value : this.color,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderHighlight(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('highlightText: $highlightText, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('color: $color, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterIndex,
    highlightText,
    rangeStart,
    rangeEnd,
    color,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderHighlight &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.highlightText == this.highlightText &&
          other.rangeStart == this.rangeStart &&
          other.rangeEnd == this.rangeEnd &&
          other.color == this.color &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ReaderHighlightsCompanion extends UpdateCompanion<ReaderHighlight> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapterIndex;
  final Value<String> highlightText;
  final Value<String> rangeStart;
  final Value<String> rangeEnd;
  final Value<int> color;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const ReaderHighlightsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.highlightText = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.color = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReaderHighlightsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapterIndex,
    required String highlightText,
    required String rangeStart,
    required String rangeEnd,
    this.color = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       highlightText = Value(highlightText),
       rangeStart = Value(rangeStart),
       rangeEnd = Value(rangeEnd),
       createdAt = Value(createdAt);
  static Insertable<ReaderHighlight> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapterIndex,
    Expression<String>? highlightText,
    Expression<String>? rangeStart,
    Expression<String>? rangeEnd,
    Expression<int>? color,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (highlightText != null) 'highlight_text': highlightText,
      if (rangeStart != null) 'range_start': rangeStart,
      if (rangeEnd != null) 'range_end': rangeEnd,
      if (color != null) 'color': color,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReaderHighlightsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? chapterIndex,
    Value<String>? highlightText,
    Value<String>? rangeStart,
    Value<String>? rangeEnd,
    Value<int>? color,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return ReaderHighlightsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      highlightText: highlightText ?? this.highlightText,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (highlightText.present) {
      map['highlight_text'] = Variable<String>(highlightText.value);
    }
    if (rangeStart.present) {
      map['range_start'] = Variable<String>(rangeStart.value);
    }
    if (rangeEnd.present) {
      map['range_end'] = Variable<String>(rangeEnd.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderHighlightsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('highlightText: $highlightText, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('color: $color, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CharacterSheetsTable extends CharacterSheets
    with TableInfo<$CharacterSheetsTable, CharacterSheet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterSheetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedAtMeta = const VerificationMeta(
    'lastUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>(
        'last_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    characterId,
    name,
    level,
    className,
    lastUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_sheets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterSheet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
        _lastUpdatedAtMeta,
        lastUpdatedAt.isAcceptableOrUnknown(
          data['last_updated_at']!,
          _lastUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterSheet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterSheet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      className: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_name'],
      ),
      lastUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated_at'],
      )!,
    );
  }

  @override
  $CharacterSheetsTable createAlias(String alias) {
    return $CharacterSheetsTable(attachedDatabase, alias);
  }
}

class CharacterSheet extends DataClass implements Insertable<CharacterSheet> {
  final int id;
  final int bookId;
  final int? characterId;
  final String name;
  final int? level;
  final String? className;
  final DateTime lastUpdatedAt;
  const CharacterSheet({
    required this.id,
    required this.bookId,
    this.characterId,
    required this.name,
    this.level,
    this.className,
    required this.lastUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    if (!nullToAbsent || characterId != null) {
      map['character_id'] = Variable<int>(characterId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    if (!nullToAbsent || className != null) {
      map['class_name'] = Variable<String>(className);
    }
    map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt);
    return map;
  }

  CharacterSheetsCompanion toCompanion(bool nullToAbsent) {
    return CharacterSheetsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      characterId: characterId == null && nullToAbsent
          ? const Value.absent()
          : Value(characterId),
      name: Value(name),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      className: className == null && nullToAbsent
          ? const Value.absent()
          : Value(className),
      lastUpdatedAt: Value(lastUpdatedAt),
    );
  }

  factory CharacterSheet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterSheet(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      characterId: serializer.fromJson<int?>(json['characterId']),
      name: serializer.fromJson<String>(json['name']),
      level: serializer.fromJson<int?>(json['level']),
      className: serializer.fromJson<String?>(json['className']),
      lastUpdatedAt: serializer.fromJson<DateTime>(json['lastUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'characterId': serializer.toJson<int?>(characterId),
      'name': serializer.toJson<String>(name),
      'level': serializer.toJson<int?>(level),
      'className': serializer.toJson<String?>(className),
      'lastUpdatedAt': serializer.toJson<DateTime>(lastUpdatedAt),
    };
  }

  CharacterSheet copyWith({
    int? id,
    int? bookId,
    Value<int?> characterId = const Value.absent(),
    String? name,
    Value<int?> level = const Value.absent(),
    Value<String?> className = const Value.absent(),
    DateTime? lastUpdatedAt,
  }) => CharacterSheet(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    characterId: characterId.present ? characterId.value : this.characterId,
    name: name ?? this.name,
    level: level.present ? level.value : this.level,
    className: className.present ? className.value : this.className,
    lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
  );
  CharacterSheet copyWithCompanion(CharacterSheetsCompanion data) {
    return CharacterSheet(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      name: data.name.present ? data.name.value : this.name,
      level: data.level.present ? data.level.value : this.level,
      className: data.className.present ? data.className.value : this.className,
      lastUpdatedAt: data.lastUpdatedAt.present
          ? data.lastUpdatedAt.value
          : this.lastUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSheet(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('className: $className, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    characterId,
    name,
    level,
    className,
    lastUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterSheet &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.characterId == this.characterId &&
          other.name == this.name &&
          other.level == this.level &&
          other.className == this.className &&
          other.lastUpdatedAt == this.lastUpdatedAt);
}

class CharacterSheetsCompanion extends UpdateCompanion<CharacterSheet> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int?> characterId;
  final Value<String> name;
  final Value<int?> level;
  final Value<String?> className;
  final Value<DateTime> lastUpdatedAt;
  const CharacterSheetsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.name = const Value.absent(),
    this.level = const Value.absent(),
    this.className = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
  });
  CharacterSheetsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    this.characterId = const Value.absent(),
    required String name,
    this.level = const Value.absent(),
    this.className = const Value.absent(),
    required DateTime lastUpdatedAt,
  }) : bookId = Value(bookId),
       name = Value(name),
       lastUpdatedAt = Value(lastUpdatedAt);
  static Insertable<CharacterSheet> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? characterId,
    Expression<String>? name,
    Expression<int>? level,
    Expression<String>? className,
    Expression<DateTime>? lastUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (characterId != null) 'character_id': characterId,
      if (name != null) 'name': name,
      if (level != null) 'level': level,
      if (className != null) 'class_name': className,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
    });
  }

  CharacterSheetsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int?>? characterId,
    Value<String>? name,
    Value<int?>? level,
    Value<String?>? className,
    Value<DateTime>? lastUpdatedAt,
  }) {
    return CharacterSheetsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      level: level ?? this.level,
      className: className ?? this.className,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSheetsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('className: $className, ')
          ..write('lastUpdatedAt: $lastUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $CharacterSheetEntriesTable extends CharacterSheetEntries
    with TableInfo<$CharacterSheetEntriesTable, CharacterSheetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterSheetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES character_sheets (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _entryKeyMeta = const VerificationMeta(
    'entryKey',
  );
  @override
  late final GeneratedColumn<String> entryKey = GeneratedColumn<String>(
    'entry_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryValueMeta = const VerificationMeta(
    'entryValue',
  );
  @override
  late final GeneratedColumn<String> entryValue = GeneratedColumn<String>(
    'entry_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sheetId,
    category,
    entryKey,
    entryValue,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_sheet_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterSheetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('entry_key')) {
      context.handle(
        _entryKeyMeta,
        entryKey.isAcceptableOrUnknown(data['entry_key']!, _entryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entryKeyMeta);
    }
    if (data.containsKey('entry_value')) {
      context.handle(
        _entryValueMeta,
        entryValue.isAcceptableOrUnknown(data['entry_value']!, _entryValueMeta),
      );
    } else if (isInserting) {
      context.missing(_entryValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterSheetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterSheetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category'],
      )!,
      entryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_key'],
      )!,
      entryValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CharacterSheetEntriesTable createAlias(String alias) {
    return $CharacterSheetEntriesTable(attachedDatabase, alias);
  }
}

class CharacterSheetEntry extends DataClass
    implements Insertable<CharacterSheetEntry> {
  final int id;
  final int sheetId;
  final int category;
  final String entryKey;
  final String entryValue;
  final int sortOrder;
  const CharacterSheetEntry({
    required this.id,
    required this.sheetId,
    required this.category,
    required this.entryKey,
    required this.entryValue,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sheet_id'] = Variable<int>(sheetId);
    map['category'] = Variable<int>(category);
    map['entry_key'] = Variable<String>(entryKey);
    map['entry_value'] = Variable<String>(entryValue);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CharacterSheetEntriesCompanion toCompanion(bool nullToAbsent) {
    return CharacterSheetEntriesCompanion(
      id: Value(id),
      sheetId: Value(sheetId),
      category: Value(category),
      entryKey: Value(entryKey),
      entryValue: Value(entryValue),
      sortOrder: Value(sortOrder),
    );
  }

  factory CharacterSheetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterSheetEntry(
      id: serializer.fromJson<int>(json['id']),
      sheetId: serializer.fromJson<int>(json['sheetId']),
      category: serializer.fromJson<int>(json['category']),
      entryKey: serializer.fromJson<String>(json['entryKey']),
      entryValue: serializer.fromJson<String>(json['entryValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sheetId': serializer.toJson<int>(sheetId),
      'category': serializer.toJson<int>(category),
      'entryKey': serializer.toJson<String>(entryKey),
      'entryValue': serializer.toJson<String>(entryValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CharacterSheetEntry copyWith({
    int? id,
    int? sheetId,
    int? category,
    String? entryKey,
    String? entryValue,
    int? sortOrder,
  }) => CharacterSheetEntry(
    id: id ?? this.id,
    sheetId: sheetId ?? this.sheetId,
    category: category ?? this.category,
    entryKey: entryKey ?? this.entryKey,
    entryValue: entryValue ?? this.entryValue,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CharacterSheetEntry copyWithCompanion(CharacterSheetEntriesCompanion data) {
    return CharacterSheetEntry(
      id: data.id.present ? data.id.value : this.id,
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      category: data.category.present ? data.category.value : this.category,
      entryKey: data.entryKey.present ? data.entryKey.value : this.entryKey,
      entryValue: data.entryValue.present
          ? data.entryValue.value
          : this.entryValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSheetEntry(')
          ..write('id: $id, ')
          ..write('sheetId: $sheetId, ')
          ..write('category: $category, ')
          ..write('entryKey: $entryKey, ')
          ..write('entryValue: $entryValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sheetId, category, entryKey, entryValue, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterSheetEntry &&
          other.id == this.id &&
          other.sheetId == this.sheetId &&
          other.category == this.category &&
          other.entryKey == this.entryKey &&
          other.entryValue == this.entryValue &&
          other.sortOrder == this.sortOrder);
}

class CharacterSheetEntriesCompanion
    extends UpdateCompanion<CharacterSheetEntry> {
  final Value<int> id;
  final Value<int> sheetId;
  final Value<int> category;
  final Value<String> entryKey;
  final Value<String> entryValue;
  final Value<int> sortOrder;
  const CharacterSheetEntriesCompanion({
    this.id = const Value.absent(),
    this.sheetId = const Value.absent(),
    this.category = const Value.absent(),
    this.entryKey = const Value.absent(),
    this.entryValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CharacterSheetEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sheetId,
    this.category = const Value.absent(),
    required String entryKey,
    required String entryValue,
    this.sortOrder = const Value.absent(),
  }) : sheetId = Value(sheetId),
       entryKey = Value(entryKey),
       entryValue = Value(entryValue);
  static Insertable<CharacterSheetEntry> custom({
    Expression<int>? id,
    Expression<int>? sheetId,
    Expression<int>? category,
    Expression<String>? entryKey,
    Expression<String>? entryValue,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sheetId != null) 'sheet_id': sheetId,
      if (category != null) 'category': category,
      if (entryKey != null) 'entry_key': entryKey,
      if (entryValue != null) 'entry_value': entryValue,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CharacterSheetEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sheetId,
    Value<int>? category,
    Value<String>? entryKey,
    Value<String>? entryValue,
    Value<int>? sortOrder,
  }) {
    return CharacterSheetEntriesCompanion(
      id: id ?? this.id,
      sheetId: sheetId ?? this.sheetId,
      category: category ?? this.category,
      entryKey: entryKey ?? this.entryKey,
      entryValue: entryValue ?? this.entryValue,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (entryKey.present) {
      map['entry_key'] = Variable<String>(entryKey.value);
    }
    if (entryValue.present) {
      map['entry_value'] = Variable<String>(entryValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterSheetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sheetId: $sheetId, ')
          ..write('category: $category, ')
          ..write('entryKey: $entryKey, ')
          ..write('entryValue: $entryValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $WorldAreasTable worldAreas = $WorldAreasTable(this);
  late final $BookImagesTable bookImages = $BookImagesTable(this);
  late final $MindmapNodesTable mindmapNodes = $MindmapNodesTable(this);
  late final $MindmapEdgesTable mindmapEdges = $MindmapEdgesTable(this);
  late final $EpubFilesTable epubFiles = $EpubFilesTable(this);
  late final $ReaderBookmarksTable readerBookmarks = $ReaderBookmarksTable(
    this,
  );
  late final $ReaderHighlightsTable readerHighlights = $ReaderHighlightsTable(
    this,
  );
  late final $CharacterSheetsTable characterSheets = $CharacterSheetsTable(
    this,
  );
  late final $CharacterSheetEntriesTable characterSheetEntries =
      $CharacterSheetEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    characters,
    notes,
    worldAreas,
    bookImages,
    mindmapNodes,
    mindmapEdges,
    epubFiles,
    readerBookmarks,
    readerHighlights,
    characterSheets,
    characterSheetEntries,
  ];
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String title,
      required String author,
      Value<String?> coverImagePath,
      Value<String?> genre,
      Value<int> totalPages,
      Value<int> currentPage,
      Value<int> status,
      Value<double?> rating,
      Value<int> sourceApp,
      required DateTime dateAdded,
      Value<DateTime?> dateFinished,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> author,
      Value<String?> coverImagePath,
      Value<String?> genre,
      Value<int> totalPages,
      Value<int> currentPage,
      Value<int> status,
      Value<double?> rating,
      Value<int> sourceApp,
      Value<DateTime> dateAdded,
      Value<DateTime?> dateFinished,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CharactersTable, List<Character>>
  _charactersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characters,
    aliasName: $_aliasNameGenerator(db.books.id, db.characters.bookId),
  );

  $$CharactersTableProcessedTableManager get charactersRefs {
    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_charactersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.books.id, db.notes.bookId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorldAreasTable, List<WorldArea>>
  _worldAreasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.worldAreas,
    aliasName: $_aliasNameGenerator(db.books.id, db.worldAreas.bookId),
  );

  $$WorldAreasTableProcessedTableManager get worldAreasRefs {
    final manager = $$WorldAreasTableTableManager(
      $_db,
      $_db.worldAreas,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_worldAreasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookImagesTable, List<BookImage>>
  _bookImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookImages,
    aliasName: $_aliasNameGenerator(db.books.id, db.bookImages.bookId),
  );

  $$BookImagesTableProcessedTableManager get bookImagesRefs {
    final manager = $$BookImagesTableTableManager(
      $_db,
      $_db.bookImages,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MindmapNodesTable, List<MindmapNode>>
  _mindmapNodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mindmapNodes,
    aliasName: $_aliasNameGenerator(db.books.id, db.mindmapNodes.bookId),
  );

  $$MindmapNodesTableProcessedTableManager get mindmapNodesRefs {
    final manager = $$MindmapNodesTableTableManager(
      $_db,
      $_db.mindmapNodes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mindmapNodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MindmapEdgesTable, List<MindmapEdge>>
  _mindmapEdgesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mindmapEdges,
    aliasName: $_aliasNameGenerator(db.books.id, db.mindmapEdges.bookId),
  );

  $$MindmapEdgesTableProcessedTableManager get mindmapEdgesRefs {
    final manager = $$MindmapEdgesTableTableManager(
      $_db,
      $_db.mindmapEdges,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mindmapEdgesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EpubFilesTable, List<EpubFile>>
  _epubFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.epubFiles,
    aliasName: $_aliasNameGenerator(db.books.id, db.epubFiles.bookId),
  );

  $$EpubFilesTableProcessedTableManager get epubFilesRefs {
    final manager = $$EpubFilesTableTableManager(
      $_db,
      $_db.epubFiles,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_epubFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReaderBookmarksTable, List<ReaderBookmark>>
  _readerBookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readerBookmarks,
    aliasName: $_aliasNameGenerator(db.books.id, db.readerBookmarks.bookId),
  );

  $$ReaderBookmarksTableProcessedTableManager get readerBookmarksRefs {
    final manager = $$ReaderBookmarksTableTableManager(
      $_db,
      $_db.readerBookmarks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readerBookmarksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReaderHighlightsTable, List<ReaderHighlight>>
  _readerHighlightsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readerHighlights,
    aliasName: $_aliasNameGenerator(db.books.id, db.readerHighlights.bookId),
  );

  $$ReaderHighlightsTableProcessedTableManager get readerHighlightsRefs {
    final manager = $$ReaderHighlightsTableTableManager(
      $_db,
      $_db.readerHighlights,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readerHighlightsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CharacterSheetsTable, List<CharacterSheet>>
  _characterSheetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterSheets,
    aliasName: $_aliasNameGenerator(db.books.id, db.characterSheets.bookId),
  );

  $$CharacterSheetsTableProcessedTableManager get characterSheetsRefs {
    final manager = $$CharacterSheetsTableTableManager(
      $_db,
      $_db.characterSheets,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterSheetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFinished => $composableBuilder(
    column: $table.dateFinished,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> charactersRefs(
    Expression<bool> Function($$CharactersTableFilterComposer f) f,
  ) {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> worldAreasRefs(
    Expression<bool> Function($$WorldAreasTableFilterComposer f) f,
  ) {
    final $$WorldAreasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.worldAreas,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorldAreasTableFilterComposer(
            $db: $db,
            $table: $db.worldAreas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookImagesRefs(
    Expression<bool> Function($$BookImagesTableFilterComposer f) f,
  ) {
    final $$BookImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookImages,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookImagesTableFilterComposer(
            $db: $db,
            $table: $db.bookImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mindmapNodesRefs(
    Expression<bool> Function($$MindmapNodesTableFilterComposer f) f,
  ) {
    final $$MindmapNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableFilterComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mindmapEdgesRefs(
    Expression<bool> Function($$MindmapEdgesTableFilterComposer f) f,
  ) {
    final $$MindmapEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapEdges,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapEdgesTableFilterComposer(
            $db: $db,
            $table: $db.mindmapEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> epubFilesRefs(
    Expression<bool> Function($$EpubFilesTableFilterComposer f) f,
  ) {
    final $$EpubFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epubFiles,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpubFilesTableFilterComposer(
            $db: $db,
            $table: $db.epubFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readerBookmarksRefs(
    Expression<bool> Function($$ReaderBookmarksTableFilterComposer f) f,
  ) {
    final $$ReaderBookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerBookmarks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderBookmarksTableFilterComposer(
            $db: $db,
            $table: $db.readerBookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readerHighlightsRefs(
    Expression<bool> Function($$ReaderHighlightsTableFilterComposer f) f,
  ) {
    final $$ReaderHighlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerHighlights,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderHighlightsTableFilterComposer(
            $db: $db,
            $table: $db.readerHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characterSheetsRefs(
    Expression<bool> Function($$CharacterSheetsTableFilterComposer f) f,
  ) {
    final $$CharacterSheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableFilterComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFinished => $composableBuilder(
    column: $table.dateFinished,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get sourceApp =>
      $composableBuilder(column: $table.sourceApp, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get dateFinished => $composableBuilder(
    column: $table.dateFinished,
    builder: (column) => column,
  );

  Expression<T> charactersRefs<T extends Object>(
    Expression<T> Function($$CharactersTableAnnotationComposer a) f,
  ) {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> worldAreasRefs<T extends Object>(
    Expression<T> Function($$WorldAreasTableAnnotationComposer a) f,
  ) {
    final $$WorldAreasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.worldAreas,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorldAreasTableAnnotationComposer(
            $db: $db,
            $table: $db.worldAreas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookImagesRefs<T extends Object>(
    Expression<T> Function($$BookImagesTableAnnotationComposer a) f,
  ) {
    final $$BookImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookImages,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.bookImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mindmapNodesRefs<T extends Object>(
    Expression<T> Function($$MindmapNodesTableAnnotationComposer a) f,
  ) {
    final $$MindmapNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mindmapEdgesRefs<T extends Object>(
    Expression<T> Function($$MindmapEdgesTableAnnotationComposer a) f,
  ) {
    final $$MindmapEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapEdges,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.mindmapEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> epubFilesRefs<T extends Object>(
    Expression<T> Function($$EpubFilesTableAnnotationComposer a) f,
  ) {
    final $$EpubFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epubFiles,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpubFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.epubFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readerBookmarksRefs<T extends Object>(
    Expression<T> Function($$ReaderBookmarksTableAnnotationComposer a) f,
  ) {
    final $$ReaderBookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerBookmarks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderBookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.readerBookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readerHighlightsRefs<T extends Object>(
    Expression<T> Function($$ReaderHighlightsTableAnnotationComposer a) f,
  ) {
    final $$ReaderHighlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerHighlights,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderHighlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.readerHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> characterSheetsRefs<T extends Object>(
    Expression<T> Function($$CharacterSheetsTableAnnotationComposer a) f,
  ) {
    final $$CharacterSheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool charactersRefs,
            bool notesRefs,
            bool worldAreasRefs,
            bool bookImagesRefs,
            bool mindmapNodesRefs,
            bool mindmapEdgesRefs,
            bool epubFilesRefs,
            bool readerBookmarksRefs,
            bool readerHighlightsRefs,
            bool characterSheetsRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int> sourceApp = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime?> dateFinished = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                coverImagePath: coverImagePath,
                genre: genre,
                totalPages: totalPages,
                currentPage: currentPage,
                status: status,
                rating: rating,
                sourceApp: sourceApp,
                dateAdded: dateAdded,
                dateFinished: dateFinished,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String author,
                Value<String?> coverImagePath = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int> sourceApp = const Value.absent(),
                required DateTime dateAdded,
                Value<DateTime?> dateFinished = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                coverImagePath: coverImagePath,
                genre: genre,
                totalPages: totalPages,
                currentPage: currentPage,
                status: status,
                rating: rating,
                sourceApp: sourceApp,
                dateAdded: dateAdded,
                dateFinished: dateFinished,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                charactersRefs = false,
                notesRefs = false,
                worldAreasRefs = false,
                bookImagesRefs = false,
                mindmapNodesRefs = false,
                mindmapEdgesRefs = false,
                epubFilesRefs = false,
                readerBookmarksRefs = false,
                readerHighlightsRefs = false,
                characterSheetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (charactersRefs) db.characters,
                    if (notesRefs) db.notes,
                    if (worldAreasRefs) db.worldAreas,
                    if (bookImagesRefs) db.bookImages,
                    if (mindmapNodesRefs) db.mindmapNodes,
                    if (mindmapEdgesRefs) db.mindmapEdges,
                    if (epubFilesRefs) db.epubFiles,
                    if (readerBookmarksRefs) db.readerBookmarks,
                    if (readerHighlightsRefs) db.readerHighlights,
                    if (characterSheetsRefs) db.characterSheets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (charactersRefs)
                        await $_getPrefetchedData<Book, $BooksTable, Character>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._charactersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).charactersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<Book, $BooksTable, Note>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (worldAreasRefs)
                        await $_getPrefetchedData<Book, $BooksTable, WorldArea>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._worldAreasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).worldAreasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookImagesRefs)
                        await $_getPrefetchedData<Book, $BooksTable, BookImage>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookImagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookImagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mindmapNodesRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          MindmapNode
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._mindmapNodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).mindmapNodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mindmapEdgesRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          MindmapEdge
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._mindmapEdgesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).mindmapEdgesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (epubFilesRefs)
                        await $_getPrefetchedData<Book, $BooksTable, EpubFile>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._epubFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).epubFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readerBookmarksRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReaderBookmark
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readerBookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readerBookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readerHighlightsRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReaderHighlight
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readerHighlightsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readerHighlightsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (characterSheetsRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          CharacterSheet
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._characterSheetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).characterSheetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool charactersRefs,
        bool notesRefs,
        bool worldAreasRefs,
        bool bookImagesRefs,
        bool mindmapNodesRefs,
        bool mindmapEdgesRefs,
        bool epubFilesRefs,
        bool readerBookmarksRefs,
        bool readerHighlightsRefs,
        bool characterSheetsRefs,
      })
    >;
typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      Value<int> id,
      required int bookId,
      required String name,
      Value<String?> description,
      Value<String?> imagePath,
      Value<int> role,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> name,
      Value<String?> description,
      Value<String?> imagePath,
      Value<int> role,
    });

final class $$CharactersTableReferences
    extends BaseReferences<_$AppDatabase, $CharactersTable, Character> {
  $$CharactersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.characters.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CharacterSheetsTable, List<CharacterSheet>>
  _characterSheetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterSheets,
    aliasName: $_aliasNameGenerator(
      db.characters.id,
      db.characterSheets.characterId,
    ),
  );

  $$CharacterSheetsTableProcessedTableManager get characterSheetsRefs {
    final manager = $$CharacterSheetsTableTableManager(
      $_db,
      $_db.characterSheets,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterSheetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> characterSheetsRefs(
    Expression<bool> Function($$CharacterSheetsTableFilterComposer f) f,
  ) {
    final $$CharacterSheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableFilterComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> characterSheetsRefs<T extends Object>(
    Expression<T> Function($$CharacterSheetsTableAnnotationComposer a) f,
  ) {
    final $$CharacterSheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          Character,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (Character, $$CharactersTableReferences),
          Character,
          PrefetchHooks Function({bool bookId, bool characterSheetsRefs})
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> role = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                imagePath: imagePath,
                role: role,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> role = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                imagePath: imagePath,
                role: role,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CharactersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookId = false, characterSheetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (characterSheetsRefs) db.characterSheets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable: $$CharactersTableReferences
                                        ._bookIdTable(db),
                                    referencedColumn:
                                        $$CharactersTableReferences
                                            ._bookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (characterSheetsRefs)
                        await $_getPrefetchedData<
                          Character,
                          $CharactersTable,
                          CharacterSheet
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._characterSheetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterSheetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      Character,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (Character, $$CharactersTableReferences),
      Character,
      PrefetchHooks Function({bool bookId, bool characterSheetsRefs})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required int bookId,
      required String content,
      Value<int?> pageNumber,
      Value<String?> chapter,
      Value<int> sourceApp,
      required DateTime createdAt,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> content,
      Value<int?> pageNumber,
      Value<String?> chapter,
      Value<int> sourceApp,
      Value<DateTime> createdAt,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias($_aliasNameGenerator(db.notes.bookId, db.books.id));

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get sourceApp =>
      $composableBuilder(column: $table.sourceApp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool bookId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int?> pageNumber = const Value.absent(),
                Value<String?> chapter = const Value.absent(),
                Value<int> sourceApp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                bookId: bookId,
                content: content,
                pageNumber: pageNumber,
                chapter: chapter,
                sourceApp: sourceApp,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String content,
                Value<int?> pageNumber = const Value.absent(),
                Value<String?> chapter = const Value.absent(),
                Value<int> sourceApp = const Value.absent(),
                required DateTime createdAt,
              }) => NotesCompanion.insert(
                id: id,
                bookId: bookId,
                content: content,
                pageNumber: pageNumber,
                chapter: chapter,
                sourceApp: sourceApp,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$NotesTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$WorldAreasTableCreateCompanionBuilder =
    WorldAreasCompanion Function({
      Value<int> id,
      required int bookId,
      required String name,
      Value<String?> description,
      Value<String?> imagePath,
    });
typedef $$WorldAreasTableUpdateCompanionBuilder =
    WorldAreasCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> name,
      Value<String?> description,
      Value<String?> imagePath,
    });

final class $$WorldAreasTableReferences
    extends BaseReferences<_$AppDatabase, $WorldAreasTable, WorldArea> {
  $$WorldAreasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.worldAreas.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorldAreasTableFilterComposer
    extends Composer<_$AppDatabase, $WorldAreasTable> {
  $$WorldAreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorldAreasTableOrderingComposer
    extends Composer<_$AppDatabase, $WorldAreasTable> {
  $$WorldAreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorldAreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorldAreasTable> {
  $$WorldAreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorldAreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorldAreasTable,
          WorldArea,
          $$WorldAreasTableFilterComposer,
          $$WorldAreasTableOrderingComposer,
          $$WorldAreasTableAnnotationComposer,
          $$WorldAreasTableCreateCompanionBuilder,
          $$WorldAreasTableUpdateCompanionBuilder,
          (WorldArea, $$WorldAreasTableReferences),
          WorldArea,
          PrefetchHooks Function({bool bookId})
        > {
  $$WorldAreasTableTableManager(_$AppDatabase db, $WorldAreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorldAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorldAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorldAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
              }) => WorldAreasCompanion(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                imagePath: imagePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
              }) => WorldAreasCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                description: description,
                imagePath: imagePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorldAreasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$WorldAreasTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$WorldAreasTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorldAreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorldAreasTable,
      WorldArea,
      $$WorldAreasTableFilterComposer,
      $$WorldAreasTableOrderingComposer,
      $$WorldAreasTableAnnotationComposer,
      $$WorldAreasTableCreateCompanionBuilder,
      $$WorldAreasTableUpdateCompanionBuilder,
      (WorldArea, $$WorldAreasTableReferences),
      WorldArea,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$BookImagesTableCreateCompanionBuilder =
    BookImagesCompanion Function({
      Value<int> id,
      required int bookId,
      required String path,
      Value<String?> caption,
      required DateTime createdAt,
    });
typedef $$BookImagesTableUpdateCompanionBuilder =
    BookImagesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> path,
      Value<String?> caption,
      Value<DateTime> createdAt,
    });

final class $$BookImagesTableReferences
    extends BaseReferences<_$AppDatabase, $BookImagesTable, BookImage> {
  $$BookImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.bookImages.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookImagesTableFilterComposer
    extends Composer<_$AppDatabase, $BookImagesTable> {
  $$BookImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookImagesTable> {
  $$BookImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookImagesTable> {
  $$BookImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookImagesTable,
          BookImage,
          $$BookImagesTableFilterComposer,
          $$BookImagesTableOrderingComposer,
          $$BookImagesTableAnnotationComposer,
          $$BookImagesTableCreateCompanionBuilder,
          $$BookImagesTableUpdateCompanionBuilder,
          (BookImage, $$BookImagesTableReferences),
          BookImage,
          PrefetchHooks Function({bool bookId})
        > {
  $$BookImagesTableTableManager(_$AppDatabase db, $BookImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookImagesCompanion(
                id: id,
                bookId: bookId,
                path: path,
                caption: caption,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String path,
                Value<String?> caption = const Value.absent(),
                required DateTime createdAt,
              }) => BookImagesCompanion.insert(
                id: id,
                bookId: bookId,
                path: path,
                caption: caption,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$BookImagesTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$BookImagesTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookImagesTable,
      BookImage,
      $$BookImagesTableFilterComposer,
      $$BookImagesTableOrderingComposer,
      $$BookImagesTableAnnotationComposer,
      $$BookImagesTableCreateCompanionBuilder,
      $$BookImagesTableUpdateCompanionBuilder,
      (BookImage, $$BookImagesTableReferences),
      BookImage,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$MindmapNodesTableCreateCompanionBuilder =
    MindmapNodesCompanion Function({
      Value<int> id,
      required int bookId,
      Value<int> entityType,
      Value<int?> entityId,
      required String label,
      Value<double> positionX,
      Value<double> positionY,
      Value<int> color,
    });
typedef $$MindmapNodesTableUpdateCompanionBuilder =
    MindmapNodesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> entityType,
      Value<int?> entityId,
      Value<String> label,
      Value<double> positionX,
      Value<double> positionY,
      Value<int> color,
    });

final class $$MindmapNodesTableReferences
    extends BaseReferences<_$AppDatabase, $MindmapNodesTable, MindmapNode> {
  $$MindmapNodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.mindmapNodes.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MindmapEdgesTable, List<MindmapEdge>>
  _edgesFromTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mindmapEdges,
    aliasName: $_aliasNameGenerator(
      db.mindmapNodes.id,
      db.mindmapEdges.fromNodeId,
    ),
  );

  $$MindmapEdgesTableProcessedTableManager get edgesFrom {
    final manager = $$MindmapEdgesTableTableManager(
      $_db,
      $_db.mindmapEdges,
    ).filter((f) => f.fromNodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_edgesFromTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MindmapEdgesTable, List<MindmapEdge>>
  _edgesToTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mindmapEdges,
    aliasName: $_aliasNameGenerator(
      db.mindmapNodes.id,
      db.mindmapEdges.toNodeId,
    ),
  );

  $$MindmapEdgesTableProcessedTableManager get edgesTo {
    final manager = $$MindmapEdgesTableTableManager(
      $_db,
      $_db.mindmapEdges,
    ).filter((f) => f.toNodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_edgesToTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MindmapNodesTableFilterComposer
    extends Composer<_$AppDatabase, $MindmapNodesTable> {
  $$MindmapNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> edgesFrom(
    Expression<bool> Function($$MindmapEdgesTableFilterComposer f) f,
  ) {
    final $$MindmapEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapEdges,
      getReferencedColumn: (t) => t.fromNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapEdgesTableFilterComposer(
            $db: $db,
            $table: $db.mindmapEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> edgesTo(
    Expression<bool> Function($$MindmapEdgesTableFilterComposer f) f,
  ) {
    final $$MindmapEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapEdges,
      getReferencedColumn: (t) => t.toNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapEdgesTableFilterComposer(
            $db: $db,
            $table: $db.mindmapEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MindmapNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $MindmapNodesTable> {
  $$MindmapNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MindmapNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MindmapNodesTable> {
  $$MindmapNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get positionX =>
      $composableBuilder(column: $table.positionX, builder: (column) => column);

  GeneratedColumn<double> get positionY =>
      $composableBuilder(column: $table.positionY, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> edgesFrom<T extends Object>(
    Expression<T> Function($$MindmapEdgesTableAnnotationComposer a) f,
  ) {
    final $$MindmapEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapEdges,
      getReferencedColumn: (t) => t.fromNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.mindmapEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> edgesTo<T extends Object>(
    Expression<T> Function($$MindmapEdgesTableAnnotationComposer a) f,
  ) {
    final $$MindmapEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mindmapEdges,
      getReferencedColumn: (t) => t.toNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.mindmapEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MindmapNodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MindmapNodesTable,
          MindmapNode,
          $$MindmapNodesTableFilterComposer,
          $$MindmapNodesTableOrderingComposer,
          $$MindmapNodesTableAnnotationComposer,
          $$MindmapNodesTableCreateCompanionBuilder,
          $$MindmapNodesTableUpdateCompanionBuilder,
          (MindmapNode, $$MindmapNodesTableReferences),
          MindmapNode,
          PrefetchHooks Function({bool bookId, bool edgesFrom, bool edgesTo})
        > {
  $$MindmapNodesTableTableManager(_$AppDatabase db, $MindmapNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MindmapNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MindmapNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MindmapNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> positionX = const Value.absent(),
                Value<double> positionY = const Value.absent(),
                Value<int> color = const Value.absent(),
              }) => MindmapNodesCompanion(
                id: id,
                bookId: bookId,
                entityType: entityType,
                entityId: entityId,
                label: label,
                positionX: positionX,
                positionY: positionY,
                color: color,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                Value<int> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                required String label,
                Value<double> positionX = const Value.absent(),
                Value<double> positionY = const Value.absent(),
                Value<int> color = const Value.absent(),
              }) => MindmapNodesCompanion.insert(
                id: id,
                bookId: bookId,
                entityType: entityType,
                entityId: entityId,
                label: label,
                positionX: positionX,
                positionY: positionY,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MindmapNodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookId = false, edgesFrom = false, edgesTo = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (edgesFrom) db.mindmapEdges,
                    if (edgesTo) db.mindmapEdges,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable:
                                        $$MindmapNodesTableReferences
                                            ._bookIdTable(db),
                                    referencedColumn:
                                        $$MindmapNodesTableReferences
                                            ._bookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (edgesFrom)
                        await $_getPrefetchedData<
                          MindmapNode,
                          $MindmapNodesTable,
                          MindmapEdge
                        >(
                          currentTable: table,
                          referencedTable: $$MindmapNodesTableReferences
                              ._edgesFromTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MindmapNodesTableReferences(
                                db,
                                table,
                                p0,
                              ).edgesFrom,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fromNodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (edgesTo)
                        await $_getPrefetchedData<
                          MindmapNode,
                          $MindmapNodesTable,
                          MindmapEdge
                        >(
                          currentTable: table,
                          referencedTable: $$MindmapNodesTableReferences
                              ._edgesToTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MindmapNodesTableReferences(
                                db,
                                table,
                                p0,
                              ).edgesTo,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.toNodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MindmapNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MindmapNodesTable,
      MindmapNode,
      $$MindmapNodesTableFilterComposer,
      $$MindmapNodesTableOrderingComposer,
      $$MindmapNodesTableAnnotationComposer,
      $$MindmapNodesTableCreateCompanionBuilder,
      $$MindmapNodesTableUpdateCompanionBuilder,
      (MindmapNode, $$MindmapNodesTableReferences),
      MindmapNode,
      PrefetchHooks Function({bool bookId, bool edgesFrom, bool edgesTo})
    >;
typedef $$MindmapEdgesTableCreateCompanionBuilder =
    MindmapEdgesCompanion Function({
      Value<int> id,
      required int bookId,
      required int fromNodeId,
      required int toNodeId,
      Value<String?> label,
    });
typedef $$MindmapEdgesTableUpdateCompanionBuilder =
    MindmapEdgesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> fromNodeId,
      Value<int> toNodeId,
      Value<String?> label,
    });

final class $$MindmapEdgesTableReferences
    extends BaseReferences<_$AppDatabase, $MindmapEdgesTable, MindmapEdge> {
  $$MindmapEdgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.mindmapEdges.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MindmapNodesTable _fromNodeIdTable(_$AppDatabase db) =>
      db.mindmapNodes.createAlias(
        $_aliasNameGenerator(db.mindmapEdges.fromNodeId, db.mindmapNodes.id),
      );

  $$MindmapNodesTableProcessedTableManager get fromNodeId {
    final $_column = $_itemColumn<int>('from_node_id')!;

    final manager = $$MindmapNodesTableTableManager(
      $_db,
      $_db.mindmapNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MindmapNodesTable _toNodeIdTable(_$AppDatabase db) =>
      db.mindmapNodes.createAlias(
        $_aliasNameGenerator(db.mindmapEdges.toNodeId, db.mindmapNodes.id),
      );

  $$MindmapNodesTableProcessedTableManager get toNodeId {
    final $_column = $_itemColumn<int>('to_node_id')!;

    final manager = $$MindmapNodesTableTableManager(
      $_db,
      $_db.mindmapNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MindmapEdgesTableFilterComposer
    extends Composer<_$AppDatabase, $MindmapEdgesTable> {
  $$MindmapEdgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MindmapNodesTableFilterComposer get fromNodeId {
    final $$MindmapNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableFilterComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MindmapNodesTableFilterComposer get toNodeId {
    final $$MindmapNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableFilterComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MindmapEdgesTableOrderingComposer
    extends Composer<_$AppDatabase, $MindmapEdgesTable> {
  $$MindmapEdgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MindmapNodesTableOrderingComposer get fromNodeId {
    final $$MindmapNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableOrderingComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MindmapNodesTableOrderingComposer get toNodeId {
    final $$MindmapNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableOrderingComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MindmapEdgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MindmapEdgesTable> {
  $$MindmapEdgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MindmapNodesTableAnnotationComposer get fromNodeId {
    final $$MindmapNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MindmapNodesTableAnnotationComposer get toNodeId {
    final $$MindmapNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.mindmapNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MindmapNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.mindmapNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MindmapEdgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MindmapEdgesTable,
          MindmapEdge,
          $$MindmapEdgesTableFilterComposer,
          $$MindmapEdgesTableOrderingComposer,
          $$MindmapEdgesTableAnnotationComposer,
          $$MindmapEdgesTableCreateCompanionBuilder,
          $$MindmapEdgesTableUpdateCompanionBuilder,
          (MindmapEdge, $$MindmapEdgesTableReferences),
          MindmapEdge,
          PrefetchHooks Function({bool bookId, bool fromNodeId, bool toNodeId})
        > {
  $$MindmapEdgesTableTableManager(_$AppDatabase db, $MindmapEdgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MindmapEdgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MindmapEdgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MindmapEdgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> fromNodeId = const Value.absent(),
                Value<int> toNodeId = const Value.absent(),
                Value<String?> label = const Value.absent(),
              }) => MindmapEdgesCompanion(
                id: id,
                bookId: bookId,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                label: label,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int fromNodeId,
                required int toNodeId,
                Value<String?> label = const Value.absent(),
              }) => MindmapEdgesCompanion.insert(
                id: id,
                bookId: bookId,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                label: label,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MindmapEdgesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookId = false, fromNodeId = false, toNodeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable:
                                        $$MindmapEdgesTableReferences
                                            ._bookIdTable(db),
                                    referencedColumn:
                                        $$MindmapEdgesTableReferences
                                            ._bookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (fromNodeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fromNodeId,
                                    referencedTable:
                                        $$MindmapEdgesTableReferences
                                            ._fromNodeIdTable(db),
                                    referencedColumn:
                                        $$MindmapEdgesTableReferences
                                            ._fromNodeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (toNodeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toNodeId,
                                    referencedTable:
                                        $$MindmapEdgesTableReferences
                                            ._toNodeIdTable(db),
                                    referencedColumn:
                                        $$MindmapEdgesTableReferences
                                            ._toNodeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MindmapEdgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MindmapEdgesTable,
      MindmapEdge,
      $$MindmapEdgesTableFilterComposer,
      $$MindmapEdgesTableOrderingComposer,
      $$MindmapEdgesTableAnnotationComposer,
      $$MindmapEdgesTableCreateCompanionBuilder,
      $$MindmapEdgesTableUpdateCompanionBuilder,
      (MindmapEdge, $$MindmapEdgesTableReferences),
      MindmapEdge,
      PrefetchHooks Function({bool bookId, bool fromNodeId, bool toNodeId})
    >;
typedef $$EpubFilesTableCreateCompanionBuilder =
    EpubFilesCompanion Function({
      Value<int> id,
      required int bookId,
      required String filePath,
      Value<int> currentChapterIndex,
      Value<double> scrollPosition,
      Value<DateTime?> lastReadAt,
      Value<int> fontSize,
      Value<String> fontFamily,
      Value<int> readerTheme,
      Value<double> lineHeight,
    });
typedef $$EpubFilesTableUpdateCompanionBuilder =
    EpubFilesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> filePath,
      Value<int> currentChapterIndex,
      Value<double> scrollPosition,
      Value<DateTime?> lastReadAt,
      Value<int> fontSize,
      Value<String> fontFamily,
      Value<int> readerTheme,
      Value<double> lineHeight,
    });

final class $$EpubFilesTableReferences
    extends BaseReferences<_$AppDatabase, $EpubFilesTable, EpubFile> {
  $$EpubFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.epubFiles.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpubFilesTableFilterComposer
    extends Composer<_$AppDatabase, $EpubFilesTable> {
  $$EpubFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentChapterIndex => $composableBuilder(
    column: $table.currentChapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrollPosition => $composableBuilder(
    column: $table.scrollPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readerTheme => $composableBuilder(
    column: $table.readerTheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpubFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpubFilesTable> {
  $$EpubFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentChapterIndex => $composableBuilder(
    column: $table.currentChapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrollPosition => $composableBuilder(
    column: $table.scrollPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readerTheme => $composableBuilder(
    column: $table.readerTheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpubFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpubFilesTable> {
  $$EpubFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get currentChapterIndex => $composableBuilder(
    column: $table.currentChapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scrollPosition => $composableBuilder(
    column: $table.scrollPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readerTheme => $composableBuilder(
    column: $table.readerTheme,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpubFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpubFilesTable,
          EpubFile,
          $$EpubFilesTableFilterComposer,
          $$EpubFilesTableOrderingComposer,
          $$EpubFilesTableAnnotationComposer,
          $$EpubFilesTableCreateCompanionBuilder,
          $$EpubFilesTableUpdateCompanionBuilder,
          (EpubFile, $$EpubFilesTableReferences),
          EpubFile,
          PrefetchHooks Function({bool bookId})
        > {
  $$EpubFilesTableTableManager(_$AppDatabase db, $EpubFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpubFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpubFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpubFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> currentChapterIndex = const Value.absent(),
                Value<double> scrollPosition = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<int> fontSize = const Value.absent(),
                Value<String> fontFamily = const Value.absent(),
                Value<int> readerTheme = const Value.absent(),
                Value<double> lineHeight = const Value.absent(),
              }) => EpubFilesCompanion(
                id: id,
                bookId: bookId,
                filePath: filePath,
                currentChapterIndex: currentChapterIndex,
                scrollPosition: scrollPosition,
                lastReadAt: lastReadAt,
                fontSize: fontSize,
                fontFamily: fontFamily,
                readerTheme: readerTheme,
                lineHeight: lineHeight,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String filePath,
                Value<int> currentChapterIndex = const Value.absent(),
                Value<double> scrollPosition = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<int> fontSize = const Value.absent(),
                Value<String> fontFamily = const Value.absent(),
                Value<int> readerTheme = const Value.absent(),
                Value<double> lineHeight = const Value.absent(),
              }) => EpubFilesCompanion.insert(
                id: id,
                bookId: bookId,
                filePath: filePath,
                currentChapterIndex: currentChapterIndex,
                scrollPosition: scrollPosition,
                lastReadAt: lastReadAt,
                fontSize: fontSize,
                fontFamily: fontFamily,
                readerTheme: readerTheme,
                lineHeight: lineHeight,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EpubFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$EpubFilesTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$EpubFilesTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpubFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpubFilesTable,
      EpubFile,
      $$EpubFilesTableFilterComposer,
      $$EpubFilesTableOrderingComposer,
      $$EpubFilesTableAnnotationComposer,
      $$EpubFilesTableCreateCompanionBuilder,
      $$EpubFilesTableUpdateCompanionBuilder,
      (EpubFile, $$EpubFilesTableReferences),
      EpubFile,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReaderBookmarksTableCreateCompanionBuilder =
    ReaderBookmarksCompanion Function({
      Value<int> id,
      required int bookId,
      required int chapterIndex,
      Value<double> scrollPosition,
      Value<String?> label,
      Value<String?> chapterTitle,
      required DateTime createdAt,
    });
typedef $$ReaderBookmarksTableUpdateCompanionBuilder =
    ReaderBookmarksCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> chapterIndex,
      Value<double> scrollPosition,
      Value<String?> label,
      Value<String?> chapterTitle,
      Value<DateTime> createdAt,
    });

final class $$ReaderBookmarksTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReaderBookmarksTable, ReaderBookmark> {
  $$ReaderBookmarksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.readerBookmarks.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReaderBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderBookmarksTable> {
  $$ReaderBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrollPosition => $composableBuilder(
    column: $table.scrollPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderBookmarksTable> {
  $$ReaderBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrollPosition => $composableBuilder(
    column: $table.scrollPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderBookmarksTable> {
  $$ReaderBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scrollPosition => $composableBuilder(
    column: $table.scrollPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderBookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderBookmarksTable,
          ReaderBookmark,
          $$ReaderBookmarksTableFilterComposer,
          $$ReaderBookmarksTableOrderingComposer,
          $$ReaderBookmarksTableAnnotationComposer,
          $$ReaderBookmarksTableCreateCompanionBuilder,
          $$ReaderBookmarksTableUpdateCompanionBuilder,
          (ReaderBookmark, $$ReaderBookmarksTableReferences),
          ReaderBookmark,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReaderBookmarksTableTableManager(
    _$AppDatabase db,
    $ReaderBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<double> scrollPosition = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> chapterTitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReaderBookmarksCompanion(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                scrollPosition: scrollPosition,
                label: label,
                chapterTitle: chapterTitle,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int chapterIndex,
                Value<double> scrollPosition = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> chapterTitle = const Value.absent(),
                required DateTime createdAt,
              }) => ReaderBookmarksCompanion.insert(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                scrollPosition: scrollPosition,
                label: label,
                chapterTitle: chapterTitle,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReaderBookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable:
                                    $$ReaderBookmarksTableReferences
                                        ._bookIdTable(db),
                                referencedColumn:
                                    $$ReaderBookmarksTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReaderBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderBookmarksTable,
      ReaderBookmark,
      $$ReaderBookmarksTableFilterComposer,
      $$ReaderBookmarksTableOrderingComposer,
      $$ReaderBookmarksTableAnnotationComposer,
      $$ReaderBookmarksTableCreateCompanionBuilder,
      $$ReaderBookmarksTableUpdateCompanionBuilder,
      (ReaderBookmark, $$ReaderBookmarksTableReferences),
      ReaderBookmark,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReaderHighlightsTableCreateCompanionBuilder =
    ReaderHighlightsCompanion Function({
      Value<int> id,
      required int bookId,
      required int chapterIndex,
      required String highlightText,
      required String rangeStart,
      required String rangeEnd,
      Value<int> color,
      Value<String?> note,
      required DateTime createdAt,
    });
typedef $$ReaderHighlightsTableUpdateCompanionBuilder =
    ReaderHighlightsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> chapterIndex,
      Value<String> highlightText,
      Value<String> rangeStart,
      Value<String> rangeEnd,
      Value<int> color,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$ReaderHighlightsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReaderHighlightsTable, ReaderHighlight> {
  $$ReaderHighlightsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.readerHighlights.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReaderHighlightsTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderHighlightsTable> {
  $$ReaderHighlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get highlightText => $composableBuilder(
    column: $table.highlightText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rangeEnd => $composableBuilder(
    column: $table.rangeEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderHighlightsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderHighlightsTable> {
  $$ReaderHighlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get highlightText => $composableBuilder(
    column: $table.highlightText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rangeEnd => $composableBuilder(
    column: $table.rangeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderHighlightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderHighlightsTable> {
  $$ReaderHighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get highlightText => $composableBuilder(
    column: $table.highlightText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rangeEnd =>
      $composableBuilder(column: $table.rangeEnd, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderHighlightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderHighlightsTable,
          ReaderHighlight,
          $$ReaderHighlightsTableFilterComposer,
          $$ReaderHighlightsTableOrderingComposer,
          $$ReaderHighlightsTableAnnotationComposer,
          $$ReaderHighlightsTableCreateCompanionBuilder,
          $$ReaderHighlightsTableUpdateCompanionBuilder,
          (ReaderHighlight, $$ReaderHighlightsTableReferences),
          ReaderHighlight,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReaderHighlightsTableTableManager(
    _$AppDatabase db,
    $ReaderHighlightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderHighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderHighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderHighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> highlightText = const Value.absent(),
                Value<String> rangeStart = const Value.absent(),
                Value<String> rangeEnd = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReaderHighlightsCompanion(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                highlightText: highlightText,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                color: color,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int chapterIndex,
                required String highlightText,
                required String rangeStart,
                required String rangeEnd,
                Value<int> color = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => ReaderHighlightsCompanion.insert(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                highlightText: highlightText,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                color: color,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReaderHighlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable:
                                    $$ReaderHighlightsTableReferences
                                        ._bookIdTable(db),
                                referencedColumn:
                                    $$ReaderHighlightsTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReaderHighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderHighlightsTable,
      ReaderHighlight,
      $$ReaderHighlightsTableFilterComposer,
      $$ReaderHighlightsTableOrderingComposer,
      $$ReaderHighlightsTableAnnotationComposer,
      $$ReaderHighlightsTableCreateCompanionBuilder,
      $$ReaderHighlightsTableUpdateCompanionBuilder,
      (ReaderHighlight, $$ReaderHighlightsTableReferences),
      ReaderHighlight,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$CharacterSheetsTableCreateCompanionBuilder =
    CharacterSheetsCompanion Function({
      Value<int> id,
      required int bookId,
      Value<int?> characterId,
      required String name,
      Value<int?> level,
      Value<String?> className,
      required DateTime lastUpdatedAt,
    });
typedef $$CharacterSheetsTableUpdateCompanionBuilder =
    CharacterSheetsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int?> characterId,
      Value<String> name,
      Value<int?> level,
      Value<String?> className,
      Value<DateTime> lastUpdatedAt,
    });

final class $$CharacterSheetsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CharacterSheetsTable, CharacterSheet> {
  $$CharacterSheetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.characterSheets.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias(
        $_aliasNameGenerator(db.characterSheets.characterId, db.characters.id),
      );

  $$CharactersTableProcessedTableManager? get characterId {
    final $_column = $_itemColumn<int>('character_id');
    if ($_column == null) return null;
    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CharacterSheetEntriesTable,
    List<CharacterSheetEntry>
  >
  _entriesSheetTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterSheetEntries,
    aliasName: $_aliasNameGenerator(
      db.characterSheets.id,
      db.characterSheetEntries.sheetId,
    ),
  );

  $$CharacterSheetEntriesTableProcessedTableManager get entriesSheet {
    final manager = $$CharacterSheetEntriesTableTableManager(
      $_db,
      $_db.characterSheetEntries,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesSheetTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharacterSheetsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterSheetsTable> {
  $$CharacterSheetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entriesSheet(
    Expression<bool> Function($$CharacterSheetEntriesTableFilterComposer f) f,
  ) {
    final $$CharacterSheetEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characterSheetEntries,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterSheetEntriesTableFilterComposer(
                $db: $db,
                $table: $db.characterSheetEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CharacterSheetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterSheetsTable> {
  $$CharacterSheetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSheetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterSheetsTable> {
  $$CharacterSheetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
    column: $table.lastUpdatedAt,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entriesSheet<T extends Object>(
    Expression<T> Function($$CharacterSheetEntriesTableAnnotationComposer a) f,
  ) {
    final $$CharacterSheetEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characterSheetEntries,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacterSheetEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.characterSheetEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CharacterSheetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterSheetsTable,
          CharacterSheet,
          $$CharacterSheetsTableFilterComposer,
          $$CharacterSheetsTableOrderingComposer,
          $$CharacterSheetsTableAnnotationComposer,
          $$CharacterSheetsTableCreateCompanionBuilder,
          $$CharacterSheetsTableUpdateCompanionBuilder,
          (CharacterSheet, $$CharacterSheetsTableReferences),
          CharacterSheet,
          PrefetchHooks Function({
            bool bookId,
            bool characterId,
            bool entriesSheet,
          })
        > {
  $$CharacterSheetsTableTableManager(
    _$AppDatabase db,
    $CharacterSheetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterSheetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterSheetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterSheetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int?> characterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<String?> className = const Value.absent(),
                Value<DateTime> lastUpdatedAt = const Value.absent(),
              }) => CharacterSheetsCompanion(
                id: id,
                bookId: bookId,
                characterId: characterId,
                name: name,
                level: level,
                className: className,
                lastUpdatedAt: lastUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                Value<int?> characterId = const Value.absent(),
                required String name,
                Value<int?> level = const Value.absent(),
                Value<String?> className = const Value.absent(),
                required DateTime lastUpdatedAt,
              }) => CharacterSheetsCompanion.insert(
                id: id,
                bookId: bookId,
                characterId: characterId,
                name: name,
                level: level,
                className: className,
                lastUpdatedAt: lastUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CharacterSheetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookId = false, characterId = false, entriesSheet = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entriesSheet) db.characterSheetEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable:
                                        $$CharacterSheetsTableReferences
                                            ._bookIdTable(db),
                                    referencedColumn:
                                        $$CharacterSheetsTableReferences
                                            ._bookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (characterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.characterId,
                                    referencedTable:
                                        $$CharacterSheetsTableReferences
                                            ._characterIdTable(db),
                                    referencedColumn:
                                        $$CharacterSheetsTableReferences
                                            ._characterIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entriesSheet)
                        await $_getPrefetchedData<
                          CharacterSheet,
                          $CharacterSheetsTable,
                          CharacterSheetEntry
                        >(
                          currentTable: table,
                          referencedTable: $$CharacterSheetsTableReferences
                              ._entriesSheetTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharacterSheetsTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesSheet,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharacterSheetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterSheetsTable,
      CharacterSheet,
      $$CharacterSheetsTableFilterComposer,
      $$CharacterSheetsTableOrderingComposer,
      $$CharacterSheetsTableAnnotationComposer,
      $$CharacterSheetsTableCreateCompanionBuilder,
      $$CharacterSheetsTableUpdateCompanionBuilder,
      (CharacterSheet, $$CharacterSheetsTableReferences),
      CharacterSheet,
      PrefetchHooks Function({bool bookId, bool characterId, bool entriesSheet})
    >;
typedef $$CharacterSheetEntriesTableCreateCompanionBuilder =
    CharacterSheetEntriesCompanion Function({
      Value<int> id,
      required int sheetId,
      Value<int> category,
      required String entryKey,
      required String entryValue,
      Value<int> sortOrder,
    });
typedef $$CharacterSheetEntriesTableUpdateCompanionBuilder =
    CharacterSheetEntriesCompanion Function({
      Value<int> id,
      Value<int> sheetId,
      Value<int> category,
      Value<String> entryKey,
      Value<String> entryValue,
      Value<int> sortOrder,
    });

final class $$CharacterSheetEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CharacterSheetEntriesTable,
          CharacterSheetEntry
        > {
  $$CharacterSheetEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharacterSheetsTable _sheetIdTable(_$AppDatabase db) =>
      db.characterSheets.createAlias(
        $_aliasNameGenerator(
          db.characterSheetEntries.sheetId,
          db.characterSheets.id,
        ),
      );

  $$CharacterSheetsTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$CharacterSheetsTableTableManager(
      $_db,
      $_db.characterSheets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterSheetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterSheetEntriesTable> {
  $$CharacterSheetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryValue => $composableBuilder(
    column: $table.entryValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$CharacterSheetsTableFilterComposer get sheetId {
    final $$CharacterSheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableFilterComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSheetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterSheetEntriesTable> {
  $$CharacterSheetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryValue => $composableBuilder(
    column: $table.entryValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharacterSheetsTableOrderingComposer get sheetId {
    final $$CharacterSheetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableOrderingComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSheetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterSheetEntriesTable> {
  $$CharacterSheetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get entryKey =>
      $composableBuilder(column: $table.entryKey, builder: (column) => column);

  GeneratedColumn<String> get entryValue => $composableBuilder(
    column: $table.entryValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$CharacterSheetsTableAnnotationComposer get sheetId {
    final $$CharacterSheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.characterSheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterSheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.characterSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterSheetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterSheetEntriesTable,
          CharacterSheetEntry,
          $$CharacterSheetEntriesTableFilterComposer,
          $$CharacterSheetEntriesTableOrderingComposer,
          $$CharacterSheetEntriesTableAnnotationComposer,
          $$CharacterSheetEntriesTableCreateCompanionBuilder,
          $$CharacterSheetEntriesTableUpdateCompanionBuilder,
          (CharacterSheetEntry, $$CharacterSheetEntriesTableReferences),
          CharacterSheetEntry,
          PrefetchHooks Function({bool sheetId})
        > {
  $$CharacterSheetEntriesTableTableManager(
    _$AppDatabase db,
    $CharacterSheetEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterSheetEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CharacterSheetEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CharacterSheetEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sheetId = const Value.absent(),
                Value<int> category = const Value.absent(),
                Value<String> entryKey = const Value.absent(),
                Value<String> entryValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CharacterSheetEntriesCompanion(
                id: id,
                sheetId: sheetId,
                category: category,
                entryKey: entryKey,
                entryValue: entryValue,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sheetId,
                Value<int> category = const Value.absent(),
                required String entryKey,
                required String entryValue,
                Value<int> sortOrder = const Value.absent(),
              }) => CharacterSheetEntriesCompanion.insert(
                id: id,
                sheetId: sheetId,
                category: category,
                entryKey: entryKey,
                entryValue: entryValue,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CharacterSheetEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$CharacterSheetEntriesTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$CharacterSheetEntriesTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterSheetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterSheetEntriesTable,
      CharacterSheetEntry,
      $$CharacterSheetEntriesTableFilterComposer,
      $$CharacterSheetEntriesTableOrderingComposer,
      $$CharacterSheetEntriesTableAnnotationComposer,
      $$CharacterSheetEntriesTableCreateCompanionBuilder,
      $$CharacterSheetEntriesTableUpdateCompanionBuilder,
      (CharacterSheetEntry, $$CharacterSheetEntriesTableReferences),
      CharacterSheetEntry,
      PrefetchHooks Function({bool sheetId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$WorldAreasTableTableManager get worldAreas =>
      $$WorldAreasTableTableManager(_db, _db.worldAreas);
  $$BookImagesTableTableManager get bookImages =>
      $$BookImagesTableTableManager(_db, _db.bookImages);
  $$MindmapNodesTableTableManager get mindmapNodes =>
      $$MindmapNodesTableTableManager(_db, _db.mindmapNodes);
  $$MindmapEdgesTableTableManager get mindmapEdges =>
      $$MindmapEdgesTableTableManager(_db, _db.mindmapEdges);
  $$EpubFilesTableTableManager get epubFiles =>
      $$EpubFilesTableTableManager(_db, _db.epubFiles);
  $$ReaderBookmarksTableTableManager get readerBookmarks =>
      $$ReaderBookmarksTableTableManager(_db, _db.readerBookmarks);
  $$ReaderHighlightsTableTableManager get readerHighlights =>
      $$ReaderHighlightsTableTableManager(_db, _db.readerHighlights);
  $$CharacterSheetsTableTableManager get characterSheets =>
      $$CharacterSheetsTableTableManager(_db, _db.characterSheets);
  $$CharacterSheetEntriesTableTableManager get characterSheetEntries =>
      $$CharacterSheetEntriesTableTableManager(_db, _db.characterSheetEntries);
}
