import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/countdown.dart';
import '../providers/countdown_provider.dart';
import '../providers/home_config_provider.dart';
import '../providers/review_start_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
import '../widgets/empty_state.dart';

const _sage = AppTokens.homeSage;
const _sageDark = AppTokens.homeSageDark;
const _warmGray = AppTokens.homeWarmGray;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownListProvider);
    final selectedCountdownId = ref.watch(homeSelectedCountdownProvider);
    final reviewStart = ref.watch(reviewStartProvider);
    final sorted = sortedHomeCountdowns(countdowns);
    final nearest = _selectedHomeCountdown(sorted, selectedCountdownId);
    final reviewDays = reviewStart == null
        ? null
        : AppDateUtils.reviewDaysSince(reviewStart.startDate);

    return Scaffold(
      backgroundColor: AppTokens.homeBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          children: [
            _TopBar(
              onOpenMonitor: () => context.push('/monitor'),
              onOpenSettings: () => context.push('/settings'),
            ),
            const SizedBox(height: 28),
            const _PageTitle(),
            const SizedBox(height: 26),
            _HeroCountdownCard(
              countdown: nearest,
              countdowns: sorted,
              onTap: nearest == null
                  ? () => context.push('/add')
                  : () => context.push('/edit/${nearest.id}'),
              onSelected: (id) {
                ref.read(homeSelectedCountdownProvider.notifier).select(id);
              },
            ),
            const SizedBox(height: 26),
            _CountdownSummaryCard(
              reviewDays: reviewDays,
              nearest: nearest,
            ),
            const SizedBox(height: 34),
            _CountdownSection(
              countdowns: sorted,
              onAdd: () => context.push('/add'),
              onOpen: (countdown) => context.push('/edit/${countdown.id}'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '\u6dfb\u52a0\u65e5\u671f',
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

List<Countdown> sortedHomeCountdowns(List<Countdown> countdowns) {
  return List<Countdown>.from(countdowns)..sort(_compareCountdown);
}

Countdown? _selectedHomeCountdown(
  List<Countdown> sorted,
  String? selectedCountdownId,
) {
  if (sorted.isEmpty) return null;
  if (selectedCountdownId == null) return sorted.first;
  for (final countdown in sorted) {
    if (countdown.id == selectedCountdownId) return countdown;
  }
  return sorted.first;
}

int _compareCountdown(Countdown a, Countdown b) {
  final expiredCompare = _isExpiredCountdown(a)
      .toString()
      .compareTo(_isExpiredCountdown(b).toString());
  if (expiredCompare != 0) return expiredCompare;
  final aNext = AppDateUtils.resolveNextTargetDate(a.targetDate, a.repeatType);
  final bNext = AppDateUtils.resolveNextTargetDate(b.targetDate, b.repeatType);
  return aNext.compareTo(bNext);
}

bool _isExpiredCountdown(Countdown countdown) {
  if (countdown.repeatType != RepeatType.once) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(
    countdown.targetDate.year,
    countdown.targetDate.month,
    countdown.targetDate.day,
  );
  return target.isBefore(today);
}

class _TopBar extends StatelessWidget {
  final VoidCallback onOpenMonitor;
  final VoidCallback onOpenSettings;

  const _TopBar({
    required this.onOpenMonitor,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const Key('home_open_monitor'),
          tooltip: '\u9662\u6821',
          onPressed: onOpenMonitor,
          icon: const Icon(Icons.menu, color: _sageDark),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Due',
              style: TextStyle(
                color: _sageDark,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        IconButton(
          key: const Key('home_open_settings'),
          tooltip: '\u8bbe\u7f6e',
          onPressed: onOpenSettings,
          icon: const Icon(Icons.account_circle_outlined, color: _sageDark),
        ),
      ],
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\u5907\u8003\u65e5\u7a0b',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Keep your focus. Stay calm.',
          style: TextStyle(
            color: Color(0xFF27332B),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroCountdownCard extends StatelessWidget {
  final Countdown? countdown;
  final List<Countdown> countdowns;
  final VoidCallback onTap;
  final ValueChanged<String?> onSelected;

  const _HeroCountdownCard({
    required this.countdown,
    required this.countdowns,
    required this.onTap,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = countdown == null
        ? null
        : AppDateUtils.daysUntil(countdown!.targetDate, countdown!.repeatType);
    final targetDate = countdown == null
        ? null
        : AppDateUtils.resolveNextTargetDate(
            countdown!.targetDate,
            countdown!.repeatType,
          );

    return Material(
      key: const Key('home_hero_countdown'),
      color: _sage,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 232,
          child: Stack(
            children: [
              const Positioned(
                right: -60,
                top: -72,
                child: _SoftCircle(size: 238, opacity: 0.09),
              ),
              const Positioned(
                left: -44,
                bottom: -58,
                child: _SoftCircle(size: 156, opacity: 0.06),
              ),
              if (countdowns.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filledTonal(
                    key: const Key('home_select_hero_countdown'),
                    tooltip: '\u9009\u62e9\u9996\u9875\u5012\u8ba1\u65f6',
                    onPressed: () => _showCountdownSelector(context),
                    icon: const Icon(Icons.swap_vert_rounded),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countdown == null
                          ? '\u8fd8\u6ca1\u6709\u76ee\u6807\u65e5\u671f'
                          : '\u8ddd\u79bb\u76ee\u6807\u8003\u8bd5\u8fd8\u6709',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _sageDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              countdown == null ? '--' : '$daysLeft',
                              style: const TextStyle(
                                color: _sageDark,
                                fontSize: 104,
                                fontWeight: FontWeight.w900,
                                height: 0.82,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                '\u5929',
                                style: TextStyle(
                                  color: _sageDark,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (countdown != null && targetDate != null) ...[
                      Center(
                        child: Text(
                          '${countdown!.title} \u00b7 ${AppDateUtils.formatDate(targetDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _sageDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ] else
                      const Center(
                        child: Text(
                          '\u70b9\u51fb\u6dfb\u52a0',
                          style: TextStyle(
                            color: _sageDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCountdownSelector(BuildContext context) async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTokens.homeBackground,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const Text(
                '\u9009\u62e9\u9996\u9875\u7f6e\u9876\u5012\u8ba1\u65f6',
                style: TextStyle(
                  color: _sageDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              for (final item in countdowns)
                ListTile(
                  key: Key('home_select_countdown_${item.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: item.displayColor.withValues(alpha: 0.12),
                    child: Text(item.icon),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    AppDateUtils.formatDate(
                      AppDateUtils.resolveNextTargetDate(
                        item.targetDate,
                        item.repeatType,
                      ),
                    ),
                  ),
                  trailing: countdown?.id == item.id
                      ? const Icon(Icons.check, color: _sageDark)
                      : null,
                  onTap: () => Navigator.pop(context, item.id),
                ),
            ],
          ),
        );
      },
    );
    if (selectedId != null) onSelected(selectedId);
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _SoftCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _CountdownSummaryCard extends StatelessWidget {
  final int? reviewDays;
  final Countdown? nearest;

  const _CountdownSummaryCard({
    required this.reviewDays,
    required this.nearest,
  });

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      keyName: 'home_countdown_count_card',
      color: _warmGray,
      icon: Icons.event_available_outlined,
      title: '\u590d\u4e60\u7edf\u8ba1',
      value: reviewDays == null ? '--' : '$reviewDays',
      unit: '\u5929',
      label: reviewDays == null
          ? '\u672a\u8bbe\u7f6e\u590d\u4e60\u65e5\u671f'
          : '\u5df2\u575a\u6301\u590d\u4e60',
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String keyName;
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String label;

  const _InsightCard({
    required this.keyName,
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(keyName),
      height: 202,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF435766)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF435766),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: _sageDark,
                      fontSize: 76,
                      fontWeight: FontWeight.w900,
                      height: 0.86,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        color: Color(0xFF506170),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8A98A0),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownSection extends StatelessWidget {
  final List<Countdown> countdowns;
  final VoidCallback onAdd;
  final ValueChanged<Countdown> onOpen;

  const _CountdownSection({
    required this.countdowns,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home_countdown_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '\u5168\u90e8\u5012\u8ba1\u65f6',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              key: const Key('home_add_countdown_text_button'),
              onPressed: onAdd,
              child: const Text('\u6dfb\u52a0'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (countdowns.isEmpty)
          EmptyState(
            message: '\u6682\u65e0\u5012\u8ba1\u65f6',
            actionLabel: '\u6dfb\u52a0\u91cd\u8981\u65e5\u671f',
            onAction: onAdd,
          )
        else
          Column(
            children: [
              for (final countdown in countdowns)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CountdownListTile(
                    countdown: countdown,
                    onTap: () => onOpen(countdown),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _CountdownListTile extends StatelessWidget {
  final Countdown countdown;
  final VoidCallback onTap;

  const _CountdownListTile({
    required this.countdown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextTarget = AppDateUtils.resolveNextTargetDate(
      countdown.targetDate,
      countdown.repeatType,
    );
    final daysLeft = AppDateUtils.daysUntil(
      countdown.targetDate,
      countdown.repeatType,
    );
    final color = countdown.displayColor;
    final isExpired = _isExpiredCountdown(countdown);
    final textDecoration =
        isExpired ? TextDecoration.lineThrough : TextDecoration.none;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    countdown.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countdown.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ).copyWith(
                        color:
                            isExpired ? const Color(0xFF8A8F86) : Colors.black,
                        decoration: textDecoration,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatDate(nextTarget),
                      style: TextStyle(
                        color: isExpired
                            ? const Color(0xFF8A8F86)
                            : const Color(0xFF5A665B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: textDecoration,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE1E4DC)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$daysLeft',
                      style: TextStyle(
                        color: isExpired ? const Color(0xFF8A8F86) : color,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        decoration: textDecoration,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '\u5929',
                      style: TextStyle(
                        color: Color(0xFF6C7468),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
