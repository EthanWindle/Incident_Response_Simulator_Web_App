import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(const ChoicePage());
}

class ChoicePage extends StatelessWidget {
  const ChoicePage({super.key});
 
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
      home: const ChoicePagePage(title: 'Incident Response selector Page'),
    );
  }

}

class ChoicePagePage extends StatefulWidget {
  const ChoicePagePage({super.key, required this.title});

  final String title;

  @override
  State<ChoicePagePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePagePage> {
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
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  void _optionsList() async {
    final String response = await rootBundle.loadString('currentSituation.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      _situation = data['Situation'];
      options = data['Options'].map<String>((option) {
        return option.values.first; // Extract the value from the option map
      }).toList();
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
                            _selecteOption(options[index]);
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