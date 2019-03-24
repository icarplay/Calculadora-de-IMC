import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class PacientePage extends StatefulWidget {

  final Map<String, dynamic> _paciente;

  PacientePage(this._paciente);

  @override
  _PacientePageState createState() => _PacientePageState(_paciente);
}

class _PacientePageState extends State<PacientePage> {
  final Map<String, dynamic> _paciente;

  _PacientePageState(this._paciente) {
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
        _imcList = filterImc();
      });
    });
  }

  Map<String, dynamic> _toDoList = {};
  List<Map<String, dynamic>> _imcList = [];

  Map<String, dynamic> lastRemoved;
  int lastRemovedIndex;

  // @override
  // void initState() { 
  //   super.initState();
    
    
  // }

  List<Map<String, dynamic>> filterImc() {
    List<Map<String, dynamic>> auxItems = [];

    for (Map<String, dynamic> item in _toDoList['IMC']) {
      print(item);
      if (item['person'] == _paciente['id']) {
        auxItems.add(item);
      }
    }

    // auxItems.sort((a, b) {
    //   if (DateTime(a["data"]).millisecondsSinceEpoch > DateTime(b["data"]).millisecondsSinceEpoch) return 1;
    //   else if (DateTime(a["data"]).millisecondsSinceEpoch < DateTime(b["data"]).millisecondsSinceEpoch) return -1;
    //   else return 0;
    // });

    return auxItems;
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
    if (_imcList != null) {
      return Dismissible(
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
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                'Peso: ' + _imcList[index]['peso'] + ' Altura:' + _imcList[index]['altura'] + ' IMC: ' + _imcList[index]['imc'].toString()
              ),
            ),
            new Divider(height: 15.0,color: Colors.teal[400],),
          ],
        ),
        onDismissed: (direction) {
          lastRemoved = Map.from(_imcList[index]);
          lastRemovedIndex = index;

          setState(() {
            _imcList.removeAt(index);
          });
          _saveData();

          final snack = SnackBar(
            content: Text("tarefa \"${_imcList[index]["peso"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _imcList.insert(lastRemovedIndex, lastRemoved);
                });
                _saveData();
              },
            ),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);

        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Paciente - " + _paciente['nome']),
        centerTitle: true,
        backgroundColor: Colors.teal[400],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                Icons.person_outline,
                size: 160.0,
                color: Colors.teal[400]
              ),
              Text(
                'Nome: ' +  _paciente['nome'] + ' ' + _paciente['sobrenome'],
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.teal[400],
                ),
              ),
              Text(
                'Idade: ' + _paciente['idade'],
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.teal[400],
                ),
              ),
            ],
          ),
          new Divider(height: 15.0,color: Colors.teal[400],),
          Expanded(
            child: ListView.builder(
              itemCount: _imcList == null ? 0 :_imcList.length,
              itemBuilder: builderItemsList,
            ),
          )
        ]
      )
    );
  }

}
// (context, index) {
//                 if (_imcList != null) {
//                   return Container(
//                     child: Text(_imcList[index]['peso']),
//                   );
//                 }
//               }