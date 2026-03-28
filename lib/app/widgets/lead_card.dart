import 'package:flutter/material.dart';
import '../data/models/lead_model.dart';
import '../theme/app_colors.dart';
import 'status_chip.dart';
import 'package:intl/intl.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? heroTag;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onDelete,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final avatarColor = AppColors
        .avatarColors[lead.avatarIndex % AppColors.avatarColors.length];
    final initials = lead.name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.width * 0.015,
        ),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with Hero
            Hero(
              tag: heroTag ?? 'avatar_${lead.id}',
              child: Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  color: avatarColor,
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
              ),
            ),
            SizedBox(width: size.width * 0.03),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lead.name,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusChip(status: lead.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (lead.company != null)
                    Text(
                      lead.company!,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lead.phone,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(lead.date),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
