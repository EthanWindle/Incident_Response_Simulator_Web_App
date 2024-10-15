import 'package:flutter/material.dart';
import 'host_outcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';
import 'main.dart';

class HostViewPage extends StatelessWidget {
  final Room room;
  const HostViewPage({super.key, required this.room});

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
      home: HostView_Page(
        title: 'Incident Response Hosts Choice Page',
        room: room,
      ),
    );
  }
}

class HostView_Page extends StatefulWidget {
  const HostView_Page({super.key, required this.title, required this.room});

  final String title;
  final Room room;

  @override
  State<HostView_Page> createState() => _HostViewPageState();
}

class _HostViewPageState extends State<HostView_Page> {
  List options = [];
  List optionContinues = [];
  bool _isEndChoice = false;
  String _situation = "";
  bool isCollapsed = true;

  @override
  void initState() {
    super.initState();
    _updateRoom();
    _setSituation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSituation();
    _updateRoom();
  }

  @override
  void didUpdateWidget(covariant HostView_Page oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room != widget.room) {
      _setSituation();
    }
    _setSituation();
    _updateRoom();
  }

  void DisplayVotes() async {
    setState(() {
      widget.room.updateShowVote(true);
    });
    CollectionReference rooms = FirebaseFirestore.instance.collection("Rooms");
    await rooms.doc(widget.room.getID()).update({"showVotes": true});
  }

  Future<void> _updatePath() async {
    CollectionReference optionList =
        FirebaseFirestore.instance.collection(widget.room.getPath());
    CollectionReference roomsList =
        FirebaseFirestore.instance.collection("Rooms");

    DocumentSnapshot room = await roomsList.doc(widget.room.getID()).get();
    var roomData = room.data() as Map<String, dynamic>;
    Map<String, double> votes = roomData["votes"];
    double topVoted = 0;
    int topIndex = 0;
    for (int i = 0; i < votes.length; i++) {
      if (votes["$i"]! > topVoted) {
        topIndex = i;
        topVoted = votes["$i"]!;
      }
    }

    DocumentSnapshot option =
        await optionList.doc("Option${topIndex + 1}").get();
    var optionData = option.data() as Map<String, dynamic>;
    setState(() {
      _isEndChoice = optionData["End"];
      String option = "Option${topIndex + 1}";
      widget.room.updateScenario("${widget.room.getPath()}/$option/Next");
    });

    setState(() {
      widget.room.updateShowVote(false);
    });
  }

  void _comfirm() async {
    await _updatePath();
    await _updateRoom();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _isEndChoice
              ? HostOutcomePage(room: widget.room)
              : HostViewPage(room: widget.room),
        )).then((value) {
      _setSituation();
      _updateRoom();
    });
  }

  void _setSituation() async {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.room.getPath());
    DocumentSnapshot doc = await scenariosCollection.doc("Situation").get();
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _situation = data["Text"];
    });
  }

  Future<void> _updateRoom() async {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.room.getPath());
    QuerySnapshot qs = await scenariosCollection
        .where(FieldPath.documentId, isNotEqualTo: "Situation")
        .get();
    int count = qs.docs.length;
    widget.room.setOptionCount(count);
    CollectionReference rooms = FirebaseFirestore.instance.collection("Rooms");
    await rooms.doc(widget.room.getID()).update(widget.room.toFirestore());
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
              color: Color.fromARGB(255, 3, 10, 0),
              size: titleFontSize * 0.75,
            ),
            color: Color.fromARGB(255, 3, 10, 0)),
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
                      "This is the 'Host's View of the Choice Page'.\n\n"
                      "On the left is the current situation you are facing."
                      "On the right is a list the possible choices the participants can vote for. \n\n"
                      "In the top right corner a number is display to indicate how many votes have come through so far. \n\n"
                      "A 'Show Votes button below the list of options can be clicked to close the viting and display what percentage of votes each option got as a bar underneth each one.\n\n"
                      "Once you have concluded the voting, the 'Show Votes' button will transform into a 'Continue' button."
                      "Click this button to move the entire simulation onto the next stage. \n\n",
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
                        child: _situation.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
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
                                    child: Text(
                                      _situation,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
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
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              border: Border.all(
                                                color: Theme.of(context)
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
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                      fontSize: 18),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 10.0),
                                                StreamBuilder<double>(
                                                  stream: getVoteCount(index),
                                                  builder:
                                                      (context, voteSnapshot) {
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
                                                        stream: getTotalVotes(),
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
                                                            double totalVotes =
                                                                totalVoteSnapshot
                                                                    .data!;
                                                            double progress =
                                                                totalVotes != 0
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
                              child: MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    widget.room.getShowVote()
                                        ? _comfirm()
                                        : DisplayVotes();
                                  });
                                },
                                color: Theme.of(context).colorScheme.secondary,
                                minWidth: screenWidth * 0.25,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  widget.room.getShowVote()
                                      ? 'Continue'
                                      : 'Show Votes',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.surface,
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
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: StreamBuilder<double>(
                      stream: getTotalVotes(),
                      builder: (context, totalVoteSnapshot) {
                        if (totalVoteSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show progress while loading
                        } else if (totalVoteSnapshot.hasError) {
                          return Text('Error: ${totalVoteSnapshot.error}');
                        } else if (totalVoteSnapshot.hasData) {
                          double totalVotes = totalVoteSnapshot.data!;
                          return Text(
                            totalVotes.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: screenWidth * 0.01,
                            ),
                          );
                        }
                        return Text(
                          "Cant see votes.",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: screenWidth * 0.015),
                        );
                      },
                    ),
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
