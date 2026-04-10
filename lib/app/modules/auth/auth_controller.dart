import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/dummy_data.dart';
import '../../data/models/user_model.dart';
import '../../data/providers/auth_provider.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<UserModel> currentUser = DummyData.currentUser.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user_data');

    if (token != null && userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        currentUser.value = UserModel.fromJson(userData).copyWith(token: token);
        isLoggedIn.value = true;
      } catch (e) {
        debugPrint('Error loading session: $e');
        logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    final trimmedEmail = email.trim();
    final isBypassUser = trimmedEmail == 'admin@test.com' && password == '123456';

    try {
      final response = await _authProvider.login(trimmedEmail, password);
      
      if (response.isOk && response.body != null) {
        final data = response.body;
        final user = UserModel.fromJson(data);
        final token = data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user_data', jsonEncode(user.toJson()));
          
          currentUser.value = user.copyWith(token: token);
          isLoggedIn.value = true;
          return true;
        }
      }

      // If API fails but it's the bypass user, allow local login
      if (isBypassUser) {
        debugPrint('Bypassing API for test user...');
        final user = DummyData.users.first; // admin@crm.com in dummy, will update to test email
        final bypassUser = user.copyWith(
          email: 'admin@test.com',
          name: 'Admin Bypass',
          roles: ['ADMIN'],
          permissions: ['MANAGE_USERS'],
          token: 'bypass_token',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'bypass_token');
        await prefs.setString('user_data', jsonEncode(bypassUser.toJson()));

        currentUser.value = bypassUser;
        isLoggedIn.value = true;
        return true;
      }
      
      Get.snackbar(
        'Login Failed',
        response.body?['message'] ?? 'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      if (isBypassUser) {
        debugPrint('Network error. Bypassing API for test user...');
        final user = DummyData.users.first;
        final bypassUser = user.copyWith(
          email: 'admin@test.com',
          name: 'Admin Bypass (Offline)',
          roles: ['ADMIN'],
          permissions: ['MANAGE_USERS'],
          token: 'bypass_token',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'bypass_token');
        await prefs.setString('user_data', jsonEncode(bypassUser.toJson()));
        currentUser.value = bypassUser;
        isLoggedIn.value = true;
        return true;
      }
      Get.snackbar('Error', 'An unexpected error occurred: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    // Note: Backend documentation doesn't show a signup endpoint yet.
    // Keeping this as dummy or showing a message.
    Get.snackbar('Info', 'Signup not implemented in backend yet.');
    return false;
  }

  Future<bool> loginDemo(UserRole role) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate delay
    
    final roleStr = role.name;
    final user = UserModel(
      id: "999",
      email: 'demo_${roleStr.toLowerCase()}@lms.com',
      name: 'Demo ${role.label}',
      userRole: role,
      roles: [roleStr.toUpperCase()],
      permissions: ['ALL'],
      avatarIndex: 0,
      phone: '0000000000',
      department: 'Sales',
      token: 'demo-token-${DateTime.now().millisecondsSinceEpoch}',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token!);
    await prefs.setString('user_data', jsonEncode(user.toJson()));

    currentUser.value = user;
    isLoggedIn.value = true;
    isLoading.value = false;
    return true;
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    
    isLoggedIn.value = false;
    currentUser.value = DummyData.currentUser;
  }

  /// Role helpers
  bool get isAdmin => currentUser.value.userRole == UserRole.admin;
  bool get isManager => currentUser.value.userRole == UserRole.manager;
  bool get isTeamLeader => currentUser.value.userRole == UserRole.teamLeader;
  bool get isAssociate => currentUser.value.userRole == UserRole.associate || currentUser.value.userRole == UserRole.associateTeamLead;

  UserRole get role => currentUser.value.userRole;
}
