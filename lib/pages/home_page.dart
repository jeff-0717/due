import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/countdown.dart';
import '../providers/countdown_provider.dart';
import '../providers/review_start_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
import '../widgets/app_section.dart';
import '../widgets/countdown_card.dart';
import '../widgets/countdown_overview.dart';
import '../widgets/empty_state.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownListProvider);
    final reviewStart = ref.watch(reviewStartProvider);

    final sorted = List<Countdown>.from(countdowns)
      ..sort((a, b) {
        final aNext =
            AppDateUtils.resolveNextTargetDate(a.targetDate, a.repeatType);
        final bNext =
            AppDateUtils.resolveNextTargetDate(b.targetDate, b.repeatType);
        return aNext.compareTo(bNext);
      });

    final nearest = sorted.isNotEmpty ? sorted.first : null;
    final reviewDays = reviewStart != null
        ? AppDateUtils.reviewDaysSince(reviewStart.startDate)
        : null;

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('Due'),
        actions: [
          IconButton(
            tooltip: '院校信息监控',
            icon: const Icon(Icons.travel_explore_outlined),
            onPressed: () => context.push('/monitor'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: countdowns.isEmpty
          ? ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _HomeHeader(reviewDays: reviewDays),
                _MonitorEntry(onTap: () => context.push('/monitor')),
                if (reviewDays != null) _ReviewDaysCard(days: reviewDays),
                EmptyState(
                  message: '暂无倒计时',
                  actionLabel: '添加重要日期',
                  onAction: () => context.push('/add'),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _HomeHeader(reviewDays: reviewDays),
                CountdownOverview(
                  nearest: nearest,
                  reviewDays: reviewDays,
                ),
                _MonitorEntry(onTap: () => context.push('/monitor')),
                AppSection(
                  title: '全部倒计时',
                  subtitle: '按最近日期排序',
                  child: Column(
                    children: sorted
                        .map(
                          (item) => CountdownCard(
                            countdown: item,
                            onTap: () => context.push('/edit/${item.id}'),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final int? reviewDays;

  const _HomeHeader({required this.reviewDays});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        AppTokens.spacing,
        AppTokens.pagePadding,
        0,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '备考日程',
                  style: TextStyle(
                    color: AppTokens.textPrimary,
                    fontSize: AppTokens.fontSizeTitle,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: AppTokens.spacingXs),
                Text(
                  '把重要日期和院校动态放在一处',
                  style: TextStyle(
                    color: AppTokens.textSecondary,
                    fontSize: AppTokens.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          if (reviewDays != null)
            AppStatusChip(
              label: '复习第 $reviewDays 天',
              icon: Icons.auto_stories_outlined,
            ),
        ],
      ),
    );
  }
}

class _MonitorEntry extends StatelessWidget {
  final VoidCallback onTap;

  const _MonitorEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        AppTokens.spacing,
        AppTokens.pagePadding,
        0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing,
            vertical: AppTokens.spacingSm,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTokens.successSoft,
              borderRadius: BorderRadius.circular(AppTokens.radius),
            ),
            child: const Icon(
              Icons.travel_explore_outlined,
              color: AppTokens.primary,
            ),
          ),
          title: const Text(
            '院校信息监控',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('关注招生简章、复试名单、拟录取等动态'),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppTokens.textMuted,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ReviewDaysCard extends StatelessWidget {
  final int days;

  const _ReviewDaysCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        AppTokens.spacing,
        AppTokens.pagePadding,
        0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '复习进度',
                style: TextStyle(
                  fontSize: AppTokens.fontSizeSmall,
                  color: AppTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '已复习 $days 天',
                style: const TextStyle(
                  fontSize: AppTokens.fontSizeBody,
                  color: AppTokens.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
