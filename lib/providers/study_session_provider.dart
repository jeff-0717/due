import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_session.dart';
import '../repositories/study_session_repository.dart';
import 'hive_provider.dart';

const int defaultFocusSeconds = 2700;

typedef StudyClock = DateTime Function();

final studyClockProvider = Provider<StudyClock>((ref) {
  return DateTime.now;
});

final studySessionRepositoryProvider =
    Provider<StudySessionRepository>((ref) {
  return StudySessionRepository(ref.watch(hiveServiceProvider));
});

final studySessionListProvider =
    StateNotifierProvider<StudySessionListNotifier, List<StudySession>>((ref) {
  return StudySessionListNotifier(ref.watch(studySessionRepositoryProvider));
});

final todayStudySummaryProvider = Provider<StudySummary>((ref) {
  final now = ref.watch(studyClockProvider)();
  final sessions = ref.watch(studySessionListProvider).where((session) {
    return session.endedAt.year == now.year &&
        session.endedAt.month == now.month &&
        session.endedAt.day == now.day;
  });
  return StudySummary(
    count: sessions.length,
    totalSeconds: sessions.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    ),
  );
});

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier(
    ref.watch(studyClockProvider),
    ref.watch(studySessionListProvider.notifier),
  );
});

class StudySummary {
  final int count;
  final int totalSeconds;

  const StudySummary({
    required this.count,
    required this.totalSeconds,
  });
}

class StudySessionListNotifier extends StateNotifier<List<StudySession>> {
  final StudySessionRepository _repository;

  StudySessionListNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAll();
  }

  Future<void> addCompletedSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
    int plannedSeconds = defaultFocusSeconds,
  }) async {
    await _repository.createSession(
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      plannedSeconds: plannedSeconds,
    );
    refresh();
  }
}

class FocusTimerState {
  final int plannedSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final DateTime? startedAt;
  final DateTime? currentRunStartedAt;
  final DateTime? pausedAt;
  final int elapsedBeforePauseSeconds;

  const FocusTimerState({
    this.plannedSeconds = defaultFocusSeconds,
    this.remainingSeconds = defaultFocusSeconds,
    this.isRunning = false,
    this.startedAt,
    this.currentRunStartedAt,
    this.pausedAt,
    this.elapsedBeforePauseSeconds = 0,
  });

  FocusTimerState copyWith({
    int? plannedSeconds,
    int? remainingSeconds,
    bool? isRunning,
    DateTime? startedAt,
    DateTime? currentRunStartedAt,
    DateTime? pausedAt,
    int? elapsedBeforePauseSeconds,
    bool clearStartedAt = false,
    bool clearCurrentRunStartedAt = false,
    bool clearPausedAt = false,
  }) {
    return FocusTimerState(
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      currentRunStartedAt: clearCurrentRunStartedAt
          ? null
          : currentRunStartedAt ?? this.currentRunStartedAt,
      pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
      elapsedBeforePauseSeconds:
          elapsedBeforePauseSeconds ?? this.elapsedBeforePauseSeconds,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final StudyClock _clock;
  final StudySessionListNotifier _sessions;

  FocusTimerNotifier(this._clock, this._sessions)
      : super(const FocusTimerState());

  void start() {
    final now = _clock();
    state = FocusTimerState(
      startedAt: now,
      currentRunStartedAt: now,
      isRunning: true,
    );
  }

  void pause() {
    if (!state.isRunning || state.startedAt == null) return;
    final now = _clock();
    final elapsed = _elapsedSeconds(_clock());
    state = state.copyWith(
      isRunning: false,
      pausedAt: now,
      elapsedBeforePauseSeconds: elapsed,
      remainingSeconds: _remainingAfter(elapsed),
      clearCurrentRunStartedAt: true,
    );
  }

  void resume() {
    if (state.isRunning || state.startedAt == null) return;
    state = state.copyWith(
      isRunning: true,
      currentRunStartedAt: _clock(),
      clearPausedAt: true,
    );
  }

  void reset() {
    state = const FocusTimerState();
  }

  Future<void> finish() async {
    if (state.startedAt == null) {
      reset();
      return;
    }
    final endedAt = _clock();
    final elapsed = _elapsedSeconds(endedAt);
    if (elapsed > 0) {
      await _sessions.addCompletedSession(
        startedAt: state.startedAt!,
        endedAt: endedAt,
        durationSeconds: elapsed,
        plannedSeconds: state.plannedSeconds,
      );
    }
    reset();
  }

  int _elapsedSeconds(DateTime now) {
    if (state.startedAt == null) return 0;
    if (!state.isRunning) return state.elapsedBeforePauseSeconds;
    final currentRunStartedAt = state.currentRunStartedAt ?? state.startedAt!;
    final runningElapsed = state.elapsedBeforePauseSeconds +
        now.difference(currentRunStartedAt).inSeconds;
    return runningElapsed < 0 ? 0 : runningElapsed;
  }

  int _remainingAfter(int elapsedSeconds) {
    final remaining = state.plannedSeconds - elapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }
}
