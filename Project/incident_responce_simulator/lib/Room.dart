import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Room {
  String id;
  String password;
  String scenario;
  List<double> votes = [0, 0, 0, 0];

  Room({required this.id, required this.password, required this.scenario});

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'password': password,
      'scenario': scenario,
      'votes': votes
    };
  }

  static Room fromMap(Map<String, dynamic> map, String id) {
    return Room(id: id, password: map['password'], scenario: map['reference']);
  }

  factory Room.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Room(
      id: data?['id'],
      password: data?['password'],
      scenario: data?['scenario'],
    );
  }

  String getPath() {
    return scenario;
  }

  String getID() {
    return id;
  }

  void setOptionCount(int count) {
    votes.clear();
    for (int i = 0; i < count; i++) {
      votes.add(0);
    }
  }

  void updateScenario(String option) {
    scenario = "$scenario/$option/Next";
  }
}
