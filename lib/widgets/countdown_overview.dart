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
        AppTokens.pagePadding,
        AppTokens.spacing,
        AppTokens.pagePadding,
        AppTokens.spacing,
      ),
      padding: const EdgeInsets.all(AppTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTokens.card,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: AppTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
                ),
              ),
              const SizedBox(width: AppTokens.spacingSm),
              const Expanded(
                child: Text(
                  '最近事项',
                  style: TextStyle(
                    fontSize: AppTokens.fontSizeSmall,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacing),
          Text(
            nearest!.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTokens.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.spacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$daysLeft',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 0.95,
                ),
              ),
              const SizedBox(width: AppTokens.spacingSm),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '天后到期',
                  style: TextStyle(
                    fontSize: AppTokens.fontSizeBody,
                    color: AppTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacing),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.spacing,
              vertical: AppTokens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTokens.surfaceLow,
              borderRadius: BorderRadius.circular(AppTokens.radius),
              border: Border.all(color: AppTokens.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_outlined,
                  size: 18,
                  color: AppTokens.textSecondary,
                ),
                const SizedBox(width: AppTokens.spacingSm),
                Text(
                  AppDateUtils.formatDate(nextTarget),
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeSmall,
                    color: AppTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (reviewDays != null) ...[
                  const Spacer(),
                  Text(
                    '已复习 $reviewDays 天',
                    style: const TextStyle(
                      fontSize: AppTokens.fontSizeSmall,
                      color: AppTokens.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
