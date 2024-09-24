import 'package:flutter/material.dart';
import 'choice_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home:
          const ScenarioSelectorPage(title: 'Incident Response selector Page'),
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
  List scenarios = [];
  String _selectedScenario = "not selected";

  @override
  void initState() {
    super.initState();
  }

  void _selecteScenario(String str) async {
    setState(() {
      _selectedScenario = str;
    });
    print(str);
    print(_selectedScenario);
  }

  void _comfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChoicePage(path: "Scenarios/$_selectedScenario")),
    );
  }

  Stream<List<String>> scenariosStream() {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection('Scenarios');
    return scenariosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.id; // Assuming you want to return the document ID
      }).toList();
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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<String>>(
                stream:
                    scenariosStream(), // Stream fetching scenarios from Firestore
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No scenarios available.'));
                  }

                  // Scenarios list from Firestore
                  List<String> scenarios = snapshot.data!;

                  return ListView.builder(
                    itemCount: scenarios.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MaterialButton(
                          onPressed: () {
                            _selecteScenario(scenarios[index]);
                          },
                          color: _selectedScenario == scenarios[index]
                              ? Colors.green
                              : Colors.blue,
                          textColor: Colors.white,
                          child: Text(scenarios[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _comfirm();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ), // Pass the method as a callback
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
