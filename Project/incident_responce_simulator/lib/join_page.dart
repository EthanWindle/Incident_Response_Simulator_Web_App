import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'client_view_selector.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  String _roomCode = '';
  String _password = '';
  bool isCollapsed = true;
  final TextEditingController _controller = TextEditingController();

  Stream<List<Room>> getRoomsStream() {
    return FirebaseFirestore.instance
        .collection('Rooms')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Room.fromMap(doc.data(), doc.id))
          .where((room) => room.getID() != "Placeholder")
          .where((doc) => doc.getID().contains(_controller.text))
          .toList();
    });
  }

  Future<void> _submit() async {
    CollectionReference rooms = FirebaseFirestore.instance.collection('Rooms');
    DocumentSnapshot doc = await rooms.doc(_roomCode).get();
    final data = doc.data() as Map<String, dynamic>;

    // Wrong password popup can not connect
    if (_password != data['password']) {
      _showAlertDialog(
          context, 'Error', 'Incorrect password. Please try again.');
    } else {
      Room room =
          Room(id: _roomCode, password: _password, scenario: data["scenario"]);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClientViewPage(room: room)),
      );
    }
  }

  void _selectRoom(Room room) async {
    setState(() {
      _roomCode = room.toFirestore()["id"];
      _controller.text = room.toFirestore()["id"];
    });
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Voting Session'),
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
                      "This is the 'Join a room page'.\n\n"
                      "On the left you will see a list of all the currently active rooms. These are buttons you can click to fill in the form on the right.\n\n"
                      "The form on the right is to be filled with the relevant details regarding the room you want to join."
                      "As you type the name of the room the form the list will update to show what room sit could be. \n\n"
                      "Once the form is filled out click 'Join Simulation' button to join the simulation at the current point. \n\n",
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
              padding: const EdgeInsets.all(50.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const Text(
                          "List Of Active Rooms",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: StreamBuilder<List<Room>>(
                            stream: getRoomsStream(),
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
                                    child: Text('No rooms available.'));
                              }

                              List<Room> rooms = snapshot.data!;

                              return ListView.builder(
                                itemCount: rooms.length,
                                itemBuilder: (context, index) {
                                  Room room = rooms[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: MaterialButton(
                                      onPressed: () {
                                        _selectRoom(room);
                                      },
                                      color: _roomCode == room
                                          ? Colors.green
                                          : Colors.blue,
                                      textColor: Colors.white,
                                      child: Text(room.getID()),
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
                            controller: _controller,
                            decoration: const InputDecoration(
                                labelText: "Enter Your Room' Name"),
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
                                    "Enter Your Room's Password (If Applicable)"),
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
                            child: const Text('Join Simulation'),
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
