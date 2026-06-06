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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: countdowns.isEmpty
          ? EmptyState(
              message: 'No countdowns yet',
              actionLabel: 'Add your first countdown',
              onAction: () => context.push('/add'),
            )
          : ListView(
              children: [
                CountdownOverview(
                  nearest: nearest,
                  reviewDays: reviewDays,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppTokens.spacing, 16, AppTokens.spacing, 8),
                  child: Text(
                    'All Countdowns',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
