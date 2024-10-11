import 'package:flutter/material.dart';
import 'client_outcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Room.dart';

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
            primary: const Color.fromARGB(255, 1, 21, 151),
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
  List optionContinues = [];
  bool _isEndChoice = false;

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
                            return Text(snapshot.data!);
                          }
                          return const Text("Situation failed to load.");
                        })),
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
                                            style: const TextStyle(
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

                                                      return widget.room
                                                              .getShowVote()
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
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ), // Pass the method as a callback
                        child: Text('Vote'),
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
