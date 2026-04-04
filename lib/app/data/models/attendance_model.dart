import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final DateTime punchInTime;
  final DateTime? punchOutTime;
  final String punchInLocation;
  final String? punchOutLocation;
  final double? latitude;
  final double? longitude;
  final bool isOnBreak;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.punchInTime,
    this.punchOutTime,
    required this.punchInLocation,
    this.punchOutLocation,
    this.latitude,
    this.longitude,
    this.isOnBreak = false,
  });

  AttendanceModel copyWith({
    String? id,
    String? userId,
    DateTime? punchInTime,
    DateTime? punchOutTime,
    String? punchInLocation,
    String? punchOutLocation,
    double? latitude,
    double? longitude,
    bool? isOnBreak,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      punchInTime: punchInTime ?? this.punchInTime,
      punchOutTime: punchOutTime ?? this.punchOutTime,
      punchInLocation: punchInLocation ?? this.punchInLocation,
      punchOutLocation: punchOutLocation ?? this.punchOutLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnBreak: isOnBreak ?? this.isOnBreak,
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      punchInTime: json['punchInTime'] != null
          ? DateTime.parse(json['punchInTime'])
          : DateTime.now(),
      punchOutTime: json['punchOutTime'] != null
          ? DateTime.parse(json['punchOutTime'])
          : null,
      punchInLocation: json['punchInLocation'] ?? '',
      punchOutLocation: json['punchOutLocation'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isOnBreak: json['isOnBreak'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'punchInTime': punchInTime.toIso8601String(),
      'punchOutTime': punchOutTime?.toIso8601String(),
      'punchInLocation': punchInLocation,
      'punchOutLocation': punchOutLocation,
      'latitude': latitude,
      'longitude': longitude,
      'isOnBreak': isOnBreak,
    };
  }

  bool get isPunchedOut => punchOutTime != null;

  String get punchInFormatted {
    return DateFormat('hh:mm a').format(punchInTime);
  }

  String get punchOutFormatted {
    if (punchOutTime == null) return '--:--';
    return DateFormat('hh:mm a').format(punchOutTime!);
  }

  String get durationFormatted {
    if (punchOutTime == null) return 'In Progress';
    final diff = punchOutTime!.difference(punchInTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
