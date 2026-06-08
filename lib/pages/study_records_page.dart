import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/study_session.dart';
import '../providers/study_session_provider.dart';
import '../theme/app_tokens.dart';
import '../widgets/empty_state.dart';

enum StudyRecordRange {
  day('日'),
  week('周'),
  month('月'),
  year('年');

  final String label;

  const StudyRecordRange(this.label);
}

class StudyRecordsPage extends ConsumerStatefulWidget {
  const StudyRecordsPage({super.key});

  @override
  ConsumerState<StudyRecordsPage> createState() => _StudyRecordsPageState();
}

class _StudyRecordsPageState extends ConsumerState<StudyRecordsPage> {
  StudyRecordRange _range = StudyRecordRange.day;

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(studyClockProvider)();
    final sessions = ref.watch(studySessionListProvider);
    final rangeWindow = _rangeWindow(now, _range);
    final scoped = sessions.where((session) {
      return !session.endedAt.isBefore(rangeWindow.start) &&
          session.endedAt.isBefore(rangeWindow.end);
    }).toList()
      ..sort((a, b) => a.endedAt.compareTo(b.endedAt));
    final rows = _groupByDate(scoped);
    final totalSeconds = scoped.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    );

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('学习记录'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          AppTokens.spacing,
          AppTokens.pagePadding,
          AppTokens.spacingLg,
        ),
        children: [
          SegmentedButton<StudyRecordRange>(
            segments: [
              for (final range in StudyRecordRange.values)
                ButtonSegment(
                  value: range,
                  label: Text(range.label),
                ),
            ],
            selected: {_range},
            onSelectionChanged: (selected) {
              setState(() => _range = selected.first);
            },
          ),
          const SizedBox(height: AppTokens.spacing),
          if (scoped.isEmpty)
            const EmptyState(message: '暂无学习记录')
          else ...[
            _SummaryCard(
              totalSeconds: totalSeconds,
              count: scoped.length,
            ),
            const SizedBox(height: AppTokens.spacing),
            _Distribution(rows: rows),
            const SizedBox(height: AppTokens.spacing),
            _RecordsTable(rows: rows),
          ],
        ],
      ),
    );
  }

  _RangeWindow _rangeWindow(DateTime now, StudyRecordRange range) {
    switch (range) {
      case StudyRecordRange.day:
        final start = DateTime(now.year, now.month, now.day);
        return _RangeWindow(start, start.add(const Duration(days: 1)));
      case StudyRecordRange.week:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final start = startOfDay.subtract(Duration(days: now.weekday - 1));
        return _RangeWindow(start, start.add(const Duration(days: 7)));
      case StudyRecordRange.month:
        final start = DateTime(now.year, now.month);
        return _RangeWindow(start, DateTime(now.year, now.month + 1));
      case StudyRecordRange.year:
        final start = DateTime(now.year);
        return _RangeWindow(start, DateTime(now.year + 1));
    }
  }

  List<_DailyStudyRow> _groupByDate(List<StudySession> sessions) {
    final grouped = <DateTime, List<StudySession>>{};
    for (final session in sessions) {
      final key = DateTime(
        session.endedAt.year,
        session.endedAt.month,
        session.endedAt.day,
      );
      grouped.putIfAbsent(key, () => []).add(session);
    }
    return grouped.entries.map((entry) {
      return _DailyStudyRow(
        date: entry.key,
        count: entry.value.length,
        totalSeconds: entry.value.fold<int>(
          0,
          (total, session) => total + session.durationSeconds,
        ),
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalSeconds;
  final int count;

  const _SummaryCard({
    required this.totalSeconds,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: '本范围累计',
                value: _formatDuration(totalSeconds),
              ),
            ),
            const SizedBox(width: AppTokens.spacing),
            Expanded(
              child: _SummaryMetric(
                label: '本范围次数',
                value: '$count 次',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTokens.textSecondary,
            fontSize: AppTokens.fontSizeSmall,
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
    );
  }
}

class _Distribution extends StatelessWidget {
  final List<_DailyStudyRow> rows;

  const _Distribution({required this.rows});

  @override
  Widget build(BuildContext context) {
    final maxSeconds = rows.fold<int>(
      1,
      (max, row) => row.totalSeconds > max ? row.totalSeconds : max,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分布',
              style: TextStyle(
                color: AppTokens.textPrimary,
                fontSize: AppTokens.fontSizeBody,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            for (final row in rows) ...[
              Row(
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      DateFormat('MM-dd').format(row.date),
                      style: const TextStyle(
                        color: AppTokens.textSecondary,
                        fontSize: AppTokens.fontSizeSmall,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: row.totalSeconds / maxSeconds,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(
                        AppTokens.radiusSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spacingSm),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordsTable extends StatelessWidget {
  final List<_DailyStudyRow> rows;

  const _RecordsTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('日期')),
            DataColumn(label: Text('专注次数')),
            DataColumn(label: Text('累计时长')),
          ],
          rows: [
            for (final row in rows)
              DataRow(
                cells: [
                  DataCell(Text(_formatDate(row.date))),
                  DataCell(Text('${row.count}')),
                  DataCell(Text(_formatDuration(row.totalSeconds))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RangeWindow {
  final DateTime start;
  final DateTime end;

  const _RangeWindow(this.start, this.end);
}

class _DailyStudyRow {
  final DateTime date;
  final int count;
  final int totalSeconds;

  const _DailyStudyRow({
    required this.date,
    required this.count,
    required this.totalSeconds,
  });
}

String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String _formatDuration(int seconds) {
  if (seconds < 60) return '$seconds 秒';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (rest == 0) return '$minutes 分钟';
  return '$minutes 分 $rest 秒';
}
