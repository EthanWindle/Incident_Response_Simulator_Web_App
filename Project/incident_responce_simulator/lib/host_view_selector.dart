import 'package:flutter/material.dart';
import 'host_outcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';

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
            primary: const Color.fromARGB(255, 1, 21, 151),
            surface: Colors.white),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: HostView_Page(
        title: 'Incident Response selector Page',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _situation.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Text(_situation),
                      ),
                      Expanded(
                        child: Column(
                          children: [
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
                                              color: Colors.blue[50],
                                              border: Border.all(
                                                color: Colors.blue,
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
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors
                                                        .blue, // Text color
                                                  ),
                                                  textAlign: TextAlign
                                                      .center, // Align text to the center
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
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  widget.room.getShowVote()
                                      ? _comfirm()
                                      : DisplayVotes();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ), // Pass the method as a callback
                              child: Text(widget.room.getShowVote()
                                  ? 'Confirm'
                                  : 'Show Votes'),
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
                      color: Colors.blueAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                          return Text(totalVotes.toString());
                        }
                        return const Text("Cant see votes.");
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
