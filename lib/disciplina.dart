class Disciplina {
  int? id;
  String nome;
  String professor;
  Disciplina({this.id, required this.nome, required this.professor});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "professor": professor,
    };
  }

  factory Disciplina.fromMap(Map<String, dynamic> map) {
    return Disciplina(
      id: map['id'],
      nome: map['nome'],
      professor: map['professor'],
    );
  }
}
