class Assessment {
  final int no;
  final String updatedTime;
  final String area;
  final String subArea;
  final String sopNumber;
  final String model;
  final String machineCodeAsset;
  final String machineName;
  final String status;
  final String details;

  Assessment({
    required this.no,
    required this.updatedTime,
    required this.area,
    required this.subArea,
    required this.sopNumber,
    required this.model,
    required this.machineCodeAsset,
    required this.machineName,
    required this.status,
    required this.details,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        no: json['id'],
        updatedTime: json['updatedTime'],
        area: json['area'],
        subArea: json['subArea'],
        sopNumber: json['sopNumber'],
        model: json['model'],
        machineCodeAsset: json['machineCodeAsset'],
        machineName: json['machineName'],
        status: json['status'],
        details: json['details'],
      );

  Map<String, dynamic> toJson() => {
        'number': no,
        'updatedTime': updatedTime,
        'area': area,
        'subArea': subArea,
        'sopNumber': sopNumber,
        'model': model,
        'machineCodeAsset': machineCodeAsset,
        'machineName': machineName,
        'status': status,
        'details': details,
      };
}
