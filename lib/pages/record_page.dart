import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/study_session_provider.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_section.dart';

class RecordPage extends ConsumerWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final summary = ref.watch(todayStudySummaryProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('记录'),
        actions: [
          IconButton(
            tooltip: '学习记录',
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => context.push('/study-records'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pagePadding,
              AppTokens.spacingLg,
              AppTokens.pagePadding,
              AppTokens.spacing,
            ),
            child: _TimerDial(timeText: _formatTimer(timer.remainingSeconds)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.pagePadding,
            ),
            child: _TimerControls(
              onStart: timerNotifier.start,
              onPause: timerNotifier.pause,
              onResume: timerNotifier.resume,
              onFinish: timerNotifier.finish,
              onReset: timerNotifier.reset,
            ),
          ),
          const SizedBox(height: AppTokens.spacingLg),
          AppSection(
            title: '今日统计',
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: '今日专注次数',
                    value: '${summary.count}',
                  ),
                ),
                const SizedBox(width: AppTokens.spacingSm),
                Expanded(
                  child: _StatTile(
                    label: '今日累计时长',
                    value: _formatDuration(summary.totalSeconds),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds 秒';
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    if (rest == 0) return '$minutes 分钟';
    return '$minutes 分 $rest 秒';
  }
}

class _TimerDial extends StatelessWidget {
  final String timeText;

  const _TimerDial({required this.timeText});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth > 280 ? 280.0 : constraints.maxWidth;
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.card,
                border: Border.all(color: AppTokens.border, width: 10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  timeText,
                  style: const TextStyle(
                    color: AppTokens.textPrimary,
                    fontSize: AppTokens.fontSizeLargeNumber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimerControls extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Future<void> Function() onFinish;
  final VoidCallback onReset;

  const _TimerControls({
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppTokens.spacingSm,
      runSpacing: AppTokens.spacingSm,
      children: [
        IconButton.filled(
          tooltip: '开始',
          icon: const Icon(Icons.play_arrow),
          onPressed: onStart,
        ),
        IconButton.outlined(
          tooltip: '暂停',
          icon: const Icon(Icons.pause),
          onPressed: onPause,
        ),
        IconButton.outlined(
          tooltip: '继续',
          icon: const Icon(Icons.replay),
          onPressed: onResume,
        ),
        IconButton.outlined(
          tooltip: '结束',
          icon: const Icon(Icons.stop),
          onPressed: () => onFinish(),
        ),
        IconButton.outlined(
          tooltip: '重置',
          icon: const Icon(Icons.refresh),
          onPressed: onReset,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTokens.textSecondary,
                fontSize: AppTokens.fontSizeSmall,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTokens.spacingXs),
            Text(
              value,
              style: const TextStyle(
                color: AppTokens.textPrimary,
                fontSize: AppTokens.fontSizeBodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
