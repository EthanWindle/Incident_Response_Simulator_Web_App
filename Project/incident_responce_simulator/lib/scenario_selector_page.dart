import 'package:flutter/material.dart';
import 'choice_page.dart';
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
          const ScenarioSelectorPage(title: 'Incident Response Selector Page'),
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
  // Operating Variables
  List scenarios = [];
  String _selectedScenario = "not selected";
  final TextEditingController _scenarioController = TextEditingController();
  final TextEditingController _aurthoroController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isCollapsed = true;

  @override
  void initState() {
    super.initState();
    _scenarioController.addListener(() => setState(() {}));
    _aurthoroController.addListener(() => setState(() {}));
  }

  void _selecteScenario(String str) async {
    setState(() {
      _selectedScenario = str;
    });
  }

  void _comfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChoicePage(path: "Scenarios/$_selectedScenario/Scenario")),
    );
  }

  Stream<List<String>> scenariosStream() {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection('Scenarios');
    return scenariosCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id.contains(_scenarioController.text))
          .where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data["Author"].contains(_aurthoroController.text);
      }).map((doc) {
        return doc.id; // Assuming you want to return the document ID
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sizing Variables
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = screenHeight * 0.08;
    double responiveFontSize = screenWidth * 0.02;
    double titleFontSize = responiveFontSize > 20 ? responiveFontSize : 20;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize: titleFontSize,
              color: Theme.of(context).colorScheme.surface),
        ),
        toolbarHeight: appBarHeight,
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
                      "This is the 'Scenario Selection Page'.\n\n"
                      "In the middle of the screen there is a list of all the avaliable simulated scenarios for you to choose from."
                      "Each scenario is button you will need to click to select your choice. Your currently selected choice will display green. \n\n"
                      "If there is a particular scenario you want to choose you can use the form above to filter the list."
                      "The first field will filter the list to only display scenarios whose name contains the input."
                      "The second field will do the same but withe scenarios author's name.\n\n"
                      "Once you have selected ypu chosen scenario please click the 'comfim' to begin the simulation. \n\n",
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(90),
                  child: Column(
                    children: [
                      Flexible(
                        child: Form(
                          key: _formKey,
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                      const SizedBox(height: 16.0),
                      const Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MaterialButton(
                      onPressed: () {
                        _comfirm();
                      },
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      minWidth: screenWidth * 0.25,
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: screenWidth * 0.015),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
