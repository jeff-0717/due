import 'package:due/models/study_session.dart';
import 'package:due/pages/record_page.dart';
import 'package:due/providers/study_session_provider.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('record page shows default timer, controls and today stats',
      (tester) async {
    final now = DateTime(2026, 6, 8, 12);
    final repository = _FakeStudySessionRepository([
      _session(id: 'today', endedAt: DateTime(2026, 6, 8, 9), seconds: 900),
      _session(id: 'yesterday', endedAt: DateTime(2026, 6, 7, 23)),
    ]);

    await tester.pumpWidget(_buildRecord(repository: repository, now: now));

    expect(find.text('45:00'), findsOneWidget);
    expect(find.text('今日专注次数'), findsOneWidget);
    expect(find.text('今日累计时长'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('15 分钟'), findsOneWidget);
    expect(find.byTooltip('开始'), findsOneWidget);
    expect(find.byTooltip('暂停'), findsOneWidget);
    expect(find.byTooltip('继续'), findsOneWidget);
    expect(find.byTooltip('结束'), findsOneWidget);
    expect(find.byTooltip('重置'), findsOneWidget);
  });

  testWidgets('record page study-record action navigates to study records',
      (tester) async {
    await tester.pumpWidget(_buildRecord());

    await tester.tap(find.byTooltip('学习记录'));
    await tester.pumpAndSettle();

    expect(find.text('Study records route'), findsOneWidget);
  });
}

Widget _buildRecord({
  _FakeStudySessionRepository? repository,
  DateTime? now,
}) {
  final router = GoRouter(
    initialLocation: '/record',
    routes: [
      GoRoute(path: '/record', builder: (_, __) => const RecordPage()),
      GoRoute(
        path: '/study-records',
        builder: (_, __) => const Scaffold(body: Text('Study records route')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      studySessionRepositoryProvider.overrideWithValue(
        repository ?? _FakeStudySessionRepository(),
      ),
      studyClockProvider.overrideWithValue(() => now ?? DateTime(2026, 6, 8)),
    ],
    child: MaterialApp.router(routerConfig: router),
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

  @override
  Future<StudySession> createSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
    int plannedSeconds = 2700,
  }) async {
    final session = StudySession(
      id: 'session-${items.length + 1}',
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      plannedSeconds: plannedSeconds,
      createdAt: endedAt,
    );
    items.add(session);
    return session;
  }
}
