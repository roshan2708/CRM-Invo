import 'package:flutter/material.dart';
import '../data/models/lead_model.dart';
import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final LeadStatus status;
  final bool compact;

  const StatusChip({super.key, required this.status, this.compact = false});

  Color _bgColor() {
    switch (status) {
      case LeadStatus.newLead:
        return AppColors.statusNew.withValues(alpha: 0.12);
      case LeadStatus.contacted:
        return AppColors.statusContacted.withValues(alpha: 0.12);
      case LeadStatus.interested:
        return AppColors.statusInterested.withValues(alpha: 0.12);
      case LeadStatus.converted:
        return AppColors.statusConverted.withValues(alpha: 0.12);
      case LeadStatus.lost:
        return AppColors.statusLost.withValues(alpha: 0.12);
    }
  }

  Color _textColor() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _textColor(),
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
