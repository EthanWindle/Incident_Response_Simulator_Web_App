import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'host_view_selector.dart';
import 'main.dart';

class HostPage extends StatelessWidget {
  const HostPage({super.key});

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
      home: const Host_Page(title: "Host's Room Creation Page"),
    );
  }
}

class Host_Page extends StatefulWidget {
  const Host_Page({super.key, required this.title});
  final String title;

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<Host_Page> {
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
            width: isCollapsed ? 70 : 250,
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
                                const Text("Filters: ",
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
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                      textColor: Colors.white,
                                      height: screenHeight * 0.05,
                                      child: Text(
                                        scenarios[index],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
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
                              'Start Hosting',
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
