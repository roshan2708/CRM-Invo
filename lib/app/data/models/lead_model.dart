// Lead status enum
enum LeadStatus {
  newLead,
  contacted,
  interested,
  converted,
  lost;

  String get label {
    switch (this) {
      case LeadStatus.newLead:
        return 'New';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.interested:
        return 'Interested';
      case LeadStatus.converted:
        return 'Converted';
      case LeadStatus.lost:
        return 'Lost';
    }
  }

  static LeadStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'contacted':
        return LeadStatus.contacted;
      case 'interested':
        return LeadStatus.interested;
      case 'converted':
        return LeadStatus.converted;
      case 'lost':
        return LeadStatus.lost;
      default:
        return LeadStatus.newLead;
    }
  }
}

class LeadModel {
  final String id;
  String name;
  String phone;
  String email;
  LeadStatus status;
  String notes;
  DateTime date;
  int avatarIndex;
  String? company;
  String? source;
  final double? revenue;
  final int connectedCallsCount;
  /// The scheduled follow-up / meeting date — drives the calendar view.
  final DateTime? followUpDate;

  LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.notes,
    required this.date,
    required this.avatarIndex,
    this.company,
    this.source,
    this.revenue = 0.0,
    this.connectedCallsCount = 0,
    this.followUpDate,
  });

  LeadModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    LeadStatus? status,
    String? notes,
    DateTime? date,
    int? avatarIndex,
    String? company,
    String? source,
    double? revenue,
    int? connectedCallsCount,
    DateTime? followUpDate,
  }) {
    return LeadModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      company: company ?? this.company,
      source: source ?? this.source,
      revenue: revenue ?? this.revenue,
      connectedCallsCount: connectedCallsCount ?? this.connectedCallsCount,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: LeadStatus.fromString(json['status'] ?? 'newLead'),
      notes: json['notes'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      avatarIndex: json['avatarIndex'] ?? 0,
      company: json['company'],
      source: json['source'],
      revenue: (json['revenue'] ?? 0).toDouble(),
      connectedCallsCount: json['connectedCallsCount'] ?? 0,
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status.label.toUpperCase().replaceAll(' ', '_'),
      'notes': notes,
      'date': date.toIso8601String(),
      'avatarIndex': avatarIndex,
      'company': company,
      'source': source,
      'revenue': revenue,
      'connectedCallsCount': connectedCallsCount,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }
}
