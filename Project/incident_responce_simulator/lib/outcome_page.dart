import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class OutcomePage extends StatelessWidget {
  final String path;
  const OutcomePage({super.key, required this.path});

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
      home: Outcome_Page(
        title: 'Incident Response Outcome Page',
        path: path,
      ),
    );
  }
}

class Outcome_Page extends StatefulWidget {
  const Outcome_Page({super.key, required this.title, required this.path});

  final String title;
  final String path;

  @override
  State<Outcome_Page> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<Outcome_Page> {
  List _notesList = [];
  String _score = "";
  String _outcome = "";
  bool isCollapsed = true;

  @override
  void initState() {
    super.initState();
    _generateResultsList();
  }

  void _generateResultsList() async {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.path);
    DocumentSnapshot doc = await scenariosCollection.doc("Outcome").get();
    final data = doc.data() as Map<String, dynamic>;

    setState(() {
      _score = "${data['Score']}/100";
      _outcome = data['Text'];
      _notesList = data['Notes'];
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Sizing Variables
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double responsiveBarHeight = screenHeight * 0.1;
    double appBarHeight = responsiveBarHeight > 20 ? responsiveBarHeight : 20;
    double responiveFontSize = screenWidth * 0.03;
    double titleFontSize = responiveFontSize > 20 ? responiveFontSize : 20;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          },
          icon: Icon(
            Icons.home,
            size: titleFontSize * 0.75,
            color: const Color.fromARGB(255, 3, 10, 0),
          ),
          color: const Color.fromARGB(255, 3, 10, 0),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 245, 255),
        title: Text(widget.title,
            style: TextStyle(
                fontSize: titleFontSize,
                color: const Color.fromARGB(255, 2, 2, 2))),
        toolbarHeight: appBarHeight,
        shadowColor: const Color.fromARGB(245, 232, 225, 235),
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
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "This is the 'Outcome Page'.\n\n"
                      "At the top is the final outcome of the choice you made."
                      "In the center is the score you recieved for making the choices you did."
                      "At the bottom is a list the note tips and advice regarding your chosen paths and what may have been a better choice at points. \n\n",
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 240, 240, 240)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        textAlign: TextAlign.left,
                        'Final Outcome',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 33, 33),
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _outcome,
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 33, 33),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Flexible(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        textAlign: TextAlign.left,
                        'Score Received',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 33, 33),
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _score,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 33, 33, 33),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Flexible(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        textAlign: TextAlign.left,
                        'Notes and Feedback',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 33, 33),
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      height: 150,
                      child: Center(
                        child: _notesList.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _notesList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          _notesList[index],
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
