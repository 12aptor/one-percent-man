import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_percent_man/features/time_tracking/domain/models/time_log.dart';

enum PomodoroSession { work, shortBreak, longBreak }

class TimeTrackingState {
  final AuditActivity? activeActivity;
  final DateTime? activeStartTime;
  final Duration currentSegmentDuration;
  final Map<AuditActivity, Duration> accumulatedDurations;
  final Map<AuditActivity, DateTime> singleChecks;
  final List<AuditLogEntry> history;

  // Pomodoro
  final bool isPomodoroMode;
  final PomodoroSession pomodoroSession;
  final int completedRounds;
  final Duration remainingPomodoroTime;
  final String dateKey;

  TimeTrackingState({
    this.activeActivity,
    this.activeStartTime,
    this.currentSegmentDuration = Duration.zero,
    this.accumulatedDurations = const {},
    this.singleChecks = const {},
    this.history = const [],
    this.isPomodoroMode = false,
    this.pomodoroSession = PomodoroSession.work,
    this.completedRounds = 0,
    this.remainingPomodoroTime = const Duration(minutes: 25),
    String? dateKey,
  }) : dateKey = dateKey ?? _todayKey();

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Duration getTotalDuration(AuditActivity activity) {
    final base = accumulatedDurations[activity] ?? Duration.zero;
    if (activeActivity == activity) {
      return base + currentSegmentDuration;
    }
    return base;
  }

  bool isSingleCheckDone(AuditActivity activity) {
    return singleChecks.containsKey(activity);
  }

  TimeTrackingState copyWith({
    AuditActivity? activeActivity,
    DateTime? activeStartTime,
    Duration? currentSegmentDuration,
    Map<AuditActivity, Duration>? accumulatedDurations,
    Map<AuditActivity, DateTime>? singleChecks,
    List<AuditLogEntry>? history,
    bool? isPomodoroMode,
    PomodoroSession? pomodoroSession,
    int? completedRounds,
    Duration? remainingPomodoroTime,
    String? dateKey,
    bool clearActive = false,
  }) {
    return TimeTrackingState(
      activeActivity: clearActive ? null : (activeActivity ?? this.activeActivity),
      activeStartTime: clearActive ? null : (activeStartTime ?? this.activeStartTime),
      currentSegmentDuration: clearActive ? Duration.zero : (currentSegmentDuration ?? this.currentSegmentDuration),
      accumulatedDurations: accumulatedDurations ?? this.accumulatedDurations,
      singleChecks: singleChecks ?? this.singleChecks,
      history: history ?? this.history,
      isPomodoroMode: isPomodoroMode ?? this.isPomodoroMode,
      pomodoroSession: pomodoroSession ?? this.pomodoroSession,
      completedRounds: completedRounds ?? this.completedRounds,
      remainingPomodoroTime: remainingPomodoroTime ?? this.remainingPomodoroTime,
      dateKey: dateKey ?? this.dateKey,
    );
  }
}

class TimeTrackingNotifier extends StateNotifier<TimeTrackingState> {
  Timer? _tickerTimer;
  static const _storagePrefix = 'auditoria_life_';

  TimeTrackingNotifier() : super(TimeTrackingState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = TimeTrackingState._todayKey();
      final savedDate = prefs.getString('${_storagePrefix}date');

      if (savedDate != today) {
        // New day: start fresh
        state = TimeTrackingState(dateKey: today);
        await prefs.setString('${_storagePrefix}date', today);
        await prefs.remove('${_storagePrefix}accumulated');
        await prefs.remove('${_storagePrefix}single_checks');
        await prefs.remove('${_storagePrefix}history');
        return;
      }

      // Load accumulated durations
      final rawAcc = prefs.getString('${_storagePrefix}accumulated');
      final Map<AuditActivity, Duration> accumulated = {};
      if (rawAcc != null) {
        final Map<String, dynamic> decoded = jsonDecode(rawAcc);
        decoded.forEach((key, value) {
          final act = AuditActivity.values.firstWhere(
            (a) => a.id == key,
            orElse: () => AuditActivity.entrenar,
          );
          accumulated[act] = Duration(seconds: value as int);
        });
      }

      // Load single checks
      final rawChecks = prefs.getString('${_storagePrefix}single_checks');
      final Map<AuditActivity, DateTime> checks = {};
      if (rawChecks != null) {
        final Map<String, dynamic> decoded = jsonDecode(rawChecks);
        decoded.forEach((key, value) {
          final act = AuditActivity.values.firstWhere(
            (a) => a.id == key,
            orElse: () => AuditActivity.madrugar,
          );
          checks[act] = DateTime.parse(value as String);
        });
      }

      // Load history
      final rawHistory = prefs.getStringList('${_storagePrefix}history') ?? [];
      final List<AuditLogEntry> history = rawHistory.map((item) {
        return AuditLogEntry.fromJson(jsonDecode(item));
      }).toList();

      state = state.copyWith(
        accumulatedDurations: accumulated,
        singleChecks: checks,
        history: history,
        dateKey: today,
      );
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_storagePrefix}date', state.dateKey);

      final Map<String, int> accMap = {};
      state.accumulatedDurations.forEach((key, value) {
        accMap[key.id] = value.inSeconds;
      });
      await prefs.setString('${_storagePrefix}accumulated', jsonEncode(accMap));

