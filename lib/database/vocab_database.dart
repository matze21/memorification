import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './model.dart';
import './read_csv.dart';

class VocabDatabase {
  static final VocabDatabase instance = VocabDatabase._init();

  static Database? _database;

  VocabDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDB('vocabs.db');
      return await createDefaultPackage(_database!); //create default table!;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    Database db = await openDatabase(path, version: 1); //, onCreate: _createDB);
    return db;
  }

  static Future createDBintern(Database db, String tableName) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType = 'INTEGER NOT NULL';

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

  static Future createDB(String tableName) async {
    createDBintern(await instance.database, tableName);
  }

  Future deleteDB(String tableName) async {
    final db = await instance.database;
    await db.execute("DROP TABLE $tableName");
  }

  Future getAllExistingDataTablesIntern(final Database db) async {
    var tables = (await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: true);
    tables.remove('android_metadata');
    tables.remove('sqlite_sequence');

    List<databaseKey> tableNames = [];
    for(String table in tables) {
      tableNames.add(databaseKey.getDataBaseKeyFromKey(table));
    }
    return tableNames;
  }

  Future getAllExistingDataTables() async {
    final db = await instance.database;
    return getAllExistingDataTablesIntern(db);
  }

  Future addWordPair(WordPair note, String tableName) async {
    final db = await instance.database;

    final id = await db.insert(tableName, note.toJson());
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
    final result = await db.query(tableName, orderBy: orderBy);

    return result.map((json) => WordPair.fromJson(json)).toList();
  }

  Future<int> updateWordPair(WordPair note, String tableName) async {
    final db = await instance.database;

    return await db.update(
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

  Future<Database> createDefaultPackage(Database db) async {

    List<String> fileNames = ['spanish_english_verbs', 'french_english_verbs', 'german_english_verbs', 'portuguese_english_verbs'];

    List<databaseKey> tables = await getAllExistingDataTablesIntern(db);
    List<String> names = [];
    for (databaseKey table in tables) {
      names.add(table.getKey(space: '_'));
    }
    for(String fileName in fileNames) {
      if (names.contains(fileName) == false) {
        createDBintern(db, fileName);

        final List<List<dynamic>> csvData = await loadCSVtoDB(fileName);
        for (int i = 0; i < csvData.length; i++) {
          WordPair newWordPair = WordPair(baseWord: csvData[i][0],
              translation: csvData[i][1],
              numberSeen: 0,
              maxNumber: 10); //DEFAULT_MAX_NR_NOTIF);
          print(csvData[i][0]);
          addWordPair(newWordPair, fileName);
        }
      }
    }
    return db;
  }
}
