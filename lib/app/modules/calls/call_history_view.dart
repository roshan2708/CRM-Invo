import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../routes/app_routes.dart';
import 'call_controller.dart';
import '../../data/models/call_log_model.dart';

class CallHistoryView extends StatelessWidget {
  const CallHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Call History',
        actions: [
          Obx(
            () => (ctrl.filterType.value != null ||
                    ctrl.filterTag.value != null ||
                    ctrl.searchQuery.value.isNotEmpty)
                ? IconButton(
                    icon: const Icon(Icons.filter_list_off_rounded),
                    onPressed: ctrl.clearFilters,
                    tooltip: 'Clear filters',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
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
              decoration: InputDecoration(
                hintText: 'Search by name or number...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Filter chips
          SizedBox(
            height: size.width * 0.14,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.width * 0.03,
              ),
              scrollDirection: Axis.horizontal,
              children: [
                Obx(
                  () => _FilterChip(
                    label: 'All Types',
                    selected: ctrl.filterType.value == null,
                    onTap: () => ctrl.setTypeFilter(null),
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                ...CallType.values.map(
                  (t) => Padding(
                    padding: EdgeInsets.only(right: size.width * 0.02),
                    child: Obx(
                      () => _FilterChip(
                        label: t.label,
                        icon: _callTypeIcon(t),
                        selected: ctrl.filterType.value == t,
                        color: _callTypeColor(t),
                        onTap: () => ctrl.setTypeFilter(
                          ctrl.filterType.value == t ? null : t,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  margin: EdgeInsets.symmetric(
                    horizontal: size.width * 0.02,
                    vertical: 4,
                  ),
                  color: theme.dividerColor,
                ),
                ...CallTag.values.where((t) => t != CallTag.none).map(
                  (t) => Padding(
                    padding: EdgeInsets.only(right: size.width * 0.02),
                    child: Obx(
                      () => _FilterChip(
                        label: t.label,
                        selected: ctrl.filterTag.value == t,
                        color: _tagColor(t),
                        onTap: () => ctrl.setTagFilter(
                          ctrl.filterTag.value == t ? null : t,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: Obx(() {
              final logs = ctrl.filteredLogs;
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_missed_rounded,
                        size: size.width * 0.18,
                        color: theme.dividerColor,
                      ),
                      const SizedBox(height: 16),
                      Text('No calls found', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Try adjusting your filters',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(size.width * 0.04),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CallLogTile(log: logs[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _callTypeIcon(CallType t) {
    switch (t) {
      case CallType.outgoing:
        return Icons.call_made_rounded;
      case CallType.missed:
        return Icons.call_missed_rounded;
      case CallType.failed:
        return Icons.call_end_rounded;
    }
  }

  Color _callTypeColor(CallType t) {
    switch (t) {
      case CallType.outgoing:
        return AppColors.success;
      case CallType.missed:
        return AppColors.error;
      case CallType.failed:
        return const Color(0xFFF59E0B);
    }
  }

  Color _tagColor(CallTag tag) {
    switch (tag) {
      case CallTag.interested:
        return AppColors.success;
      case CallTag.followUp:
        return const Color(0xFFF59E0B);
      case CallTag.notInterested:
        return AppColors.error;
      case CallTag.none:
        return AppColors.primary;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                size: 14,
                color: selected ? activeColor : theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? activeColor : theme.textTheme.bodySmall?.color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallLogTile extends StatelessWidget {
  final CallLogModel log;
  const _CallLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final typeColor = _callTypeColor(log.callType);
    final tagColor = _tagColor(log.tag);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.callDetail, arguments: log.id),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_callTypeIcon(log.callType), color: typeColor, size: 20),
            ),
            SizedBox(width: size.width * 0.03),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.clientName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    log.phone,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        log.formattedDuration,
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(log.startTime),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tag badge
            if (log.tag != CallTag.none)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.tag.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: tagColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _callTypeIcon(CallType t) {
    switch (t) {
      case CallType.outgoing:
        return Icons.call_made_rounded;
      case CallType.missed:
        return Icons.call_missed_rounded;
      case CallType.failed:
        return Icons.call_end_rounded;
    }
  }

  Color _callTypeColor(CallType t) {
    switch (t) {
      case CallType.outgoing:
        return AppColors.success;
      case CallType.missed:
        return AppColors.error;
      case CallType.failed:
        return const Color(0xFFF59E0B);
    }
  }

  Color _tagColor(CallTag tag) {
    switch (tag) {
      case CallTag.interested:
        return AppColors.success;
      case CallTag.followUp:
        return const Color(0xFFF59E0B);
      case CallTag.notInterested:
        return AppColors.error;
      case CallTag.none:
        return AppColors.primary;
    }
  }
}
