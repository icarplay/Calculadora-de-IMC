import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:calculadora_imc/paciente_page.dart';

class PeoplePage extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {

  Map<String, dynamic> _toDoList = {};

  Map<String, dynamic> lastRemoved;
  int lastRemovedIndex;

  @override
  void initState() { 
    super.initState();
    
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });

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

  Widget builderItemsList(context, index) {
    return GestureDetector(
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: ListTile(
          title: Text(
            _toDoList['People'][index]['nome'] + ' ' + _toDoList['People'][index]['sobrenome']),
        ),
        onDismissed: (direction) {
          lastRemoved = Map.from(_toDoList['People'][index]);
          lastRemovedIndex = index;

          setState(() {
            _toDoList['People'].removeAt(index);
          });
          _saveData();

          final snack = SnackBar(
            content: Text("tarefa \"${lastRemoved["nome"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList['People'].insert(lastRemovedIndex, lastRemoved);
                });
                _saveData();
              },
            ),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);

        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PacientePage(_toDoList['People'][index]) //GifPage(snapshot.data["data"][index])
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pacientes"),
        centerTitle: true,
        backgroundColor: Colors.teal[400],
      ),
      body: ListView.builder(
        itemCount: _toDoList['People'] == null ? 0 : _toDoList['People'].length,
        itemBuilder: builderItemsList,
      ),
    );
  }
}