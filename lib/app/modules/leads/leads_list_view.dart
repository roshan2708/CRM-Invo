import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/leads/lead_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_button.dart';
import '../../data/models/lead_model.dart';

class LeadsListView extends StatelessWidget {
  const LeadsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final ctrl = Get.find<LeadController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Leads',
        showBack: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: size.width * 0.03),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.04,
              size.width * 0.03,
              size.width * 0.04,
              0,
            ),
            child: TextField(
              onChanged: ctrl.setSearch,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search leads by name, email, company...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: Obx(
                  () => ctrl.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            ctrl.setSearch('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          SizedBox(height: size.width * 0.03),
          // Status filter chips
          SizedBox(
            height: 40,
            child: Obx(() {
              final statuses = [null, ...LeadStatus.values];
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                scrollDirection: Axis.horizontal,
                itemCount: statuses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final s = statuses[i];
                  final isSelected = ctrl.selectedStatus.value == s;
                  return GestureDetector(
                    onTap: () => ctrl.setStatusFilter(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                      child: Text(
                        s == null ? 'All' : s.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(height: size.width * 0.02),
          // Count badge
          Obx(
            () => Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Text(
                '${ctrl.filteredLeads.length} leads found',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          SizedBox(height: size.width * 0.01),
          // Leads list
          Expanded(
            child: Obx(() {
              if (ctrl.filteredLeads.isEmpty) {
                return EmptyStateWidget(
                  title: 'No Leads Found',
                  message: 'Try changing your filters or add a new lead.',
                  icon: Icons.people_outline_rounded,
                  action: CustomButton(
                    label: 'Add Lead',
                    icon: Icons.add_rounded,
                    width: size.width * 0.45,
                    onPressed: () => Get.toNamed(AppRoutes.addLead),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.only(bottom: size.height * 0.12),
                itemCount: ctrl.filteredLeads.length,
                itemBuilder: (ctx, i) {
                  final lead = ctrl.filteredLeads[i];
                  return Dismissible(
                    key: Key(lead.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: size.width * 0.06),
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.width * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: size.width * 0.03,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (_) async {
                      return await _confirmDelete(context, lead.name);
                    },
                    onDismissed: (_) {
                      ctrl.deleteLead(lead.id);
                      Get.snackbar(
                        'Deleted',
                        '${lead.name} has been removed.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: theme.cardColor,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: LeadCard(
                      lead: lead,
                      heroTag: 'list_${lead.id}',
                      onTap: () =>
                          Get.toNamed(AppRoutes.leadDetail, arguments: lead.id),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _LeadsBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addLead),
        tooltip: 'Add Lead',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lead'),
        content: Text('Remove "$name" from your leads?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LeadsBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
                route: AppRoutes.dashboard,
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Leads',
                route: AppRoutes.leads,
                active: true,
              ),
              _NavItem(
                icon: Icons.event_note_rounded,
                label: 'Activity',
                route: AppRoutes.activity,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                route: AppRoutes.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.textTheme.bodySmall?.color ?? Colors.grey;
    return GestureDetector(
      onTap: () {
        if (!active) Get.offNamed(route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
