// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ProtoPdfDao? _protoPdfDaoInstance;

  ImageDao? _imageDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ProtoPdf` (`id` INTEGER, `title` TEXT NOT NULL, `creation` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PdfImage` (`id` INTEGER, `proto_pdf` INTEGER NOT NULL, `path` TEXT NOT NULL, `thumb_path` TEXT, `position` INTEGER NOT NULL, FOREIGN KEY (`proto_pdf`) REFERENCES `ProtoPdf` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ProtoPdfDao get protoPdfDao {
    return _protoPdfDaoInstance ??= _$ProtoPdfDao(database, changeListener);
  }

  @override
  ImageDao get imageDao {
    return _imageDaoInstance ??= _$ImageDao(database, changeListener);
  }
}

class _$ProtoPdfDao extends ProtoPdfDao {
  _$ProtoPdfDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _protoPdfInsertionAdapter = InsertionAdapter(
            database,
            'ProtoPdf',
            (ProtoPdf item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'creation': item.creation
                },
            changeListener),
        _protoPdfUpdateAdapter = UpdateAdapter(
            database,
            'ProtoPdf',
            ['id'],
            (ProtoPdf item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'creation': item.creation
                },
            changeListener),
        _protoPdfDeletionAdapter = DeletionAdapter(
            database,
            'ProtoPdf',
            ['id'],
            (ProtoPdf item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'creation': item.creation
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProtoPdf> _protoPdfInsertionAdapter;

  final UpdateAdapter<ProtoPdf> _protoPdfUpdateAdapter;

  final DeletionAdapter<ProtoPdf> _protoPdfDeletionAdapter;

  @override
  Stream<List<ProtoPdf>> findAllProtoPdfsAsStream() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM ProtoPdf ORDER BY ProtoPdf.creation ASC',
        mapper: (Map<String, Object?> row) => ProtoPdf(
            row['id'] as int?, row['title'] as String, row['creation'] as int),
        queryableName: 'ProtoPdf',
        isView: false);
  }

  @override
  Future<void> insertProtoPdf(ProtoPdf pdf) async {
    await _protoPdfInsertionAdapter.insert(pdf, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProtoPdf(ProtoPdf pdf) async {
    await _protoPdfUpdateAdapter.update(pdf, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProtoPdfById(ProtoPdf pdf) async {
    await _protoPdfDeletionAdapter.delete(pdf);
  }
}

class _$ImageDao extends ImageDao {
  _$ImageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _pdfImageInsertionAdapter = InsertionAdapter(
            database,
            'PdfImage',
            (PdfImage item) => <String, Object?>{
                  'id': item.id,
                  'proto_pdf': item.protoPdf,
                  'path': item.path,
                  'thumb_path': item.thumb_path,
                  'position': item.position
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PdfImage> _pdfImageInsertionAdapter;

  @override
  Future<PdfImage?> lastPosition(int protoPdfId) async {
    return _queryAdapter.query(
        'SELECT * FROM PdfImage WHERE ?1=PdfImage.proto_pdf AND PdfImage.position=(SELECT MAX(PdfImage.position) FROM PdfImage)',
        mapper: (Map<String, Object?> row) => PdfImage(row['id'] as int?, row['proto_pdf'] as int, row['path'] as String, row['thumb_path'] as String?, row['position'] as int),
        arguments: [protoPdfId]);
  }

  @override
  Stream<List<PdfImage>> findAllImagesAsStream(int protoPdfId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM PdfImage WHERE ?1=PdfImage.proto_pdf ORDER BY PdfImage.position ASC',
        mapper: (Map<String, Object?> row) => PdfImage(
            row['id'] as int?,
            row['proto_pdf'] as int,
            row['path'] as String,
            row['thumb_path'] as String?,
            row['position'] as int),
        arguments: [protoPdfId],
        queryableName: 'PdfImage',
        isView: false);
  }

  @override
  Future<List<PdfImage>> findAllImages(int protoPdfId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PdfImage WHERE ?1=PdfImage.proto_pdf ORDER BY PdfImage.position ASC',
        mapper: (Map<String, Object?> row) => PdfImage(row['id'] as int?, row['proto_pdf'] as int, row['path'] as String, row['thumb_path'] as String?, row['position'] as int),
        arguments: [protoPdfId]);
  }

  @override
  Future<void> insertImage(PdfImage image) async {
    await _pdfImageInsertionAdapter.insert(image, OnConflictStrategy.abort);
  }
}
