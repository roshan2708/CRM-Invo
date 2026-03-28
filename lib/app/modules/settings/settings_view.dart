import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.02),
            _SectionLabel('General', size: size, theme: theme),
            _Tile(
              icon: Icons.language_rounded,
              title: 'Language',
              value: 'English',
              theme: theme,
              size: size,
            ),
            _Tile(
              icon: Icons.currency_rupee_rounded,
              title: 'Currency',
              value: 'INR ()',
              theme: theme,
              size: size,
            ),
            _Tile(
              icon: Icons.date_range_rounded,
              title: 'Date Format',
              value: 'DD MMM YYYY',
              theme: theme,
              size: size,
            ),
            _SectionLabel('Notifications', size: size, theme: theme),
            _SwitchTile(
              icon: Icons.notifications_active_rounded,
              title: 'Push Notifications',
              subtitle: 'Activity reminders and alerts',
              value: true,
              theme: theme,
              size: size,
            ),
            _SwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Digest',
              subtitle: 'Weekly leads summary',
              value: false,
              theme: theme,
              size: size,
            ),
            _SectionLabel('Privacy & Security', size: size, theme: theme),
            _Tile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              theme: theme,
              size: size,
            ),
            _Tile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              theme: theme,
              size: size,
            ),
            _Tile(
              icon: Icons.security_rounded,
              title: 'Two-Factor Authentication',
              value: 'Disabled',
              theme: theme,
              size: size,
            ),
            _SectionLabel('About', size: size, theme: theme),
            _Tile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              value: '1.0.0',
              theme: theme,
              size: size,
              showArrow: false,
            ),
            _Tile(
              icon: Icons.star_outline_rounded,
              title: 'Rate the App',
              theme: theme,
              size: size,
            ),
            _Tile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Send Feedback',
              theme: theme,
              size: size,
            ),
            SizedBox(height: size.width * 0.04),
            // Logout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: GestureDetector(
                onTap: () => _confirmLogout(context, auth),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Log Out',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.06),
            Center(
              child: Text(
                'CRM Pro v1.0.0    Made with ',
                style: theme.textTheme.labelSmall,
              ),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  final Size size;
  final ThemeData theme;
  const _SectionLabel(this.text, {required this.size, required this.theme});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.04,
        size.width * 0.03,
        size.width * 0.04,
        size.width * 0.015,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final ThemeData theme;
  final Size size;
  final bool showArrow;
  const _Tile({
    required this.icon,
    required this.title,
    this.value,
    required this.theme,
    required this.size,
    this.showArrow = true,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.04,
        0,
        size.width * 0.04,
        size.width * 0.02,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.width * 0.035,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          SizedBox(width: size.width * 0.03),
          Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ],
      ),
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ThemeData theme;
  final Size size;
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.theme,
    required this.size,
  });
  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _val;
  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        widget.size.width * 0.04,
        0,
        widget.size.width * 0.04,
        widget.size.width * 0.02,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.size.width * 0.04,
        vertical: widget.size.width * 0.03,
      ),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: widget.theme.colorScheme.primary),
          SizedBox(width: widget.size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: widget.theme.textTheme.titleMedium),
                Text(widget.subtitle, style: widget.theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: _val,
            onChanged: (v) => setState(() => _val = v),
            activeThumbColor: widget.theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
