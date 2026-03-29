import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../modules/leads/lead_controller.dart';
import '../../modules/activity/activity_controller.dart';
import '../../modules/calls/call_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/status_chip.dart';
import '../../data/models/lead_model.dart';
import '../../data/models/call_log_model.dart';

class LeadDetailView extends StatelessWidget {
  const LeadDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final String leadId = Get.arguments as String;
    final ctrl = Get.find<LeadController>();
    final actCtrl = Get.find<ActivityController>();
    final callCtrl = Get.find<CallController>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Obx(() {
      final lead = ctrl.getLeadById(leadId);
      if (lead == null) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Lead Detail'),
          body: const Center(child: Text('Lead not found')),
        );
      }

      final avatarColor = AppColors
          .avatarColors[lead.avatarIndex % AppColors.avatarColors.length];
      final initials = lead.name
          .split(' ')
          .take(2)
          .map((e) => e.isNotEmpty ? e[0] : '')
          .join();
      final leadActivities = actCtrl.activitiesForLead(leadId);

      return Scaffold(
        appBar: CustomAppBar(
          title: '',
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Get.toNamed(AppRoutes.addLead, arguments: lead.id),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              onPressed: () => _confirmDelete(context, ctrl, lead),
            ),
            SizedBox(width: size.width * 0.02),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.06),
                decoration: BoxDecoration(color: theme.cardColor),
                child: Column(
                  children: [
                    Hero(
                      tag: 'list_${lead.id}',
                      child: Container(
                        width: size.width * 0.22,
                        height: size.width * 0.22,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: BorderRadius.circular(
                            size.width * 0.06,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.04),
                    Text(lead.name, style: theme.textTheme.headlineLarge),
                    if (lead.company != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lead.company!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                    SizedBox(height: size.width * 0.03),
                    StatusChip(status: lead.status),
                    SizedBox(height: size.width * 0.04),
                    // Call & WhatsApp Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => callCtrl.initiateCall(lead),
                            icon: const Icon(Icons.call_rounded, size: 18),
                            label: const Text('Call Now'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366), // WhatsApp Green
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => callCtrl.openWhatsApp(lead),
                            icon: const Icon(
                              Icons.wechat_rounded, // Temporary until custom icon
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Message on WhatsApp',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Performance info
              _SectionCard(
                title: 'Lead Performance',
                children: [
                  _InfoRow(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Revenue',
                    value: NumberFormat.currency(
                      symbol: '₹',
                      decimalDigits: 0,
                    ).format(lead.revenue ?? 0.0),
                  ),
                  Obx(() {
                    final count = callCtrl.logsForLead(lead.id).length;
                    return _InfoRow(
                      icon: Icons.call_made_rounded,
                      label: 'Connected Calls',
                      value: count.toString(),
                    );
                  }),
                ],
              ),
              // Call History section
              Obx(() {
                final callLogs = callCtrl.logsForLead(lead.id);
                return _SectionCard(
                  title: 'Call History (${callLogs.length})',
                  trailing: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.callHistory),
                    child: const Text('View All'),
                  ),
                  children: callLogs.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No calls yet. Tap Call Now to get started.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ]
                      : callLogs.take(3).map((log) {
                          final typeColor = log.callType == CallType.outgoing
                              ? AppColors.success
                              : AppColors.error;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                AppRoutes.callDetail,
                                arguments: log.id,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      log.callType == CallType.outgoing
                                          ? Icons.call_made_rounded
                                          : Icons.call_missed_rounded,
                                      color: typeColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log.callType.label,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${log.formattedDuration}  •  ${DateFormat('dd MMM, hh:mm a').format(log.startTime)}',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (log.tag != CallTag.none)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _tagColor(log.tag)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        log.tag.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _tagColor(log.tag),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                );
              }),
              // Contact info
              _SectionCard(
                title: 'Contact Information',
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: lead.phone,
                  ),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: lead.email,
                  ),
                  if (lead.source != null)
                    _InfoRow(
                      icon: Icons.source_outlined,
                      label: 'Source',
                      value: lead.source!,
                    ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Added',
                    value: DateFormat('dd MMM yyyy').format(lead.date),
                  ),
                ],
              ),
              // Notes
              if (lead.notes.isNotEmpty)
                _SectionCard(
                  title: 'Notes',
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        lead.notes,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              // Activities
              _SectionCard(
                title: 'Activities (${leadActivities.length})',
                trailing: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.activity),
                  child: const Text('View All'),
                ),
                children: leadActivities.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No activities yet.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ]
                    : leadActivities.take(3).map((a) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Text(
                                a.type.icon,
                                style: TextStyle(fontSize: size.width * 0.05),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.description,
                                      style: theme.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd MMM, hh:mm a',
                                      ).format(a.dateTime),
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (a.isDone)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      );
    });
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

  void _confirmDelete(
    BuildContext context,
    LeadController ctrl,
    LeadModel lead,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Lead'),
        content: Text('Remove "${lead.name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ctrl.deleteLead(lead.id);
              Get.until((route) => route.settings.name == AppRoutes.leads);
              Get.snackbar(
                'Deleted',
                '${lead.name} has been removed.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.04,
        size.width * 0.03,
        size.width * 0.04,
        0,
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
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.headlineSmall),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
