import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class CountdownCard extends StatelessWidget {
  final Countdown countdown;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CountdownCard({
    super.key,
    required this.countdown,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        AppDateUtils.daysUntil(countdown.targetDate, countdown.repeatType);
    final nextTarget = AppDateUtils.resolveNextTargetDate(
        countdown.targetDate, countdown.repeatType);

    final color = Color(int.parse(countdown.color.replaceFirst('#', '0xFF')));

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    countdown.icon,
                    style: const TextStyle(fontSize: AppTokens.fontSizeTitle),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countdown.title,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    daysLeft.toString(),
                    style: TextStyle(
                      fontSize: AppTokens.fontSizeLargeNumber,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    '天',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
