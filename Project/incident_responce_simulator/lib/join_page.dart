import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'client_view_selector.dart';
import 'main.dart';

class JoinPage extends StatelessWidget {
  const JoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Response',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 1, 21, 151),
            primary: const Color.fromARGB(255, 31, 86, 140),
            secondary: const Color.fromARGB(
              255,
              56,
              111,
              166,
            ),
            tertiary: const Color.fromARGB(255, 93, 152, 194),
            surface: Colors.white),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: const Join_Page(
        title: 'Incident Response Join a Room Page',
      ),
    );
  }
}

class Join_Page extends StatefulWidget {
  const Join_Page({super.key, required this.title});
  final String title;
  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<Join_Page> {
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
    // Sizing Variables
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double responsiveBarHeight = screenHeight * 0.1;
    double appBarHeight = responsiveBarHeight > 20 ? responsiveBarHeight : 20;
    double responiveFontSize = screenWidth * 0.03;
    double titleFontSize = responiveFontSize > 20 ? responiveFontSize : 20;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            size: titleFontSize * 0.75,
            color: const Color.fromARGB(255, 25, 23, 51),
          ),
          color: const Color.fromARGB(255, 25, 23, 51),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 245, 255),
        title: Text(widget.title,
            style: TextStyle(
                fontSize: titleFontSize,
                color: const Color.fromARGB(255, 2, 2, 2))),
        toolbarHeight: appBarHeight,
        shadowColor: const Color.fromARGB(245, 232, 225, 235),
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
                  icon: Icon(
                    isCollapsed
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios,
                    color: const Color.fromARGB(255, 44, 43, 43),
                  ),
                  color: const Color.fromARGB(255, 44, 43, 43),
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

                              return Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        height: screenHeight * 0.05,
                                        color: _roomCode == room.getID()
                                            ? Colors.green
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        child: Text(
                                          room.getID(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40.0),
                  Flexible(
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
                          MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();
                                _submit();
                              }
                            },
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                            minWidth: screenWidth * 0.25,
                            child: Text(
                              'Join Simulation',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontSize: screenWidth * 0.015),
                            ),
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
