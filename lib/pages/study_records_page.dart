import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/study_session.dart';
import '../providers/study_session_provider.dart';
import '../theme/app_tokens.dart';

enum StudyRecordRange {
  day('\u65e5'),
  week('\u5468'),
  month('\u6708'),
  year('\u5e74');

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
    final categoryRows = _groupByCategory(scoped);
    final totalSeconds = scoped.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    );

    return Scaffold(
      backgroundColor: AppTokens.homeBackground,
      appBar: AppBar(
        title: const Text('\u5b66\u4e60\u8bb0\u5f55'),
        backgroundColor: AppTokens.homeBackground,
        foregroundColor: AppTokens.homeSageDark,
        elevation: 0,
      ),
      body: ListView(
        key: const Key('study_records_dashboard'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _RangeSelector(
            selected: _range,
            onSelected: (range) => setState(() => _range = range),
          ),
          const SizedBox(height: 14),
          _DateRangeLabel(rangeWindow: rangeWindow),
          const SizedBox(height: 14),
          if (scoped.isEmpty)
            const _StudyRecordsEmpty()
          else ...[
            _SummaryCard(
              totalSeconds: totalSeconds,
              count: scoped.length,
              averageSeconds: totalSeconds ~/ scoped.length,
            ),
            const SizedBox(height: 14),
            _DistributionChart(rows: rows),
            const SizedBox(height: 14),
            _CategoryChart(rows: categoryRows),
            const SizedBox(height: 14),
            _RecordList(rows: rows),
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

  List<_CategoryStudyRow> _groupByCategory(List<StudySession> sessions) {
    final grouped = <String, List<StudySession>>{};
    for (final session in sessions) {
      final note = session.note.trim();
      final category =
          note.isNotEmpty ? note : _normalizedStudyCategory(session.category);
      grouped.putIfAbsent(category, () => []).add(session);
    }
    return grouped.entries.map((entry) {
      return _CategoryStudyRow(
        category: entry.key,
        totalSeconds: entry.value.fold<int>(
          0,
          (total, session) => total + session.durationSeconds,
        ),
      );
    }).toList()
      ..sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));
  }
}

class _RangeSelector extends StatelessWidget {
  final StudyRecordRange selected;
  final ValueChanged<StudyRecordRange> onSelected;

  const _RangeSelector({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('study_range_selector'),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: const Color(0xFFDCEAF2)),
      ),
      child: Row(
        children: [
          for (final range in StudyRecordRange.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _RangeButton(
                  range: range,
                  selected: selected == range,
                  onPressed: () => onSelected(range),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  final StudyRecordRange range;
  final bool selected;
  final VoidCallback onPressed;

  const _RangeButton({
    required this.range,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key('study_range_${range.name}'),
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : const Color(0xFF597F93),
        backgroundColor:
            selected ? const Color(0xFF1D6C93) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
        ),
        padding: const EdgeInsets.symmetric(vertical: 11),
      ),
      onPressed: onPressed,
      child: Text(
        range.label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DateRangeLabel extends StatelessWidget {
  final _RangeWindow rangeWindow;

  const _DateRangeLabel({required this.rangeWindow});

  @override
  Widget build(BuildContext context) {
    final endInclusive = rangeWindow.end.subtract(const Duration(days: 1));
    return Row(
      key: const Key('study_date_range'),
      children: [
        const Icon(
          Icons.calendar_month_rounded,
          color: Color(0xFF4D7E99),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '${_formatDate(rangeWindow.start)} - ${_formatDate(endInclusive)}',
          style: const TextStyle(
            color: Color(0xFF315D75),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StudyRecordsEmpty extends StatelessWidget {
  const _StudyRecordsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('study_records_empty'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: const Color(0xFFDCEAF2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 44,
            color: Color(0xFF8EB0C2),
          ),
          SizedBox(height: 12),
          Text(
            '\u6682\u65e0\u5b66\u4e60\u8bb0\u5f55',
            style: TextStyle(
              color: Color(0xFF4E7489),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalSeconds;
  final int count;
  final int averageSeconds;

  const _SummaryCard({
    required this.totalSeconds,
    required this.count,
    required this.averageSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('study_summary_card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1D6C93),
        borderRadius: BorderRadius.circular(AppTokens.radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D6C93).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: '\u603b\u8ba1',
              value: _formatDuration(totalSeconds),
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: '\u4e13\u6ce8\u6b21\u6570',
              value: '$count \u6b21',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: '\u5e73\u5747',
              value: _formatDuration(averageSeconds),
            ),
          ),
        ],
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
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DistributionChart extends StatelessWidget {
  final List<_DailyStudyRow> rows;

  const _DistributionChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final maxSeconds = rows.fold<int>(
      1,
      (max, row) => row.totalSeconds > max ? row.totalSeconds : max,
    );

    return Container(
      key: const Key('study_distribution_chart'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: const Color(0xFFDCEAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u5b66\u4e60\u5206\u5e03',
            style: TextStyle(
              color: Color(0xFF153C55),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final row in rows)
                  Expanded(
                    child: _ChartBar(
                      row: row,
                      ratio: row.totalSeconds / maxSeconds,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final _DailyStudyRow row;
  final double ratio;

  const _ChartBar({
    required this.row,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${row.totalSeconds ~/ 60}',
          style: const TextStyle(
            color: Color(0xFF5A8196),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 76,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.08, 1),
              child: Container(
                width: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF74BDE8),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('MM/dd').format(row.date),
          style: const TextStyle(
            color: Color(0xFF6D8FA1),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final List<_CategoryStudyRow> rows;

  const _CategoryChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = rows.fold<int>(
      0,
      (total, row) => total + row.totalSeconds,
    );
    final maxSeconds = rows.fold<int>(
      1,
      (max, row) => row.totalSeconds > max ? row.totalSeconds : max,
    );
    return Container(
      key: const Key('study_category_chart'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: const Color(0xFFDCEAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u5206\u7c7b\u65f6\u957f',
            style: TextStyle(
              color: Color(0xFF153C55),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final row in rows) ...[
            Row(
              children: [
                SizedBox(
                  width: 68,
                  child: Text(
                    row.category,
                    style: const TextStyle(
                      color: Color(0xFF153C55),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: row.totalSeconds / maxSeconds,
                      minHeight: 6,
                      color: _categoryColor(row.category),
                      backgroundColor: const Color(0xFFE8F1F6),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 72,
                  child: Text(
                    _formatDuration(row.totalSeconds),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF4F7488),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${((row.totalSeconds / totalSeconds) * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF6F8FA1),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  final List<_DailyStudyRow> rows;

  const _RecordList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('study_record_list'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: const Color(0xFFDCEAF2)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _RecordRow(row: rows[index]),
            if (index != rows.length - 1)
              const Divider(height: 1, color: Color(0xFFE4EEF4)),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final _DailyStudyRow row;

  const _RecordRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F3FC),
              borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF1D6C93),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(row.date),
                  style: const TextStyle(
                    color: Color(0xFF153C55),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${row.count} \u6b21\u4e13\u6ce8',
                  style: const TextStyle(
                    color: Color(0xFF6B8EA1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(row.totalSeconds),
            style: const TextStyle(
              color: Color(0xFF1D6C93),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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

class _CategoryStudyRow {
  final String category;
  final int totalSeconds;

  const _CategoryStudyRow({
    required this.category,
    required this.totalSeconds,
  });
}

String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String _formatDuration(int seconds) {
  if (seconds < 60) return '$seconds \u79d2';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (rest == 0) return '$minutes \u5206\u949f';
  return '$minutes \u5206 $rest \u79d2';
}

Color _categoryColor(String category) {
  switch (category) {
    case '\u6570\u5b66':
      return const Color(0xFF6A9FE6);
    case '\u82f1\u8bed':
      return const Color(0xFF62B6E8);
    case '\u653f\u6cbb':
      return const Color(0xFF70BE8A);
    case '\u5176\u4ed6':
      return const Color(0xFFF2A24A);
    default:
      return const Color(0xFF8D92D8);
  }
}

String _normalizedStudyCategory(String category) {
  switch (category.trim()) {
    case '\u6570\u5b66':
    case '\u82f1\u8bed':
    case '\u653f\u6cbb':
      return category.trim();
    default:
      return '\u5176\u4ed6';
  }
}
