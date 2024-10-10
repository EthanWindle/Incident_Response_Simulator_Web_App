import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            primary: const Color.fromARGB(255, 1, 21, 151),
            surface: Colors.white),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: Outcome_Page(
        title: 'Incident Response selector Page',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    );
  }
}
