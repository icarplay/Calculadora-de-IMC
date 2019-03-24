import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class AddPeoplePage extends StatefulWidget {
  @override
  _AddPeoplePageState createState() => _AddPeoplePageState();
}

class _AddPeoplePageState extends State<AddPeoplePage> {

  TextEditingController nomeController = TextEditingController();
  TextEditingController sobrenomeController = TextEditingController();
  TextEditingController idadeController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _toDoList = {};

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _resetFields() {
    nomeController.text = "";
    sobrenomeController.text = "";
    idadeController.text = "";
  }

  void _addToDo() {
    Map<String, dynamic> newToDo = Map();
    newToDo["id"] = DateTime.now().millisecondsSinceEpoch.toString();
    newToDo["nome"] = nomeController.text;
    newToDo["sobrenome"] = sobrenomeController.text;
    newToDo["idade"] = idadeController.text;

    setState(() {
      if (_toDoList.containsKey('People')) {
        _toDoList['People'].add(newToDo);
      } else {
        _toDoList['People'] = [];
        _toDoList['People'].add(newToDo);
      }
    });

    _saveData();
    _resetFields();
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch(e) {
      return null;
    }
  }

  Widget _inputTextGenerator(TextInputType type, String label, String name, TextEditingController controller) {
    return TextFormField(
            keyboardType: type,
            decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                    color: Colors.teal[400]
                )
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.teal[400],
                fontSize: 25.0
            ),
            controller: controller,
            validator: (value) {
              if (value.isEmpty) {
                return "Insina seu/sua $name!";
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Adicionar novo paciente"),
          centerTitle: true,
          backgroundColor: Colors.teal[400],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetFields,
            )
          ],
        ),
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                    Icons.person_outline,
                    size: 120.0,
                    color: Colors.teal[400]
                ),
                _inputTextGenerator(TextInputType.text, "Nome", "nome", nomeController),
                _inputTextGenerator(TextInputType.text, "Sobrenome", "sobrenome", sobrenomeController),
                _inputTextGenerator(TextInputType.number, "Idade", "idade", idadeController),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                      height: 50.0,
                      child: RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate() ) {
                            _addToDo();
                          }
                        },
                        child: Text(
                          "Salvar",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0
                          ),
                        ),
                        color: Colors.teal[400],
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}