class Room {
  String id;
  String name;
  String password;

  Room({required this.id, required this.name, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
    };
  }

  static Room fromMap(Map<String, dynamic> map, String id) {
    return Room(id: id, name: map['name'], password: map['password']);
  }
}
