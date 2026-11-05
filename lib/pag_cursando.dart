import 'package:dbestudante/cursando.dart';
import 'package:dbestudante/cursando_dao.dart';
import 'package:dbestudante/disciplina.dart';
import 'package:dbestudante/disciplina_dao.dart';
import 'package:dbestudante/estudante.dart';
import 'package:dbestudante/estudante_dao.dart';
import 'package:flutter/material.dart';

class PagCursando extends StatefulWidget {
  const PagCursando({super.key});

  @override
  State<PagCursando> createState() => _PagCursandoState();
}

class _PagCursandoState extends State<PagCursando> {
  final _cursandoDao = CursandoDao();
  final _estudanteDao = EstudanteDao();
  final _disciplinaDao = DisciplinaDao();

  List<Estudante> _estudantes = [];
  List<Disciplina> _disciplinas = [];
  List<CursandoDetalhe> _lista = [];

  int? _estudanteId;
  int? _disciplinaId;
  CursandoDetalhe? _atual;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final estudantes = await _estudanteDao.listarEstudantes();
    final disciplinas = await _disciplinaDao.listarDisciplinas();
    final lista = await _cursandoDao.listarCursando();
    if (!mounted) return;
    setState(() {
      _estudantes = estudantes;
      _disciplinas = disciplinas;
      _lista = lista;
    });
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  void _limpar() {
    setState(() {
      _estudanteId = null;
      _disciplinaId = null;
      _atual = null;
    });
  }

  Future<void> _salvarOUEditar() async {
    if (_estudanteId == null || _disciplinaId == null) {
      _msg("Escolha o estudante e a disciplina");
      return;
    }
    try {
      if (_atual == null) {
        await _cursandoDao.incluirCursando(
            Cursando(estudanteId: _estudanteId!, disciplinaId: _disciplinaId!));
      } else {
        await _cursandoDao.editarCursando(Cursando(
            id: _atual!.id,
            estudanteId: _estudanteId!,
            disciplinaId: _disciplinaId!));
      }
    } catch (_) {
      _msg("Esse estudante já cursa essa disciplina");
      return;
    }
    _limpar();
    await _carregar();
  }

  Future<void> _apagar(int id) async {
    await _cursandoDao.deleteCursando(id);
    if (_atual?.id == id) _limpar();
    await _carregar();
    _msg("Matrícula removida");
  }

  void _selecionar(CursandoDetalhe c) {
    setState(() {
      _atual = c;
      _estudanteId = c.estudanteId;
      _disciplinaId = c.disciplinaId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    if (_estudantes.isEmpty || _disciplinas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Cadastre pelo menos um estudante e uma disciplina para poder relacioná-los.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final editando = _atual != null;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          color: cores.tertiaryContainer.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: _estudanteId,
                  decoration: const InputDecoration(
                    labelText: "Estudante",
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  items: _estudantes
                      .map((e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(e.nome),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _estudanteId = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _disciplinaId,
                  decoration: const InputDecoration(
                    labelText: "Disciplina",
                    prefixIcon: Icon(Icons.menu_book),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  items: _disciplinas
                      .map((d) => DropdownMenuItem<int>(
                            value: d.id,
                            child: Text(d.nome),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _disciplinaId = v),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _salvarOUEditar,
                        icon: Icon(editando ? Icons.check : Icons.add),
                        label: Text(editando ? "Atualizar" : "Matricular"),
                      ),
                    ),
                    if (editando) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _limpar,
                        child: const Text("Cancelar"),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _lista.isEmpty
              ? const Center(child: Text("Nenhuma matrícula ainda"))
              : ListView.builder(
                  itemCount: _lista.length,
                  itemBuilder: (context, index) {
                    final c = _lista[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cores.tertiary,
                          foregroundColor: cores.onTertiary,
                          child: Text(c.estudanteNome.isEmpty
                              ? "?"
                              : c.estudanteNome[0].toUpperCase()),
                        ),
                        title: Text(c.estudanteNome),
                        subtitle: Text(
                            "${c.disciplinaNome} · Prof. ${c.professor}"),
                        trailing: IconButton(
                          onPressed: () => _apagar(c.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                        onTap: () => _selecionar(c),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
