import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.width * 0.22,
              height: size.width * 0.22,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(size.width * 0.06),
              ),
              child: Icon(
                icon,
                size: size.width * 0.1,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: size.width * 0.06),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.width * 0.02),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: size.width * 0.06),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
