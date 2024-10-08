import 'package:flutter/material.dart';
import 'outcome_page.dart';
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
  String _selectedOption = "not selected";
  bool _isEndChoice = false;
  String _situation = "";
  bool _showVotes = false;

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
      /* Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _isEndChoice
                ? OutcomePage(path: "${widget.path}/$_selectedOption/Next")
                : HostViewPage(path: "${widget.path}/$_selectedOption/Next"),
          ));*/
    }
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

  void _setOptions() async {
    CollectionReference scenariosCollection =
        FirebaseFirestore.instance.collection(widget.room.getPath());

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
      body: Padding(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
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
                                        stream: getVoteCount(
                                            index), // Stream for vote count
                                        builder: (context, voteSnapshot) {
                                          if (voteSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator(); // Show progress while loading
                                          } else if (voteSnapshot.hasError) {
                                            return Text(
                                                'Error: ${voteSnapshot.error}');
                                          } else if (voteSnapshot.hasData) {
                                            double voteCount =
                                                voteSnapshot.data!;

                                            return StreamBuilder<double>(
                                              stream:
                                                  getTotalVotes(), // Stream for total votes
                                              builder:
                                                  (context, totalVoteSnapshot) {
                                                if (totalVoteSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator(); // Show progress while loading
                                                } else if (totalVoteSnapshot
                                                    .hasError) {
                                                  return Text(
                                                      'Error: ${totalVoteSnapshot.error}');
                                                } else if (totalVoteSnapshot
                                                    .hasData) {
                                                  double totalVotes =
                                                      totalVoteSnapshot.data!;
                                                  double progress =
                                                      totalVotes != 0
                                                          ? voteCount /
                                                              totalVotes
                                                          : 0.0;

                                                  return LinearProgressIndicator(
                                                    value: progress,
                                                  );
                                                } else {
                                                  return const Text('No data');
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
                      _comfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ), // Pass the method as a callback
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
