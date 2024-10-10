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
  bool _showVotes = false;

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

  void _updatePath() async {
    CollectionReference optionList =
        FirebaseFirestore.instance.collection(widget.room.getPath());
    CollectionReference roomsList =
        FirebaseFirestore.instance.collection("Rooms");

    DocumentSnapshot room = await roomsList.doc(widget.room.getID()).get();
    var roomData = room.data() as Map<String, dynamic>;
    List<int> votes = roomData["votes"];
    int topVoted = 0;
    int topIndex = 0;
    for (int i = 0; i < votes.length; i++) {
      if (votes[i] > topVoted) {
        topIndex = i;
        topVoted = votes[i];
      }
    }

    DocumentSnapshot option =
        await optionList.doc("Option${topIndex + 1}").get();
    var optionData = option.data() as Map<String, dynamic>;
    setState(() {
      _isEndChoice = optionData["End"];
      widget.room.updateScenario("Option${topIndex + 1}");
    });
  }

  void _comfirm() async {
    _updatePath();
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
        FirebaseFirestore.instance.collection('${widget.room.getPath()}');

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
        var list = data["votes"] as List<dynamic>?;

        if (list != null && index < list.length) {
          return (list[index] is double) ? list[index] : 0.0;
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
        var list = data["votes"] as List<dynamic>?;

        double count = 0;
        if (list != null) {
          for (var vote in list) {
            if (vote is double || vote is int) {
              count += vote.toDouble();
            }
          }
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                                        color: Colors.blue[
                                            50], // Background color of the box
                                        border: Border.all(
                                          color: Colors.blue, // Border color
                                          width: 2, // Border width
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            10), // Rounded corners
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            options[index],
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue, // Text color
                                            ),
                                            textAlign: TextAlign
                                                .center, // Align text to the center
                                          ),
                                          const SizedBox(height: 10.0),
                                          StreamBuilder<double>(
                                            stream: getVoteCount(index),
                                            builder: (context, voteSnapshot) {
                                              if (voteSnapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator(); // Show progress while loading
                                              } else if (voteSnapshot
                                                  .hasError) {
                                                return Text(
                                                    'Error: ${voteSnapshot.error}');
                                              } else if (voteSnapshot.hasData) {
                                                double voteCount =
                                                    voteSnapshot.data!;

                                                return StreamBuilder<double>(
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
                                                      double totalVotes =
                                                          totalVoteSnapshot
                                                              .data!;
                                                      double progress =
                                                          totalVotes != 0
                                                              ? voteCount /
                                                                  totalVotes
                                                              : 0.0;

                                                      return _showVotes
                                                          ? LinearProgressIndicator(
                                                              value: progress,
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
                                                return const Text('No data');
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
                            _showVotes ? _comfirm() : _showVotes = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ), // Pass the method as a callback
                        child: Text(_showVotes ? 'Confirm' : 'Show Votes'),
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
                    offset: Offset(2, 2),
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
    );
  }
}
