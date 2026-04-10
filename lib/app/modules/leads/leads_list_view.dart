import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../modules/leads/lead_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_button.dart';
import '../../data/models/lead_model.dart';

class LeadsListView extends StatelessWidget {
  const LeadsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeadController>();
    return Obx(() => ctrl.isCalendarMode.value
        ? _CalendarLeadsView(ctrl: ctrl)
        : _ListLeadsView(ctrl: ctrl));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CALENDAR VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _CalendarLeadsView extends StatelessWidget {
  final LeadController ctrl;
  const _CalendarLeadsView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          _LeadsSliverAppBar(
            isCalendar: true,
            ctrl: ctrl,
            theme: theme,
            isDark: isDark,
            size: size,
          ),
        ],
        body: Obx(() {
          final focusedDay = ctrl.focusedCalendarDay.value;
          final selectedDay = ctrl.selectedCalendarDay.value;

          return Column(
            children: [
              // ── Calendar ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TableCalendar<LeadModel>(
                  firstDay: DateTime.utc(2026, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) =>
                      selectedDay != null && isSameDay(selectedDay, day),
                  eventLoader: ctrl.eventLoader,
                  onDaySelected: ctrl.onDaySelected,
                  onPageChanged: (fd) =>
                      ctrl.focusedCalendarDay.value = fd,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: theme.iconTheme.color,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.iconTheme.color,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.6),
                    ),
                    weekendStyle: theme.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.error.withValues(alpha: 0.8),
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.transparent,
                    ),
                    markersMaxCount: 4,
                    markerSizeScale: 0.22,
                    cellMargin: const EdgeInsets.all(2),
                  ),
                  calendarBuilders: CalendarBuilders<LeadModel>(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      // Show up to 4 colored dots by status
                      final shown = events.take(4).toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: shown
                              .map((e) => _statusDot(_statusColor(e.status)))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Day leads panel ──────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  final day = ctrl.selectedCalendarDay.value;
                  final leads = ctrl.leadsForSelectedDay;

                  if (day == null) {
                    return _CalendarHintPanel(
                      theme: theme,
                      ctrl: ctrl,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE').format(day),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  DateFormat('d MMMM yyyy').format(day),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (leads.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${leads.length} lead${leads.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Leads for selected day
                      Expanded(
                        child: leads.isEmpty
                            ? _NoLeadsForDay(
                                day: day,
                                theme: theme,
                                size: size,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: leads.length,
                                itemBuilder: (ctx, i) {
                                  final lead = leads[i];
                                  return LeadCard(
                                    lead: lead,
                                    heroTag: 'cal_${lead.id}',
                                    onStatusChanged: (status) =>
                                        ctrl.updateLeadStatus(lead.id, status),
                                    onTap: () => Get.toNamed(
                                      AppRoutes.leadDetail,
                                      arguments: lead.id,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: null,
      floatingActionButton: _AddLeadFAB(),
    );
  }

  Color _statusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return AppColors.statusNew;
      case LeadStatus.contacted:
        return AppColors.statusContacted;
      case LeadStatus.interested:
        return AppColors.statusInterested;
      case LeadStatus.converted:
        return AppColors.statusConverted;
      case LeadStatus.lost:
        return AppColors.statusLost;
    }
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  LIST VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _ListLeadsView extends StatelessWidget {
  final LeadController ctrl;
  const _ListLeadsView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          _LeadsSliverAppBar(
            isCalendar: false,
            ctrl: ctrl,
            theme: theme,
            isDark: isDark,
            size: size,
          ),
        ],
        body: Column(
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
                  hintText: 'Search by name, email, company...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: Obx(
                    () => ctrl.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => ctrl.setSearch(''),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Status filter chips
            SizedBox(
              height: 36,
              child: Obx(() {
                final statuses = [null, ...LeadStatus.values];
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  scrollDirection: Axis.horizontal,
                  itemCount: statuses.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final s = statuses[i];
                    final isSelected = ctrl.selectedStatus.value == s;
                    final chipColor = s == null
                        ? AppColors.primary
                        : _statusColorForFilter(s);
                    return GestureDetector(
                      onTap: () => ctrl.setStatusFilter(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? chipColor
                              : chipColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? chipColor
                                : chipColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s != null) ...[
                              Icon(
                                _statusIcon(s),
                                size: 11,
                                color: isSelected
                                    ? AppColors.white
                                    : chipColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              s == null ? 'All' : s.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? AppColors.white
                                    : chipColor,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 6),
            // Count badge
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Row(
                  children: [
                    Text(
                      '${ctrl.filteredLeads.length} leads',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
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
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: ctrl.filteredLeads.length,
                  itemBuilder: (ctx, i) {
                    final lead = ctrl.filteredLeads[i];
                    return Dismissible(
                      key: Key(lead.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding:
                            EdgeInsets.only(right: size.width * 0.06),
                        margin: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.width * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(18),
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
                      confirmDismiss: (_) async =>
                          await _confirmDelete(context, lead.name),
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
                        onStatusChanged: (status) =>
                            ctrl.updateLeadStatus(lead.id, status),
                        onTap: () => Get.toNamed(
                          AppRoutes.leadDetail,
                          arguments: lead.id,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: null,
      floatingActionButton: _AddLeadFAB(),
    );
  }

  Color _statusColorForFilter(LeadStatus s) {
    switch (s) {
      case LeadStatus.newLead:
        return AppColors.statusNew;
      case LeadStatus.contacted:
        return AppColors.statusContacted;
      case LeadStatus.interested:
        return AppColors.statusInterested;
      case LeadStatus.converted:
        return AppColors.statusConverted;
      case LeadStatus.lost:
        return AppColors.statusLost;
    }
  }

  IconData _statusIcon(LeadStatus s) {
    switch (s) {
      case LeadStatus.newLead:
        return Icons.fiber_new_rounded;
      case LeadStatus.contacted:
        return Icons.call_made_rounded;
      case LeadStatus.interested:
        return Icons.thumb_up_alt_rounded;
      case LeadStatus.converted:
        return Icons.check_circle_rounded;
      case LeadStatus.lost:
        return Icons.cancel_rounded;
    }
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
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED SLIVER APP BAR
// ══════════════════════════════════════════════════════════════════════════════
class _LeadsSliverAppBar extends StatelessWidget {
  final bool isCalendar;
  final LeadController ctrl;
  final ThemeData theme;
  final bool isDark;
  final Size size;

  const _LeadsSliverAppBar({
    required this.isCalendar,
    required this.ctrl,
    required this.theme,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 145,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _LeadsHeader(ctrl: ctrl, theme: theme, isDark: isDark),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 1,
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      actions: [
        // View mode toggle
        Obx(
          () => Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewToggleButton(
                  icon: Icons.calendar_month_rounded,
                  isActive: ctrl.isCalendarMode.value,
                  onTap: () {
                    if (!ctrl.isCalendarMode.value) ctrl.toggleViewMode();
                  },
                  tooltip: 'Calendar View',
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                _ViewToggleButton(
                  icon: Icons.list_rounded,
                  isActive: !ctrl.isCalendarMode.value,
                  onTap: () {
                    if (ctrl.isCalendarMode.value) ctrl.toggleViewMode();
                  },
                  tooltip: 'List View',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Leads header with stats strip ─────────────────────────────────────────────
class _LeadsHeader extends StatelessWidget {
  final LeadController ctrl;
  final ThemeData theme;
  final bool isDark;

  const _LeadsHeader({
    required this.ctrl,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [AppColors.primary, const Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.04,
            size.height * 0.015,
            size.width * 0.04,
            size.height * 0.015,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Leads Pipeline',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatPill(
                        label: 'Total',
                        count: ctrl.totalLeads,
                        color: AppColors.white,
                        bg: AppColors.white.withValues(alpha: 0.18),
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'New',
                        count: ctrl.newLeads,
                        color: const Color(0xFFA5B4FC),
                        bg: AppColors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Interested',
                        count: ctrl.interestedLeads,
                        color: const Color(0xFF6EE7B7),
                        bg: AppColors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Converted',
                        count: ctrl.convertedLeads,
                        color: const Color(0xFF93C5FD),
                        bg: AppColors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Lost',
                        count: ctrl.lostLeads,
                        color: const Color(0xFFFCA5A5),
                        bg: AppColors.white.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat pill widget ───────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _StatPill({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── View toggle button ─────────────────────────────────────────────────────────
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ── Calendar hint panel (nothing selected yet) ─────────────────────────────────
class _CalendarHintPanel extends StatelessWidget {
  final ThemeData theme;
  final LeadController ctrl;

  const _CalendarHintPanel({required this.theme, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final todayLeads = ctrl.todayFollowUpLeads;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.touch_app_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Tap a date to see scheduled follow-ups',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (todayLeads.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusInterested.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Today's Follow-ups: ${todayLeads.length}",
                    style: TextStyle(
                      color: AppColors.statusInterested,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: todayLeads.length,
              itemBuilder: (ctx, i) {
                final lead = todayLeads[i];
                return LeadCard(
                  lead: lead,
                  heroTag: 'today_${lead.id}',
                  onStatusChanged: (status) =>
                      ctrl.updateLeadStatus(lead.id, status),
                  onTap: () => Get.toNamed(
                    AppRoutes.leadDetail,
                    arguments: lead.id,
                  ),
                );
              },
            ),
          ),
        ] else
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 52,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No follow-ups today',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap any date with dots to see leads',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── No leads for selected day ──────────────────────────────────────────────────
class _NoLeadsForDay extends StatelessWidget {
  final DateTime day;
  final ThemeData theme;
  final Size size;

  const _NoLeadsForDay({
    required this.day,
    required this.theme,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 52,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            'No follow-ups on ${DateFormat('d MMM').format(day)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.addLead),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Add Lead for this day',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────────
class _AddLeadFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed(AppRoutes.addLead),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Lead',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
    );
  }
}
