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
        case UserRole.salesManager:
          return const _ManagerDashboard();
        case UserRole.salesRep:
          return const _SalesRepDashboard();
      }
    });
  }
}

//   SHARED BOTTOM NAV
class _BottomNav extends StatelessWidget {
  final String active;
  const _BottomNav({required this.active});
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
                active: active == 'dashboard',
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Leads',
                route: AppRoutes.leads,
                active: active == 'leads',
              ),
              _NavItem(
                icon: Icons.call_rounded,
                label: 'Calls',
                route: AppRoutes.callHistory,
                active: active == 'calls',
              ),
              _NavItem(
                icon: Icons.event_note_rounded,
                label: 'Activity',
                route: AppRoutes.activity,
                active: active == 'activity',
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                route: AppRoutes.profile,
                active: active == 'profile',
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
              final name = auth.currentUser.value.name;
              final idx = auth.currentUser.value.avatarIndex;
              final color =
                  AppColors.avatarColors[idx % AppColors.avatarColors.length];
              final initials = name.split(' ').take(2).map((e) => e[0]).join();
              return Container(
                width: size.width * 0.1,
                height: size.width * 0.1,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
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
            horizontal: size.width * 0.04, vertical: size.width * 0.03),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
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
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: size.width * 0.05,
                color: AppColors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: size.width * 0.065,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size.width * 0.03,
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
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
                    crossAxisCount: 2,
                    crossAxisSpacing: size.width * 0.03,
                    mainAxisSpacing: size.width * 0.03,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        label: 'Total Leads',
                        value: leads.totalLeads.toString(),
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF4F46E5),
                        onTap: () => Get.toNamed(AppRoutes.leads),
                      ),
                      _StatCard(
                        label: 'Today Follow-ups',
                        value: activities.todayFollowupsCount.toString(),
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFFEC4899),
                        onTap: () => Get.toNamed(AppRoutes.activity),
                      ),
                      _StatCard(
                        label: 'Daily Revenue',
                        value: NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1).format(leads.dailyRevenue),
                        icon: Icons.payments_rounded,
                        color: const Color(0xFF14B8A6), // Teal
                      ),
                      _StatCard(
                        label: 'Monthly Revenue',
                        value: NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1).format(leads.monthlyRevenue),
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF0F766E), // Dark Teal
                      ),
                      _StatCard(
                        label: 'Total Revenue',
                        value: NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1).format(leads.totalRevenue),
                        icon: Icons.public_rounded,
                        color: const Color(0xFF1E3A8A), // Indigo
                      ),
                      _StatCard(
                        label: 'Converted',
                        value: leads.convertedLeads.toString(),
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                      ),
                      _StatCard(
                        label: 'Connected Calls',
                        value: callCtrl.connectedCallsCount.toString(),
                        icon: Icons.call_made_rounded,
                        color: const Color(0xFF06B6D4),
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
                  color: const Color(0xFF1E1B4B),
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
      bottomNavigationBar: const _BottomNav(active: 'dashboard'),
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
                    crossAxisCount: 2,
                    crossAxisSpacing: size.width * 0.03,
                    mainAxisSpacing: size.width * 0.03,
                    childAspectRatio: 1.55,
                    children: [
                      _StatCard(
                        label: 'Total Leads',
                        value: leads.totalLeads.toString(),
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF4F46E5),
                        onTap: () => Get.toNamed(AppRoutes.leads),
                      ),
                      _StatCard(
                        label: 'Follow-ups',
                        value: activities.todayFollowupsCount.toString(),
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFFEC4899),
                        onTap: () => Get.toNamed(AppRoutes.activity),
                      ),
                      _StatCard(
                        label: 'Converted',
                        value: leads.convertedLeads.toString(),
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                      ),
                      _StatCard(
                        label: 'Connected Calls',
                        value: callCtrl.connectedCallsCount.toString(),
                        icon: Icons.call_made_rounded,
                        color: const Color(0xFF06B6D4),
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
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.event_note_rounded,
                        label: 'Activities',
                        onTap: () => Get.toNamed(AppRoutes.activity),
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.people_outline_rounded,
                        label: 'All Leads',
                        onTap: () => Get.toNamed(AppRoutes.leads),
                        color: const Color(0xFF10B981),
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
      bottomNavigationBar: const _BottomNav(active: 'dashboard'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addLead),
        tooltip: 'Add Lead',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

//   SALES REP DASHBOARD
class _SalesRepDashboard extends StatelessWidget {
  const _SalesRepDashboard();
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
                    crossAxisCount: 2,
                    crossAxisSpacing: size.width * 0.03,
                    mainAxisSpacing: size.width * 0.03,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        label: 'My Leads',
                        value: myLeads.length.toString(),
                        icon: Icons.person_pin_rounded,
                        color: const Color(0xFF4F46E5),
                        onTap: () => Get.toNamed(AppRoutes.leads),
                      ),
                      _StatCard(
                        label: 'Today Follow-ups',
                        value: myPending.toString(),
                        icon: Icons.alarm_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => Get.toNamed(AppRoutes.activity),
                      ),
                      _StatCard(
                        label: 'Converted',
                        value: myConverted.toString(),
                        icon: Icons.verified_rounded,
                        color: const Color(0xFF10B981),
                      ),
                      _StatCard(
                        label: 'Connected',
                        value: callCtrl.connectedCallsCount.toString(),
                        icon: Icons.call_made_rounded,
                        color: const Color(0xFF06B6D4),
                        onTap: () => Get.toNamed(AppRoutes.callHistory),
                      ),
                      _StatCard(
                        label: 'Revenue',
                        value: NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1).format(leads.totalRevenue),
                        icon: Icons.currency_rupee_rounded,
                        color: const Color(0xFF0F766E),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Today's target card
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  size.width * 0.04,
                  0,
                  size.width * 0.04,
                  size.width * 0.03,
                ),
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Goal",
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          SizedBox(height: size.width * 0.01),
                          Text(
                            'Make 5 calls & follow up on 3 leads',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontSize: size.width * 0.032,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.phone_callback_rounded,
                        label: 'Call History',
                        onTap: () => Get.toNamed(AppRoutes.callHistory),
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.calendar_today_rounded,
                        label: 'Schedule',
                        onTap: () => Get.toNamed(AppRoutes.activity),
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // My leads
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
                    Text('My Leads', style: theme.textTheme.headlineSmall),
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
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => LeadCard(
                    lead: recent[i],
                    heroTag: 'rep_${recent[i].id}',
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
      bottomNavigationBar: const _BottomNav(active: 'dashboard'),
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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.width * 0.04),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: size.width * 0.065),
            SizedBox(height: size.width * 0.015),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
