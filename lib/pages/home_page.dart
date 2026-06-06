import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/countdown.dart';
import '../providers/countdown_provider.dart';
import '../providers/review_start_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
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
            tooltip: 'School Monitoring',
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
              children: [
                _MonitorEntry(onTap: () => context.push('/monitor')),
                EmptyState(
                  message: 'No countdowns yet',
                  actionLabel: 'Start with one important date',
                  onAction: () => context.push('/add'),
                ),
              ],
            )
          : ListView(
              children: [
                CountdownOverview(
                  nearest: nearest,
                  reviewDays: reviewDays,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppTokens.spacing, 16, AppTokens.spacing, 8),
                  child: Text(
                    'All Countdowns',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTokens.spacing,
                    0,
                    AppTokens.spacing,
                    8,
                  ),
                  child: Text(
                    'Sorted by next date',
                    style: TextStyle(
                      fontSize: AppTokens.fontSizeSmall,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ),
                ...sorted.map(
                  (item) => CountdownCard(
                    countdown: item,
                    onTap: () => context.push('/edit/${item.id}'),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
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
        AppTokens.spacing,
        AppTokens.spacing,
        AppTokens.spacing,
        0,
      ),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.travel_explore_outlined),
          title: const Text('School Monitoring'),
          subtitle: const Text('Track RSS and static notice pages'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