      final Map<String, String> checkMap = {};
      state.singleChecks.forEach((key, value) {
        checkMap[key.id] = value.toIso8601String();
      });
      await prefs.setString('${_storagePrefix}single_checks', jsonEncode(checkMap));

      final historyJson = state.history.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('${_storagePrefix}history', historyJson);
    } catch (_) {}
  }

  void toggleMode() {
    if (state.activeActivity != null) stopTracking();
    state = state.copyWith(
      isPomodoroMode: !state.isPomodoroMode,
      remainingPomodoroTime: !state.isPomodoroMode ? const Duration(minutes: 25) : Duration.zero,
    );
  }

  void toggleActivity(AuditActivity activity) {
    if (activity.isTimer) {
      if (state.activeActivity == activity) {
        // Turn off / stop current segment
        stopTracking();
      } else {
        // Start or switch to new timed activity
        if (state.activeActivity != null) {
          stopTracking();
        }
        _startTimerActivity(activity);
      }
    } else {
      // Single check toggle
      _toggleSingleCheck(activity);
    }
  }

  void _startTimerActivity(AuditActivity activity) {
    final now = DateTime.now();
    HapticFeedback.mediumImpact();

    Duration initialPomodoro;
    if (state.pomodoroSession == PomodoroSession.work) {
      initialPomodoro = const Duration(minutes: 25);
    } else if (state.pomodoroSession == PomodoroSession.shortBreak) {
      initialPomodoro = const Duration(minutes: 5);
    } else {
      initialPomodoro = const Duration(minutes: 15);
    }

    state = state.copyWith(
      activeActivity: activity,
      activeStartTime: now,
      currentSegmentDuration: Duration.zero,
      remainingPomodoroTime: initialPomodoro,
    );

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.activeActivity == null || state.activeStartTime == null) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(state.activeStartTime!);

      if (state.isPomodoroMode) {
        if (state.remainingPomodoroTime.inSeconds > 0) {
          state = state.copyWith(
            remainingPomodoroTime: state.remainingPomodoroTime - const Duration(seconds: 1),
            currentSegmentDuration: elapsed,
          );
        } else {
          _handlePomodoroCompletion();
        }
      } else {
        state = state.copyWith(currentSegmentDuration: elapsed);
      }
    });
  }

  void _handlePomodoroCompletion() {
    HapticFeedback.vibrate();
    stopTracking();

    if (state.pomodoroSession == PomodoroSession.work) {
      final rounds = state.completedRounds + 1;
      final nextSession = (rounds % 4 == 0)
          ? PomodoroSession.longBreak
          : PomodoroSession.shortBreak;

      state = state.copyWith(
        pomodoroSession: nextSession,
        completedRounds: rounds,
        remainingPomodoroTime: nextSession == PomodoroSession.longBreak
            ? const Duration(minutes: 15)
            : const Duration(minutes: 5),
      );
    } else {
      state = state.copyWith(
        pomodoroSession: PomodoroSession.work,
        remainingPomodoroTime: const Duration(minutes: 25),
      );
    }
  }

  void stopTracking() {
    if (state.activeActivity == null || state.activeStartTime == null) return;

    _tickerTimer?.cancel();
    HapticFeedback.lightImpact();

    final activity = state.activeActivity!;
    final now = DateTime.now();
    final segmentDuration = now.difference(state.activeStartTime!);

    // Accumulate time for this activity
    final currentTotal = state.accumulatedDurations[activity] ?? Duration.zero;
    final newAccumulated = Map<AuditActivity, Duration>.from(state.accumulatedDurations);
    newAccumulated[activity] = currentTotal + segmentDuration;

    // Create history entry
    final newEntry = AuditLogEntry(
      id: now.millisecondsSinceEpoch.toString(),
      activity: activity,
      timestamp: state.activeStartTime!,
      endTime: now,
      duration: segmentDuration,
      isSingleCheck: false,
    );

    state = state.copyWith(
      clearActive: true,
      accumulatedDurations: newAccumulated,
      history: [newEntry, ...state.history],
    );

    _saveToStorage();
  }

  void _toggleSingleCheck(AuditActivity activity) {
    HapticFeedback.mediumImpact();
    final newChecks = Map<AuditActivity, DateTime>.from(state.singleChecks);
    final now = DateTime.now();

    if (newChecks.containsKey(activity)) {
      // Toggle off / unmark
      newChecks.remove(activity);
      final newHistory = state.history.where((e) => !(e.activity == activity && e.isSingleCheck)).toList();
      state = state.copyWith(singleChecks: newChecks, history: newHistory);
    } else {
      // Mark as completed
      newChecks[activity] = now;
      final newEntry = AuditLogEntry(
        id: now.millisecondsSinceEpoch.toString(),
        activity: activity,
        timestamp: now,
        isSingleCheck: true,
      );
      state = state.copyWith(
        singleChecks: newChecks,
        history: [newEntry, ...state.history],
      );
    }

    _saveToStorage();
  }

  void clearTodayData() {
    _tickerTimer?.cancel();
    state = TimeTrackingState(dateKey: TimeTrackingState._todayKey());
    _saveToStorage();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

final timeTrackingProvider =
    StateNotifierProvider<TimeTrackingNotifier, TimeTrackingState>((ref) {
  return TimeTrackingNotifier();
});
