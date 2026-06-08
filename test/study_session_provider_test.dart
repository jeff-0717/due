import 'package:due/models/study_session.dart';
import 'package:due/providers/study_session_provider.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('today summary counts only sessions ended today', () {
    final now = DateTime(2026, 6, 8, 12);
    final repository = _FakeStudySessionRepository([
      _session(id: 'yesterday', endedAt: DateTime(2026, 6, 7, 23, 59)),
      _session(id: 'today-1', endedAt: DateTime(2026, 6, 8, 8), seconds: 600),
      _session(id: 'today-2', endedAt: DateTime(2026, 6, 8, 9), seconds: 900),
      _session(id: 'tomorrow', endedAt: DateTime(2026, 6, 9, 0)),
    ]);
    final container = _container(repository: repository, now: now);
    addTearDown(container.dispose);

    final summary = container.read(todayStudySummaryProvider);

    expect(summary.count, 2);
    expect(summary.totalSeconds, 1500);
  });

  test('finishing a positive-duration timer saves one session', () async {
    var now = DateTime(2026, 6, 8, 9);
    final repository = _FakeStudySessionRepository();
    final container = _container(repository: repository, nowGetter: () => now);
    addTearDown(container.dispose);
    final timer = container.read(focusTimerProvider.notifier);

    timer.start();
    now = now.add(const Duration(minutes: 12));
    await timer.finish();

    expect(repository.items, hasLength(1));
    expect(repository.items.single.durationSeconds, 720);
    expect(container.read(todayStudySummaryProvider).count, 1);
  });

  test('reset clears the active timer without saving a session', () {
    var now = DateTime(2026, 6, 8, 9);
    final repository = _FakeStudySessionRepository();
    final container = _container(repository: repository, nowGetter: () => now);
    addTearDown(container.dispose);
    final timer = container.read(focusTimerProvider.notifier);

    timer.start();
    now = now.add(const Duration(minutes: 5));
    timer.reset();

    expect(repository.items, isEmpty);
    expect(container.read(focusTimerProvider).remainingSeconds, 2700);
    expect(container.read(focusTimerProvider).isRunning, isFalse);
  });

  test('pause and resume do not count paused time in saved duration', () async {
    var now = DateTime(2026, 6, 8, 9);
    final repository = _FakeStudySessionRepository();
    final container = _container(repository: repository, nowGetter: () => now);
    addTearDown(container.dispose);
    final timer = container.read(focusTimerProvider.notifier);

    timer.start();
    now = now.add(const Duration(minutes: 5));
    timer.pause();
    now = now.add(const Duration(minutes: 20));
    timer.resume();
    now = now.add(const Duration(minutes: 7));
    await timer.finish();

    expect(repository.items.single.durationSeconds, 720);
  });
}

ProviderContainer _container({
  required _FakeStudySessionRepository repository,
  DateTime? now,
  DateTime Function()? nowGetter,
}) {
  return ProviderContainer(
    overrides: [
      studySessionRepositoryProvider.overrideWithValue(repository),
      studyClockProvider.overrideWithValue(nowGetter ?? () => now!),
    ],
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
  Future<void> save(StudySession session) async {
    items.add(session);
  }

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
    await save(session);
    return session;
  }
}
