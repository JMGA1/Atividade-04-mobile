import 'package:dbestudante/disciplina.dart';
import 'package:dbestudante/disciplina_dao.dart';
import 'package:flutter/material.dart';

class PagDisciplina extends StatefulWidget {
  const PagDisciplina({super.key});

  @override
  State<PagDisciplina> createState() => _PagDisciplinaState();
}

class _PagDisciplinaState extends State<PagDisciplina> {
  final _disciplinaDAO = DisciplinaDao();
  Disciplina? _disciplinaAtual;

  final _controllerNome = TextEditingController();
  final _controllerProfessor = TextEditingController();
  List<Disciplina> _listaDisciplinas = [];

  @override
  void initState() {
    super.initState();
    _loadDisciplinas();
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerProfessor.dispose();
    super.dispose();
  }

  Future<void> _loadDisciplinas() async {
    List<Disciplina> temp = await _disciplinaDAO.listarDisciplinas();
    if (!mounted) return;
    setState(() {
      _listaDisciplinas = temp;
    });
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  void _limpar() {
    _controllerNome.clear();
    _controllerProfessor.clear();
    setState(() {
      _disciplinaAtual = null;
    });
  }

  Future<void> _salvarOUEditar() async {
    final nome = _controllerNome.text.trim();
    final professor = _controllerProfessor.text.trim();
    if (nome.isEmpty || professor.isEmpty) {
      _msg("Preencha o nome e o professor");
      return;
    }
    if (_disciplinaAtual == null) {
      await _disciplinaDAO
          .incluirDisciplina(Disciplina(nome: nome, professor: professor));
    } else {
      _disciplinaAtual!.nome = nome;
      _disciplinaAtual!.professor = professor;
      await _disciplinaDAO.editarDisciplina(_disciplinaAtual!);
    }
    _limpar();
    await _loadDisciplinas();
  }

  Future<void> _apagarDisciplina(int id) async {
    await _disciplinaDAO.deleteDisciplina(id);
    if (_disciplinaAtual?.id == id) _limpar();
    await _loadDisciplinas();
    _msg("Disciplina removida");
  }

  void _selecionar(Disciplina d) {
    setState(() {
      _disciplinaAtual = d;
      _controllerNome.text = d.nome;
      _controllerProfessor.text = d.professor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final editando = _disciplinaAtual != null;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          color: cores.secondaryContainer.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _controllerNome,
                  decoration: const InputDecoration(
                    labelText: "Nome da disciplina",
                    prefixIcon: Icon(Icons.menu_book),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controllerProfessor,
                  decoration: const InputDecoration(
                    labelText: "Professor",
                    prefixIcon: Icon(Icons.person_pin),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _salvarOUEditar,
                        icon: Icon(editando ? Icons.check : Icons.add),
                        label: Text(editando ? "Atualizar" : "Salvar"),
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
          child: _listaDisciplinas.isEmpty
              ? const Center(child: Text("Nenhuma disciplina cadastrada"))
              : ListView.builder(
                  itemCount: _listaDisciplinas.length,
                  itemBuilder: (context, index) {
                    final d = _listaDisciplinas[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cores.secondary,
                          foregroundColor: cores.onSecondary,
                          child: Text(d.nome.isEmpty
                              ? "?"
                              : d.nome[0].toUpperCase()),
                        ),
                        title: Text(d.nome),
                        subtitle: Text("Prof. ${d.professor}"),
                        trailing: IconButton(
                          onPressed: () => _apagarDisciplina(d.id!),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                        onTap: () => _selecionar(d),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
