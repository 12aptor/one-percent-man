import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/models/activity.dart';

const _kActivitiesKey = 'schedule_activities_v2';

class ActivitiesNotifier extends StateNotifier<List<Activity>> {
  SharedPreferences? _prefs;

  ActivitiesNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getStringList(_kActivitiesKey);

    if (saved != null && saved.isNotEmpty) {
      state = saved.map(Activity.fromJsonString).toList();
    } else {
      state = []; // or keep the seed data if desired
    }
    _updateAllNotifications();
  }

  void _updateAllNotifications() {
    // We only clear activity-related notifications (IDs start with 2000000)
    // Actually, NotificationService().cancelAll() might be too aggressive if both notifiers use it.
    // I'll make IDs specific. Tasks use id.hashCode, Activities will use 2000000 + id.hashCode.
    
    for (final activity in state) {
       _scheduleActivityNotification(activity);
    }
  }

  void _scheduleActivityNotification(Activity activity) {
    NotificationService().cancelNotification(2000000 + activity.id.hashCode);
    
    // We only schedule if not completed (though recurring might be completed for today)
    // For now, let's assume we always schedule the NEXT one.
    final triggerTime = activity.scheduledNotificationDateTime(DateTime.now());
    if (triggerTime != null) {
       NotificationService().scheduleNotification(
         id: 2000000 + activity.id.hashCode,
         title: 'Próxima actividad: ${activity.title}',
         body: 'Comienza a las ${activity.time}. ${activity.description}',
         scheduledDate: triggerTime,
       );
    }
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kActivitiesKey,
      state.map((a) => a.toJsonString()).toList(),
    );
  }

  /// Activities that occur on [date]
  List<Activity> activitiesForDate(DateTime date) {
    return state.where((a) => a.occursOn(date)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  void addActivity(Activity activity) {
    state = [...state, activity];
    _scheduleActivityNotification(activity);
    _sortAndPersist();
  }

  void updateActivity(Activity updated) {
    state = [
      for (final a in state) if (a.id == updated.id) updated else a
    ];
    _scheduleActivityNotification(updated);
    _sortAndPersist();
  }

  void deleteActivity(String id) {
    NotificationService().cancelNotification(2000000 + id.hashCode);
    state = state.where((a) => a.id != id).toList();
    _persist();
  }

  void toggleCompletion(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(isCompleted: !a.isCompleted) else a
    ];
    // Re-schedule based on new completion status 
    // (If it was a one-time thing, it might not have another occurrence)
    final activity = state.firstWhere((a) => a.id == id);
    _scheduleActivityNotification(activity);
    _persist();
  }

  void _sortAndPersist() {
    state.sort((a, b) => a.time.compareTo(b.time));
    state = [...state];
    _persist();
  }
}

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<Activity>>((ref) {
  return ActivitiesNotifier();
});

