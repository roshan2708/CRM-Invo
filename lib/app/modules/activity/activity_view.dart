import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../modules/activity/activity_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../data/models/activity_model.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final ctrl = Get.find<ActivityController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Activities', showBack: false),
      body: Obx(() {
        final activities = ctrl.activities;
        if (activities.isEmpty) {
          return const EmptyStateWidget(
            title: 'No Activities',
            message: 'Schedule calls, meetings, and follow-ups here.',
            icon: Icons.event_note_rounded,
          );
        }

        // Group by date
        final grouped = <String, List<ActivityModel>>{};
        for (final a in activities) {
          final key = DateFormat('dd MMM yyyy').format(a.dateTime);
          grouped.putIfAbsent(key, () => []).add(a);
        }

        final keys = grouped.keys.toList();
        return ListView.builder(
          padding: EdgeInsets.only(
            bottom: size.height * 0.12,
            top: size.width * 0.02,
          ),
          itemCount: keys.length,
          itemBuilder: (ctx, i) {
            final dateKey = keys[i];
            final items = grouped[dateKey]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.04,
                    size.width * 0.04,
                    size.width * 0.04,
                    size.width * 0.02,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dateKey,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...items.map((a) => _ActivityCard(activity: a, ctrl: ctrl)),
              ],
            );
          },
        );
      }),
      bottomNavigationBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(context, ctrl),
        tooltip: 'Add Activity',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, ActivityController ctrl) {
    final theme = Theme.of(context);
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    ActivityType selectedType = ActivityType.call;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: size.width * 0.05,
              right: size.width * 0.05,
              top: size.width * 0.05,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.04),
                Text('New Activity', style: theme.textTheme.headlineMedium),
                SizedBox(height: size.width * 0.04),
                // Type picker
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ActivityType.values.map((t) {
                    final sel = selectedType == t;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? theme.colorScheme.primary
                              : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.icon,
                              style: TextStyle(fontSize: size.width * 0.04),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t.label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: sel ? AppColors.white : null,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: size.width * 0.04),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Lead name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: size.width * 0.03),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description...',
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: size.width * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          descCtrl.text.trim().isEmpty) {
                        return;
                      }
                      ctrl.addActivity(
                        ActivityModel(
                          id: 'a${DateTime.now().millisecondsSinceEpoch}',
                          leadId: 'manual',
                          leadName: nameCtrl.text.trim(),
                          type: selectedType,
                          description: descCtrl.text.trim(),
                          dateTime: DateTime.now(),
                        ),
                      );
                      Get.back();
                      Get.snackbar(
                        'Activity Added',
                        'Activity scheduled successfully.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: AppColors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                    child: const Text('Add Activity'),
                  ),
                ),
                SizedBox(height: size.width * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final ActivityController ctrl;

  const _ActivityCard({required this.activity, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.04,
        0,
        size.width * 0.04,
        size.width * 0.02,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: activity.isDone
            ? theme.cardColor.withValues(alpha: 0.6)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.isDone
              ? theme.dividerColor.withValues(alpha: 0.5)
              : theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          // Type icon
          Container(
            width: size.width * 0.11,
            height: size.width * 0.11,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              activity.type.icon,
              style: TextStyle(fontSize: size.width * 0.055),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.leadName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: activity.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    color: activity.isDone
                        ? theme.textTheme.bodySmall?.color
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: theme.textTheme.labelSmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm a').format(activity.dateTime),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activity.type.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Done toggle
          GestureDetector(
            onTap: () => ctrl.toggleDone(activity.id),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: activity.isDone
                    ? AppColors.success.withValues(alpha: 0.1)
                    : theme.scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: activity.isDone
                      ? AppColors.success
                      : theme.dividerColor,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: activity.isDone ? AppColors.success : theme.dividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
