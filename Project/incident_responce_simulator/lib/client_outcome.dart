import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';

class ClientOutcomePage extends StatelessWidget {
  final Room room;
  const ClientOutcomePage({super.key, required this.room});

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
      home: ClientOutcome_Page(
        title: 'Incident Response selector Page',
        room: room,
      ),
    );
  }
}

class ClientOutcome_Page extends StatefulWidget {
  const ClientOutcome_Page(
      {super.key, required this.title, required this.room});

  final String title;
  final Room room;

  @override
  State<ClientOutcome_Page> createState() => _ClientOutcomePageState();
}

class _ClientOutcomePageState extends State<ClientOutcome_Page> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
          Flexible(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Flexible(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 150,
                          child: Center(
                            child: _notesList.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ListView.builder(
                                    itemCount: _notesList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
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
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text(
                      "Leave Room",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
