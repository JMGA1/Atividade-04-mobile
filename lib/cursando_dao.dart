import 'package:dbestudante/DatabaseHelper.dart';
import 'package:dbestudante/cursando.dart';

class CursandoDao {
  final Databasehelper _dbHelper = Databasehelper();

  // da erro se estudandte e disciplina existir
  Future<void> incluirCursando(Cursando c) async {
    final db = await _dbHelper.database;
    await db.insert("cursando", c.toMap());
  }

  Future<void> editarCursando(Cursando c) async {
    final db = await _dbHelper.database;
    await db.update(
      "cursando",
      c.toMap(),
      where: "id = ?",
      whereArgs: [c.id],
    );
  }

  Future<void> deleteCursando(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      "cursando",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // JOIN entre as 3 tabelas
  Future<List<CursandoDetalhe>> listarCursando() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.id, c.estudante_id, c.disciplina_id,
             e.nome AS estudante_nome, e.matricula,
             d.nome AS disciplina_nome, d.professor
      FROM cursando c
      INNER JOIN estudante e ON e.id = c.estudante_id
      INNER JOIN disciplina d ON d.id = c.disciplina_id
      ORDER BY e.nome, d.nome
    ''');
    return List.generate(maps.length, (index) {
      return CursandoDetalhe.fromMap(maps[index]);
    });
  }
}
