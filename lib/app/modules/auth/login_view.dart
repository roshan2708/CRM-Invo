import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../data/models/user_model.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthController _auth = Get.find();

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(val.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (success) {
      if (_auth.isAdmin) {
        Get.offNamed(AppRoutes.adminDashboard);
      } else if (_auth.isManager) {
        Get.offNamed(AppRoutes.managerDashboard);
      } else if (_auth.isTeamLeader) {
        Get.offNamed(AppRoutes.tlDashboard);
      } else {
        Get.offNamed(AppRoutes.associateDashboard);
      }
    } else {
      Get.snackbar(
        'Login Failed',
        'Invalid credentials. Use demo access below.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _loginDemo(UserRole role) async {
    final success = await _auth.loginDemo(role);
    if (success) {
      if (_auth.isAdmin) {
        Get.offNamed(AppRoutes.adminDashboard);
      } else if (_auth.isManager) {
        Get.offNamed(AppRoutes.managerDashboard);
      } else if (_auth.isTeamLeader) {
        Get.offNamed(AppRoutes.tlDashboard);
      } else {
        Get.offNamed(AppRoutes.associateDashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.06),
                      // Logo
                      Container(
                        width: size.width > 600 ? 64 : size.width * 0.14,
                        height: size.width > 600 ? 64 : size.width * 0.14,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(size.width > 600 ? 16 : size.width * 0.04),
                        ),
                        child: Icon(
                          Icons.people_alt_rounded,
                          size: size.width > 600 ? 32 : size.width * 0.07,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text('Welcome back', style: theme.textTheme.displaySmall),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Sign in with your role credentials',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
    
                      // Fields
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        controller: _emailCtrl,
                        validator: _validateEmail,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: size.height * 0.025),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passCtrl,
                        validator: _validatePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot password?',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Obx(
                        () => CustomButton(
                          label: 'Sign In',
                          onPressed: _login,
                          isLoading: _auth.isLoading.value,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'DEMO ACCESS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor)),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      
                      // Demo Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _DemoButton(
                              label: 'Admin',
                              icon: Icons.security_rounded,
                              color: const Color(0xFF6366F1),
                              onTap: () => _loginDemo(UserRole.admin),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: _DemoButton(
                              label: 'Manager',
                              icon: Icons.manage_accounts_rounded,
                              color: const Color(0xFF22D3EE),
                              onTap: () => _loginDemo(UserRole.manager),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.width > 600 ? 12 : size.width * 0.02),
                      Row(
                        children: [
                          Expanded(
                            child: _DemoButton(
                              label: 'Team Lead',
                              icon: Icons.groups_rounded,
                              color: const Color(0xFF10B981),
                              onTap: () => _loginDemo(UserRole.teamLeader),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: _DemoButton(
                              label: 'Associate',
                              icon: Icons.person_rounded,
                              color: const Color(0xFFF59E0B),
                              onTap: () => _loginDemo(UserRole.associate),
                            ),
                          ),
                        ],
                      ),
    
                      SizedBox(height: size.height * 0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.signup),
                            child: Text(
                              'Sign Up',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DemoButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
