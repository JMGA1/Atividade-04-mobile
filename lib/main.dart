import 'package:dbestudante/pag1.dart';
import 'package:dbestudante/pag_cursando.dart';
import 'package:dbestudante/pag_disciplina.dart';
import 'package:flutter/material.dart';
 import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

 void main() {
        if (kIsWeb) {
          databaseFactory = databaseFactoryFfiWeb;
        }
        runApp(const app());
      }
class app extends StatelessWidget {
  const app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CRUD Estudante",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const Home(),
    );
  }
}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _aba = 0;

  static const _titulos = ["Estudantes", "Disciplinas", "Cursando"];

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    // As páginas são recriadas ao trocar de aba, então sempre recarregam o banco
    final paginas = const [pag1(), PagDisciplina(), PagCursando()];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_aba]),
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
      ),
      body: paginas[_aba],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.school), label: "Estudantes"),
          NavigationDestination(
              icon: Icon(Icons.menu_book), label: "Disciplinas"),
          NavigationDestination(icon: Icon(Icons.link), label: "Cursando"),
        ],
      ),
    );
  }
}
