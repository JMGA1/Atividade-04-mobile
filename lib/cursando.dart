
class Cursando {
  int? id;
  int estudanteId;
  int disciplinaId;
  Cursando({this.id, required this.estudanteId, required this.disciplinaId});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "estudante_id": estudanteId,
      "disciplina_id": disciplinaId,
    };
  }
}

// resultado do JOIN
class CursandoDetalhe {
  int id;
  int estudanteId;
  int disciplinaId;
  String estudanteNome;
  String matricula;
  String disciplinaNome;
  String professor;

  CursandoDetalhe({
    required this.id,
    required this.estudanteId,
    required this.disciplinaId,
    required this.estudanteNome,
    required this.matricula,
    required this.disciplinaNome,
    required this.professor,
  });

  factory CursandoDetalhe.fromMap(Map<String, dynamic> map) {
    return CursandoDetalhe(
      id: map['id'],
      estudanteId: map['estudante_id'],
      disciplinaId: map['disciplina_id'],
      estudanteNome: map['estudante_nome'],
      matricula: map['matricula'],
      disciplinaNome: map['disciplina_nome'],
      professor: map['professor'],
    );
  }
}
