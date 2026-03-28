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
    );
  }
}
