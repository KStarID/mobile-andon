class Assessment {
  final int? id;
  final String shift;
  final SOP sop;
  final DateTime assessmentDate;
  final String? notes;
  final User user;
  final SubArea subArea;
  final Machine machine;
  final Model model;
  final String status;

  Assessment({
    this.id,
    required this.shift,
    required this.sop,
    required this.assessmentDate,
    this.notes,
    required this.user,
    required this.subArea,
    required this.machine,
    required this.model,
    required this.status,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      shift: json['shift'] ?? '',
      sop: SOP.fromJson(json['sop'] ?? {}),
      assessmentDate: DateTime.tryParse(json['assessment_date'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
      user: User.fromJson(json['user'] ?? {}),
      subArea: SubArea.fromJson(json['subArea'] ?? {}),
      machine: Machine.fromJson(json['machine'] ?? {}),
      model: Model.fromJson(json['model'] ?? {}),
      status: json['status'] ?? '',
    );
  }
}

// Tambahkan atau perbarui kelas User di sini
class User {
  final int id;
  final String username;
  final String name;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class SubArea {
  final int id;
  final String name;
  final Area area;

  SubArea({required this.id, required this.name, required this.area});

  factory SubArea.fromJson(Map<String, dynamic> json) {
    return SubArea(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      area: json['area'] != null ? Area.fromJson(json['area']) : Area(id: 0, name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area.toJson(),
    };
  }
}

class Area {
  final int id;
  final String name;

  Area({required this.id, required this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Machine {
  final String id;
  final String name;
  final String status;

  Machine({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'ok',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }
}

class SOP {
  final int? id;
  final String name;

  SOP({this.id, required this.name});

  factory SOP.fromJson(Map<String, dynamic> json) {
    return SOP(
      id: json['id'] != null ? (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString())) : null,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Model {
  final int id;
  final String name;
  final String? line;
  final bool? isActive;

  Model({
    required this.id,
    required this.name,
    this.line,
    this.isActive,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      line: json['line'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'line': line,
      'is_active': isActive,
    };
  }
}
