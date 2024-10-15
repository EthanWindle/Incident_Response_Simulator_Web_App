import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'main.dart';

class HostOutcomePage extends StatelessWidget {
  final Room room;
  const HostOutcomePage({super.key, required this.room});

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
      home: HostOutcome_Page(
        title: 'Incident Response Outcome Page',
        room: room,
      ),
    );
  }
}

class HostOutcome_Page extends StatefulWidget {
  const HostOutcome_Page({super.key, required this.title, required this.room});

  final String title;
  final Room room;

  @override
  State<HostOutcome_Page> createState() => _HostOutcomePageState();
}

class _HostOutcomePageState extends State<HostOutcome_Page> {
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
        FirebaseFirestore.instance.collection(widget.room.getPath());
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
            color: const Color.fromARGB(255, 25, 23, 51),
          ),
          color: const Color.fromARGB(255, 25, 23, 51),
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
                      "At the top is the final outcome of the choice your team made."
                      "In the center is the score you recieved for making the choices your team did."
                      "At the bottom is a list the note tips and advice regarding your team's chosen path and what may have been a better choice at points. \n\n"
                      "In the bottom right corner lies a 'Close Room' button to push and close the room once your team have finished going over the feedback. \n\n",
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
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Flexible(
                      child: Container(
                        alignment: Alignment.center,
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
                        alignment: Alignment.center,
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
                        alignment: Alignment.center,
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
              Positioned(
                bottom: 20,
                right: 20,
                child: MaterialButton(
                  onPressed: () => {},
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  minWidth: screenWidth * 0.25,
                  child: Text(
                    "Close Room",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: screenWidth * 0.015,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
