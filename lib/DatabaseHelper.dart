import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  static final Databasehelper _instance = Databasehelper._internal();
  static Database? _database;
  factory Databasehelper() {
    return _instance;
  }
  Databasehelper._internal();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'if.db'),
      version: 2,
      
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS estudante(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, matricula TEXT)');
    await _criarTabelasNovas(db);
  }

  
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _criarTabelasNovas(db);
    }
  }

  Future _criarTabelasNovas(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS disciplina(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, professor TEXT)');
   
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cursando(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudante_id INTEGER NOT NULL,
        disciplina_id INTEGER NOT NULL,
        UNIQUE(estudante_id, disciplina_id),
        FOREIGN KEY (estudante_id) REFERENCES estudante(id) ON DELETE CASCADE,
        FOREIGN KEY (disciplina_id) REFERENCES disciplina(id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
