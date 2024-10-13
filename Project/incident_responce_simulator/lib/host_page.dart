import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'host_view_selector.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final _formKey = GlobalKey<FormState>();
  String _roomCode = '';
  String _password = '';
  String _selectedScenario = "not selected";
  bool isCollapsed = true;

  Future<void> _submit() async {
    CollectionReference rooms = FirebaseFirestore.instance.collection('Rooms');

    Room room = Room(
        id: _roomCode,
        password: _password,
        scenario: "Scenarios/$_selectedScenario/Scenario");
    rooms.doc(_roomCode).set(room.toFirestore());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HostViewPage(room: room)),
    );
  }

  Stream<List<String>> scenariosStream() {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection('Scenarios');
    return scenariosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.id;
      }).toList();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host a Voting Session'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                    child: StreamBuilder<List<String>>(
                      stream:
                          scenariosStream(), // Stream fetching scenarios from Firestore
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No scenarios available.'));
                        }

                        // Scenarios list from Firestore
                        List<String> scenarios = snapshot.data!;

                        return ListView.builder(
                          itemCount: scenarios.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                  const SizedBox(width: 16.0),
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
          ),
        ],
      ),
    );
  }
}
