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

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

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
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
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
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ProtoPdfDao _protoPdfDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
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
            'CREATE TABLE IF NOT EXISTS `ProtoPdf` (`id` INTEGER, `title` TEXT, `creation` INTEGER, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ProtoPdfDao get protoPdfDao {
    return _protoPdfDaoInstance ??= _$ProtoPdfDao(database, changeListener);
  }
}

class _$ProtoPdfDao extends ProtoPdfDao {
  _$ProtoPdfDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _protoPdfInsertionAdapter = InsertionAdapter(
            database,
            'ProtoPdf',
            (ProtoPdf item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'creation': item.creation
                },
            changeListener),
        _protoPdfUpdateAdapter = UpdateAdapter(
            database,
            'ProtoPdf',
            ['id'],
            (ProtoPdf item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'creation': item.creation
                },
            changeListener),
        _protoPdfDeletionAdapter = DeletionAdapter(
            database,
            'ProtoPdf',
            ['id'],
            (ProtoPdf item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'creation': item.creation
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _protoPdfMapper = (Map<String, dynamic> row) => ProtoPdf(
      row['id'] as int, row['title'] as String, row['creation'] as int);

  final InsertionAdapter<ProtoPdf> _protoPdfInsertionAdapter;

  final UpdateAdapter<ProtoPdf> _protoPdfUpdateAdapter;

  final DeletionAdapter<ProtoPdf> _protoPdfDeletionAdapter;

  @override
  Stream<List<ProtoPdf>> findAllDeadlinesAsStream() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM ProtoPdf ORDER BY ProtoPdf.creation ASC',
        queryableName: 'ProtoPdf',
        isView: false,
        mapper: _protoPdfMapper);
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
