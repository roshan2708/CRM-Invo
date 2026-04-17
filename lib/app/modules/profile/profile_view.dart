import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../modules/leads/lead_controller.dart';
import '../../modules/activity/activity_controller.dart';
import '../../modules/theme_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final auth = Get.find<AuthController>();
    final themeCtrl = Get.find<ThemeController>();
    final leads = Get.find<LeadController>();
    final activities = Get.find<ActivityController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
          SizedBox(width: size.width * 0.02),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Avatar + info header
                Obx(() {
                  final user = auth.currentUser.value;
                  final initials = user.name
                      .split(' ')
                      .take(2)
                      .map((e) => e[0])
                      .join();
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.04,
                      horizontal: size.width * 0.06,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: size.width > 600 ? 120 : size.width * 0.25,
                          height: size.width > 600 ? 120 : size.width * 0.25,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            borderRadius: BorderRadius.circular(size.width > 600 ? 32 : size.width * 0.07),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: size.width > 600 ? 44 : size.width * 0.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(user.name, style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          user.role,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(user.email, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                }),
                // Stats row
                Obx(
                  () => Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    padding: EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                          value: leads.totalLeads.toString(),
                          label: 'Total Leads',
                        ),
                        _Divider(),
                        _StatItem(
                          value: leads.convertedLeads.toString(),
                          label: 'Converted',
                        ),
                        _Divider(),
                        _StatItem(
                          value: activities.pendingCount.toString(),
                          label: 'Pending',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),
                // Settings section
                _SectionTitle('Preferences', theme: theme, size: size),
                // Dark mode toggle
                Obx(
                  () => _SettingsTile(
                    icon: themeCtrl.isDarkMode.value
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: themeCtrl.isDarkMode.value ? 'On' : 'Off',
                    trailing: Switch(
                      value: themeCtrl.isDarkMode.value,
                      onChanged: (_) => themeCtrl.toggleTheme(),
                      activeThumbColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
                _SectionTitle('Account', theme: theme, size: size),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your information',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Keep your account secure',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Manage alerts & reminders',
                  onTap: () {},
                ),
                _SectionTitle('More', theme: theme, size: size),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App configuration',
                  onTap: () => Get.toNamed(AppRoutes.settings),
                ),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  subtitle: 'Sign out from your account',
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  onTap: () => _confirmLogout(context, auth),
                ),
                SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              auth.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final Size size;
  const _SectionTitle(this.title, {required this.theme, required this.size});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.04,
        size.width * 0.04,
        size.width * 0.04,
        size.width * 0.01,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          size.width * 0.04,
          0,
          size.width * 0.04,
          size.width * 0.02,
        ),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: titleColor,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.textTheme.bodySmall?.color,
                ),
          ],
        ),
      ),
    );
  }
}
