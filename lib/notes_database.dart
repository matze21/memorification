import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './model.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('vocabs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${WordPairFields.id} $idType, 
  ${WordPairFields.numberSeen} $integerType,
  ${WordPairFields.baseWord} $textType,
  ${WordPairFields.translation} $textType
  )
''');
  }

  Future<WordPair> addWordPair(WordPair note) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  Future<WordPair> readWordPair(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
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

  Future<List<WordPair>> readAllWordPairs() async {
    final db = await instance.database;

    final orderBy = '${WordPairFields.baseWord} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => WordPair.fromJson(json)).toList();
  }

  Future<int> updateWordPair(WordPair note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${WordPairFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteWordPair(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${WordPairFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}