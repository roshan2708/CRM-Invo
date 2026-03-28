import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
      Get.offNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar(
        'Login Failed',
        'Invalid credentials. Use one of the roles below.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    width: size.width * 0.14,
                    height: size.width * 0.14,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(size.width * 0.04),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      size: size.width * 0.07,
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
                  SizedBox(height: size.height * 0.035),
                  // Role credentials table
                  Container(
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.vpn_key_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Demo Credentials',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.width * 0.03),
                        _CredRow(
                          role: 'Admin',
                          email: 'admin@crm.com',
                          pass: 'admin123',
                          onTap: () {
                            _emailCtrl.text = 'admin@crm.com';
                            _passCtrl.text = 'admin123';
                          },
                        ),
                        _CredRow(
                          role: 'Manager',
                          email: 'manager@crm.com',
                          pass: 'manager123',
                          onTap: () {
                            _emailCtrl.text = 'manager@crm.com';
                            _passCtrl.text = 'manager123';
                          },
                        ),
                        _CredRow(
                          role: 'Sales Rep',
                          email: 'rep@crm.com',
                          pass: 'rep123',
                          borderBottom: false,
                          onTap: () {
                            _emailCtrl.text = 'rep@crm.com';
                            _passCtrl.text = 'rep123';
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
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
                  SizedBox(height: size.height * 0.025),
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
    );
  }
}

class _CredRow extends StatelessWidget {
  final String role;
  final String email;
  final String pass;
  final VoidCallback onTap;
  final bool borderBottom;

  const _CredRow({
    required this.role,
    required this.email,
    required this.pass,
    required this.onTap,
    this.borderBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.width * 0.025),
        decoration: BoxDecoration(
          border: borderBottom
              ? Border(bottom: BorderSide(color: theme.dividerColor))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    '$email    $pass',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Use',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
