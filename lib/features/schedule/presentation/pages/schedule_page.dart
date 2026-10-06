import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/activities_provider.dart';
import '../../domain/models/activity.dart';

// ─── State providers ──────────────────────────────────
final _selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ─────────────────────────────────────────────────────
// SchedulePage
// ─────────────────────────────────────────────────────
class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivities = ref.watch(activitiesProvider);
    final selectedDate = ref.watch(_selectedDateProvider);
    final todayActivities =
        ref.read(activitiesProvider.notifier).activitiesForDate(selectedDate);

    final completedCount = todayActivities.where((a) => a.isCompleted).length;
    final total = todayActivities.length;
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── App bar + progress ───────────────────────
          _ScheduleAppBar(
            completedCount: completedCount,
            total: total,
            progress: progress,
          ),
          // ── Horizontal calendar ──────────────────────
          _HorizontalCalendar(
            allActivities: allActivities,
            selectedDate: selectedDate,
            onSelect: (d) => ref.read(_selectedDateProvider.notifier).state = d,
          ),
          // ── Timeline ─────────────────────────────────
          Expanded(
            child: todayActivities.isEmpty
                ? _buildEmptyTimeline(context, ref, selectedDate)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: todayActivities.length,
                    itemBuilder: (ctx, i) => _TimelineItem(
                      activity: todayActivities[i],
                      isFirst: i == 0,
                      isLast: i == todayActivities.length - 1,
                      ref: ref,
                      onTap: () => _showActivityDialog(context, ref,
                          activity: todayActivities[i],
                          selectedDate: selectedDate),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schedule_fab',
        onPressed: () =>
            _showActivityDialog(context, ref, selectedDate: selectedDate),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyTimeline(
      BuildContext context, WidgetRef ref, DateTime date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: Icon(LucideIcons.calendarX,
                  size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin actividades',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega una actividad nueva o crea una recurrente que aplique a este día',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDialog(BuildContext context, WidgetRef ref,
      {Activity? activity, required DateTime selectedDate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityFormSheet(
        activity: activity,
        ref: ref,
        selectedDate: selectedDate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Schedule App Bar
// ─────────────────────────────────────────────────────
class _ScheduleAppBar extends StatelessWidget {
  final int completedCount;
  final int total;
  final double progress;

  const _ScheduleAppBar({
    required this.completedCount,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Horario',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$completedCount/$total completadas',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: Theme.of(context).cardColor,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Horizontal Calendar with activity dots
// ─────────────────────────────────────────────────────
class _HorizontalCalendar extends StatelessWidget {
  final List<Activity> allActivities;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  const _HorizontalCalendar({
    required this.allActivities,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 21,
        itemBuilder: (_, index) {
          final date = DateTime.now()
              .subtract(const Duration(days: 3))
              .add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          final hasActivities = allActivities.any((a) => a.occursOn(date));

          return GestureDetector(
            onTap: () => onSelect(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'es').format(date).toUpperCase(),
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Activity dot indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: hasActivities
                          ? (isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Theme.of(context).colorScheme.primary)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Timeline item card
// ─────────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final Activity activity;
  final bool isFirst;
  final bool isLast;
  final WidgetRef ref;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.activity,
    required this.isFirst,
    required this.isLast,
    required this.ref,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Text(
                  activity.time,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 2,
                height: isFirst ? 12 : 20,
                color: isFirst ? Colors.transparent : Theme.of(context).dividerColor,
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                      activity.isCompleted ? Theme.of(context).colorScheme.primary : activity.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activity.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Theme.of(context).dividerColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Activity card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: activity.isCompleted ? 0.6 : 1.0,
                  child: CustomCard(
                    color: activity.color,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                                      decoration: activity.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (activity.description.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      activity.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete button
                            GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    title: const Text('Eliminar actividad'),
                                    content: Text('¿Eliminar "${activity.title}"?\n\n'
                                        '${activity.recurrence != RecurrenceType.none ? 'Esto eliminará la actividad recurrente por completo.' : 'Esta acción no se puede deshacer.'}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red.shade400),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
                                if (confirm) {
                                  ref.read(activitiesProvider.notifier).deleteActivity(activity.id);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.trash2,
                                  size: 15,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Checkbox
                            GestureDetector(
                              onTap: () => ref
                                  .read(activitiesProvider.notifier)
                                  .toggleCompletion(activity.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: activity.isCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: activity.isCompleted
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: activity.isCompleted
                                    ? const Icon(LucideIcons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Meta row
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _MetaChip(
                              icon: LucideIcons.clock,
                              label: '${activity.time} – ${activity.endTime}',
                            ),
                            _MetaChip(
                              icon: LucideIcons.timer,
                              label:
                                  _formatDuration(activity.durationMinutes),
                            ),
                            // Recurrence badge
                            if (activity.recurrence != RecurrenceType.none)
                              _MetaChip(
                                icon: LucideIcons.repeat,
                                label: activity.recurrenceLabel,
                                highlight: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaChip(
      {required this.icon, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11,
              color: highlight ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: highlight ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Activity Form Sheet – with recurrence support
// ─────────────────────────────────────────────────────
class _ActivityFormSheet extends StatefulWidget {
  final Activity? activity;
  final WidgetRef ref;
  final DateTime selectedDate;

  const _ActivityFormSheet({
    this.activity,
    required this.ref,
    required this.selectedDate,
  });

  @override
  State<_ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<_ActivityFormSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late Color _selectedColor;
  late TimeOfDay _selectedTime;
  late TimeOfDay _selectedEndTime;
  late RecurrenceType _recurrence;
  late DateTime _startDate;
  late List<int> _weekDays;
  late int _monthDay;
  late int _annualMonth;
  late int _annualDay;

  final List<Color> _colors = const [
    AppColors.pastelBlue,
    AppColors.pastelOrange,
    AppColors.pastelGreen,
    AppColors.pastelPurple,
    AppColors.pastelRed,
    AppColors.pastelYellow,
    AppColors.pastelPink,
    AppColors.pastelTeal,
  ];

  final List<int> _durations = const [15, 30, 45, 60, 75, 90, 105, 120, 150, 180, 210, 240, 300, 360];

  static const _monthNames = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _descCtrl = TextEditingController(text: a?.description ?? '');
    _selectedColor = a?.color ?? AppColors.pastelBlue;
    _recurrence = a?.recurrence ?? RecurrenceType.none;
    _startDate = a?.startDate ?? widget.selectedDate;
    _weekDays = List<int>.from(a?.weekDays ?? []);
    _monthDay = a?.monthDay ?? (a?.startDate.day ?? widget.selectedDate.day);
    _annualMonth =
        a?.annualMonth ?? (a?.startDate.month ?? widget.selectedDate.month);
    _annualDay = a?.annualDay ?? (a?.startDate.day ?? widget.selectedDate.day);

    if (a != null) {
      final parts = a.time.split(':');
      _selectedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final endParts = a.endTime.split(':');
      _selectedEndTime =
          TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
    } else {
      _selectedTime = TimeOfDay.now();
      _selectedEndTime = TimeOfDay(
          hour: (_selectedTime.hour + 1) % 24, minute: _selectedTime.minute);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _selectedTime : _selectedEndTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(context).colorScheme,
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Theme.of(context).cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedTime = picked;
          // Sync end time if it's now before start time
          final startMin = _selectedTime.hour * 60 + _selectedTime.minute;
          final endMin = _selectedEndTime.hour * 60 + _selectedEndTime.minute;
          if (endMin <= startMin) {
            _selectedEndTime = TimeOfDay(
                hour: (_selectedTime.hour + 1) % 24, minute: _selectedTime.minute);
          }
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_recurrence == RecurrenceType.monthly) {
          _monthDay = picked.day;
        }
        if (_recurrence == RecurrenceType.annual) {
          _annualMonth = picked.month;
          _annualDay = picked.day;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;

    final startMin = _selectedTime.hour * 60 + _selectedTime.minute;
    var endMin = _selectedEndTime.hour * 60 + _selectedEndTime.minute;
    if (endMin <= startMin) endMin += 24 * 60; // Assume next day
    final duration = endMin - startMin;

    HapticFeedback.lightImpact();

    final a = widget.activity;
    final updated = Activity(
      id: a?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      time: _formatTimeOfDay(_selectedTime),
      durationMinutes: duration,
      color: _selectedColor,
      isCompleted: a?.isCompleted ?? false,
      recurrence: _recurrence,
      startDate: _startDate,
      weekDays: _recurrence == RecurrenceType.weekly ? _weekDays : [],
      monthDay: _recurrence == RecurrenceType.monthly ? _monthDay : null,
      annualMonth: _recurrence == RecurrenceType.annual ? _annualMonth : null,
      annualDay: _recurrence == RecurrenceType.annual ? _annualDay : null,
    );

    if (a == null) {
      widget.ref.read(activitiesProvider.notifier).addActivity(updated);
    } else {
      widget.ref.read(activitiesProvider.notifier).updateActivity(updated);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Editar Actividad' : 'Nueva Actividad',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _label('Título *'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecor('ej. Cálculo Diferencial'),
              ),
              const SizedBox(height: 14),
              _label('Descripción'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: _inputDecor('Detalles adicionales...'),
              ),
              const SizedBox(height: 14),

              // ── Time Selection ───────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Inicia'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickTime(true),
                          child: _pickerTile(
                              icon: LucideIcons.clock,
                              label: _formatTimeOfDay(_selectedTime)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Termina'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickTime(false),
                          child: _pickerTile(
                              icon: LucideIcons.checkCircle,
                              label: _formatTimeOfDay(_selectedEndTime)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _label('Repetición'),
              const SizedBox(height: 10),
              _RecurrenceSelector(
                value: _recurrence,
                onChanged: (r) => setState(() => _recurrence = r),
              ),
              const SizedBox(height: 14),
              if (_recurrence != RecurrenceType.none) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_recurrence == RecurrenceType.weekly) ...[
                        _label('Días de la semana'),
                        const SizedBox(height: 10),
                        _WeekDayPicker(
                          selected: _weekDays,
                          onToggle: (d) => setState(() {
                            _weekDays.contains(d)
                                ? _weekDays.remove(d)
                                : _weekDays.add(d);
                          }),
                        ),
                        const SizedBox(height: 12),
                        _label('Fecha de inicio'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickStartDate,
                          child: _pickerTile(
                            icon: LucideIcons.calendar,
                            label: DateFormat('d MMM yyyy', 'es')
                                .format(_startDate),
                          ),
                        ),
                      ],
                      if (_recurrence == RecurrenceType.monthly) ...[
                        _label('Día del mes'),
                        const SizedBox(height: 10),
                        _MonthDayPicker(
                          value: _monthDay,
                          onChanged: (d) => setState(() => _monthDay = d),
                        ),
                        const SizedBox(height: 12),
                        _label('Fecha de inicio (referencia)'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickStartDate,
                          child: _pickerTile(
                            icon: LucideIcons.calendar,
                            label: DateFormat('MMMM yyyy', 'es')
                                .format(_startDate),
                          ),
                        ),
                      ],
                      if (_recurrence == RecurrenceType.annual) ...[
                        _label('Mes y día'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _annualMonth,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(12),
                                    icon: const Icon(LucideIcons.chevronDown,
                                        size: 16),
                                    items: List.generate(
                                      12,
                                      (i) => DropdownMenuItem(
                                        value: i + 1,
                                        child: Text(_monthNames[i + 1],
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _annualMonth = v!),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _MonthDayPicker(
                                value: _annualDay,
                                onChanged: (d) =>
                                    setState(() => _annualDay = d),
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _label('Color'),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (_, i) {
                    final color = _colors[i];
                    final isSel = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 10),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSel
                              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2.5)
                              : Border.all(
                                  color: Colors.transparent, width: 2.5),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: isSel
                            ? Icon(LucideIcons.check,
                                size: 18, color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Guardar Cambios' : 'Crear Actividad',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.titleSmall?.color ?? Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0.3,
        ),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _pickerTile({required IconData icon, required String label}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────
// Recurrence type selector (pill chips)
// ─────────────────────────────────────────────────────
class _RecurrenceSelector extends StatelessWidget {
  final RecurrenceType value;
  final ValueChanged<RecurrenceType> onChanged;

  const _RecurrenceSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RecurrenceType.values.map((r) {
        final isSelected = value == r;
        return GestureDetector(
          onTap: () => onChanged(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _recurrenceIcon(r),
                  size: 13,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.titleSmall?.color ?? Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 5),
                Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.titleSmall?.color ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _recurrenceIcon(RecurrenceType r) {
    switch (r) {
      case RecurrenceType.none:
        return LucideIcons.minus;
      case RecurrenceType.weekly:
        return LucideIcons.calendarDays;
      case RecurrenceType.monthly:
        return LucideIcons.calendarRange;
      case RecurrenceType.annual:
        return LucideIcons.cake;
    }
  }
}

// ─────────────────────────────────────────────────────
// Weekday picker (Mon–Sun circles)
// ─────────────────────────────────────────────────────
class _WeekDayPicker extends StatelessWidget {
  final List<int> selected;
  final ValueChanged<int> onToggle;

  const _WeekDayPicker({required this.selected, required this.onToggle});

  static const _days = [
    (DateTime.monday, 'L'),
    (DateTime.tuesday, 'M'),
    (DateTime.wednesday, 'X'),
    (DateTime.thursday, 'J'),
    (DateTime.friday, 'V'),
    (DateTime.saturday, 'S'),
    (DateTime.sunday, 'D'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _days.map(((int, String) entry) {
        final (day, label) = entry;
        final isSel = selected.contains(day);
        return GestureDetector(
          onTap: () => onToggle(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSel ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.titleSmall?.color ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────
// Month day picker (1-31 scrollable row)
// ─────────────────────────────────────────────────────
class _MonthDayPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool compact;

  const _MonthDayPicker({
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(LucideIcons.chevronDown, size: 16),
            items: List.generate(
              31,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text('Día ${i + 1}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            onChanged: (v) => onChanged(v!),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 31,
        itemBuilder: (_, i) {
          final day = i + 1;
          final isSel = value == day;
          return GestureDetector(
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.titleSmall?.color ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

