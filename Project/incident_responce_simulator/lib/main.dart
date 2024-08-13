import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'scenarioSelectorPage.dart';
=======
import 'scenario_selector_page.dart';
>>>>>>> 6a6cfa6e7edb5cff29e4d2f95803da967fd8a6ca

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      home: const MyHomePage(title: 'Incident Response Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedScenario = "not selected";

  void _selecteScenario(String str) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _selectedScenario = str;
    });
  }

  void _comfirm(){
     Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScenarioSelector()),
            );
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
