import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_percent_man/features/time_tracking/domain/models/time_log.dart';

enum PomodoroSession { work, shortBreak, longBreak }

class TimeTrackingState {
  final TimeLog? activeLog;
  final List<TimeLog> history;
  final Duration activeDuration;
  
  // Pomodoro fields
  final bool isPomodoroMode;
  final PomodoroSession pomodoroSession;
  final int completedRounds;
  final Duration remainingTime;

  TimeTrackingState({
    this.activeLog,
    this.history = const [],
    this.activeDuration = Duration.zero,
    this.isPomodoroMode = false,
    this.pomodoroSession = PomodoroSession.work,
    this.completedRounds = 0,
    this.remainingTime = const Duration(minutes: 25),
  });

  TimeTrackingState copyWith({
    TimeLog? activeLog,
    List<TimeLog>? history,
    Duration? activeDuration,
    bool? isPomodoroMode,
    PomodoroSession? pomodoroSession,
    int? completedRounds,
    Duration? remainingTime,
    bool clearActive = false,
  }) {
    return TimeTrackingState(
      activeLog: clearActive ? null : (activeLog ?? this.activeLog),
      history: history ?? this.history,
      activeDuration: activeDuration ?? this.activeDuration,
      isPomodoroMode: isPomodoroMode ?? this.isPomodoroMode,
      pomodoroSession: pomodoroSession ?? this.pomodoroSession,
      completedRounds: completedRounds ?? this.completedRounds,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

class TimeTrackingNotifier extends StateNotifier<TimeTrackingState> {
  Timer? _timer;

  TimeTrackingNotifier() : super(TimeTrackingState());

  void toggleMode() {
    if (state.activeLog != null) stopTracking();
    state = state.copyWith(
      isPomodoroMode: !state.isPomodoroMode,
      remainingTime: !state.isPomodoroMode ? const Duration(minutes: 25) : Duration.zero,
    );
  }

  void startTracking(TimeCategory category) {
    if (state.activeLog != null) {
      stopTracking();
    }

    final newLog = TimeLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      startTime: DateTime.now(),
    );

    if (state.isPomodoroMode) {
      _startPomodoro(category, newLog);
    } else {
      _startFreeTracking(newLog);
    }
  }

  void _startFreeTracking(TimeLog newLog) {
    state = state.copyWith(activeLog: newLog, activeDuration: Duration.zero);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.activeLog != null) {
        state = state.copyWith(
          activeDuration: DateTime.now().difference(state.activeLog!.startTime),
        );
      }
    });
  }

  void _startPomodoro(TimeCategory category, TimeLog newLog) {
    // Standard Pomodoro: 25 min work, 5 min break, 15 min long break every 4 rounds
    Duration initialTime;
    if (state.pomodoroSession == PomodoroSession.work) {
      initialTime = const Duration(minutes: 25);
    } else if (state.pomodoroSession == PomodoroSession.shortBreak) {
      initialTime = const Duration(minutes: 5);
    } else {
      initialTime = const Duration(minutes: 15);
    }

    state = state.copyWith(
      activeLog: newLog,
      activeDuration: Duration.zero,
      remainingTime: initialTime,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime.inSeconds > 0) {
        state = state.copyWith(
          remainingTime: state.remainingTime - const Duration(seconds: 1),
          activeDuration: DateTime.now().difference(state.activeLog!.startTime),
        );
      } else {
        _handlePomodoroCompletion();
      }
    });
  }

  void _handlePomodoroCompletion() {
    HapticFeedback.vibrate();
    stopTracking();
    
    // Switch session
    if (state.pomodoroSession == PomodoroSession.work) {
      final rounds = state.completedRounds + 1;
      final nextSession = (rounds % 4 == 0) 
          ? PomodoroSession.longBreak 
          : PomodoroSession.shortBreak;
      
      state = state.copyWith(
        pomodoroSession: nextSession,
        completedRounds: rounds,
        remainingTime: nextSession == PomodoroSession.longBreak 
            ? const Duration(minutes: 15) 
            : const Duration(minutes: 5),
      );
    } else {
      state = state.copyWith(
        pomodoroSession: PomodoroSession.work,
        remainingTime: const Duration(minutes: 25),
      );
    }
  }

  void stopTracking() {
    if (state.activeLog == null) return;

    _timer?.cancel();
    final finishedLog = state.activeLog!.copyWith(endTime: DateTime.now());
    
    state = state.copyWith(
      history: [finishedLog, ...state.history],
      clearActive: true,
      activeDuration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timeTrackingProvider =
    StateNotifierProvider<TimeTrackingNotifier, TimeTrackingState>((ref) {
  return TimeTrackingNotifier();
});

