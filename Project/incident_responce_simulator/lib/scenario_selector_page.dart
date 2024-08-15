import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'main.dart';
import 'choice_page.dart';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(const ScenarioSelector());
}

class ScenarioSelector extends StatelessWidget {
  const ScenarioSelector({super.key});
 
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
      home: const ScenarioSelectorPage(title: 'Incident Response selector Page'),
    );
  }

}

class ScenarioSelectorPage extends StatefulWidget {
  const ScenarioSelectorPage({super.key, required this.title});

  final String title;

  @override
  State<ScenarioSelectorPage> createState() => _ScenarioSelectorState();
}

class _ScenarioSelectorState extends State<ScenarioSelectorPage> {
  List scenarios = [];
  String _selectedScenario = "not selected";
  
  @override
  void initState() {
    super.initState();
    _scenariosList();
  }

  void _selecteScenario(String str) async {
    setState(() {
      _selectedScenario = str;
    });
    print(str);
    print(_selectedScenario);
  }

  void _comfirm(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChoicePage(path: "Scenarios/$_selectedScenario")),
    );
  }

  void _scenariosList() async {
    final String response = await rootBundle.loadString('ScenariorsList.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      scenarios = data.cast<String>();
    });
    print("print all scenarios $scenarios[0]");
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
              child: scenarios.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: scenarios.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MaterialButton(
                          onPressed: () {
                            _selecteScenario(scenarios[index]);
                          },
                          color: _selectedScenario == scenarios[index] ? Colors.green : Colors.blue,
                          textColor: Colors.white,
                          child: Text(scenarios[index]),
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