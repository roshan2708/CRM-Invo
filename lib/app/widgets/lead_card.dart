import 'package:flutter/material.dart';
import '../data/models/lead_model.dart';
import '../theme/app_colors.dart';
import 'status_chip.dart';
import 'package:intl/intl.dart';

/// Full-featured lead card with status accent bar, source badge, revenue chip,
/// follow-up date indicator, and a subtle glassmorphism/shadow effect.
class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onTap;
  final Function(LeadStatus)? onStatusChanged;
  final String? heroTag;
  final bool compact;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onStatusChanged,
    this.heroTag,
    this.compact = false,
  });

  Color get _statusColor {
    switch (lead.status) {
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final avatarColor =
        AppColors.avatarColors[lead.avatarIndex % AppColors.avatarColors.length];
    final initials = lead.name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join();

    final bool hasRevenue = (lead.revenue ?? 0) > 0;
    final bool hasFollowUp = lead.followUpDate != null;
    final sc = _statusColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.width * 0.015,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sc.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left status accent bar ─────────────────────────────────────
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: sc,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            // ── Main content ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.035),
                child: Row(
                  children: [
                    // Avatar
                    Hero(
                      tag: heroTag ?? 'avatar_${lead.id}',
                      child: Container(
                        width: size.width * 0.12,
                        height: size.width * 0.12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              avatarColor,
                              avatarColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + status dropdown
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lead.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _StatusDropdown(
                                currentStatus: lead.status,
                                onChanged: onStatusChanged,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Company
                          if (lead.company != null)
                            Text(
                              lead.company!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.75),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 6),
                          // Bottom row: phone + date + badges
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 11,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  lead.phone,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Tag row: source, revenue, follow-up date
                          Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            children: [
                              if (lead.source != null)
                                _MiniChip(
                                  label: lead.source!,
                                  color: AppColors.primary,
                                  icon: Icons.source_rounded,
                                ),
                              if (hasRevenue)
                                _MiniChip(
                                  label:
                                      '₹${NumberFormat.compact().format(lead.revenue)}',
                                  color: AppColors.statusConverted,
                                  icon: Icons.currency_rupee_rounded,
                                ),
                              if (hasFollowUp)
                                _MiniChip(
                                  label: DateFormat('d MMM')
                                      .format(lead.followUpDate!),
                                  color: AppColors.warning,
                                  icon: Icons.event_rounded,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini badge chip ────────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MiniChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status dropdown ────────────────────────────────────────────────────────────
class _StatusDropdown extends StatelessWidget {
  final LeadStatus currentStatus;
  final Function(LeadStatus)? onChanged;

  const _StatusDropdown({
    required this.currentStatus,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LeadStatus>(
      initialValue: currentStatus,
      padding: EdgeInsets.zero,
      onSelected: onChanged,
      child: StatusChip(status: currentStatus),
      itemBuilder: (context) => LeadStatus.values.map((status) {
        return PopupMenuItem<LeadStatus>(
          value: status,
          child: Row(
            children: [
              if (status == currentStatus)
                const Icon(Icons.check, size: 18, color: AppColors.primary)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(status.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}
