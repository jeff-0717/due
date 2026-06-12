import 'package:due/models/study_session.dart';
import 'package:due/pages/record_page.dart';
import 'package:due/providers/study_session_provider.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/focus_notification_service.dart';
import 'package:due/services/hive_service.dart';
import 'package:due/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('record page shows 45-minute and unlimited modes with note input',
      (tester) async {
    final now = DateTime(2026, 6, 8, 12);
    final repository = _FakeStudySessionRepository([
      _session(id: 'today', endedAt: DateTime(2026, 6, 8, 9), seconds: 900),
      _session(id: 'yesterday', endedAt: DateTime(2026, 6, 7, 23)),
    ]);

    await tester.pumpWidget(_buildRecord(repository: repository, now: now));

    expect(find.byKey(const Key('record_sky_focus_page')), findsOneWidget);
    final page = tester.widget<Container>(
      find.byKey(const Key('record_sky_focus_page')),
    );
    expect((page.decoration as BoxDecoration).color, AppTokens.homeBackground);
    expect(find.byKey(const Key('record_timer_dial')), findsOneWidget);
    expect(find.text('45:00'), findsOneWidget);
    expect(find.byKey(const Key('focus_duration_45')), findsOneWidget);
    expect(find.byKey(const Key('focus_duration_unlimited')), findsOneWidget);
    expect(find.byKey(const Key('focus_note_field')), findsOneWidget);
    expect(find.byKey(const Key('focus_category_selector')), findsOneWidget);
    expect(find.byKey(const Key('focus_category_math')), findsOneWidget);
    expect(find.byKey(const Key('focus_category_english')), findsOneWidget);
    expect(find.byKey(const Key('focus_category_politics')), findsOneWidget);
    expect(find.byKey(const Key('focus_category_other')), findsOneWidget);
    expect(find.byKey(const Key('focus_category_uncategorized')), findsNothing);
    expect(find.byKey(const Key('focus_category_physics')), findsNothing);
    expect(find.byKey(const Key('focus_category_chinese')), findsNothing);
    expect(find.byKey(const Key('focus_duration_90')), findsNothing);
    expect(find.byKey(const Key('focus_duration_120')), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('record page study-record action navigates to study records',
      (tester) async {
    await tester.pumpWidget(_buildRecord());

    await tester.tap(find.byKey(const Key('record_open_study_records')));
    await tester.pumpAndSettle();

    expect(find.text('Study records route'), findsOneWidget);
  });

  testWidgets('record page unlimited mode counts up and starts notification',
      (tester) async {
    var now = DateTime(2026, 6, 8, 12);
    final notificationService = _FakeFocusNotificationService();
    await tester.pumpWidget(
      _buildRecord(
        nowGetter: () => now,
        notificationService: notificationService,
      ),
    );

    await tester
        .ensureVisible(find.byKey(const Key('focus_duration_unlimited')));
    await tester.tap(find.byKey(const Key('focus_duration_unlimited')));
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    await tester.ensureVisible(find.byIcon(Icons.play_arrow));
    await tester.tap(find.byIcon(Icons.play_arrow));
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 1100));

    await tester.ensureVisible(find.byKey(const Key('record_timer_dial')));
    expect(find.text('00:01'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(notificationService.startedMode, 'unlimited');
  });

  testWidgets('record page saves note and category when finishing',
      (tester) async {
    var now = DateTime(2026, 6, 8, 12);
    final repository = _FakeStudySessionRepository();
    await tester.pumpWidget(
      _buildRecord(repository: repository, nowGetter: () => now),
    );

    await tester.enterText(
      find.byKey(const Key('focus_note_field')),
      '英语阅读',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pump();
    await tester.tap(find.byKey(const Key('focus_category_english')));
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    now = now.add(const Duration(minutes: 20));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    expect(repository.items.single.note, '英语阅读');
    expect(repository.items.single.category, '英语');
  });
}

Widget _buildRecord({
  _FakeStudySessionRepository? repository,
  DateTime? now,
  DateTime Function()? nowGetter,
  FocusNotificationService? notificationService,
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
      studyClockProvider.overrideWithValue(
        nowGetter ?? () => now ?? DateTime(2026, 6, 8),
      ),
      focusNotificationServiceProvider.overrideWithValue(
        notificationService ?? _FakeFocusNotificationService(),
      ),
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
    int? plannedSeconds = 2700,
    String note = '',
    String category = '未分类',
  }) async {
    final session = StudySession(
      id: 'session-${items.length + 1}',
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      plannedSeconds: plannedSeconds,
      note: note,
      category: category,
      createdAt: endedAt,
    );
    items.add(session);
    return session;
  }
}

class _FakeFocusNotificationService extends FocusNotificationService {
  int? startedPlannedSeconds;
  String? startedMode;
  var cancelled = false;

  @override
  Future<void> showRunningTimer({
    required int? plannedSeconds,
    required int remainingSeconds,
    required bool isRunning,
    required String mode,
  }) async {
    startedPlannedSeconds = plannedSeconds;
    startedMode = mode;
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
  }
}
