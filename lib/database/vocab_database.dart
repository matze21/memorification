import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './model.dart';

class VocabDatabase {
  static final VocabDatabase instance = VocabDatabase._init();

  static Database? _database;

  VocabDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('vocabs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1); //, onCreate: _createDB);
  }

  static Future createDB(String tableName) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    final db = await instance.database;

      await db.execute('''
CREATE TABLE $tableName ( 
  ${WordPairFields.id} $idType, 
  ${WordPairFields.numberSeen} $integerType,
  ${WordPairFields.baseWord} $textType,
  ${WordPairFields.translation} $textType,
  ${WordPairFields.maxNumber} $integerType
  )
''');
  }

  Future deleteDB(String tableName) async {
    final db = await instance.database;
    await db.execute("DROP TABLE $tableName");
    //db.delete(tableName);
  }

  Future getAllExistingDataTables() async {
    final db = await instance.database;
    var tables = (await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: true);
    tables.remove('android_metadata');
    tables.remove('sqlite_sequence');
    //final tables = await db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
    //return tables.map((json) => databaseKey.fromJson(json)).toList();

    tableNames = [];
    //print(tables);
    for(String table in tables) {
      tableNames.add(databaseKey.getDataBaseKeyFromKey(table));
      }
  }

  Future<WordPair> addWordPair(WordPair note, String tableName) async {
    final db = await instance.database;

    final id = await db.insert(tableName, note.toJson());
    return note.copy(id: id);
  }

  Future<WordPair> readWordPair(int id, String tableName) async {
    final db = await instance.database;

    final maps = await db.query(
      tableName,
      columns: WordPairFields.values,
      where: '${WordPairFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return WordPair.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<WordPair>> readAllWordPairs(String tableName) async {
    final db = await instance.database;

    final orderBy = '${WordPairFields.baseWord} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableName, orderBy: orderBy);

    return result.map((json) => WordPair.fromJson(json)).toList();
  }

/*  List<WordPair> readAllWordPairsStatic(String tableName) {
    final Database db = _database!;

    final orderBy = '${WordPairFields.baseWord} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = db.query(tableName, orderBy: orderBy);

    return result.map((json) => WordPair.fromJson(json)).toList();
  }*/

  Future<int> updateWordPair(WordPair note, String tableName) async {
    final db = await instance.database;

    return db.update(
      tableName,
      note.toJson(),
      where: '${WordPairFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteWordPair(int id, String tableName) async {
    final db = await instance.database;

    return await db.delete(
      tableName,
      where: '${WordPairFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}