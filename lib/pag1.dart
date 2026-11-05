import 'package:dbestudante/estudante.dart';
import 'package:dbestudante/estudante_dao.dart';
import 'package:flutter/material.dart';

class pag1 extends StatefulWidget {
  const pag1({super.key});

  @override
  State<pag1> createState() => _pag1State();
}

class _pag1State extends State<pag1> {
  final _estudanteDAO = EstudanteDao();
  Estudante? _estudanteAtual;

  final _controllerNome = TextEditingController();
  final _controllerMatricula = TextEditingController();
  List<Estudante> _listaEstudantes = [];

  @override
  void initState() {
    super.initState();
    _loadEstudantes();
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerMatricula.dispose();
    super.dispose();
  }

  Future<void> _loadEstudantes() async {
    List<Estudante> temp = await _estudanteDAO.listarEstudantes();
    if (!mounted) return;
    setState(() {
      _listaEstudantes = temp;
    });
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  void _limpar() {
    _controllerNome.clear();
    _controllerMatricula.clear();
    setState(() {
      _estudanteAtual = null;
    });
  }

  Future<void> _salvarOUEditar() async {
    final nome = _controllerNome.text.trim();
    final matricula = _controllerMatricula.text.trim();
    if (nome.isEmpty || matricula.isEmpty) {
      _msg("Preencha o nome e a matrícula");
      return;
    }
    if (_estudanteAtual == null) {
      //novo estudante
      await _estudanteDAO
          .incluirEstudante(Estudante(nome: nome, matricula: matricula));
    } else {
      //atualizar estudante
      _estudanteAtual!.nome = nome;
      _estudanteAtual!.matricula = matricula;
      await _estudanteDAO.editarEstudante(_estudanteAtual!);
    }
    _limpar();
    await _loadEstudantes();
  }

  Future<void> _apagarEstudante(int id) async {
    await _estudanteDAO.deleteEstudante(id);
    if (_estudanteAtual?.id == id) _limpar();
    await _loadEstudantes();
    _msg("Estudante removido");
  }

  void _selecionar(Estudante e) {
    setState(() {
      _estudanteAtual = e;
      _controllerNome.text = e.nome;
      _controllerMatricula.text = e.matricula;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final editando = _estudanteAtual != null;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          color: cores.primaryContainer.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _controllerNome,
                  decoration: const InputDecoration(
                    labelText: "Nome",
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controllerMatricula,
                  decoration: const InputDecoration(
                    labelText: "Matrícula",
                    prefixIcon: Icon(Icons.badge),
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
          child: _listaEstudantes.isEmpty
              ? const Center(child: Text("Nenhum estudante cadastrado"))
              : ListView.builder(
                  itemCount: _listaEstudantes.length,
                  itemBuilder: (context, index) {
                    final e = _listaEstudantes[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cores.primary,
                          foregroundColor: cores.onPrimary,
                          child: Text(e.nome.isEmpty
                              ? "?"
                              : e.nome[0].toUpperCase()),
                        ),
                        title: Text(e.nome),
                        subtitle: Text("Matrícula: ${e.matricula}"),
                        trailing: IconButton(
                          onPressed: () => _apagarEstudante(e.id!),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                        onTap: () => _selecionar(e),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
