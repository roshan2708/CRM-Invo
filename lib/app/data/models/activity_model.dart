enum ActivityType {
  call,
  email,
  meeting,
  followUp,
  demo,
  other;

  String get label {
    switch (this) {
      case ActivityType.call:
        return 'Call';
      case ActivityType.email:
        return 'Email';
      case ActivityType.meeting:
        return 'Meeting';
      case ActivityType.followUp:
        return 'Follow-up';
      case ActivityType.demo:
        return 'Demo';
      case ActivityType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.call:
        return '';
      case ActivityType.email:
        return '';
      case ActivityType.meeting:
        return '';
      case ActivityType.followUp:
        return '';
      case ActivityType.demo:
        return '';
      case ActivityType.other:
        return '';
    }
  }
}

class ActivityModel {
  final String id;
  final String leadId;
  String leadName;
  ActivityType type;
  String description;
  DateTime dateTime;
  bool isDone;

  ActivityModel({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.type,
    required this.description,
    required this.dateTime,
    this.isDone = false,
  });

  ActivityModel copyWith({
    String? id,
    String? leadId,
    String? leadName,
    ActivityType? type,
    String? description,
    DateTime? dateTime,
    bool? isDone,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      type: type ?? this.type,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isDone: isDone ?? this.isDone,
    );
  }
}
