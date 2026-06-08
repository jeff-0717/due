import 'package:uuid/uuid.dart';

import '../models/study_session.dart';
import '../services/hive_service.dart';

class StudySessionRepository {
  final HiveService _hive;
  static const _uuid = Uuid();

  const StudySessionRepository(this._hive);

  List<StudySession> getAll() => _hive.getAllStudySessions();

  Future<void> save(StudySession session) async {
    await _hive.saveStudySession(session);
  }

  Future<StudySession> createSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
    int plannedSeconds = 2700,
  }) async {
    final session = StudySession(
      id: _uuid.v4(),
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      plannedSeconds: plannedSeconds,
      createdAt: DateTime.now(),
    );
    await save(session);
    return session;
  }

  List<StudySession> forLocalDay(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return forRange(start: start, end: end);
  }

  List<StudySession> forRange({
    required DateTime start,
    required DateTime end,
  }) {
    final sessions = getAll()
        .where((session) =>
            !session.endedAt.isBefore(start) && session.endedAt.isBefore(end))
        .toList()
      ..sort((a, b) => a.endedAt.compareTo(b.endedAt));
    return sessions;
  }
}
