import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  String id;
  String password;
  String scenario;

  Room({required this.id, required this.password, required this.scenario});

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'password': password,
      'scenario': scenario,
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
}
