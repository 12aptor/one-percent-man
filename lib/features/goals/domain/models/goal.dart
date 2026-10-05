import 'package:flutter/material.dart';
import 'dart:convert';

enum GoalUnit {
  money,
  books,
  gymDays,
  kilometers,
  hours,
  pages,
  courses,
  habits,
  weight,
  custom,
}

extension GoalUnitExtension on GoalUnit {
  String get label {
    switch (this) {
      case GoalUnit.money:     return 'Ahorro';
      case GoalUnit.books:     return 'Libros';
      case GoalUnit.gymDays:   return 'Días de gym';
      case GoalUnit.kilometers:return 'Kilómetros';
      case GoalUnit.hours:     return 'Horas';
      case GoalUnit.pages:     return 'Páginas';
      case GoalUnit.courses:   return 'Cursos';
      case GoalUnit.habits:    return 'Hábitos';
      case GoalUnit.weight:    return 'kg';
      case GoalUnit.custom:    return 'Unidades';
    }
  }

  String get symbol {
    switch (this) {
      case GoalUnit.money:     return '\$';
      case GoalUnit.books:     return '📚';
      case GoalUnit.gymDays:   return '💪';
      case GoalUnit.kilometers:return 'km';
      case GoalUnit.hours:     return 'h';
      case GoalUnit.pages:     return 'pp.';
      case GoalUnit.courses:   return '🎓';
      case GoalUnit.habits:    return '✅';
      case GoalUnit.weight:    return 'kg';
      case GoalUnit.custom:    return '#';
    }
  }

  IconData get icon {
    switch (this) {
      case GoalUnit.money:     return Icons.savings_rounded;
      case GoalUnit.books:     return Icons.menu_book_rounded;
      case GoalUnit.gymDays:   return Icons.fitness_center_rounded;
      case GoalUnit.kilometers:return Icons.directions_run_rounded;
      case GoalUnit.hours:     return Icons.schedule_rounded;
      case GoalUnit.pages:     return Icons.import_contacts_rounded;
      case GoalUnit.courses:   return Icons.school_rounded;
      case GoalUnit.habits:    return Icons.check_circle_rounded;
      case GoalUnit.weight:    return Icons.monitor_weight_rounded;
      case GoalUnit.custom:    return Icons.flag_rounded;
    }
  }

  Color get color {
    switch (this) {
      case GoalUnit.money:     return const Color(0xFF10B981); // emerald
      case GoalUnit.books:     return const Color(0xFF6366F1); // indigo
      case GoalUnit.gymDays:   return const Color(0xFFEF4444); // red
      case GoalUnit.kilometers:return const Color(0xFF3B82F6); // blue
      case GoalUnit.hours:     return const Color(0xFFF59E0B); // amber
      case GoalUnit.pages:     return const Color(0xFF8B5CF6); // violet
      case GoalUnit.courses:   return const Color(0xFF0EA5E9); // sky
      case GoalUnit.habits:    return const Color(0xFF14B8A6); // teal
      case GoalUnit.weight:    return const Color(0xFFF97316); // orange
      case GoalUnit.custom:    return const Color(0xFF64748B); // slate
    }
  }

  bool get isMoney => this == GoalUnit.money;
}

class Goal {
  final String id;
  final String title;
  final GoalUnit unit;
  final String customUnitLabel; // used only when unit == GoalUnit.custom
  final double target;
  final double current;
  final DateTime createdAt;
  final DateTime? deadline;

  Goal({
    required this.id,
    required this.title,
    required this.unit,
    this.customUnitLabel = '',
    required this.target,
    this.current = 0,
    required this.createdAt,
    this.deadline,
  });

  double get progress => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
  bool get isCompleted => current >= target;

  String get unitLabel =>
      unit == GoalUnit.custom ? customUnitLabel : unit.label;

  String formatValue(double value) {
    if (unit.isMoney) {
      // Format as currency with commas
      final formatted = value.toStringAsFixed(2);
      final parts = formatted.split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final buffer = StringBuffer();
      int count = 0;
      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buffer.write(',');
        buffer.write(intPart[i]);
        count++;
      }
      return '\$' + buffer.toString().split('').reversed.join() + '.' + decPart;
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Goal copyWith({
    String? title,
    GoalUnit? unit,
    String? customUnitLabel,
    double? target,
    double? current,
    DateTime? deadline,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      unit: unit ?? this.unit,
      customUnitLabel: customUnitLabel ?? this.customUnitLabel,
      target: target ?? this.target,
      current: current ?? this.current,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'unit': unit.index,
        'customUnitLabel': customUnitLabel,
        'target': target,
        'current': current,
        'createdAt': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        unit: GoalUnit.values[json['unit'] as int],
        customUnitLabel: json['customUnitLabel'] as String? ?? '',
        target: (json['target'] as num).toDouble(),
        current: (json['current'] as num? ?? 0).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
      );

  String toJsonString() => jsonEncode(toJson());
  factory Goal.fromJsonString(String s) => Goal.fromJson(jsonDecode(s));
}

