import 'assessment_model.dart';

class AndonCall {
  final int id;
  final String andonNumber;
  final String assignedTo;
  final String? shift;
  final DateTime startTime;
  final String? failureTime;
  final DateTime? responseTime;
  final double? totalRepairingTime;
  final double? totalResponseTime;
  final int? repairCount;
  final String currentStatus;
  final String? problem;
  final String? solution;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isDelayNotified;
  final SOP sop;
  final Area area;
  final SubArea subarea;
  final Model model;
  final PIC? pic;
  final User? leader;
  final List<StatusHistory> statusHistories;

  AndonCall({
    required this.id,
    required this.andonNumber,
    required this.assignedTo,
    this.shift,
    required this.startTime,
    this.failureTime,
    this.responseTime,
    this.totalRepairingTime,
    this.totalResponseTime,
    this.repairCount,
    required this.currentStatus,
    this.problem,
    this.solution,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.isDelayNotified,
    required this.sop,
    required this.area,
    required this.subarea,
    required this.model,
    this.pic,
    this.leader,
    required this.statusHistories,
  });

  factory AndonCall.fromJson(Map<String, dynamic> json) {
    return AndonCall(
      id: json['id'] ?? 0,
      andonNumber: json['andon_number'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
      failureTime: json['failure_time'],
      shift: json['shift'],
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      responseTime: json['response_time'] != null ? DateTime.tryParse(json['response_time']) : null,
      totalRepairingTime: json['total_repairing_time'] != null ? double.parse(json['total_repairing_time'].toString()) : null,
      totalResponseTime: json['total_response_time'] != null ? double.parse(json['total_response_time'].toString()) : null,
      repairCount: json['repair_count'],
      currentStatus: json['current_status'] ?? '',
      problem: json['problem'],
      solution: json['solution'],
      remarks: json['remarks'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isDelayNotified: json['is_delay_notified'],
      sop: json['sop'] != null ? SOP.fromJson(json['sop']) : SOP(id: null, name: ''),
      area: json['area'] != null ? Area.fromJson(json['area']) : Area(id: 0, name: ''),
      subarea: json['subarea'] != null ? SubArea.fromJson(json['subarea']) : SubArea(id: 0, name: '', area: Area(id: 0, name: '')),
      model: json['model'] != null ? Model.fromJson(json['model']) : Model(id: 0, name: ''),
      pic: json['pic'] != null ? PIC.fromJson(json['pic']) : null,
      leader: json['leader'] != null ? User.fromJson(json['leader']) : null,
      statusHistories: (json['status_histories'] as List<dynamic>?)
          ?.map((e) => StatusHistory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Leader {
  final int id;
  final String name;
  final String username;
  final String role;

  Leader({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
  });

  factory Leader.fromJson(Map<String, dynamic> json) {
    return Leader(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class StatusHistory {
  final int id;
  final int andonCallId;
  final String status;
  final DateTime changedAt;

  StatusHistory({
    required this.id,
    required this.andonCallId,
    required this.status,
    required this.changedAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'],
      andonCallId: json['andon_call_id'],
      status: json['status'],
      changedAt: DateTime.parse(json['changed_at']),
    );
  }
}

class PIC {
  final int id;
  final String username;
  final String name;
  final String role;

  PIC({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
  });

  factory PIC.fromJson(Map<String, dynamic> json) {
    return PIC(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      role: json['role'],
    );
  }
}
