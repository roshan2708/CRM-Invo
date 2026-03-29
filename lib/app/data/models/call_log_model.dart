/// Tag applied to a call after it ends.
enum CallTag {
  none,
  interested,
  followUp,
  notInterested;

  String get label {
    switch (this) {
      case CallTag.none:
        return 'None';
      case CallTag.interested:
        return 'Interested';
      case CallTag.followUp:
        return 'Follow-up';
      case CallTag.notInterested:
        return 'Not Interested';
    }
  }
}

/// Type of call from the CRM user's perspective.
enum CallType {
  outgoing,
  missed,
  failed;

  String get label {
    switch (this) {
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
      case CallType.failed:
        return 'Failed';
    }
  }
}

class CallLogModel {
  final String id;
  final String userId;
  final String clientId;
  final String clientName;
  final String phone;
  final CallType callType;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds; // total duration
  final String? recordingPath; // null if recording not available
  String notes;
  CallTag tag;

  CallLogModel({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.clientName,
    required this.phone,
    required this.callType,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.recordingPath,
    this.notes = '',
    this.tag = CallTag.none,
  });

  /// Formatted duration string e.g. "2m 34s"
  String get formattedDuration {
    if (durationSeconds == 0) return '0s';
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  CallLogModel copyWith({
    String? notes,
    CallTag? tag,
    String? recordingPath,
  }) {
    return CallLogModel(
      id: id,
      userId: userId,
      clientId: clientId,
      clientName: clientName,
      phone: phone,
      callType: callType,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      recordingPath: recordingPath ?? this.recordingPath,
      notes: notes ?? this.notes,
      tag: tag ?? this.tag,
    );
  }
}
