import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.message = '暂无倒计时',
    this.actionLabel = '添加第一个',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTokens.surfaceLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
                border: Border.all(color: AppTokens.border),
              ),
              child: const Icon(
                Icons.event_note_outlined,
                size: 28,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: AppTokens.spacing),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppTokens.fontSizeBody,
                color: AppTokens.textSecondary,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppTokens.spacing),
              OutlinedButton(
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
