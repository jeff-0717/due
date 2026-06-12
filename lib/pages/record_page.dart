import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/study_session_provider.dart';
import '../services/focus_notification_service.dart';
import '../theme/app_tokens.dart';

const _otherLabel = '\u5176\u4ed6';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  final _noteController = TextEditingController();
  FocusNotificationService? _notificationService;
  var _category = _otherLabel;

  static const _categories = [
    _FocusCategory(key: 'math', label: '\u6570\u5b66'),
    _FocusCategory(key: 'english', label: '\u82f1\u8bed'),
    _FocusCategory(key: 'politics', label: '\u653f\u6cbb'),
    _FocusCategory(key: 'other', label: _otherLabel),
  ];

  @override
  void dispose() {
    _notificationService?.setActionHandler(null);
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showFocusNotification({required bool isRunning}) {
    final notificationService = _notificationService;
    if (notificationService == null) return Future<void>.value();
    final activeTimer = ref.read(focusTimerProvider);
    return notificationService.showRunningTimer(
      plannedSeconds: activeTimer.plannedSeconds,
      remainingSeconds: activeTimer.remainingSeconds,
      isRunning: isRunning,
      mode: activeTimer.mode.name,
    );
  }

  Future<void> _finishFocusTimer() async {
    await ref.read(focusTimerProvider.notifier).finish(
          note: _noteController.text,
          category: _category,
        );
    _noteController.clear();
    if (mounted) {
      setState(() => _category = _otherLabel);
    }
    await _notificationService?.cancel();
  }

  Future<void> _handleNotificationAction(String action) async {
    final timerNotifier = ref.read(focusTimerProvider.notifier);
    switch (action) {
      case FocusNotificationService.actionPause:
        timerNotifier.pause();
        await _showFocusNotification(isRunning: false);
      case FocusNotificationService.actionResume:
        timerNotifier.resume();
        await _showFocusNotification(isRunning: true);
      case FocusNotificationService.actionFinish:
        await _finishFocusTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(focusTimerProvider);
    final summary = ref.watch(todayStudySummaryProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);
    final notificationService = ref.read(focusNotificationServiceProvider);
    if (!identical(_notificationService, notificationService)) {
      _notificationService?.setActionHandler(null);
      _notificationService = notificationService;
      notificationService.setActionHandler(_handleNotificationAction);
    }

    return Scaffold(
      body: Container(
        key: const Key('record_sky_focus_page'),
        decoration: const BoxDecoration(color: AppTokens.homeBackground),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 104),
            children: [
              _Header(onOpenRecords: () => context.push('/study-records')),
              const SizedBox(height: 34),
              _TimerDial(
                timeText: _formatTimer(timer.remainingSeconds),
                statusText: timer.isRunning
                    ? '\u6b63\u5728\u4e13\u6ce8'
                    : '\u51c6\u5907\u5f00\u59cb',
              ),
              const SizedBox(height: 20),
              _DurationSelector(
                selectedMode: timer.mode,
                enabled: timer.startedAt == null,
                onSelected: timerNotifier.setMode,
              ),
              const SizedBox(height: 16),
              _NoteEditor(
                controller: _noteController,
                selectedCategory: _category,
                categories: _categories,
                enabled: timer.startedAt == null,
                onCategorySelected: (category) {
                  setState(() => _category = category.label);
                },
              ),
              const SizedBox(height: 28),
              _TimerControls(
                isRunning: timer.isRunning,
                hasStarted: timer.startedAt != null,
                onStart: () async {
                  if (timer.startedAt == null) {
                    timerNotifier.start();
                  } else {
                    timerNotifier.resume();
                  }
                  await _showFocusNotification(isRunning: true);
                },
                onPause: () async {
                  timerNotifier.pause();
                  await _showFocusNotification(isRunning: false);
                },
                onFinish: () async {
                  await _finishFocusTimer();
                },
                onReset: () async {
                  timerNotifier.reset();
                  await notificationService.cancel();
                },
              ),
              const SizedBox(height: 32),
              _TodayStats(summary: summary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onOpenRecords;

  const _Header({required this.onOpenRecords});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u6c89\u6d78\u4e13\u6ce8',
                style: TextStyle(
                  color: Color(0xFF16435F),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\u4eca\u5929\u4e5f\u8981\u7a33\u7a33\u5b8c\u6210',
                style: TextStyle(
                  color: Color(0xFF3D7190),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          key: const Key('record_open_study_records'),
          tooltip: '\u5b66\u4e60\u8bb0\u5f55',
          onPressed: onOpenRecords,
          icon: const Icon(Icons.bar_chart_rounded),
        ),
      ],
    );
  }
}

class _TimerDial extends StatelessWidget {
  final String timeText;
  final String statusText;

  const _TimerDial({
    required this.timeText,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth > 310 ? 310.0 : constraints.maxWidth;
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: Container(
              key: const Key('record_timer_dial'),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.86),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.92),
                  width: 14,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1675A7).withValues(alpha: 0.18),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(
                      color: Color(0xFF4B7F9C),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: Color(0xFF123C57),
                      fontSize: 58,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '\u4e13\u6ce8\u65f6\u957f',
                    style: TextStyle(
                      color: Color(0xFF6E98AE),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final FocusTimerMode selectedMode;
  final bool enabled;
  final ValueChanged<FocusTimerMode> onSelected;

  const _DurationSelector({
    required this.selectedMode,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _DurationChip(
          keyName: 'focus_duration_45',
          label: '45\u5206\u949f',
          selected: selectedMode == FocusTimerMode.fixed45,
          enabled: enabled,
          onSelected: () => onSelected(FocusTimerMode.fixed45),
        ),
        _DurationChip(
          keyName: 'focus_duration_unlimited',
          label: '\u65e0\u9650\u8ba1\u65f6',
          selected: selectedMode == FocusTimerMode.unlimited,
          enabled: enabled,
          onSelected: () => onSelected(FocusTimerMode.unlimited),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String keyName;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  const _DurationChip({
    required this.keyName,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: Key(keyName),
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onSelected() : null,
      selectedColor: const Color(0xFF1D6C93),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF315D75),
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.86)),
      backgroundColor: Colors.white.withValues(alpha: 0.62),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
      ),
    );
  }
}

class _NoteEditor extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCategory;
  final List<_FocusCategory> categories;
  final bool enabled;
  final ValueChanged<_FocusCategory> onCategorySelected;

  const _NoteEditor({
    required this.controller,
    required this.selectedCategory,
    required this.categories,
    required this.enabled,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
      ),
      child: Column(
        children: [
          TextField(
            key: const Key('focus_note_field'),
            controller: controller,
            enabled: enabled,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: '\u5907\u6ce8',
              hintText: '\u4f8b\u5982\uff1a\u6570\u5b66\u9519\u9898',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            key: const Key('focus_category_selector'),
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                ChoiceChip(
                  key: Key('focus_category_${category.key}'),
                  label: Text(category.label),
                  selected: selectedCategory == category.label,
                  onSelected:
                      enabled ? (_) => onCategorySelected(category) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusCategory {
  final String key;
  final String label;

  const _FocusCategory({
    required this.key,
    required this.label,
  });
}

class _TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool hasStarted;
  final Future<void> Function() onStart;
  final Future<void> Function() onPause;
  final Future<void> Function() onFinish;
  final Future<void> Function() onReset;

  const _TimerControls({
    required this.isRunning,
    required this.hasStarted,
    required this.onStart,
    required this.onPause,
    required this.onFinish,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundAction(
          tooltip: '\u91cd\u7f6e',
          icon: Icons.refresh,
          onPressed: onReset,
        ),
        const SizedBox(width: 18),
        SizedBox.square(
          dimension: 72,
          child: IconButton.filled(
            tooltip: isRunning ? '\u6682\u505c' : '\u5f00\u59cb',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1D6C93),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
            iconSize: 34,
            icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: isRunning ? onPause : onStart,
          ),
        ),
        const SizedBox(width: 18),
        _RoundAction(
          tooltip: '\u7ed3\u675f',
          icon: Icons.stop,
          onPressed: hasStarted ? () => onFinish() : null,
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 52,
      child: IconButton.outlined(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF1D5C7F),
          disabledForegroundColor: const Color(0xFF7EA6BB),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
          backgroundColor: Colors.white.withValues(alpha: 0.56),
          shape: const CircleBorder(),
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

class _TodayStats extends StatelessWidget {
  final StudySummary summary;

  const _TodayStats({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('record_today_stats'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: '\u4eca\u65e5\u4e13\u6ce8',
              value: '${summary.count}',
              unit: '\u6b21',
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: const Color(0xFFD8EAF5),
          ),
          Expanded(
            child: _StatItem(
              label: '\u4eca\u65e5\u7d2f\u8ba1',
              value: _formatDuration(summary.totalSeconds),
              unit: '',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5C8298),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Color(0xFF153C55),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    color: Color(0xFF5C8298),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatTimer(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${rest.toString().padLeft(2, '0')}';
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '$seconds\u79d2';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (rest == 0) return '$minutes\u5206\u949f';
  return '$minutes\u5206$rest\u79d2';
}
