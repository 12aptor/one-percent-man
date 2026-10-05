import 'dart:convert';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────
// Recurrence type
// ─────────────────────────────────────────────────────
enum RecurrenceType { none, weekly, monthly, annual }

extension RecurrenceTypeX on RecurrenceType {
  String get label {
    switch (this) {
      case RecurrenceType.none:     return 'Sin repetición';
      case RecurrenceType.weekly:   return 'Semanal';
      case RecurrenceType.monthly:  return 'Mensual';
      case RecurrenceType.annual:   return 'Anual';
    }
  }

  String get jsonVal {
    switch (this) {
      case RecurrenceType.none:    return 'none';
      case RecurrenceType.weekly:  return 'weekly';
      case RecurrenceType.monthly: return 'monthly';
      case RecurrenceType.annual:  return 'annual';
    }
  }

  static RecurrenceType fromJson(String v) {
    switch (v) {
      case 'weekly':  return RecurrenceType.weekly;
      case 'monthly': return RecurrenceType.monthly;
      case 'annual':  return RecurrenceType.annual;
      default:        return RecurrenceType.none;
    }
  }
}

// ─────────────────────────────────────────────────────
// Weekday helpers (1 = Monday … 7 = Sunday)
// ─────────────────────────────────────────────────────
const _weekdayNames = {
  DateTime.monday:    'Lun',
  DateTime.tuesday:   'Mar',
  DateTime.wednesday: 'Mié',
  DateTime.thursday:  'Jue',
  DateTime.friday:    'Vie',
  DateTime.saturday:  'Sáb',
  DateTime.sunday:    'Dom',
};

String weekdayShortName(int weekday) => _weekdayNames[weekday] ?? '';

// ─────────────────────────────────────────────────────
// Activity model
// ─────────────────────────────────────────────────────
class Activity {
  final String id;
  final String title;
  final String description;
  final String time;           // "HH:mm"
  final int durationMinutes;
  final Color color;
  final bool isCompleted;

  // ── Recurrence ─────────────────────────────────────
  final RecurrenceType recurrence;
  final DateTime startDate;    // base / anchor date
  /// For weekly: list of ISO weekdays (1=Mon…7=Sun)
  final List<int> weekDays;
  /// For monthly: day of month (1-31)
  final int? monthDay;
  /// For annual: month (1-12) and day
  final int? annualMonth;
  final int? annualDay;

  Activity({
    required this.id,
    required this.title,
    this.description = '',
    required this.time,
    this.durationMinutes = 60,
    required this.color,
    this.isCompleted = false,
    this.recurrence = RecurrenceType.none,
    DateTime? startDate,
    this.weekDays = const [],
    this.monthDay,
    this.annualMonth,
    this.annualDay,
  }) : startDate = startDate ?? DateTime.now();

  // ── Occurrence logic ───────────────────────────────
  /// Returns true if this activity occurs on [date]
  bool occursOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);

    // Must not be before start date
    if (d.isBefore(s)) return false;

    switch (recurrence) {
      case RecurrenceType.none:
        return d == s;

      case RecurrenceType.weekly:
        if (weekDays.isEmpty) return d.weekday == s.weekday;
        return weekDays.contains(d.weekday);

      case RecurrenceType.monthly:
        final targetDay = monthDay ?? s.day;
        return date.day == targetDay;

      case RecurrenceType.annual:
        final m = annualMonth ?? s.month;
        final dy = annualDay ?? s.day;
        return date.month == m && date.day == dy;
    }
  }

  /// Returns the next occurrence of this activity on or after [after]
  DateTime? nextOccurrenceAfter(DateTime after) {
    DateTime current = DateTime(after.year, after.month, after.day);

    // Check next 365 days
    for (int i = 0; i < 366; i++) {
      final day = current.add(Duration(days: i));
      if (occursOn(day)) {
        final parts = time.split(':');
        final eventTime = DateTime(day.year, day.month, day.day,
            int.parse(parts[0]), int.parse(parts[1]));
        if (eventTime.isAfter(after)) {
          return eventTime;
        }
      }
    }
    return null;
  }

  /// Trigger time (5 minutes before the event) for the next occurrence after [after]
  DateTime? scheduledNotificationDateTime(DateTime after) {
    // We add 5 minutes buffer to 'after' to ensure we don't pick a time that is too close or already passed its 5-min lead
    final next = nextOccurrenceAfter(after.add(const Duration(minutes: 5)));
    if (next == null) return null;
    return next.subtract(const Duration(minutes: 5));
  }

  // ── Recurrence human-readable label ───────────────
  String get recurrenceLabel {
    switch (recurrence) {
      case RecurrenceType.none:
        return 'Una vez';
      case RecurrenceType.weekly:
        if (weekDays.isEmpty) return 'Semanal';
        final names = weekDays.map(weekdayShortName).join(', ');
        return 'Cada $names';
      case RecurrenceType.monthly:
        final d = monthDay ?? startDate.day;
        return 'Cada día $d del mes';
      case RecurrenceType.annual:
        final m = annualMonth ?? startDate.month;
        final d = annualDay ?? startDate.day;
        final months = [
          '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
          'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
        ];
        return 'Cada ${months[m]} $d';
    }
  }

  // ── endTime ────────────────────────────────────────
  String get endTime {
    final parts = time.split(':');
    final totalMinutes =
        int.parse(parts[0]) * 60 + int.parse(parts[1]) + durationMinutes;
    final h = (totalMinutes ~/ 60) % 24;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // ── copyWith ───────────────────────────────────────
  Activity copyWith({
    String? title,
    String? description,
    String? time,
    int? durationMinutes,
    Color? color,
    bool? isCompleted,
    RecurrenceType? recurrence,
    DateTime? startDate,
    List<int>? weekDays,
    int? monthDay,
    int? annualMonth,
    int? annualDay,
  }) {
    return Activity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
      weekDays: weekDays ?? this.weekDays,
      monthDay: monthDay ?? this.monthDay,
      annualMonth: annualMonth ?? this.annualMonth,
      annualDay: annualDay ?? this.annualDay,
    );
  }

  // ── JSON ───────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'time': time,
        'durationMinutes': durationMinutes,
        'colorValue': color.value,
        'isCompleted': isCompleted,
        'recurrence': recurrence.jsonVal,
        'startDate': startDate.toIso8601String(),
        'weekDays': weekDays,
        'monthDay': monthDay,
        'annualMonth': annualMonth,
        'annualDay': annualDay,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        time: json['time'] as String,
        durationMinutes: json['durationMinutes'] as int? ?? 60,
        color: Color(json['colorValue'] as int),
        isCompleted: json['isCompleted'] as bool? ?? false,
        recurrence: RecurrenceTypeX.fromJson(json['recurrence'] as String? ?? 'none'),
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : DateTime.now(),
        weekDays: (json['weekDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        monthDay: json['monthDay'] as int?,
        annualMonth: json['annualMonth'] as int?,
        annualDay: json['annualDay'] as int?,
      );

  String toJsonString() => jsonEncode(toJson());
  factory Activity.fromJsonString(String s) =>
      Activity.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

