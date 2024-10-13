import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';

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
            primary: const Color.fromARGB(255, 1, 21, 151),
            surface: Colors.white),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: HostOutcome_Page(
        title: 'Incident Response selector Page',
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(_outcome),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(_score),
                  ),
                  Expanded(
                    child: _notesList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _notesList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  _notesList[index],
                                ),
                              );
                            },
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
