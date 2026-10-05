import 'package:flutter/material.dart';

enum TimeCategory {
  procrastination(
    label: 'Procrastinación',
    icon: Icons.timer_off,
    color: Color(0xFFEF4444), // Red
    description: 'Tiempo perdido en distracciones.',
  ),
  exercise(
    label: 'Ejercicio',
    icon: Icons.fitness_center,
    color: Color(0xFF10B981), // Green
    description: 'Actividad física y deporte.',
  ),
  study(
    label: 'Estudio/Lectura',
    icon: Icons.book,
    color: Color(0xFF6366F1), // Indigo
    description: 'Crecimiento intelectual y aprendizaje.',
  ),
  family(
    label: 'Familia/Amigos',
    icon: Icons.groups,
    color: Color(0xFFF59E0B), // Amber
    description: 'Tiempo de calidad con seres queridos.',
  );

  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const TimeCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class TimeLog {
  final String id;
  final TimeCategory category;
  final DateTime startTime;
  final DateTime? endTime;
  final String? note;

  TimeLog({
    required this.id,
    required this.category,
    required this.startTime,
    this.endTime,
    this.note,
  });

  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  TimeLog copyWith({
    String? id,
    TimeCategory? category,
    DateTime? startTime,
    DateTime? endTime,
    String? note,
  }) {
    return TimeLog(
      id: id ?? this.id,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      note: note ?? this.note,
    );
  }
}

