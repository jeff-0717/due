import 'package:due/models/study_session.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  setUp(() async {
    Hive.init('test/.hive_study_session_repository');
    await Hive.deleteBoxFromDisk(HiveService.studySessionBoxName);
  });

  tearDown(() async {
    await Hive.close();
  });

  test('study session serializes all persisted fields', () {
    final startedAt = DateTime(2026, 6, 8, 9);
    final endedAt = DateTime(2026, 6, 8, 9, 45);
    final createdAt = DateTime(2026, 6, 8, 9, 46);
    final session = StudySession(
      id: 'session-1',
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: 2700,
      plannedSeconds: 2700,
      createdAt: createdAt,
    );

    final decoded = StudySession.fromJson(session.toJson());

    expect(decoded.id, 'session-1');
    expect(decoded.startedAt, startedAt);
    expect(decoded.endedAt, endedAt);
    expect(decoded.durationSeconds, 2700);
    expect(decoded.plannedSeconds, 2700);
    expect(decoded.createdAt, createdAt);
  });

  test('forLocalDay includes sessions whose endedAt is on the requested date',
      () async {
    final hive = HiveService();
    await hive.init();
    final repository = StudySessionRepository(hive);

    await repository.save(_session(
      id: 'yesterday',
      endedAt: DateTime(2026, 6, 7, 23, 59),
    ));
    await repository.save(_session(
      id: 'morning',
      endedAt: DateTime(2026, 6, 8, 0),
    ));
    await repository.save(_session(
      id: 'night',
      endedAt: DateTime(2026, 6, 8, 23, 59, 59),
    ));
    await repository.save(_session(
      id: 'tomorrow',
      endedAt: DateTime(2026, 6, 9, 0),
    ));

    final sessions = repository.forLocalDay(DateTime(2026, 6, 8, 12));

    expect(sessions.map((item) => item.id), ['morning', 'night']);
  });

  test('clearAll removes persisted study sessions', () async {
    final hive = HiveService();
    await hive.init();
    final repository = StudySessionRepository(hive);

    await repository.save(_session(id: 'session-1'));

    await hive.clearAll();

    expect(repository.getAll(), isEmpty);
  });
}

StudySession _session({
  required String id,
  DateTime? endedAt,
}) {
  final end = endedAt ?? DateTime(2026, 6, 8, 10);
  return StudySession(
    id: id,
    startedAt: end.subtract(const Duration(minutes: 45)),
    endedAt: end,
    durationSeconds: 2700,
    plannedSeconds: 2700,
    createdAt: end,
  );
}
