import 'package:due/models/study_session.dart';
import 'package:due/pages/study_records_page.dart';
import 'package:due/providers/study_session_provider.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:due/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('weekly mode shows range, time chart and category chart',
      (tester) async {
    final repository = _FakeStudySessionRepository([
      _session(
        id: 'monday-a',
        endedAt: DateTime(2026, 6, 8, 9),
        seconds: 900,
        category: '数学',
      ),
      _session(
        id: 'monday-b',
        endedAt: DateTime(2026, 6, 8, 15),
        seconds: 600,
        category: '英语',
      ),
      _session(
        id: 'sunday',
        endedAt: DateTime(2026, 6, 14, 20),
        seconds: 1200,
        category: '数学',
      ),
      _session(
        id: 'outside',
        endedAt: DateTime(2026, 6, 15, 8),
        seconds: 1800,
        category: '物理',
      ),
    ]);

    await tester.pumpWidget(
      _buildPage(repository: repository, now: DateTime(2026, 6, 10, 12)),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTokens.homeBackground);

    await tester.tap(find.byKey(const Key('study_range_week')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('study_records_dashboard')), findsOneWidget);
    expect(find.byKey(const Key('study_range_selector')), findsOneWidget);
    expect(find.byKey(const Key('study_date_range')), findsOneWidget);
    expect(find.byKey(const Key('study_summary_card')), findsOneWidget);
    expect(find.byKey(const Key('study_distribution_chart')), findsOneWidget);
    expect(find.byKey(const Key('study_category_chart')), findsOneWidget);
    expect(find.text('2026-06-08 - 2026-06-14'), findsOneWidget);
    expect(find.text('45 分钟'), findsOneWidget);
    expect(find.text('3 次'), findsOneWidget);
    expect(find.text('总计'), findsOneWidget);
    expect(find.text('专注次数'), findsOneWidget);
    expect(find.text('平均'), findsOneWidget);
    expect(find.text('学习分布'), findsOneWidget);
    expect(find.text('分类时长'), findsOneWidget);
    expect(find.text('数学'), findsOneWidget);
    expect(find.text('英语'), findsOneWidget);
    expect(find.text('物理'), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const Key('study_record_list')),
      120,
    );
    expect(find.byKey(const Key('study_record_list')), findsOneWidget);
    expect(find.text('Day'), findsNothing);
    expect(find.text('Week'), findsNothing);
    expect(find.text('Month'), findsNothing);
    expect(find.text('Year'), findsNothing);
  });

  testWidgets('empty state appears when no sessions exist', (tester) async {
    await tester.pumpWidget(_buildPage());

    expect(find.byKey(const Key('study_records_empty')), findsOneWidget);
  });

  testWidgets('category chart uses note before saved category', (tester) async {
    final repository = _FakeStudySessionRepository([
      _session(
        id: 'note-first',
        endedAt: DateTime(2026, 6, 8, 9),
        seconds: 900,
        note: '\u5fae\u79ef\u5206\u9519\u9898',
        category: '\u5176\u4ed6',
      ),
      _session(
        id: 'politics',
        endedAt: DateTime(2026, 6, 8, 10),
        seconds: 600,
        category: '\u653f\u6cbb',
      ),
      _session(
        id: 'legacy',
        endedAt: DateTime(2026, 6, 8, 11),
        seconds: 300,
        category: '\u7269\u7406',
      ),
    ]);

    await tester.pumpWidget(
      _buildPage(repository: repository, now: DateTime(2026, 6, 8, 12)),
    );

    expect(find.text('\u5fae\u79ef\u5206\u9519\u9898'), findsOneWidget);
    expect(find.text('\u653f\u6cbb'), findsOneWidget);
    expect(find.text('\u5176\u4ed6'), findsOneWidget);
    expect(find.text('\u7269\u7406'), findsNothing);
  });
}

Widget _buildPage({
  _FakeStudySessionRepository? repository,
  DateTime? now,
}) {
  return ProviderScope(
    overrides: [
      studySessionRepositoryProvider.overrideWithValue(
        repository ?? _FakeStudySessionRepository(),
      ),
      studyClockProvider.overrideWithValue(() => now ?? DateTime(2026, 6, 8)),
    ],
    child: const MaterialApp(home: StudyRecordsPage()),
  );
}

StudySession _session({
  required String id,
  required DateTime endedAt,
  int seconds = 2700,
  String category = '未分类',
  String note = '',
}) {
  return StudySession(
    id: id,
    startedAt: endedAt.subtract(Duration(seconds: seconds)),
    endedAt: endedAt,
    durationSeconds: seconds,
    plannedSeconds: 2700,
    note: note,
    category: category,
    createdAt: endedAt,
  );
}

class _FakeStudySessionRepository extends StudySessionRepository {
  _FakeStudySessionRepository([List<StudySession>? seed])
      : items = [...?seed],
        super(HiveService());

  final List<StudySession> items;

  @override
  List<StudySession> getAll() => [...items];
}
