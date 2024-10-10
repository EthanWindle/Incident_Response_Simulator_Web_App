import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'Room.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  String _roomCode = '';
  String _password = '';

  List<String> scenarios = [];
  final String _selectedRoom = "not selected";

  final TextEditingController _controller = TextEditingController();

  Stream<List<Room>> getRoomsStream() {
    return FirebaseFirestore.instance
        .collection('Rooms')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Room.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> _submit() async {
    CollectionReference rooms = FirebaseFirestore.instance.collection('Rooms');
    DocumentSnapshot doc = await rooms.doc(_roomCode).get();
    final data = doc.data() as Map<String, dynamic>;

    // cant connect
    if (_password != data['password']) {
      _showAlertDialog(
          context, 'Error', 'Incorrect password. Please try again.');
    } else {}

    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const Join_View_Page(scenario: _selectedScenario)),
    );*/
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Voting Session'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: StreamBuilder<List<Room>>(
                stream: getRoomsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No rooms available.'));
                  }

                  List<Room> rooms = snapshot.data!;

                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      Room room = rooms[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MaterialButton(
                          onPressed: () {
                            _selectRoom(room);
                          },
                          color: _selectedRoom == room
                              ? Colors.green
                              : Colors.blue,
                          textColor: Colors.white,
                          child: Text(room.id),
                        ),
                      );
                    },
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
                      controller: _controller,
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
                      child: const Text('Join Simulation'),
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
