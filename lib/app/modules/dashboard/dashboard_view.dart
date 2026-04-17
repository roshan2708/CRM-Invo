import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../modules/leads/lead_controller.dart';
import '../../modules/activity/activity_controller.dart';
import '../../modules/auth/auth_controller.dart';
import '../../modules/calls/call_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/lead_card.dart';
import '../attendance/widgets/attendance_card.dart';
import '../../data/models/user_model.dart';
import '../../data/models/lead_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      switch (auth.role) {
        case UserRole.admin:
          return const _AdminDashboard();
        case UserRole.manager:
          return const _ManagerDashboard();
        case UserRole.teamLeader:
        case UserRole.associateTeamLead:
        case UserRole.associate:
          return const _AssociateDashboard();
      }
    });
  }
}

//   SHARED HEADER
class _DashHeader extends StatelessWidget {
  final String greeting;
  final AuthController auth;
  const _DashHeader({required this.greeting, required this.auth});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.04,
        size.height * 0.02,
        size.width * 0.04,
        size.height * 0.01,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                Obx(
                  () => Text(
                    auth.currentUser.value.name,
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
                Obx(
                  () => Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      auth.currentUser.value.userRole.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: theme.iconTheme.color,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Obx(() {
              final user = auth.currentUser.value;
              final name = user.name;
              final idx = user.avatarIndex;
              final color =
                  AppColors.avatarColors[idx % AppColors.avatarColors.length];
              final initials = name.isNotEmpty
                  ? name
                        .split(' ')
                        .take(2)
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .join()
                  : '?';
              return Container(
                width: size.width * 0.1,
                height: size.width * 0.1,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

//   STAT CARD
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.width * 0.03,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                255,
                38,
                128,
                173,
              ).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  176,
                  56,
                  56,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: (size.width * 0.05).clamp(18.0, 24.0),
                color: AppColors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: (size.width * 0.065).clamp(20.0, 32.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: (size.width * 0.03).clamp(10.0, 14.0),
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//   ADMIN DASHBOARD
class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();
  @override
  Widget build(BuildContext context) {
    final leads = Get.find<LeadController>();
    final activities = Get.find<ActivityController>();
    final auth = Get.find<AuthController>();
    final callCtrl = Get.find<CallController>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashHeader(greeting: 'Admin Overview ', auth: auth),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: AttendanceCard()),
            // Big stat grid
            SliverToBoxAdapter(
              child: Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.width * 0.03,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: size.width > 900 ? 4 : (size.width > 600 ? 3 : 2),
                    crossAxisSpacing: size.width * 0.03,
                    mainAxisSpacing: size.width * 0.03,
                    childAspectRatio: size.width > 600 ? 1.3 : 1.5,
                    children: [
                      _StatCard(
                        label: 'Total Leads',
                        value: leads.totalLeads.toString(),
                        icon: Icons.people_alt_rounded,
                        color: AppColors.primary,
                        onTap: () => Get.toNamed(AppRoutes.leads),
                      ),
                      _StatCard(
                        label: 'Today Follow-ups',
                        value: activities.todayFollowupsCount.toString(),
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.statusNew,
                        onTap: () => Get.toNamed(AppRoutes.activity),
                      ),
                      _StatCard(
                        label: 'Daily Revenue',
                        value: NumberFormat.compactCurrency(
                          symbol: '₹',
                          decimalDigits: 1,
                        ).format(leads.dailyRevenue),
                        icon: Icons.payments_rounded,
                        color: AppColors.accent,
                      ),
                      _StatCard(
                        label: 'Monthly Revenue',
                        value: NumberFormat.compactCurrency(
                          symbol: '₹',
                          decimalDigits: 1,
                        ).format(leads.monthlyRevenue),
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color.fromARGB(255, 204, 103, 103),
                      ),
                      _StatCard(
                        label: 'Total Revenue',
                        value: NumberFormat.compactCurrency(
                          symbol: '₹',
                          decimalDigits: 1,
                        ).format(leads.totalRevenue),
                        icon: Icons.public_rounded,
                        color: AppColors.primaryDark,
                      ),
                      _StatCard(
                        label: 'Converted',
                        value: leads.convertedLeads.toString(),
                        icon: Icons.check_circle_rounded,
                        color: AppColors.statusInterested,
                      ),
                      _StatCard(
                        label: 'Connected Calls',
                        value: callCtrl.connectedCallsCount.toString(),
                        icon: Icons.call_made_rounded,
                        color: AppColors.statusConverted,
                        onTap: () => Get.toNamed(AppRoutes.callHistory),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // System info banner
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  0,
                  size.width * 0.04,
                  size.width * 0.02,
                ),
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Access',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'Full system view  all leads, all users, all data',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.75),
                              fontSize: size.width * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Recent leads header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  size.width * 0.02,
                  size.width * 0.04,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Recent Leads',
                      style: theme.textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.leads),
                      child: Text(
                        'View All',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              final recent = leads.recentLeads;
              final isTablet = size.width > 600;
              if (isTablet) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 900 ? 3 : 2,
                      childAspectRatio: size.width > 900 ? 2.3 : 2.0,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => LeadCard(
                        lead: recent[i],
                        heroTag: 'admin_${recent[i].id}',
                        onStatusChanged: (status) =>
                            leads.updateLeadStatus(recent[i].id, status),
                        onTap: () => Get.toNamed(
                          AppRoutes.leadDetail,
                          arguments: recent[i].id,
                        ),
                      ),
                      childCount: recent.length,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => LeadCard(
                    lead: recent[i],
                    heroTag: 'admin_${recent[i].id}',
                    onStatusChanged: (status) =>
                        leads.updateLeadStatus(recent[i].id, status),
                    onTap: () => Get.toNamed(
                      AppRoutes.leadDetail,
                      arguments: recent[i].id,
                    ),
                  ),
                  childCount: recent.length,
                ),
              );
            }),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
          ],
        ),
      ),
      bottomNavigationBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addLead),
        tooltip: 'Add Lead',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

//   MANAGER DASHBOARD
class _ManagerDashboard extends StatelessWidget {
  const _ManagerDashboard();
  @override
  Widget build(BuildContext context) {
    final leads = Get.find<LeadController>();
    final activities = Get.find<ActivityController>();
    final auth = Get.find<AuthController>();
    final callCtrl = Get.find<CallController>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashHeader(greeting: 'Team Overview ', auth: auth),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: AttendanceCard()),
            // 4-card grid
            SliverToBoxAdapter(
              child: Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.width * 0.03,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: size.width > 600 ? 4 : 2,
                    crossAxisSpacing: size.width * 0.03,
                    mainAxisSpacing: size.width * 0.03,
                    childAspectRatio: size.width > 600 ? 1.3 : 1.55,
                    children: [
                      _StatCard(
                        label: 'Total Leads',
                        value: leads.totalLeads.toString(),
                        icon: Icons.people_alt_rounded,
                        color: AppColors.primary,
                        onTap: () => Get.toNamed(AppRoutes.leads),
                      ),
                      _StatCard(
                        label: 'Follow-ups',
                        value: activities.todayFollowupsCount.toString(),
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.statusNew,
                        onTap: () => Get.toNamed(AppRoutes.activity),
                      ),
                      _StatCard(
                        label: 'Converted',
                        value: leads.convertedLeads.toString(),
                        icon: Icons.check_circle_rounded,
                        color: AppColors.statusInterested,
                      ),
                      _StatCard(
                        label: 'Connected Calls',
                        value: callCtrl.connectedCallsCount.toString(),
                        icon: Icons.call_made_rounded,
                        color: AppColors.statusConverted,
                        onTap: () => Get.toNamed(AppRoutes.callHistory),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Pipeline progress bar
            SliverToBoxAdapter(
              child: Obx(() {
                final total = leads.totalLeads;
                final conv = leads.convertedLeads;
                final rate = total > 0 ? conv / total : 0.0;
                return Container(
                  margin: EdgeInsets.fromLTRB(
                    size.width * 0.04,
                    0,
                    size.width * 0.04,
                    size.width * 0.03,
                  ),
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Team Conversion Progress',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${(rate * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.width * 0.03),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: rate.toDouble(),
                          minHeight: 10,
                          backgroundColor: theme.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.02),
                      Text(
                        '$conv out of $total leads converted',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  0,
                  size.width * 0.04,
                  size.width * 0.03,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Add Lead',
                        onTap: () => Get.toNamed(AppRoutes.addLead),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.event_note_rounded,
                        label: 'Activities',
                        onTap: () => Get.toNamed(AppRoutes.activity),
                        color: AppColors.statusConverted,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.people_outline_rounded,
                        label: 'All Leads',
                        onTap: () => Get.toNamed(AppRoutes.leads),
                        color: AppColors.statusInterested,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Recent leads
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  size.width * 0.01,
                  size.width * 0.04,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Pipeline',
                      style: theme.textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.leads),
                      child: Text(
                        'View All',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              final recent = leads.recentLeads;
              final isTablet = size.width > 600;
              if (isTablet) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 900 ? 3 : 2,
                      childAspectRatio: size.width > 900 ? 2.3 : 2.0,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => LeadCard(
                        lead: recent[i],
                        heroTag: 'mgr_${recent[i].id}',
                        onStatusChanged: (status) =>
                            leads.updateLeadStatus(recent[i].id, status),
                        onTap: () => Get.toNamed(
                          AppRoutes.leadDetail,
                          arguments: recent[i].id,
                        ),
                      ),
                      childCount: recent.length,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => LeadCard(
                    lead: recent[i],
                    heroTag: 'mgr_${recent[i].id}',
                    onStatusChanged: (status) =>
                        leads.updateLeadStatus(recent[i].id, status),
                    onTap: () => Get.toNamed(
                      AppRoutes.leadDetail,
                      arguments: recent[i].id,
                    ),
                  ),
                  childCount: recent.length,
                ),
              );
            }),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
          ],
        ),
      ),
      bottomNavigationBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addLead),
        tooltip: 'Add Lead',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

//   ASSOCIATE DASHBOARD
class _AssociateDashboard extends StatelessWidget {
  const _AssociateDashboard();
  @override
  Widget build(BuildContext context) {
    final leads = Get.find<LeadController>();
    final activities = Get.find<ActivityController>();
    final auth = Get.find<AuthController>();
    final callCtrl = Get.find<CallController>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    // Sales rep sees "their" leads = last 5 leads in list (simulated)
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashHeader(greeting: 'My Pipeline ', auth: auth),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: AttendanceCard()),
            // 2 personal stat cards
            SliverToBoxAdapter(
              child: Obx(() {
                final myLeads = leads.recentLeads.take(6).toList();
                final myConverted = myLeads
                    .where((l) => l.status == LeadStatus.converted)
                    .length;
                final myPending = activities.todayFollowupsCount;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.width * 0.03,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: size.width > 600 ? 4 : 2,
                    crossAxisSpacing: size.width * 0.03,
                    mainAxisSpacing: size.width * 0.03,
                    childAspectRatio: size.width > 600 ? 1.3 : 1.5,
                    children: [
                      _StatCard(
                        label: 'My Leads',
                        value: myLeads.length.toString(),
                        icon: Icons.person_pin_rounded,
                        color: AppColors.primary,
                        onTap: () => Get.toNamed(AppRoutes.leads),
                      ),
                      _StatCard(
                        label: 'Today Follow-ups',
                        value: myPending.toString(),
                        icon: Icons.alarm_rounded,
                        color: AppColors.warning,
                        onTap: () => Get.toNamed(AppRoutes.activity),
                      ),
                      _StatCard(
                        label: 'Converted',
                        value: myConverted.toString(),
                        icon: Icons.verified_rounded,
                        color: AppColors.statusInterested,
                      ),
                      _StatCard(
                        label: 'Connected Calls',
                        value: callCtrl.connectedCallsCount.toString(),
                        icon: Icons.call_made_rounded,
                        color: AppColors.statusConverted,
                        onTap: () => Get.toNamed(AppRoutes.callHistory),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Quick Action row
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  0,
                  size.width * 0.04,
                  size.width * 0.03,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_chart_rounded,
                        label: 'Add Lead',
                        onTap: () => Get.toNamed(AppRoutes.addLead),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.history_rounded,
                        label: 'Activity',
                        onTap: () => Get.toNamed(AppRoutes.activity),
                        color: AppColors.statusConverted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Recent assigned leads
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  size.width * 0.01,
                  size.width * 0.04,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assigned Leads',
                      style: theme.textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.leads),
                      child: Text(
                        'View All',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              final myLeads = leads.recentLeads.take(6).toList();
              final isTablet = size.width > 600;
              if (isTablet) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 900 ? 3 : 2,
                      childAspectRatio: size.width > 900 ? 2.3 : 2.0,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => LeadCard(
                        lead: myLeads[i],
                        heroTag: 'asc_${myLeads[i].id}',
                        onStatusChanged: (status) =>
                            leads.updateLeadStatus(myLeads[i].id, status),
                        onTap: () => Get.toNamed(
                          AppRoutes.leadDetail,
                          arguments: myLeads[i].id,
                        ),
                      ),
                      childCount: myLeads.length,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => LeadCard(
                    lead: myLeads[i],
                    heroTag: 'asc_${myLeads[i].id}',
                    onStatusChanged: (status) =>
                        leads.updateLeadStatus(myLeads[i].id, status),
                    onTap: () => Get.toNamed(
                      AppRoutes.leadDetail,
                      arguments: myLeads[i].id,
                    ),
                  ),
                  childCount: myLeads.length,
                ),
              );
            }),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
          ],
        ),
      ),
      bottomNavigationBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addLead),
        tooltip: 'Add Lead',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

//   QUICK ACTION WIDGET
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
