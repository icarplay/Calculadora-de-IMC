import 'package:flutter/material.dart';
import 'package:calculadora_imc/home_page.dart';
import 'package:calculadora_imc/add_page.dart';
import 'package:calculadora_imc/people_page.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int currentTabIndex = 1;

  List<Widget> tabs = [
    PeoplePage(),
    HomePage(),
    AddPeoplePage()
  ];

  Map<String, dynamic> _toDoList;
  Map<String, dynamic> _modelToDoList = { 'People' : [], 'IMC': [] };  

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
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
      if (await file.exists()) {
        return file.readAsString();
      } else {
        file.writeAsString(json.encode(_modelToDoList));
        return file.readAsString();
      }
    } catch(e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: tabs[currentTabIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTapped,
          currentIndex: currentTabIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text("Pessoas")
            ),            
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text("Home")
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              title: Text("Adicionar")
            )
          ],
        ),
      );
  }
}
