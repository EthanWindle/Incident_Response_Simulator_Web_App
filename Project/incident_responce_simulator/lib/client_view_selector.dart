import 'package:flutter/material.dart';
import 'client_outcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'main.dart';

class ClientViewPage extends StatelessWidget {
  final Room room;
  const ClientViewPage({super.key, required this.room});

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
      home: ClientView_Page(
        title: 'Incident Response selector Page',
        room: room,
      ),
    );
  }
}

class ClientView_Page extends StatefulWidget {
  const ClientView_Page({super.key, required this.title, required this.room});

  final String title;
  final Room room;

  @override
  State<ClientView_Page> createState() => _ClientViewPageState();
}

class _ClientViewPageState extends State<ClientView_Page> {
  List options = [];
  bool _isEndChoice = false;
  int currentVote = -1;
  int newVote = -1;
  bool isCollapsed = true;

  @override
  void initState() {
    super.initState();
    listenToRoom();
  }

  void _comfirm() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _isEndChoice
              ? ClientOutcomePage(room: widget.room)
              : ClientViewPage(room: widget.room),
        ));
  }

  void updateVote() async {
    if (newVote == -1 || newVote == currentVote) {
      return;
    }
    DocumentReference room =
        FirebaseFirestore.instance.collection("Rooms").doc(widget.room.getID());

    if (currentVote != -1) {
      await room.update({"votes.$currentVote": FieldValue.increment(-1)});
    }
    await room.update({"votes.$newVote": FieldValue.increment(1)});
    setState(() {
      currentVote = newVote;
    });
  }

  void listenToRoom() {
    DocumentReference room =
        FirebaseFirestore.instance.collection("Rooms").doc(widget.room.getID());

    room.snapshots().listen((snapahot) {
      var data = snapahot.data() as Map<String, dynamic>;
      String currentPath = data["scenario"];
      setState(() {
        if (currentPath != widget.room.getPath()) {
          widget.room.updateScenario(currentPath);
          CollectionReference scenario =
              FirebaseFirestore.instance.collection(currentPath);
          scenario.doc("Outcome").get().then((docSnapshot) {
            if (docSnapshot.exists) {
              setState(() {
                _isEndChoice = true;
              });
            }
            ;
          });
          _comfirm();
        }
        if (widget.room.getShowVote() != data["showVotes"]) {
          setState(() {
            widget.room.updateShowVote(data["showVotes"]);
          });
        }
      });
    });
  }

  Stream<String> _situationStream() {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.room.getPath());
    return scenariosCollection.snapshots().map((snapshot) {
      var situation = snapshot.docs.firstWhere((doc) => doc.id == "Situation");
      final data = situation.data() as Map<String, dynamic>;
      return data["Text"];
    });
  }

  Stream<List<String>> optionsStream() {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.room.getPath());

    return scenariosCollection.snapshots().map((snapshot) {
      return snapshot.docs.where((doc) => doc.id != "Situation").map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null && data.containsKey('Option')
            ? data['Option'] as String
            : "";
      }).toList();
    });
  }

  // Return vote values
  Stream<double> getVoteCount(int index) {
    CollectionReference rooms = FirebaseFirestore.instance.collection('Rooms');
    DocumentReference doc = rooms.doc(widget.room.getID());
    return doc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        Map<String, double>? map = data["votes"];

        if (map != null && index < map.length) {
          return (map["$index"] as num).toDouble();
        }
      }
      return 0.0;
    });
  }

  Stream<double> getTotalVotes() {
    CollectionReference rooms = FirebaseFirestore.instance.collection('Rooms');
    DocumentReference doc = rooms.doc(widget.room.getID());

    return doc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        Map<String, double>? map = data["votes"];

        double count = 0;
        if (map != null) {
          map.forEach((key, value) {
            if (value is num) {
              count += value.toDouble(); // Safely add votes
            }
          });
        }
        return count;
      }
      return 0.0;
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
            color: const Color.fromARGB(255, 3, 10, 0),
          ),
          color: const Color.fromARGB(255, 3, 10, 0),
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
                      "This is the 'Participants' View of the Choice Page'.\n\n"
                      "On the left is the current situation you are facing."
                      "On the right is a list the possible choices you can vote for. \n\n"
                      "Click the choice you want to vote for to select it, the selected choice will be displayed as green."
                      "Once you know the choice you have selected is the one you want to make push the 'Vote' to submit it.\n\n"
                      "After you have voted the option you voted for will be outlined in green."
                      "If you want to change your vote before the stage ends you can by following the same steps as when you initally voted.\n\n"
                      "Once the voting has concluded, bars will show up under each option display what percentage of votes it got. \n\n",
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
                  padding: const EdgeInsets.all(50.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        // display situation
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "The Current Situation",
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: StreamBuilder<String>(
                                stream: _situationStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData &&
                                      snapshot.data!.isNotEmpty) {
                                    return Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    );
                                  }
                                  return const Text(
                                      "Situation failed to load.");
                                },
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
                            Container(
                              child: const Text(
                                "Options:",
                                style: TextStyle(
                                  fontSize: 30,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                newVote = index;
                                              });
                                            },
                                            padding: const EdgeInsets.all(16),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: newVote == index
                                                    ? Colors.green[50]
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .tertiary,
                                                border: Border.all(
                                                  color: currentVote == index
                                                      ? Colors.green
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    options[index],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: newVote == index
                                                            ? Color.fromARGB(
                                                                255, 24, 36, 32)
                                                            : Color.fromARGB(
                                                                255,
                                                                231,
                                                                219,
                                                                223)),
                                                    textAlign: TextAlign
                                                        .center, // Align text to the center
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  // Vote split bars
                                                  StreamBuilder<double>(
                                                    stream: getVoteCount(index),
                                                    builder: (context,
                                                        voteSnapshot) {
                                                      if (voteSnapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const CircularProgressIndicator(); // Show progress while loading
                                                      } else if (voteSnapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${voteSnapshot.error}');
                                                      } else if (voteSnapshot
                                                          .hasData) {
                                                        double voteCount =
                                                            voteSnapshot.data!;

                                                        return StreamBuilder<
                                                            double>(
                                                          stream:
                                                              getTotalVotes(), // Stream for total votes
                                                          builder: (context,
                                                              totalVoteSnapshot) {
                                                            if (totalVoteSnapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const CircularProgressIndicator(); // Show progress while loading
                                                            } else if (totalVoteSnapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${totalVoteSnapshot.error}');
                                                            } else if (totalVoteSnapshot
                                                                .hasData) {
                                                              double
                                                                  totalVotes =
                                                                  totalVoteSnapshot
                                                                      .data!;
                                                              double progress =
                                                                  totalVotes !=
                                                                          0
                                                                      ? voteCount /
                                                                          totalVotes
                                                                      : 0.0;

                                                              return widget.room
                                                                      .getShowVote()
                                                                  ? LinearProgressIndicator(
                                                                      value:
                                                                          progress,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink();
                                                            } else {
                                                              return const Text(
                                                                  'No data');
                                                            }
                                                          },
                                                        );
                                                      } else {
                                                        return const Text(
                                                            'No data');
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return const Text('No options available');
                                  }
                                },
                              ),
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  updateVote();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ), // Pass the method as a callback
                                child: Text(
                                    currentVote == -1 ? 'Vote' : "Update Vote"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
