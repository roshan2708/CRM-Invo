import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, outlined, ghost }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final btnWidth = width ?? screenWidth;

    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: btnWidth,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: btnWidth,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
      case ButtonVariant.ghost:
        return SizedBox(
          width: btnWidth,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: child,
          ),
        );
    }
  }
}
