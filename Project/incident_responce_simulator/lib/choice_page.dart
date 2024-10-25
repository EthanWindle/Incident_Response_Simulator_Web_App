import 'package:flutter/material.dart';
import 'outcome_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

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
      home: Choice_Page(
        title: 'Incident Response Choice Page',
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
  bool isCollapsed = true;

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

  Stream<List<String>> optionsStream() {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.path);

    return scenariosCollection.snapshots().map((snapshot) {
      return snapshot.docs.where((doc) => doc.id != "Situation").map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null && data.containsKey('Option')
            ? data['Option'] as String
            : "";
      }).toList();
    });
  }

  // This widget is the root of your application.
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
              Icons.home,
              size: titleFontSize * 0.75,
              color: const Color.fromARGB(255, 2, 2, 2),
            ),
            color: const Color.fromARGB(255, 2, 2, 2)),
        backgroundColor: const Color.fromARGB(255, 252, 245, 255),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: titleFontSize,
            color: const Color.fromARGB(255, 2, 2, 2),
          ),
        ),
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
                IconButton(
                  icon: Icon(isCollapsed
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios),
                  color: const Color.fromARGB(255, 235, 254, 245),
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
                      "This is the 'Choice Page'.\n\n"
                      "On the left is the current situation you are facing."
                      "On the right is a list the possible choices you can make. \n\n"
                      "Click the choice you want to make to select it, the selected choice will be displayed as green."
                      "Once you know the choice you have selected is the one you want to make push the 'Confirm' button to advance to the next stage of the simulation.\n\n",
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _situation.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  child: const Text(
                                    "The Current Situation",
                                    style: const TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  child: Text(
                                    _situation,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            child: const Text(
                              "Options:",
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<String>>(
                            stream: optionsStream(), // Stream for options
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                List<String> options = snapshot.data!;

                                return ListView.builder(
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: MaterialButton(
                                        onPressed: () {
                                          _selecteOption("Option${index + 1}",
                                              optionContinues[index]);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: _selectedOption ==
                                                    "Option${index + 1}"
                                                ? Colors.green[50]
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                            border: Border.all(
                                              color: _selectedOption ==
                                                      "Option${index + 1}"
                                                  ? Colors.green
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            options[index],
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: _selectedOption ==
                                                      "Option${index + 1}"
                                                  ? const Color.fromARGB(
                                                      255, 17, 10, 27)
                                                  : const Color.fromARGB(
                                                      255, 238, 245, 228),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const Text('No data');
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: MaterialButton(
                            onPressed: () {
                              _comfirm();
                            },
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minWidth: screenWidth * 0.25,
                            color: Theme.of(context).colorScheme.secondary,
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontSize: screenWidth * 0.015),
                            ),
                          ),
                        ),
                      ],
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
