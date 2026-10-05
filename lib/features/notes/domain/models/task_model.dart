import 'dart:convert';

enum TaskPriority { low, medium, high, urgent }

// ─────────────────────────────────────────────────────
// Task model
// ─────────────────────────────────────────────────────
class Task {
  final String id;
  final String listId;
  final String title;
  final String description;
  final DateTime date;    // fecha completa (año-mes-día)
  final String time;      // "HH:mm"
  final bool reminderEnabled;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.listId,
    required this.title,
    this.description = '',
    required this.date,
    required this.time,
    this.reminderEnabled = true,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
  });

  /// DateTime combinando fecha + hora para comparar con alarmas
  DateTime get scheduledDateTime {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Task copyWith({
    String? listId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    bool? reminderEnabled,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return Task(
      id: id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listId': listId,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'time': time,
        'reminderEnabled': reminderEnabled,
        'isCompleted': isCompleted,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        listId: json['listId'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        time: json['time'] as String,
        reminderEnabled: json['reminderEnabled'] as bool? ?? true,
        isCompleted: json['isCompleted'] as bool? ?? false,
        priority: TaskPriority.values.byName(json['priority'] as String? ?? 'medium'),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
  factory Task.fromJsonString(String s) => Task.fromJson(jsonDecode(s));
}

// ─────────────────────────────────────────────────────
// TaskList model (group / bucket)
// ─────────────────────────────────────────────────────
class TaskList {
  final String id;
  final String name;
  final int colorValue; // Color.value int
  final bool isDefault;
  final DateTime createdAt;

  const TaskList({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isDefault = false,
    required this.createdAt,
  });

  TaskList copyWith({
    String? name,
    int? colorValue,
    bool? isDefault,
  }) {
    return TaskList(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TaskList.fromJson(Map<String, dynamic> json) => TaskList(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: json['colorValue'] as int,
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
  factory TaskList.fromJsonString(String s) =>
      TaskList.fromJson(jsonDecode(s));
}

