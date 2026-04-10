import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/leads/leads_list_view.dart';
import '../../modules/calls/call_history_view.dart';
import '../../modules/activity/activity_view.dart';
import '../../modules/profile/profile_view.dart';
import 'main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await controller.onWillPop();
        if (shouldPop) {
          // If we're on the first tab and want to exit, we can't just return true in onPopInvoked
          // We must manually trigger the system to close the app if we really want to.
          // But usually specifically returning true/false in PopScope is enough if we use the right logic.
          // For now, if shouldPop is true, it means we let it close.
          Get.back(); // Standard way in Get to close the current screen/app if at root.
        }
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              DashboardView(),
              LeadsListView(),
              CallHistoryView(),
              ActivityView(),
              ProfileView(),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => Container(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      index: 0,
                      active: controller.currentIndex.value == 0,
                      onTap: () => controller.changePage(0),
                    ),
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      label: 'Leads',
                      index: 1,
                      active: controller.currentIndex.value == 1,
                      onTap: () => controller.changePage(1),
                    ),
                    _NavItem(
                      icon: Icons.call_rounded,
                      label: 'Calls',
                      index: 2,
                      active: controller.currentIndex.value == 2,
                      onTap: () => controller.changePage(2),
                    ),
                    _NavItem(
                      icon: Icons.event_note_rounded,
                      label: 'Activity',
                      index: 3,
                      active: controller.currentIndex.value == 3,
                      onTap: () => controller.changePage(3),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      index: 4,
                      active: controller.currentIndex.value == 4,
                      onTap: () => controller.changePage(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
