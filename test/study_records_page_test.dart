import 'package:due/models/study_session.dart';
import 'package:due/pages/study_records_page.dart';
import 'package:due/providers/study_session_provider.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('weekly mode groups sessions by date and excludes out of range',
      (tester) async {
    final repository = _FakeStudySessionRepository([
      _session(id: 'monday-a', endedAt: DateTime(2026, 6, 8, 9), seconds: 900),
      _session(id: 'monday-b', endedAt: DateTime(2026, 6, 8, 15), seconds: 600),
      _session(id: 'sunday', endedAt: DateTime(2026, 6, 14, 20), seconds: 1200),
      _session(id: 'outside', endedAt: DateTime(2026, 6, 15, 8), seconds: 1800),
    ]);

    await tester.pumpWidget(
      _buildPage(repository: repository, now: DateTime(2026, 6, 10, 12)),
    );

    await tester.tap(find.text('周'));
    await tester.pumpAndSettle();

    expect(find.text('本范围累计'), findsOneWidget);
    expect(find.text('45 分钟'), findsOneWidget);
    expect(find.text('3 次'), findsOneWidget);
    expect(find.text('日期'), findsOneWidget);
    expect(find.text('专注次数'), findsOneWidget);
    expect(find.text('累计时长'), findsOneWidget);
    expect(find.text('2026-06-08'), findsOneWidget);
    expect(find.text('2026-06-14'), findsOneWidget);
    expect(find.text('2026-06-15'), findsNothing);
  });

  testWidgets('empty state appears when no sessions exist', (tester) async {
    await tester.pumpWidget(_buildPage());

    expect(find.text('暂无学习记录'), findsOneWidget);
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
}) {
  return StudySession(
    id: id,
    startedAt: endedAt.subtract(Duration(seconds: seconds)),
    endedAt: endedAt,
    durationSeconds: seconds,
    plannedSeconds: 2700,
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
