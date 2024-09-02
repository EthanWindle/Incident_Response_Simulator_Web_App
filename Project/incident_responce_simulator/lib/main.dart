import 'package:flutter/material.dart';
import 'choice_page.dart';
import 'scenario_selector_page.dart';

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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 1, 21, 151),
            primary: const Color.fromARGB(255, 1, 21, 151),
            surface: Colors.white),
        textTheme: const TextTheme(
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
  void _scenarioSelection(bool hosting) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const ScenarioSelector()), //add Hosting when choice page is set up
    );
  }

  void _joinPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScenarioSelector()),
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
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            MaterialButton(
              onPressed: () => _scenarioSelection(false),
              color: Theme.of(context).primaryColor,
              height: 140.0,
              minWidth: 100.0,
              child: const Text(
                'Run by Yourself',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () => _scenarioSelection(true),
              color: Theme.of(context).primaryColor,
              height: 140.0,
              minWidth: 100.0,
              child: const Text(
                'Host',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () => _joinPage(),
              color: Theme.of(context).primaryColor,
              height: 140.0,
              minWidth: 100.0,
              child: const Text(
                'Join',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
