import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';


class ChoicePage extends StatelessWidget {
  final String path;
  ChoicePage({super.key, required this.path});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Response',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 21, 151), 
        primary: Color.fromARGB(255, 1, 21, 151),
        surface: Colors.white),
        textTheme: TextTheme(
          displayLarge: TextStyle(
          color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: Choice_Page(title: 'Incident Response selector Page', path: path,),
    );
  }

}

class Choice_Page extends StatefulWidget {
  Choice_Page({super.key, required this.title, required this.path});

  final String title;
  final String path;

  @override
  State<Choice_Page> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<Choice_Page> {
  List options = [];
  String _selectedOption = "not selected";
  String _situation = "";

  @override
  void initState() {
    super.initState();
    _optionsList();
  }

  void _selecteOption(String str) async {
    setState(() {
      _selectedOption = str;
    });
  }

  void _comfirm(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChoicePage(path: "${widget.path}/$_selectedOption")),
    );
  }

  void _optionsList() async {
    final String response = await rootBundle.loadString('currentSituation.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      _situation = data['Situation'];
      options = data['Options'];
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: options.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MaterialButton(
                          onPressed: () {
                            _selecteOption("Option$index");
                          },
                          color: _selectedOption == options[index] ? Colors.green : Colors.blue,
                          textColor: Colors.white,
                          child: Text(options[index]),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      );
                    },
                  ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _comfirm();
              }, // Pass the method as a callback
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}