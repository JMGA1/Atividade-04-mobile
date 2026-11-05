import 'package:dbestudante/DatabaseHelper.dart';
import 'package:dbestudante/disciplina.dart';
import 'package:sqflite/sqflite.dart';

class DisciplinaDao {
  final Databasehelper _dbHelper = Databasehelper();

  Future<void> incluirDisciplina(Disciplina d) async {
    final db = await _dbHelper.database;
    await db.insert(
      "disciplina",
      d.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> editarDisciplina(Disciplina d) async {
    final db = await _dbHelper.database;
    await db.update(
      "disciplina",
      d.toMap(),
      where: "id = ?",
      whereArgs: [d.id],
    );
  }

  Future<void> deleteDisciplina(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      "disciplina",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Disciplina>> listarDisciplinas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query("disciplina");
    return List.generate(maps.length, (index) {
      return Disciplina.fromMap(maps[index]);
    });
  }
}
