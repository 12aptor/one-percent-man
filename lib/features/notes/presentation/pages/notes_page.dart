import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/tasks_notifier.dart';
import '../../domain/models/task_model.dart';

// ─────────────────────────────────────────────────────
// Selected list provider (tab state)
// ─────────────────────────────────────────────────────
final _selectedListIdProvider = StateProvider<String>((ref) => defaultListId);

// ─────────────────────────────────────────────────────
// TasksPage – main widget
// ─────────────────────────────────────────────────────
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _notifOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(taskReminderStreamProvider, (_, next) {
        next.whenData(_showPushNotification);
      });
    });
  }

  // ── In-app push notification overlay ─────────────
  void _showPushNotification(Task task) {
    _notifOverlay?.remove();
    _notifOverlay = null;

    final entry = OverlayEntry(
      builder: (_) => _PushNotificationBanner(
        task: task,
        onDismiss: () {
          _notifOverlay?.remove();
          _notifOverlay = null;
        },
        onComplete: () {
          ref.read(tasksNotifierProvider.notifier).toggleCompletion(task.id);
          _notifOverlay?.remove();
          _notifOverlay = null;
        },
      ),
    );

    _notifOverlay = entry;
    Overlay.of(context).insert(entry);

    // Auto-dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (_notifOverlay == entry) {
        _notifOverlay?.remove();
        _notifOverlay = null;
      }
    });
  }

  @override
  void dispose() {
    _notifOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksNotifierProvider);
    final selectedId = ref.watch(_selectedListIdProvider);

    if (!state.isLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentList = state.lists.isEmpty
        ? null
        : state.lists.firstWhere(
            (l) => l.id == selectedId,
            orElse: () => state.lists.first,
          );

    final tasks = currentList != null
        ? state.tasksForList(currentList.id)
        : <Task>[];

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    final total = tasks.length;
    final completedCount = completed.length;
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── App Bar ──────────────────────────────
          _TasksAppBar(
            pendingCount: pending.length,
            completedCount: completedCount,
            progress: progress,
            onCreateList: () => _showListForm(context),
          ),
          // ── List tabs ────────────────────────────
          _ListTabBar(
            lists: state.lists,
            selectedId: selectedId,
            onSelect: (id) =>
                ref.read(_selectedListIdProvider.notifier).state = id,
            onEdit: (list) => _showListForm(context, list: list),
            onDelete: (list) => _showDeleteListDialog(context, list),
          ),
          // ── Task content ─────────────────────────
          Expanded(
            child: tasks.isEmpty
                ? const _EmptyListState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      if (pending.isNotEmpty) ...[
                        _SectionHeader(
                            label: 'Pendientes',
                            count: pending.length,
                            color: Theme.of(context).colorScheme.primary),
                        ...pending.map((t) => _TaskCard(
                              task: t,
                              listColor: Color(
                                state.lists
                                    .firstWhere((l) => l.id == t.listId,
                                        orElse: () => state.lists.first)
                                    .colorValue,
                              ),
                              onToggle: () => ref
                                  .read(tasksNotifierProvider.notifier)
                                  .toggleCompletion(t.id),
                              onEdit: () =>
                                  _showTaskForm(context, task: t),
                              onDelete: () => ref
                                  .read(tasksNotifierProvider.notifier)
                                  .deleteTask(t.id),
                            )),
                      ],
                      if (completed.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionHeader(
                            label: 'Completadas',
                            count: completedCount,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                        ...completed.map((t) => _TaskCard(
                              task: t,
                              listColor: Color(
                                state.lists
                                    .firstWhere((l) => l.id == t.listId,
                                        orElse: () => state.lists.first)
                                    .colorValue,
                              ),
                              onToggle: () => ref
                                  .read(tasksNotifierProvider.notifier)
                                  .toggleCompletion(t.id),
                              onEdit: () =>
                                  _showTaskForm(context, task: t),
                              onDelete: () => ref
                                  .read(tasksNotifierProvider.notifier)
                                  .deleteTask(t.id),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: currentList == null
          ? null
          : FloatingActionButton(
              heroTag: 'tasks_fab',
              onPressed: () => _showTaskForm(context, listId: currentList.id),
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 4,
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
            ),
    );
  }

  // ── Dialogs ────────────────────────────────────────
  void _showTaskForm(BuildContext context, {String? listId, Task? task}) {
    final state = ref.read(tasksNotifierProvider);
    final effectiveListId = listId ?? task?.listId ?? defaultListId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(
        task: task,
        listId: effectiveListId,
        lists: state.lists,
        ref: ref,
      ),
    );
  }

  void _showListForm(BuildContext context, {TaskList? list}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ListFormSheet(list: list, ref: ref),
    );
  }



  void _showDeleteListDialog(BuildContext context, TaskList list) {
    if (list.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La lista por defecto no puede eliminarse'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar lista'),
        content: Text(
            '¿Eliminar "${list.name}" y todas sus tareas? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              ref.read(tasksNotifierProvider.notifier).deleteList(list.id);
              ref.read(_selectedListIdProvider.notifier).state = defaultListId;
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────
class _TasksAppBar extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final double progress;
  final VoidCallback onCreateList;

  const _TasksAppBar({
    required this.pendingCount,
    required this.completedCount,
    required this.progress,
    required this.onCreateList,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = pendingCount + completedCount;
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
                'Tareas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCreateList,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.folderPlus,
                          size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Nueva lista',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$completedCount/$totalCount completadas',
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
// List Tab Bar
// ─────────────────────────────────────────────────────
class _ListTabBar extends StatelessWidget {
  final List<TaskList> lists;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final ValueChanged<TaskList> onEdit;
  final ValueChanged<TaskList> onDelete;

  const _ListTabBar({
    required this.lists,
    required this.selectedId,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Bottom border line (full width)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Theme.of(context).dividerColor),
          ),
          // Scrollable tabs
          ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16),
            itemCount: lists.length,
            itemBuilder: (_, i) {
              final list = lists[i];
              final isSelected = list.id == selectedId;
              final dotColor = Color(list.colorValue);

              return GestureDetector(
                onTap: () => onSelect(list.id),
                onLongPress: () => _showListOptions(context, list),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border(
                            bottom: BorderSide(
                              color: dotColor,
                              width: 2.5,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        list.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          // Always use high-contrast colors – never the list color
                          color: isSelected
                              ? Theme.of(context).textTheme.displayLarge?.color ?? Colors.black
                              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showListOptions(BuildContext context, TaskList list) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(list.name,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(LucideIcons.pencil, color: Theme.of(context).colorScheme.primary),
              title: const Text('Editar lista'),
              onTap: () {
                Navigator.pop(context);
                onEdit(list);
              },
            ),
            if (!list.isDefault)
              ListTile(
                leading: Icon(LucideIcons.trash2, color: Colors.red.shade400),
                title: Text('Eliminar lista',
                    style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(list);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionHeader(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.8)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99)),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────
class _EmptyListState extends StatelessWidget {
  const _EmptyListState();

  @override
  Widget build(BuildContext context) {
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
              child: Icon(LucideIcons.clipboardList,
                  size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text('Sin tareas todavía',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black)),
            const SizedBox(height: 8),
            Text(
              'Usa el botón "Nueva Tarea" para añadir tu primera tarea y activar un recordatorio',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final Color listColor;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.listColor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    final dateLabel = DateFormat('EEE d MMM', 'es').format(task.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
          onTap: onEdit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: isDone
                  ? Theme.of(context).cardColor.withOpacity(0.6)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDone
                    ? Theme.of(context).dividerColor
                    : listColor.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isDone ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(LucideIcons.check,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDone
                                    ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                                    : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Meta row: date + time + reminder
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Date badge
                          _Badge(
                            icon: LucideIcons.calendar,
                            label: dateLabel,
                            color: isDone
                                ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                                : listColor,
                            bgColor: isDone
                                ? Theme.of(context).dividerColor
                                : listColor.withOpacity(0.1),
                          ),
                          // Time badge
                          _Badge(
                            icon: LucideIcons.clock,
                            label: task.time,
                            color: isDone
                                ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            bgColor: isDone
                                ? Theme.of(context).dividerColor
                                : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          ),
                          // Reminder badge
                          if (task.reminderEnabled && !isDone)
                            _Badge(
                              icon: LucideIcons.bell,
                              label: 'Alerta',
                              color: Colors.orange.shade600,
                              bgColor: Colors.orange.shade50,
                            ),
                          // Priority badge
                          if (!isDone)
                            _PriorityBadge(priority: task.priority),
                        ],
                      ),
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
                        title: const Text('Eliminar tarea'),
                        content: Text(
                            '¿Eliminar "${task.title}"? Esta acción no se puede deshacer.'),
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
                      onDelete();
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
              ],
            ),
          ),
        ),
      );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String label;

    switch (priority) {
      case TaskPriority.low:
        color = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
        bgColor = Theme.of(context).dividerColor;
        label = 'Baja';
        break;
      case TaskPriority.medium:
        color = Theme.of(context).colorScheme.primary;
        bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
        label = 'Media';
        break;
      case TaskPriority.high:
        color = const Color(0xFFFF9800);
        bgColor = const Color(0xFFFF9800).withOpacity(0.1);
        label = 'Alta';
        break;
      case TaskPriority.urgent:
        color = const Color(0xFFFF4C4C);
        bgColor = const Color(0xFFFF4C4C).withOpacity(0.1);
        label = 'Urgente';
        break;
    }

    return _Badge(
      icon: LucideIcons.alertCircle,
      label: label,
      color: color,
      bgColor: bgColor,
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _Badge(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Task Form Sheet (create / edit)
// ─────────────────────────────────────────────────────
class _TaskFormSheet extends StatefulWidget {
  final Task? task;
  final String listId;
  final List<TaskList> lists;
  final WidgetRef ref;

  const _TaskFormSheet({
    this.task,
    required this.listId,
    required this.lists,
    required this.ref,
  });

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _reminderEnabled;
  late String _selectedListId;
  late TaskPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _selectedDate = t?.date ?? DateTime.now();
    _reminderEnabled = t?.reminderEnabled ?? true;
    _selectedListId = t?.listId ?? widget.listId;
    _selectedPriority = t?.priority ?? TaskPriority.medium;

    if (t != null) {
      final parts = t.time.split(':');
      _selectedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String get _formattedTime =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    final t = widget.task;
    if (t == null) {
      widget.ref.read(tasksNotifierProvider.notifier).addTask(
            Task(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              listId: _selectedListId,
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              date: _selectedDate,
              time: _formattedTime,
              reminderEnabled: _reminderEnabled,
              priority: _selectedPriority,
              createdAt: DateTime.now(),
            ),
          );
    } else {
      widget.ref.read(tasksNotifierProvider.notifier).updateTask(
            t.copyWith(
              listId: _selectedListId,
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              date: _selectedDate,
              time: _formattedTime,
              reminderEnabled: _reminderEnabled,
              priority: _selectedPriority,
            ),
          );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final dateLabel = DateFormat('EEE, d MMM yyyy', 'es').format(_selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Text(
                isEditing ? 'Editar Tarea' : 'Nueva Tarea',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // List selector chip
              if (widget.lists.length > 1)
                GestureDetector(
                  onTap: _pickList,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(
                        widget.lists
                            .firstWhere((l) => l.id == _selectedListId,
                                orElse: () => widget.lists.first)
                            .colorValue,
                      ).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: Color(
                              widget.lists
                                  .firstWhere(
                                      (l) => l.id == _selectedListId,
                                      orElse: () => widget.lists.first)
                                  .colorValue,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.lists
                              .firstWhere((l) => l.id == _selectedListId,
                                  orElse: () => widget.lists.first)
                              .name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(
                              widget.lists
                                  .firstWhere(
                                      (l) => l.id == _selectedListId,
                                      orElse: () => widget.lists.first)
                                  .colorValue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 12,
                          color: Color(
                            widget.lists
                                .firstWhere((l) => l.id == _selectedListId,
                                    orElse: () => widget.lists.first)
                                .colorValue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          _label('Título *'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            autofocus: !isEditing,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecor('p.ej. Revisar metas semanales'),
          ),
          const SizedBox(height: 14),

          // Description
          _label('Descripción'),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: _inputDecor('Agrega más detalles...'),
          ),
          const SizedBox(height: 14),

          // Date + Time row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Fecha'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: _pickerTile(
                        icon: LucideIcons.calendar,
                        label: dateLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Hora'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickTime,
                      child: _pickerTile(
                        icon: LucideIcons.clock,
                        label: _formattedTime,
                        isBig: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Priority Selector
          _label('Prioridad'),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((p) {
              final isSel = _selectedPriority == p;
              Color color;
              String label;
              switch (p) {
                case TaskPriority.low:
                  color = Colors.blueGrey;
                  label = 'Baja';
                  break;
                case TaskPriority.medium:
                  color = Theme.of(context).colorScheme.primary;
                  label = 'Media';
                  break;
                case TaskPriority.high:
                  color = Colors.orange;
                  label = 'Alta';
                  break;
                case TaskPriority.urgent:
                  color = Colors.red;
                  label = 'Urgente';
                  break;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: p == TaskPriority.urgent ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? color.withOpacity(0.15) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? color : Theme.of(context).dividerColor,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? color : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Reminder toggle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _reminderEnabled
                  ? Colors.orange.withOpacity(0.15)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _reminderEnabled
                    ? Colors.orange.withOpacity(0.4)
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _reminderEnabled
                        ? Colors.orange.withOpacity(0.25)
                        : Theme.of(context).dividerColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _reminderEnabled ? LucideIcons.bell : LucideIcons.bellOff,
                    size: 18,
                    color: _reminderEnabled
                        ? Colors.orangeAccent
                        : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recordatorio',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _reminderEnabled
                              ? Colors.orangeAccent
                              : Theme.of(context).textTheme.displayLarge?.color ?? Colors.white,
                        ),
                      ),
                      Text(
                        _reminderEnabled
                            ? 'Te alertará el $dateLabel a las $_formattedTime'
                            : 'Sin alerta',
                        style: TextStyle(
                          fontSize: 11,
                          color: _reminderEnabled
                              ? Colors.orange.shade600
                              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                  activeColor: Colors.orange.shade600,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                isEditing ? 'Guardar Cambios' : 'Crear Tarea',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Seleccionar lista',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...widget.lists.map((list) {
              final color = Color(list.colorValue);
              final isSelected = list.id == _selectedListId;
              return ListTile(
                leading: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                  ),
                ),
                title: Text(list.name),
                trailing: isSelected
                    ? Icon(LucideIcons.check, color: color)
                    : null,
                onTap: () {
                  setState(() => _selectedListId = list.id);
                  Navigator.pop(context);
                },
              );
            }),
          ],
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
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _pickerTile(
      {required IconData icon, required String label, bool isBig = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isBig ? 17 : 12,
                color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
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
// List Form Sheet (create / edit)
// ─────────────────────────────────────────────────────
class _ListFormSheet extends StatefulWidget {
  final TaskList? list;
  final WidgetRef ref;

  const _ListFormSheet({this.list, required this.ref});

  @override
  State<_ListFormSheet> createState() => _ListFormSheetState();
}

class _ListFormSheetState extends State<_ListFormSheet> {
  late TextEditingController _nameCtrl;
  late Color _selectedColor;

  final List<Color> _palette = const [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF7C3AED), // Violet
    Color(0xFFDB2777), // Pink
    Color(0xFFDC2626), // Red
    Color(0xFFEA580C), // Orange
    Color(0xFFD97706), // Amber
    Color(0xFF16A34A), // Green
    Color(0xFF0891B2), // Cyan
    Color(0xFF0EA5E9), // Sky
    Color(0xFF059669), // Emerald
    Color(0xFF64748B), // Slate
    Color(0xFF374151), // Gray
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.list?.name ?? '');
    _selectedColor = widget.list != null
        ? Color(widget.list!.colorValue)
        : _palette.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    final l = widget.list;
    if (l == null) {
      widget.ref.read(tasksNotifierProvider.notifier).addList(
            TaskList(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameCtrl.text.trim(),
              colorValue: _selectedColor.value,
              createdAt: DateTime.now(),
            ),
          );
    } else {
      widget.ref.read(tasksNotifierProvider.notifier).updateList(
            l.copyWith(
              name: _nameCtrl.text.trim(),
              colorValue: _selectedColor.value,
            ),
          );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.list != null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEditing ? 'Editar Lista' : 'Nueva Lista',
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Name field
          Text('Nombre',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'p.ej. Trabajo, Personal, Fitness...',
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.list, size: 16, color: _selectedColor),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _selectedColor, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Color picker
          Text('Color',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _palette.map((color) {
              final isSelected = (_selectedColor.value == color.value);
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(LucideIcons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                isEditing ? 'Guardar Cambios' : 'Crear Lista',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Push Notification Banner (in-app overlay)
// ─────────────────────────────────────────────────────
class _PushNotificationBanner extends StatefulWidget {
  final Task task;
  final VoidCallback onDismiss;
  final VoidCallback onComplete;

  const _PushNotificationBanner({
    required this.task,
    required this.onDismiss,
    required this.onComplete,
  });

  @override
  State<_PushNotificationBanner> createState() =>
      _PushNotificationBannerState();
}

class _PushNotificationBannerState extends State<_PushNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _slide = Tween<Offset>(
            begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final dateLabel = DateFormat('d MMM', 'es').format(widget.task.date);

    return Positioned(
      top: safeTop + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity! < 0) _dismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bell icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.bellRing,
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App label + time
                          Row(
                            children: [
                              const Text(
                                'One Percent Man · Recordatorio',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$dateLabel ${widget.task.time}',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.task.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (widget.task.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.task.description,
                              style: TextStyle(
                                color: Color(0xFFAEAEB2),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _dismiss,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2E),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Descartar',
                                      style: TextStyle(
                                        color: Color(0xFFAEAEB2),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await _ctrl.reverse();
                                    widget.onComplete();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade700,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Completar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

