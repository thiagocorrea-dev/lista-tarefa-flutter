import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];

  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    // criar os dados
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivos();
    _controllerTarefa.text = "";
  }

  _salvarArquivos() async {
    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget criarItemLista(context, index) {
    //final item = _listaTarefas[index]["titulo"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          // Recuperar o item excluido
          _ultimaTarefaRemovida = _listaTarefas[index];

          // Remove o item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivos();

          final snackbar = SnackBar(
            backgroundColor: Colors.green,
            content: Text("Tarefa Removida"),
            action: SnackBarAction(
              label: "Desfazer",
              textColor: Colors.white,
              onPressed: () {
                // desfazer a ação
                setState(() {
                  _listaTarefas.insert(index, _ultimaTarefaRemovida);
                });
                _salvarArquivos();
              },
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.redAccent,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete_sweep,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(
            _listaTarefas[index]['titulo'],
            style: TextStyle(color: Colors.white),
          ),
          value: _listaTarefas[index]['realizada'],
          onChanged: (valorAlterado) {
            setState(() {
              _listaTarefas[index]['realizada'] = valorAlterado;
            });

            _salvarArquivos();
          },
        ));
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //_salvarArquivos();
    //print("itens: " + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(

        // Definição do app bar | Header
        appBar: AppBar(
          backgroundColor: Color(0xFF5c2d91),
          title: Text(
            "MINHAS TAREFAS",
          ),
        ),

        // Cor de fundo
        backgroundColor: Color(0XFF1e1e1e),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: _listaTarefas.length, itemBuilder: criarItemLista),
            ),
          ],
        ),

        // ìcone para adicionar a tarefa
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF5c2d91),
          foregroundColor: Colors.white,
          mini: false,
          elevation: 30,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Adicionar Tarefa"),
                    content: TextField(
                      controller: _controllerTarefa,
                      decoration:
                          InputDecoration(labelText: "Digite sua tarefa"),
                      onChanged: (text) {},
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancelar"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        child: Text("Salvar"),
                        onPressed: () {
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          },
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Color(0xff5c2d91),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Adicionar Tarefa"),
                          content: TextField(
                            controller: _controllerTarefa,
                            decoration:
                                InputDecoration(labelText: "Digite sua tarefa"),
                            onChanged: (text) {},
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Cancelar"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FlatButton(
                              child: Text("Salvar"),
                              onPressed: () {
                                _salvarTarefa();
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      });
                },
                icon: Icon(Icons.add),
                color: Colors.white,
              )
            ],
          ),
        ));
  }
}
