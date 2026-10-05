import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/models/task_model.dart';

// ─────────────────────────────────────────────────────
// Keys for SharedPreferences
// ─────────────────────────────────────────────────────
const _kTaskListsKey = 'task_lists_v2';
const _kTasksKey = 'tasks_v2';

const String defaultListId = 'default';

// ─────────────────────────────────────────────────────
// Reminder stream provider
// ─────────────────────────────────────────────────────
final taskReminderStreamProvider = StreamProvider<Task>((ref) {
  return ref.watch(tasksNotifierProvider.notifier).reminderStream;
});

// ─────────────────────────────────────────────────────
// State: {lists, tasks}
// ─────────────────────────────────────────────────────
class TasksState {
  final List<TaskList> lists;
  final List<Task> tasks;
  final bool isLoaded;

  const TasksState({
    this.lists = const [],
    this.tasks = const [],
    this.isLoaded = false,
  });

  TasksState copyWith({
    List<TaskList>? lists,
    List<Task>? tasks,
    bool? isLoaded,
  }) {
    return TasksState(
      lists: lists ?? this.lists,
      tasks: tasks ?? this.tasks,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  List<Task> tasksForList(String listId) =>
      tasks.where((t) => t.listId == listId).toList()
        ..sort((a, b) {
          // 1. Completion status (pending first)
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          // 2. Priority (Urgent > High > Medium > Low)
          if (a.priority != b.priority) {
            return b.priority.index.compareTo(a.priority.index);
          }
          // 3. Date and Time
          return a.scheduledDateTime.compareTo(b.scheduledDateTime);
        });
}

// ─────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────
class TasksNotifier extends StateNotifier<TasksState> {
  SharedPreferences? _prefs;
  final _reminderController = StreamController<Task>.broadcast();

  TasksNotifier() : super(const TasksState()) {
    _init();
  }

  Stream<Task> get reminderStream => _reminderController.stream;

  // ── Init: load from disk ──────────────────────────
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final listsJson = _prefs!.getStringList(_kTaskListsKey) ?? [];
    final tasksJson = _prefs!.getStringList(_kTasksKey) ?? [];

    List<TaskList> lists =
        listsJson.map((s) => TaskList.fromJsonString(s)).toList();

    // Ensure default list always exists
    if (lists.isEmpty || lists.every((l) => l.id != defaultListId)) {
      final defaultList = TaskList(
        id: defaultListId,
        name: 'My Tasks',
        colorValue: const Color(0xFF4F46E5).value,
        isDefault: true,
        createdAt: DateTime.now(),
      );
      lists = [defaultList, ...lists];
    }

    final tasks = tasksJson.map((s) => Task.fromJsonString(s)).toList();

    state = TasksState(lists: lists, tasks: tasks, isLoaded: true);
    // Refresh all notifications to ensure they are scheduled
    _updateAllNotifications();
  }

  void _updateAllNotifications() {
    NotificationService().cancelAll(); // Reset
    for (final task in state.tasks) {
      if (!task.isCompleted && task.reminderEnabled) {
        _scheduleTaskNotification(task);
      }
    }
  }

  void _scheduleTaskNotification(Task task) {
    NotificationService().scheduleNotification(
      id: task.id.hashCode,
      title: 'Tarea pendiente: ${task.title}',
      body: task.description.isNotEmpty ? task.description : '¡Es hora de completar esta tarea!',
      scheduledDate: task.scheduledDateTime,
    );
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kTaskListsKey,
      state.lists.map((l) => l.toJsonString()).toList(),
    );
    await _prefs!.setStringList(
      _kTasksKey,
      state.tasks.map((t) => t.toJsonString()).toList(),
    );
  }

  /// Manual trigger (for testing from UI)
  void triggerReminderNow(Task task) {
    _reminderController.add(task);
  }

  // ── Task Lists CRUD ───────────────────────────────
  Future<void> addList(TaskList list) async {
    state = state.copyWith(lists: [...state.lists, list]);
    await _persist();
  }

  Future<void> updateList(TaskList updated) async {
    state = state.copyWith(
      lists: [for (final l in state.lists) l.id == updated.id ? updated : l],
    );
    await _persist();
  }

  Future<void> deleteList(String listId) async {
    if (listId == defaultListId) return; // cannot delete default
    state = state.copyWith(
      lists: state.lists.where((l) => l.id != listId).toList(),
      tasks: state.tasks.where((t) => t.listId != listId).toList(),
    );
    await _persist();
  }

  // ── Tasks CRUD ────────────────────────────────────
  Future<void> addTask(Task task) async {
    state = state.copyWith(tasks: [task, ...state.tasks]);
    if (task.reminderEnabled) _scheduleTaskNotification(task);
    await _persist();
  }

  Future<void> updateTask(Task updated) async {
    state = state.copyWith(
      tasks: [for (final t in state.tasks) t.id == updated.id ? updated : t],
    );
    // Refresh its notification
    NotificationService().cancelNotification(updated.id.hashCode);
    if (updated.reminderEnabled && !updated.isCompleted) {
      _scheduleTaskNotification(updated);
    }
    await _persist();
  }

  Future<void> deleteTask(String id) async {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );
    NotificationService().cancelNotification(id.hashCode);
    await _persist();
  }

  Future<void> toggleCompletion(String id) async {
    final updatedTasks = [
      for (final t in state.tasks)
        if (t.id == id) t.copyWith(isCompleted: !t.isCompleted) else t
    ];
    state = state.copyWith(tasks: updatedTasks);

    final task = updatedTasks.firstWhere((t) => t.id == id);
    if (task.isCompleted) {
      NotificationService().cancelNotification(id.hashCode);
    } else if (task.reminderEnabled) {
      _scheduleTaskNotification(task);
    }
    await _persist();
  }

  @override
  void dispose() {
    _reminderController.close();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────
final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier();
});

