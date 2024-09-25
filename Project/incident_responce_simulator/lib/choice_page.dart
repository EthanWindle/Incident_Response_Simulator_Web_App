import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'outcome_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChoicePage extends StatelessWidget {
  final String path;
  const ChoicePage({super.key, required this.path});

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
      home: Choice_Page(
        title: 'Incident Response selector Page',
        path: path,
      ),
    );
  }
}

class Choice_Page extends StatefulWidget {
  const Choice_Page({super.key, required this.title, required this.path});

  final String title;
  final String path;

  @override
  State<Choice_Page> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<Choice_Page> {
  List options = [];
  List optionContinues = [];
  String _selectedOption = "not selected";
  bool _isEndChoice = false;
  String _situation = "";

  @override
  void initState() {
    super.initState();
    _setSituation();
    _setOptions();
  }

  void _selecteOption(String str, bool end) async {
    setState(() {
      _selectedOption = str;
      _isEndChoice = end;
    });
  }

  void _comfirm() {
    if (_selectedOption == "not selected") {
      (BuildContext context) => AlertDialog(
            title: const Text('AlertDialog Title'),
            content: const Text('AlertDialog description'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _isEndChoice
                ? OutcomePage(path: "${widget.path}/$_selectedOption/Next")
                : ChoicePage(path: "${widget.path}/$_selectedOption/Next"),
          ));
    }
  }

  void _setSituation() async {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.path);
    DocumentSnapshot doc = await scenariosCollection.doc("Situation").get();
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _situation = data["Text"];
    });
  }

  void _setOptions() async {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.path);

    scenariosCollection
        .where('Option', isNotEqualTo: 'Situation')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        options.add(data['Option']);
        optionContinues.add(data['End']);
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
              child: _situation.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Text(_situation),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MaterialButton(
                      onPressed: () {
                        _selecteOption(
                            "Option${index + 1}", optionContinues[index]);
                      },
                      color: _selectedOption == "Option${index + 1}"
                          ? Colors.green
                          : Colors.blue,
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(options[index]),
                    ),
                  );
                },
              ),
            ),
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
