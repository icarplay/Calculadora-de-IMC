import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _statusText = "Entre com as informações";
  double imc = 0;
  Map<String, dynamic> _toDoList = {};

  List<DropdownMenuItem<String>> _peopleItems;
  String _currentPeople;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
        _peopleItems = _getDropdownItems();
      });
    });
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    List<DropdownMenuItem<String>> auxItems = List();

    for (Map<String, dynamic> item in _toDoList['People']) {
      auxItems.add(
        DropdownMenuItem(
          value: item['id'],
          child: Text(item['nome']),
        )
      );
    }

    return auxItems;
  }

  void _addToDo() {

    if (_currentPeople != null) {

      Map<String, dynamic> newToDo = Map();
      newToDo["id"] = DateTime.now().millisecondsSinceEpoch.toString();
      newToDo["peso"] = weightController.text;
      newToDo["altura"] = heightController.text;
      newToDo["imc"] = imc.toStringAsPrecision(2);
      newToDo["person"] = _currentPeople;
      newToDo["data"] = DateTime.now().toIso8601String();

      setState(() {
        if (_toDoList.containsKey('IMC')) {
          _toDoList['IMC'].add(newToDo);
        } else {
          _toDoList['IMC'] = [];
          _toDoList['IMC'].add(newToDo);
        }
      });

      _saveData();
      _resetFields();
    }
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

  void _resetFields() {
    weightController.text = "";
    heightController.text = "";
    setState(() {
      _statusText = "Entre com as informações!";
      _currentPeople = null;
    });
  }

  void calculate() {
    setState(() {
      double weight = double.parse(weightController.text.replaceAll(",", "."));
      double height = double.parse(heightController.text.replaceAll(",", ".")) / 100;

      imc = weight / (height * height);

      if (imc < 18.6) {
        _statusText = "Abaixo do Peso (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 18.6 && imc < 24.9) {
        _statusText = "Peso Ideal (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 24.9 && imc < 29.9) {
        _statusText = "Levemente Acima do Peso (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 29.9 && imc < 34.9) {
        _statusText = "Obesidade Grau I (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 34.9 && imc < 39.9) {
        _statusText = "Obesidade Grau II (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 40) {
        _statusText = "Obesidade Grau III (${imc.toStringAsPrecision(4)})";
      }

      _addToDo();
    });
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
          title: Text("Calculadora de IMC"),
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
                DropdownButton(
                  hint: Text(
                    "Escolha um paciente",
                    style: TextStyle(
                      color: Colors.teal[400],
                      fontSize: 25.0
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.teal[400],
                    fontSize: 25.0
                  ),
                  items: _peopleItems,
                  value: _currentPeople,
                  onChanged: (selected) {
                    setState(() {
                      _currentPeople = selected;
                    });
                  },
                ),
                _inputTextGenerator(TextInputType.number, "Peso (Kg)", "peso", weightController),
                _inputTextGenerator(TextInputType.number, "Altura (cm)", "altura", heightController),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                      height: 50.0,
                      child: RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            calculate();
                          }
                        },
                        child: Text(
                          "Calcular",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0
                          ),
                        ),
                        color: Colors.teal[400],
                      )
                  ),
                ),
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.teal[400],
                      fontSize: 25.0
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }
}
