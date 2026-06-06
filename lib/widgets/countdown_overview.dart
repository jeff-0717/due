import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class CountdownOverview extends StatelessWidget {
  final Countdown? nearest;
  final int? reviewDays;

  const CountdownOverview({
    super.key,
    this.nearest,
    this.reviewDays,
  });

  @override
  Widget build(BuildContext context) {
    if (nearest == null) {
      return const SizedBox.shrink();
    }

    final daysLeft =
        AppDateUtils.daysUntil(nearest!.targetDate, nearest!.repeatType);
    final nextTarget = AppDateUtils.resolveNextTargetDate(
        nearest!.targetDate, nearest!.repeatType);
    final color = Color(int.parse(nearest!.color.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppTokens.spacing, AppTokens.spacing, AppTokens.spacing, 8),
      padding: const EdgeInsets.all(AppTokens.spacing + 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
      ),
      child: Column(
        children: [
          const Text(
            '最近事项',
            style: TextStyle(
              fontSize: AppTokens.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: AppTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nearest!.title,
            style: const TextStyle(
              fontSize: AppTokens.fontSizeTitle,
              fontWeight: FontWeight.w600,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$daysLeft',
            style: TextStyle(
              fontSize: AppTokens.fontSizeHero,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.1,
            ),
          ),
          const Text(
            '天后到期',
            style: TextStyle(
              fontSize: AppTokens.fontSizeBody,
              color: AppTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppDateUtils.formatDate(nextTarget),
            style: const TextStyle(
              fontSize: AppTokens.fontSizeSmall,
              color: AppTokens.textSecondary,
            ),
          ),
          if (reviewDays != null) ...[
            const SizedBox(height: 4),
            Text(
              '已复习 $reviewDays 天',
              style: const TextStyle(
                fontSize: AppTokens.fontSizeSmall,
                color: AppTokens.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
