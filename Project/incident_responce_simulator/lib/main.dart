import 'package:flutter/material.dart';
import 'host_page.dart';
import 'scenario_selector_page.dart';
import 'join_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            primary: const Color.fromARGB(255, 31, 86, 140),
            secondary: const Color.fromARGB(
              255,
              56,
              111,
              166,
            ),
            tertiary: const Color.fromARGB(255, 93, 152, 194),
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
  bool isCollapsed = true;
  void _scenarioSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScenarioSelector()),
    );
  }

  void _hostPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HostPage()),
    );
  }

  void _joinPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sizing Variables
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = screenHeight * 0.08;
    double fontSize = screenWidth * 0.02;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 252, 245, 255),
        title: Text(widget.title,
            style: TextStyle(
                fontSize: fontSize, color: Color.fromARGB(255, 2, 2, 2))),
        toolbarHeight: appBarHeight,
        shadowColor: Color.fromARGB(245, 242, 235, 245),
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed
                ? 70
                : 250, // Width changes based on collapsed state
            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(isCollapsed
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                ),
                if (!isCollapsed) ...[
                  const SizedBox(height: 20),
                  Text(
                    "EXPLAIN THE PAGE",
                    style: TextStyle(color: Color.fromARGB(255, 240, 240, 240)),
                  )
                ],
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Flexible(
            child: Container(
              color: Color.fromARGB(255, 59, 74, 138),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MaterialButton(
                        onPressed: () => _scenarioSelection(),
                        color: Theme.of(context).colorScheme.primary,
                        height: 140.0,
                        minWidth: screenWidth * 0.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          'Run By Yourself',
                          style: TextStyle(
                            fontSize: 50.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MaterialButton(
                        onPressed: () => _hostPage(),
                        color: Theme.of(context).colorScheme.secondary,
                        height: 140.0,
                        minWidth: screenWidth * 0.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          'Host A Room',
                          style: TextStyle(
                            fontSize: 50.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MaterialButton(
                        onPressed: () => _joinPage(),
                        color: Theme.of(context).colorScheme.tertiary,
                        height: 140.0,
                        minWidth: screenWidth * 0.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          'Join A Room',
                          style: TextStyle(
                            fontSize: 50.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
