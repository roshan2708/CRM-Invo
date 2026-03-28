import 'package:get/get.dart';
import '../../data/dummy_data.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<UserModel> currentUser = DummyData.currentUser.obs;

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;

    final user = DummyData.authenticate(email, password);
    if (user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    // Signup creates a dummy sales-rep account
    currentUser.value = UserModel(
      id: 'u_new_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      password: password,
      userRole: UserRole.salesRep,
      avatarIndex: DateTime.now().millisecond % 8,
      phone: '',
      department: 'Sales',
    );
    isLoggedIn.value = true;
    return true;
  }

  void logout() {
    isLoggedIn.value = false;
    currentUser.value = DummyData.currentUser;
  }

  /// Role helpers
  bool get isAdmin => currentUser.value.userRole == UserRole.admin;
  bool get isManager => currentUser.value.userRole == UserRole.salesManager;
  bool get isSalesRep => currentUser.value.userRole == UserRole.salesRep;

  UserRole get role => currentUser.value.userRole;
}
