import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../auth/auth_controller.dart';
import '../attendance_controller.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authCtrl = Get.find<AuthController>();
    final attendanceCtrl = Get.find<AttendanceController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Obx(() {
          final isPunchedIn = attendanceCtrl.isPunchedIn;
          final isLoading = attendanceCtrl.isLoading.value;
          final record = attendanceCtrl.currentRecord.value;
          final user = authCtrl.currentUser.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isPunchedIn
                              ? const Color(0xFF25D366) // Green
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPunchedIn ? 'Punched In' : 'Not Punched In',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    user.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (record != null) ...[
                const SizedBox(height: 16),
                _BuildDetailRow(
                  icon: Icons.login_rounded,
                  label: 'In',
                  time: record.punchInFormatted,
                  location: record.punchInLocation,
                ),
                if (record.isPunchedOut) ...[
                  const SizedBox(height: 12),
                  _BuildDetailRow(
                    icon: Icons.logout_rounded,
                    label: 'Out',
                    time: record.punchOutFormatted,
                    location: record.punchOutLocation ?? 'Unknown',
                  ),
                ]
              ],

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isPunchedIn) {
                            attendanceCtrl.punchOut();
                          } else {
                            attendanceCtrl.punchIn();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPunchedIn
                        ? AppColors.error
                        : const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isPunchedIn ? 'PUNCH OUT' : 'PUNCH IN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BuildDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final String location;

  const _BuildDetailRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label: $time',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
