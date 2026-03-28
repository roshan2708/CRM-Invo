enum UserRole {
  admin,
  salesManager,
  salesRep;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.salesManager:
        return 'Sales Manager';
      case UserRole.salesRep:
        return 'Sales Rep';
    }
  }

  String get dashboardTitle {
    switch (this) {
      case UserRole.admin:
        return 'Admin Dashboard';
      case UserRole.salesManager:
        return 'Manager Dashboard';
      case UserRole.salesRep:
        return 'My Dashboard';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole userRole;
  final int avatarIndex;
  final String phone;
  final String department;

  // Legacy: keep `role` as readable label for profile display
  String get role => userRole.label;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userRole,
    required this.avatarIndex,
    required this.phone,
    required this.department,
  });
}
