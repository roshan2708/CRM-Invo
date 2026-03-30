import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final DateTime punchInTime;
  final DateTime? punchOutTime;
  final String punchInLocation;
  final String? punchOutLocation;
  final bool isOnBreak;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.punchInTime,
    this.punchOutTime,
    required this.punchInLocation,
    this.punchOutLocation,
    this.isOnBreak = false,
  });

  AttendanceModel copyWith({
    String? id,
    String? userId,
    DateTime? punchInTime,
    DateTime? punchOutTime,
    String? punchInLocation,
    String? punchOutLocation,
    bool? isOnBreak,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      punchInTime: punchInTime ?? this.punchInTime,
      punchOutTime: punchOutTime ?? this.punchOutTime,
      punchInLocation: punchInLocation ?? this.punchInLocation,
      punchOutLocation: punchOutLocation ?? this.punchOutLocation,
      isOnBreak: isOnBreak ?? this.isOnBreak,
    );
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
