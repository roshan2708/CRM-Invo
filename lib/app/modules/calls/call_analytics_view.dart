import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import 'call_controller.dart';

class CallAnalyticsView extends StatelessWidget {
  const CallAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(title: 'Call Analytics'),
      body: Obx(() {
        final perDay = ctrl.callsPerDay;
        final maxDay = perDay.fold(0, (m, e) => e.value > m ? e.value : m);

        return SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPI row
              _kpiRow(context, ctrl),
              SizedBox(height: size.width * 0.04),

              // Bar chart - calls per day
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calls This Week', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Last 7 days activity',
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(height: size.width * 0.05),
                    SizedBox(
                      height: size.width * 0.45,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: perDay.map((entry) {
                          final isToday = entry.key.day == DateTime.now().day &&
                              entry.key.month == DateTime.now().month;
                          final ratio = maxDay > 0 ? entry.value / maxDay : 0.0;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.01,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (entry.value > 0)
                                    Text(
                                      '${entry.value}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isToday
                                            ? theme.colorScheme.primary
                                            : theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOut,
                                    height: ratio > 0
                                        ? size.width * 0.35 * ratio
                                        : 4,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primary
                                              .withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('E').format(entry.key),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isToday
                                          ? theme.colorScheme.primary
                                          : theme.textTheme.bodySmall?.color,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.width * 0.04),

              // Tag distribution
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Call Outcome Distribution', style: theme.textTheme.headlineSmall),
                    SizedBox(height: size.width * 0.04),
                    _TagBar(
                      label: 'Interested',
                      count: ctrl.interestedCount,
                      total: ctrl.totalCalls,
                      color: AppColors.success,
                    ),
                    SizedBox(height: size.width * 0.03),
                    _TagBar(
                      label: 'Follow-up',
                      count: ctrl.followUpCount,
                      total: ctrl.totalCalls,
                      color: const Color(0xFFF59E0B),
                    ),
                    SizedBox(height: size.width * 0.03),
                    _TagBar(
                      label: 'Not Interested',
                      count: ctrl.notInterestedCount,
                      total: ctrl.totalCalls,
                      color: AppColors.error,
                    ),
                    SizedBox(height: size.width * 0.03),
                    _TagBar(
                      label: 'Untagged',
                      count: ctrl.totalCalls -
                          ctrl.interestedCount -
                          ctrl.followUpCount -
                          ctrl.notInterestedCount,
                      total: ctrl.totalCalls,
                      color: theme.dividerColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.width * 0.04),

              // Tips banner
              Container(
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
                        Icons.tips_and_updates_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Call Summary',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Auto-summarize calls with AI — coming soon.',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        );
      }),
    );
  }

  Widget _kpiRow(BuildContext context, CallController ctrl) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Total Calls',
            value: ctrl.totalCalls.toString(),
            icon: Icons.call_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _KpiCard(
            label: "Today's Calls",
            value: ctrl.todayCallsCount.toString(),
            icon: Icons.today_rounded,
            color: const Color(0xFF06B6D4),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _KpiCard(
            label: 'Avg Duration',
            value: ctrl.avgDurationFormatted,
            icon: Icons.timer_outlined,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: size.width * 0.055),
          SizedBox(height: size.width * 0.02),
          Text(
            value,
            style: TextStyle(
              fontSize: size.width * 0.055,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _TagBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total > 0 ? count / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              '$count (${(ratio * 100).toStringAsFixed(0)}%)',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.toDouble(),
            minHeight: 8,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
