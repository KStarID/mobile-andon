class Assessment {
  final int id;
  final String shift;
  final String sopNumber;
  final DateTime assessmentDate;
  final String? notes;
  final User user;
  final SubArea subArea;
  final Machine machine;
  final Model model;

  Assessment({
    required this.id,
    required this.shift,
    required this.sopNumber,
    required this.assessmentDate,
    this.notes,
    required this.user,
    required this.subArea,
    required this.machine,
    required this.model,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      shift: json['shift'],
      sopNumber: json['sop_number'],
      assessmentDate: DateTime.parse(json['assessmentDate']),
      notes: json['notes'],
      user: User.fromJson(json['user']),
      subArea: SubArea.fromJson(json['subArea']),
      machine: Machine.fromJson(json['machine']),
      model: Model.fromJson(json['model']),
    );
  }
}

class User {
  final String username;

  User({required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(username: json['username']);
  }
}

class SubArea {
  final int id;
  final String name;
  final Area area;

  SubArea({required this.id, required this.name, required this.area});

  factory SubArea.fromJson(Map<String, dynamic> json) {
    return SubArea(
      id: json['id'],
      name: json['name'],
      area: Area.fromJson(json['area']),
    );
  }
}

class Area {
  final int id;
  final String name;

  Area({required this.id, required this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Machine {
  final String id;
  final String name;
  final String status;

  Machine({required this.id, required this.name, required this.status});

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }
}

class Model {
  final int id;
  final String name;

  Model({required this.id, required this.name});

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      name: json['name'],
    );
  }
}