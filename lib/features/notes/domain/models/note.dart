class Task {
  final String id;
  final String title;
  final String description;
  final String time; // "HH:mm" – hora del recordatorio
  final bool isCompleted;
  final bool reminderEnabled;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.time,
    this.isCompleted = false,
    this.reminderEnabled = true,
    required this.createdAt,
  });

  Task copyWith({
    String? title,
    String? description,
    String? time,
    bool? isCompleted,
    bool? reminderEnabled,
    DateTime? createdAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

