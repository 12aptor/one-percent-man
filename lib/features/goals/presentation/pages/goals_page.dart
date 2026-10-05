import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/pin_protection_wrapper.dart';
import '../providers/goals_provider.dart';
import '../../domain/models/goal.dart';
import '../../../finances/presentation/providers/finances_provider.dart';
import '../../../finances/domain/models/transaction.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final completed = goals.where((g) => g.isCompleted).length;
    final total = goals.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return PinProtectionWrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── App Bar ──────────────────────────────
          _GoalsAppBar(
            completedCount: completed,
            total: total,
            progress: progress,
          ),
          // ── Content ──────────────────────────────
          Expanded(
            child: goals.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: total,
                    itemBuilder: (context, index) => _GoalCard(
                      goal: goals[index],
                      onAddProgress: () =>
                          _showAddProgressSheet(context, ref, goals[index]),
                      onEdit: () =>
                          _showGoalForm(context, ref, goal: goals[index]),
                      onDelete: () => ref
                          .read(goalsProvider.notifier)
                          .deleteGoal(goals[index].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'goals_fab',
        onPressed: () => _showGoalForm(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.target,
                  size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin metas todavía',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Establece un gran objetivo y sigue tu\nprogreso paso a paso',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProgressSheet(BuildContext context, WidgetRef ref, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddProgressSheet(goal: goal, ref: ref),
    );
  }

  void _showGoalForm(BuildContext context, WidgetRef ref, {Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoalFormSheet(goal: goal, ref: ref),
    );
  }
}

// ─────────────────────────────────────────────────────
// Goals App Bar
// ─────────────────────────────────────────────────────
class _GoalsAppBar extends StatelessWidget {
  final int completedCount;
  final int total;
  final double progress;

  const _GoalsAppBar({
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
                'Metas',
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

// ──────────────────────────────────────────────
// Goal Card
// ──────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onAddProgress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onAddProgress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = goal.unit.color;
    final progress = goal.progress;
    final isCompleted = goal.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: Key(goal.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 25),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(LucideIcons.trash2, color: Colors.white, size: 24),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Eliminar Meta'),
              content: Text(
                  '¿Eliminar "${goal.title}"? Esta acción no se puede deshacer.'),
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
          );
        },
        onDismissed: (_) => onDelete(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isCompleted ? color.withOpacity(0.5) : Theme.of(context).dividerColor,
              width: isCompleted ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(goal.unit.icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.trophy,
                                          size: 11, color: color),
                                      const SizedBox(width: 4),
                                      Text(
                                        '¡Hecho!',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: color),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.unit.label,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(LucideIcons.pencil,
                            size: 14, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.formatValue(goal.current),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              'de ${goal.formatValue(goal.target)} ${goal.unitLabel}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: color.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        tween: Tween(begin: 0, end: progress),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Remaining
                    if (!isCompleted)
                      Text(
                        'Restan ${goal.formatValue(goal.target - goal.current)} ${goal.unitLabel}',
                        style: TextStyle(
                            fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                      ),
                    if (goal.deadline != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Fecha límite: ${DateFormat('d MMM, yyyy', 'es').format(goal.deadline!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _isDeadlineSoon(goal.deadline!)
                              ? Colors.red.shade400
                              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                          fontWeight: _isDeadlineSoon(goal.deadline!)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Add Progress button
              if (!isCompleted)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddProgress,
                      icon: const Icon(LucideIcons.plusCircle, size: 18),
                      label: const Text('Agregar Progreso',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.checkCircle, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          '¡Meta completada! 🎉',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDeadlineSoon(DateTime deadline) {
    return deadline.difference(DateTime.now()).inDays <= 30;
  }
}

// ──────────────────────────────────────────────
// Add Progress Bottom Sheet
// ──────────────────────────────────────────────
class _AddProgressSheet extends StatefulWidget {
  final Goal goal;
  final WidgetRef ref;

  const _AddProgressSheet({required this.goal, required this.ref});

  @override
  State<_AddProgressSheet> createState() => _AddProgressSheetState();
}

class _AddProgressSheetState extends State<_AddProgressSheet> {
  late TextEditingController _amountController;
  double _quickAmount = 0;
  late bool _addToWallet;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _quickAmount = _defaultQuickAmount();
    _addToWallet = widget.goal.unit == GoalUnit.money;
  }

  double _defaultQuickAmount() {
    switch (widget.goal.unit) {
      case GoalUnit.money:
        return 500;
      case GoalUnit.books:
        return 1;
      case GoalUnit.gymDays:
        return 1;
      case GoalUnit.kilometers:
        return 5;
      case GoalUnit.hours:
        return 1;
      case GoalUnit.pages:
        return 50;
      case GoalUnit.courses:
        return 1;
      case GoalUnit.habits:
        return 1;
      case GoalUnit.weight:
        return 0.5;
      case GoalUnit.custom:
        return 1;
    }
  }

  List<double> get _quickAmounts {
    switch (widget.goal.unit) {
      case GoalUnit.money:
        return [100, 500, 1000, 5000, 10000];
      case GoalUnit.books:
      case GoalUnit.gymDays:
      case GoalUnit.courses:
      case GoalUnit.habits:
        return [1, 2, 3, 5, 7];
      case GoalUnit.kilometers:
        return [1, 3, 5, 10, 21];
      case GoalUnit.hours:
        return [0.5, 1, 2, 3, 4];
      case GoalUnit.pages:
        return [10, 25, 50, 100, 200];
      case GoalUnit.weight:
        return [0.1, 0.5, 1, 2, 5];
      case GoalUnit.custom:
        return [1, 5, 10, 25, 50];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addProgress() {
    final text = _amountController.text.trim();
    final amount = text.isEmpty ? _quickAmount : double.tryParse(text) ?? 0;
    if (amount <= 0) return;

    widget.ref.read(goalsProvider.notifier).addProgress(widget.goal.id, amount);

    if (_addToWallet) {
      final transaction = FinancialTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ahorro',
        amount: amount,
        type: TransactionType.income,
        date: DateTime.now(),
        category: TransactionCategory.savings,
        accountId: widget.goal.id, // Link to the specific goal account
      );
      widget.ref.read(financesProvider.notifier).addTransaction(transaction);
    }

    Navigator.pop(context);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(widget.goal.unit.icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              '+${widget.goal.formatValue(amount)} agregado a ${widget.goal.title}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: widget.goal.unit.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final color = goal.unit.color;
    final remaining = goal.target - goal.current;

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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Goal header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(goal.unit.icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Restan: ${goal.formatValue(remaining)} ${goal.unitLabel}',
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick amounts
          Text('Atajos rápido',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  letterSpacing: 0.3)),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickAmounts.length,
              itemBuilder: (context, index) {
                final amount = _quickAmounts[index];
                final isSelected = _quickAmount == amount;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _quickAmount = amount;
                      _amountController.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: isSelected ? color : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      goal.unit.isMoney
                          ? goal.formatValue(amount)
                          : '${goal.formatValue(amount)} ${goal.unit.symbol}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color:
                            isSelected ? Colors.white : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Custom amount
          Text('Cantidad personalizada',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  letterSpacing: 0.3)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (_) => setState(() => _quickAmount = 0),
            decoration: InputDecoration(
              hintText: goal.unit.isMoney
                  ? 'Ingresa monto \$...'
                  : 'Ingresa ${goal.unitLabel.toLowerCase()}...',
              prefixText: goal.unit.isMoney ? '\$ ' : null,
              prefixIcon: goal.unit.isMoney
                  ? null
                  : Icon(goal.unit.icon,
                      size: 20, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: color, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Sync to wallet toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.piggyBank,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reflejar en Billetera',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Se sumará a tu acumulado de ahorros',
                        style: TextStyle(
                            fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _addToWallet,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) => setState(() => _addToWallet = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _addProgress,
              icon: const Icon(LucideIcons.plusCircle, size: 20),
              label: const Text('Sumar a la Meta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Goal Form (Create / Edit)
// ──────────────────────────────────────────────
class _GoalFormSheet extends StatefulWidget {
  final Goal? goal;
  final WidgetRef ref;

  const _GoalFormSheet({this.goal, required this.ref});

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late TextEditingController _customUnitController;
  late GoalUnit _selectedUnit;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _targetController =
        TextEditingController(text: g != null ? g.target.toString() : '');
    _currentController =
        TextEditingController(text: g != null ? g.current.toString() : '0');
    _customUnitController =
        TextEditingController(text: g?.customUnitLabel ?? '');
    _selectedUnit = g?.unit ?? GoalUnit.money;
    _deadline = g?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() => _deadline = picked);
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final target = double.tryParse(_targetController.text.trim()) ?? 0;
    if (target <= 0) return;

    final g = widget.goal;
    final current = double.tryParse(_currentController.text.trim()) ?? 0;

    if (g == null) {
      widget.ref.read(goalsProvider.notifier).addGoal(
            Goal(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              unit: _selectedUnit,
              customUnitLabel: _customUnitController.text.trim(),
              target: target,
              current: current,
              createdAt: DateTime.now(),
              deadline: _deadline,
            ),
          );
    } else {
      widget.ref.read(goalsProvider.notifier).updateGoal(
            g.copyWith(
              title: _titleController.text.trim(),
              unit: _selectedUnit,
              customUnitLabel: _customUnitController.text.trim(),
              target: target,
              current: current,
              deadline: _deadline,
            ),
          );
    }
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    final color = _selectedUnit.color;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
              isEditing ? 'Editar Meta' : 'Nueva Meta',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Title
            _label('Título de la meta *'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration('ej. Ahorrar para una casa'),
            ),
            const SizedBox(height: 16),

            // Unit selector
            _label('Categoría'),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: GoalUnit.values.length,
                itemBuilder: (context, index) {
                  final unit = GoalUnit.values[index];
                  final isSelected = _selectedUnit == unit;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedUnit = unit),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 10),
                      width: 72,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? unit.color.withOpacity(0.12)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? unit.color : Theme.of(context).dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(unit.icon,
                              color: isSelected
                                  ? unit.color
                                  : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                              size: 26),
                          const SizedBox(height: 6),
                          Text(
                            unit.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? unit.color
                                  : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Custom unit label (only if custom selected)
            if (_selectedUnit == GoalUnit.custom) ...[
              const SizedBox(height: 16),
              _label('Nombre de unidad *'),
              const SizedBox(height: 8),
              TextField(
                controller: _customUnitController,
                decoration: _inputDecoration('ej. Meditaciones, Cuadros...'),
              ),
            ],

            const SizedBox(height: 16),

            // Progress + Target + Deadline
            if (isEditing) ...[
              _label('Progreso Acumulado'),
              const SizedBox(height: 8),
              TextField(
                controller: _currentController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: _inputDecoration(
                  'Monto alcanzado hasta hoy',
                  prefix: _selectedUnit.isMoney ? '\$ ' : null,
                  prefixIcon: _selectedUnit.isMoney
                      ? null
                      : Icon(LucideIcons.trendingUp,
                          size: 18, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Target + deadline row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(_selectedUnit.isMoney
                          ? 'Monto Objetivo *'
                          : 'Objetivo *'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: _inputDecoration(
                          _selectedUnit.isMoney ? '100000' : '12',
                          prefix: _selectedUnit.isMoney ? '\$ ' : null,
                          prefixIcon: _selectedUnit.isMoney
                              ? null
                              : Icon(_selectedUnit.icon,
                                  size: 18, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
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
                      _label('Fecha límite'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDeadline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendarDays,
                                  size: 16,
                                  color: _deadline != null
                                      ? color
                                      : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _deadline != null
                                      ? DateFormat('d MMM, yy', 'es')
                                          .format(_deadline!)
                                      : 'Ninguna',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _deadline != null
                                        ? Theme.of(context).textTheme.displayLarge?.color ?? Colors.black
                                        : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Crear Meta',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
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
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          letterSpacing: 0.3,
        ),
      );

  InputDecoration _inputDecoration(
    String hint, {
    String? prefix,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _selectedUnit.color, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

