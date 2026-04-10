enum UserRole {
  admin,
  manager,
  teamLeader,
  associate,
  associateTeamLead;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.teamLeader:
        return 'Team Leader';
      case UserRole.associate:
        return 'Associate';
      case UserRole.associateTeamLead:
        return 'Associate TL';
    }
  }

  String get dashboardTitle {
    switch (this) {
      case UserRole.admin:
        return 'Admin Dashboard';
      case UserRole.manager:
        return 'Manager Dashboard';
      case UserRole.teamLeader:
        return 'Team Leader Dashboard';
      case UserRole.associate:
      case UserRole.associateTeamLead:
        return 'My Dashboard';
    }
  }

  static UserRole fromBackendRoles(List<dynamic> roles) {
    if (roles.contains('ADMIN')) return UserRole.admin;
    if (roles.contains('MANAGER')) return UserRole.manager;
    if (roles.contains('TEAM_LEADER')) return UserRole.teamLeader;
    if (roles.contains('ASSOCIATE_TEAM_LEAD')) return UserRole.associateTeamLead;
    return UserRole.associate;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? password;
  final UserRole userRole;
  final int avatarIndex;
  final String phone;
  final String department;
  final List<String> roles;
  final List<String> permissions;
  final String? token;

  // Legacy: keep `role` as readable label for profile display
  String get role => userRole.label;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.userRole,
    required this.avatarIndex,
    required this.phone,
    required this.department,
    this.roles = const [],
    this.permissions = const [],
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesList = (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      userRole: json['role'] != null 
          ? UserRole.values.firstWhere((e) => e.name == json['role'], orElse: () => UserRole.associate)
          : UserRole.fromBackendRoles(rolesList),
      avatarIndex: json['avatarIndex'] ?? (json['id'] is int ? (json['id'] as int) % 8 : 0),
      phone: json['phone'] ?? '',
      department: json['department'] ?? 'General',
      roles: rolesList,
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': userRole.name,
      'avatarIndex': avatarIndex,
      'phone': phone,
      'department': department,
      'roles': roles,
      'permissions': permissions,
      'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? userRole,
    int? avatarIndex,
    String? phone,
    String? department,
    List<String>? roles,
    List<String>? permissions,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      userRole: userRole ?? this.userRole,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      token: token ?? this.token,
    );
  }
}
