import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

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
    _generateNotesList();
  }

  void _comfirm() {}

  void _generateNotesList() async {
    final String response =
        await rootBundle.loadString('${widget.path}/outcome.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      _score = data["Score"];
      _outcome = data['Outcome'];

      for (var note in data['Notes']) {
        // `button` is now a Map<String, String>
        // Add the option to the list
        _notesList.add(note["Note"]);
      }
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
              child: Text(_score),
            ),
            Expanded(
              flex: 2,
              child: Text(_outcome),
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
