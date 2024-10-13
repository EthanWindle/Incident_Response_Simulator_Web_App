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
  final _filterKey = GlobalKey<FormState>();
  String _roomCode = '';
  String _password = '';
  String _selectedScenario = "not selected";
  final TextEditingController _scenarioController = TextEditingController();
  final TextEditingController _aurthoroController = TextEditingController();
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
    _scenarioController.addListener(() => setState(() {}));
    _aurthoroController.addListener(() => setState(() {}));
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
                const SizedBox(height: 10),
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
                      "This is the 'Host a room page'.\n\n"
                      "On the left you will see a list of all the currently available simulation scenarios."
                      "When one is clicked it will turn green to indicate that it is the scenario that will be simulated. \n\n"
                      "The input fields above the list will filter the list. The first field will filter the list to only display scenarios whose name contains the input."
                      "The second field will do the same but withe scenarios author's name.\n\n"
                      "The form on the right is used to set up the details of the room. This includes the room's name and if you want to add one password. \n\n"
                      "Once the form is filled out click 'Start Hosting' button to join the simulation at the current point. \n\n",
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
              padding: const EdgeInsets.all(40.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Form(
                            key: _filterKey,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Filters: ",
                                    style: TextStyle(
                                      fontSize: 30,
                                    )),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: TextFormField(
                                    controller: _scenarioController,
                                    decoration: const InputDecoration(
                                        labelText: 'By Scenario Name'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  child: TextFormField(
                                    controller: _aurthoroController,
                                    decoration: const InputDecoration(
                                        labelText: "By Author's Name"),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a namew';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Expanded(
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: MaterialButton(
                                      onPressed: () {
                                        _selecteScenario(scenarios[index]);
                                      },
                                      color:
                                          _selectedScenario == scenarios[index]
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 40.0),
                  Expanded(
                    flex: 2,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Enter Your Room Name'),
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
                                labelText:
                                    'Enter Tour Room Password (Optional)'),
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
