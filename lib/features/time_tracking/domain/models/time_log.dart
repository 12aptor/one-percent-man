import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AuditActivityType {
  timer, // Se presiona al iniciar y se apaga al finalizar; se acumula en tramos
  singleCheck, // Se presiona una sola vez
}

enum AuditActivity {
  // ── Modo Guerra ─────────────────────────────
  madrugar(
    id: 'madrugar',
    label: 'Madrugar',
    icon: LucideIcons.sunrise,
    color: Color(0xFFF59E0B), // Amber sunrise
    type: AuditActivityType.singleCheck,
    description: 'Levantarse temprano y ganar la primera victoria del día.',
    isMonkOnly: false,
  ),
  entrenar(
    id: 'entrenar',
    label: 'Entrenar',
    icon: LucideIcons.dumbbell,
    color: Color(0xFFEF4444), // Crimson red
    type: AuditActivityType.timer,
    description: 'Fuerza, cardio y superación física.',
    isMonkOnly: false,
  ),
  trabajarEstudiar(
    id: 'trabajar_estudiar',
    label: 'Trabajar/Estudiar',
    icon: LucideIcons.briefcase,
    color: Color(0xFF3B82F6), // Electric blue
    type: AuditActivityType.timer,
    description: 'Bloques de trabajo y estudio enfocado sin distracciones.',
    isMonkOnly: false,
  ),
  desarrollo(
    id: 'desarrollo',
    label: 'Desarrollo',
    icon: LucideIcons.bookOpen,
    color: Color(0xFF8B5CF6), // Purple
    type: AuditActivityType.timer,
    description: 'Lectura, aprendizaje y desarrollo personal continuo.',
    isMonkOnly: false,
  ),
  nutricion(
    id: 'nutricion',
    label: 'Nutrición',
    icon: LucideIcons.utensils,
    color: Color(0xFF10B981), // Emerald green
    type: AuditActivityType.singleCheck,
    description: 'Alimentación limpia, hidratación y cero comida chatarra.',
    isMonkOnly: false,
  ),
  planificar(
    id: 'planificar',
    label: 'Planificar',
    icon: LucideIcons.calendarCheck,
    color: Color(0xFF06B6D4), // Cyan
    type: AuditActivityType.singleCheck,
    description: 'Planificación nocturna y organización de objetivos.',
    isMonkOnly: false,
  ),
  ceroSimpeo(
    id: 'cero_simpeo',
    label: 'Cero Simpeo',
    icon: LucideIcons.shieldAlert,
    color: Color(0xFFEC4899), // Rose pink
    type: AuditActivityType.singleCheck,
    description: 'Dignidad, auto-respeto y cero validación ajena.',
    isMonkOnly: false,
  ),
  meditacion(
    id: 'meditacion',
    label: 'Meditación',
    icon: LucideIcons.brain,
    color: Color(0xFF6366F1), // Indigo
    type: AuditActivityType.singleCheck,
    description: 'Calma mental, respiración consciente y serenidad estoica.',
    isMonkOnly: false,
  ),
  descansarTemprano(
    id: 'descansar_temprano',
    label: 'Descansar Temprano',
    icon: LucideIcons.moon,
    color: Color(0xFF64748B), // Slate night
    type: AuditActivityType.singleCheck,
    description: 'Dormir a tiempo para recuperación profunda del organismo.',
    isMonkOnly: false,
  ),

  // ── Modo Monje (Adicionales) ─────────────────
  ceroDopamina(
    id: 'cero_dopamina',
    label: 'Cero Dopamina',
    icon: LucideIcons.monitorOff,
    color: Color(0xFFF97316), // Vivid orange
    type: AuditActivityType.singleCheck,
    description: 'Cero redes sociales, pornografía y consumo de contenido digital.',
    isMonkOnly: true,
  ),
  aislamiento(
    id: 'aislamiento',
    label: 'Aislamiento',
    icon: LucideIcons.userX,
    color: Color(0xFF14B8A6), // Teal
    type: AuditActivityType.singleCheck,
    description: 'Evitar relaciones personales, compromisos sociales y distracciones de terceros.',
    isMonkOnly: true,
  );

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final AuditActivityType type;
  final String description;
  final bool isMonkOnly;

  const AuditActivity({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
    required this.description,
    required this.isMonkOnly,
  });

  bool get isTimer => type == AuditActivityType.timer;
  bool get isSingleCheck => type == AuditActivityType.singleCheck;
}

class AuditLogEntry {
  final String id;
  final AuditActivity activity;
  final DateTime timestamp;
  final DateTime? endTime;
  final Duration duration;
  final bool isSingleCheck;

  AuditLogEntry({
    required this.id,
    required this.activity,
    required this.timestamp,
    this.endTime,
    this.duration = Duration.zero,
    required this.isSingleCheck,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityId': activity.id,
    'timestamp': timestamp.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'durationSeconds': duration.inSeconds,
    'isSingleCheck': isSingleCheck,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    final actId = json['activityId'] as String;
    final activity = AuditActivity.values.firstWhere(
      (a) => a.id == actId,
      orElse: () => AuditActivity.entrenar,
    );
    return AuditLogEntry(
      id: json['id'] as String,
      activity: activity,
      timestamp: DateTime.parse(json['timestamp'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      isSingleCheck: json['isSingleCheck'] as bool? ?? false,
    );
  }
}
