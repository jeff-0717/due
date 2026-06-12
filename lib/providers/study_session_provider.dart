import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_session.dart';
import '../repositories/study_session_repository.dart';
import '../services/focus_notification_service.dart';
import 'hive_provider.dart';

const int defaultFocusSeconds = 2700;
const String defaultStudyCategory = '\u672a\u5206\u7c7b';
const String otherStudyCategory = '\u5176\u4ed6';

typedef StudyClock = DateTime Function();

enum FocusTimerMode {
  fixed45,
  unlimited,
}

final studyClockProvider = Provider<StudyClock>((ref) {
  return DateTime.now;
});

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return StudySessionRepository(ref.watch(hiveServiceProvider));
});

final focusNotificationServiceProvider = Provider<FocusNotificationService>((
  ref,
) {
  return const FocusNotificationService();
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
    int? plannedSeconds = defaultFocusSeconds,
    String note = '',
    String category = defaultStudyCategory,
  }) async {
    await _repository.createSession(
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      plannedSeconds: plannedSeconds,
      note: note,
      category: category,
    );
    refresh();
  }
}

class FocusTimerState {
  final FocusTimerMode mode;
  final int? plannedSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final DateTime? startedAt;
  final DateTime? currentRunStartedAt;
  final DateTime? pausedAt;
  final int elapsedBeforePauseSeconds;

  const FocusTimerState({
    this.mode = FocusTimerMode.fixed45,
    this.plannedSeconds = defaultFocusSeconds,
    this.remainingSeconds = defaultFocusSeconds,
    this.isRunning = false,
    this.startedAt,
    this.currentRunStartedAt,
    this.pausedAt,
    this.elapsedBeforePauseSeconds = 0,
  });

  FocusTimerState copyWith({
    FocusTimerMode? mode,
    int? plannedSeconds,
    int? remainingSeconds,
    bool? isRunning,
    DateTime? startedAt,
    DateTime? currentRunStartedAt,
    DateTime? pausedAt,
    int? elapsedBeforePauseSeconds,
    bool clearPlannedSeconds = false,
    bool clearStartedAt = false,
    bool clearCurrentRunStartedAt = false,
    bool clearPausedAt = false,
  }) {
    return FocusTimerState(
      mode: mode ?? this.mode,
      plannedSeconds:
          clearPlannedSeconds ? null : plannedSeconds ?? this.plannedSeconds,
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
  Timer? _ticker;

  FocusTimerNotifier(this._clock, this._sessions)
      : super(const FocusTimerState());

  void start() {
    _stopTicker();
    final now = _clock();
    state = FocusTimerState(
      mode: state.mode,
      plannedSeconds: state.plannedSeconds,
      remainingSeconds: state.mode == FocusTimerMode.unlimited
          ? 0
          : state.plannedSeconds ?? defaultFocusSeconds,
      startedAt: now,
      currentRunStartedAt: now,
      isRunning: true,
    );
    _startTicker();
  }

  void setMode(FocusTimerMode mode) {
    if (state.isRunning || state.startedAt != null) return;
    switch (mode) {
      case FocusTimerMode.fixed45:
        state = state.copyWith(
          mode: mode,
          plannedSeconds: defaultFocusSeconds,
          remainingSeconds: defaultFocusSeconds,
        );
      case FocusTimerMode.unlimited:
        state = state.copyWith(
          mode: mode,
          remainingSeconds: 0,
          clearPlannedSeconds: true,
        );
    }
  }

  void pause() {
    if (!state.isRunning || state.startedAt == null) return;
    final now = _clock();
    final elapsed = _elapsedSeconds(now);
    _stopTicker();
    state = state.copyWith(
      isRunning: false,
      pausedAt: now,
      elapsedBeforePauseSeconds: elapsed,
      remainingSeconds: _timerDisplaySeconds(elapsed),
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
    _startTicker();
  }

  void reset() {
    _stopTicker();
    state = const FocusTimerState();
  }

  Future<void> finish({
    String note = '',
    String category = defaultStudyCategory,
  }) async {
    _stopTicker();
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
        note: note.trim(),
        category: _normalizeCategory(category, note),
      );
    }
    reset();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    if (!state.isRunning || state.startedAt == null) {
      _stopTicker();
      return;
    }
    final elapsed = _elapsedSeconds(_clock());
    final displaySeconds = _timerDisplaySeconds(elapsed);
    if (displaySeconds != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: displaySeconds);
    }
    if (state.mode == FocusTimerMode.fixed45 && displaySeconds == 0) {
      _stopTicker();
    }
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
    final remaining =
        (state.plannedSeconds ?? defaultFocusSeconds) - elapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  int _timerDisplaySeconds(int elapsedSeconds) {
    if (state.mode == FocusTimerMode.unlimited) return elapsedSeconds;
    return _remainingAfter(elapsedSeconds);
  }

  String _normalizeCategory(String category, String note) {
    final trimmedCategory = category.trim();
    switch (trimmedCategory) {
      case '\u6570\u5b66':
      case '\u82f1\u8bed':
      case '\u653f\u6cbb':
      case otherStudyCategory:
        return trimmedCategory;
    }
    final trimmedNote = note.trim();
    if (trimmedNote.contains('\u6570\u5b66')) return '\u6570\u5b66';
    if (trimmedNote.contains('\u82f1\u8bed')) return '\u82f1\u8bed';
    if (trimmedNote.contains('\u653f\u6cbb')) return '\u653f\u6cbb';
    return otherStudyCategory;
  }
}
