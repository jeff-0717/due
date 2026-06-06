import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.message = 'No countdowns yet',
    this.actionLabel = 'Add your first',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📋',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppTokens.fontSizeBody,
                color: AppTokens.textSecondary,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
