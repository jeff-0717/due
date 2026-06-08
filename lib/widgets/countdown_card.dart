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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTokens.radius),
                  border: Border.all(color: color.withValues(alpha: 0.16)),
                ),
                child: Center(
                  child: Text(
                    countdown.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countdown.title,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeBody,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.spacingXs),
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
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    '天后',
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
