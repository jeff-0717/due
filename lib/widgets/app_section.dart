import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppTokens.pagePadding,
      0,
      AppTokens.pagePadding,
      AppTokens.spacing,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTokens.textPrimary,
              fontSize: AppTokens.fontSizeBodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTokens.spacingXs),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTokens.textSecondary,
                fontSize: AppTokens.fontSizeSmall,
              ),
            ),
          ],
          const SizedBox(height: AppTokens.spacingSm),
          child,
        ],
      ),
    );
  }
}

class AppStatusChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  const AppStatusChip({
    super.key,
    required this.label,
    this.foreground = AppTokens.primaryDark,
    this.background = AppTokens.successSoft,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
        border: Border.all(color: foreground.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
