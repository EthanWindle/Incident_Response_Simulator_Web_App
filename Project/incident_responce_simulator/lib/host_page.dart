import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'Room.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final _formKey = GlobalKey<FormState>();
  String _roomCode = '';
  String _password = '';

  List<String> scenarios = [];
  String _selectedScenario = "not selected";

  Future<void> _submit() async {
    CollectionReference rooms = FirebaseFirestore.instance.collection('rooms');
    String roomId = rooms.doc().id;

    Room room = Room(id: roomId, name: _roomCode, password: _password);
    await rooms.doc(roomId).set(room.toMap());

    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const Host_View_Page(scenario: _selectedScenario)),
    );*/
  }

  void _scenariosList() async {
    final String response = await rootBundle.loadString('ScenariorsList.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      scenarios = data.cast<String>();
    });
  }

  void _selecteScenario(String str) async {
    setState(() {
      _selectedScenario = str;
    });
  }

  @override
  void initState() {
    super.initState();
    _scenariosList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host a Voting Session'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: scenarios.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
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
                    ),
            ),
            const SizedBox(width: 16.0), // Fixed the width since it's in a Row.
            Expanded(
              flex: 2,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Enter your Server Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _roomCode = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Enter your Server Password'),
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          _submit();
                        }
                      },
                      child: const Text('Start Hosting'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
