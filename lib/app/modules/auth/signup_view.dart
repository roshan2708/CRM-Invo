import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final AuthController _auth = Get.find();

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _auth.signup(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (success) {
      Get.snackbar(
        'Account Created!',
        'Welcome to CRM Pro, ${_nameCtrl.text.trim()}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Get.offNamed(AppRoutes.dashboard);
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
                  SizedBox(height: size.height * 0.04),
                  // Back
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('Create Account', style: theme.textTheme.displaySmall),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Join CRM Pro and manage your pipeline',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Name is required' : null,
                  ),
                  SizedBox(height: size.height * 0.025),
                  CustomTextField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Email is required';
                      final regex = RegExp(
                        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                      );
                      if (!regex.hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.025),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Minimum 6 characters',
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.025),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPassCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _signup(),
                    validator: (v) {
                      if (v != _passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.04),
                  Obx(
                    () => CustomButton(
                      label: 'Create Account',
                      onPressed: _signup,
                      isLoading: _auth.isLoading.value,
                    ),
                  ),
                  SizedBox(height: size.height * 0.025),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Text(
                                'Sign In',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
