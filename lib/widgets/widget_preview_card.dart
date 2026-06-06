import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class WidgetPreviewCard extends StatelessWidget {
  final Countdown? countdown;

  const WidgetPreviewCard({
    super.key,
    this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    if (countdown == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppTokens.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokens.border),
        ),
        child: const Center(
          child: Text(
            'No countdown selected',
            style: TextStyle(color: AppTokens.textSecondary),
          ),
        ),
      );
    }

    final daysLeft =
        AppDateUtils.daysUntil(countdown!.targetDate, countdown!.repeatType);
    final nextTarget = AppDateUtils.resolveNextTargetDate(
        countdown!.targetDate, countdown!.repeatType);
    final color = Color(int.parse(countdown!.color.replaceFirst('#', '0xFF')));

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  countdown!.title,
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeBody,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatDate(nextTarget),
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeSmall,
                    color: AppTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$daysLeft',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'days',
            style: TextStyle(
              fontSize: AppTokens.fontSizeSmall,
              color: AppTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
