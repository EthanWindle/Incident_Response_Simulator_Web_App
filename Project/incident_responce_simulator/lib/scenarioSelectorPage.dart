import 'package:flutter/material.dart';
import 'dart:io';
import 'main.dart';

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
  String _selectedScenario = "not selected";

  void _selecteScenario(String str) async {
    final myDir = Directory('dir');
    var isThere = await myDir.exists();
    setState(() {
      _selectedScenario = isThere ? 'exists' : 'nonexistent';
    });
  }

  void _comfirm(){
     Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title,
        style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _selectedScenario,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        /*onPressed: () => _selecteScenario("111"),
        tooltip: 'set selection',
        child: const Icon(Icons.add),
      ),

      comfirmButton: FloatingActionButton(*/
        onPressed: () => _comfirm(),
        tooltip: 'set selection',
        child: const Icon(Icons.add),
      ),
    );
  }
}
