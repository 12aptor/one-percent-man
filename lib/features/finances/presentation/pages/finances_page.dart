import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/pin_protection_wrapper.dart';
import '../providers/finances_provider.dart';
import '../../domain/models/transaction.dart';
import '../../../goals/presentation/providers/goals_provider.dart';

class FinancesPage extends ConsumerWidget {
  const FinancesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final selectedId = ref.watch(selectedAccountIdProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(incomeProvider);
    final expense = ref.watch(expenseProvider);

    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    final selectedAccount = accounts.firstWhere((a) => a.id == selectedId,
        orElse: () => accounts.first);

    return PinProtectionWrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _WalletHeader(
              accounts: accounts,
              selectedAccountId: selectedId,
              balance: balance,
              income: income,
              expense: expense,
              onAccountChanged: (id) =>
                  ref.read(selectedAccountIdProvider.notifier).state = id,
              onAdd: (type) =>
                  _showAddTransactionForm(context, ref, type: type),
              onAddAccount: () => _showAddAccountForm(context, ref),
              onDeleteAccount: (account) {
                if (account.id == selectedId) {
                  ref.read(selectedAccountIdProvider.notifier).state = 'main';
                }
                
                // 1. Delete transactions
                ref.read(financesProvider.notifier).deleteTransactionsByAccountId(account.id);
                
                // 2. Delete the account itself
                if (account.goalId != null) {
                  ref.read(goalsProvider.notifier).deleteGoal(account.goalId!);
                } else {
                  ref.read(manualAccountsProvider.notifier).deleteAccount(account.id);
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Historial de la Cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                ),
              ),
            ),
          ),
          if (sortedTransactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context, selectedAccount.name),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = sortedTransactions[index];
                    return _TransactionCard(
                      transaction: tx,
                      onTap: () => _showAddTransactionForm(context, ref,
                          transaction: tx),
                      onDelete: () => ref
                          .read(financesProvider.notifier)
                          .deleteTransaction(tx.id),
                    );
                  },
                  childCount: sortedTransactions.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'finances_fab',
        onPressed: () => _showAddTransactionForm(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String accountName) {
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
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.wallet,
                  size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin movimientos en $accountName',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza a registrar tus finanzas para ver tu historial aquí.',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionForm(BuildContext context, WidgetRef ref,
      {FinancialTransaction? transaction, TransactionType? type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTransactionSheet(
        ref: ref,
        transaction: transaction,
        initialType: type,
      ),
    );
  }

  void _showAddAccountForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddAccountSheet(ref: ref),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  final List<FinancialAccount> accounts;
  final String selectedAccountId;
  final double balance;
  final double income;
  final double expense;
  final Function(String) onAccountChanged;
  final Function(TransactionType) onAdd;
  final VoidCallback onAddAccount;
  final Function(FinancialAccount) onDeleteAccount;

  const _WalletHeader({
    required this.accounts,
    required this.selectedAccountId,
    required this.balance,
    required this.income,
    required this.expense,
    required this.onAccountChanged,
    required this.onAdd,
    required this.onAddAccount,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
        locale: 'en_US', symbol: '\$', decimalDigits: 2);
    final selectedAccount = accounts.firstWhere((a) => a.id == selectedAccountId,
        orElse: () => accounts.first);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF6366F1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6366F1),
            Color(0xFF4F46E5),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 32),
      child: Column(
        children: [
          // Account Selector (Directly on purple)
          GestureDetector(
            onTap: () => _showAccountPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedAccount.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.chevronDown,
                      size: 14, color: Colors.white70),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Balance total disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(balance),
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _CompactStat(
                  label: 'Ingresos',
                  amount: currencyFormatter.format(income),
                  icon: LucideIcons.arrowDownLeft,
                  color: Colors.green,
                  onTap: () => onAdd(TransactionType.income),
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withOpacity(0.15),
              ),
              Expanded(
                child: _CompactStat(
                  label: 'Gastos',
                  amount: currencyFormatter.format(expense),
                  icon: LucideIcons.arrowUpRight,
                  color: Colors.red,
                  onTap: () => onAdd(TransactionType.expense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seleccionar Cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...accounts.map((account) {
              final isSelected = account.id == selectedAccountId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    onAccountChanged(account.id);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: account.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(account.icon, size: 18, color: account.color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            account.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                            ),
                          ),
                        ),
                        if (account.id != 'main')
                          IconButton(
                            icon: const Icon(LucideIcons.trash2,
                                size: 22, color: Colors.redAccent),
                            onPressed: () => _confirmDelete(context, account),
                          ),
                        if (isSelected)
                          Icon(LucideIcons.checkCircle2,
                              size: 20, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                onAddAccount();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.plus, size: 20, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 16),
                    Text(
                      'Agregar nueva cuenta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FinancialAccount account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Eliminar cuenta?'),
        content: Text(
            'Esto borrará la cuenta "${account.name}" y sus transacciones asociadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onDeleteAccount(account);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Brighten the colors for dark background visibility
    final displayColor = color == Colors.green ? const Color(0xFF4ADE80) : const Color(0xFFFB7185);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: displayColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 10, color: displayColor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: displayColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final FinancialTransaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final currencyFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
    final sign = isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(LucideIcons.trash2, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  title: const Text('¿Eliminar transacción?'),
                  content: Text(
                      'Esto borrará "${transaction.title}" permanentemente.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: transaction.category.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    transaction.category.icon,
                    color: transaction.category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.category.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sign${currencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM, HH:mm', 'es').format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTransactionSheet extends StatefulWidget {
  final WidgetRef ref;
  final FinancialTransaction? transaction;
  final TransactionType? initialType;

  const _AddTransactionSheet({
    required this.ref,
    this.transaction,
    this.initialType,
  });

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TransactionType _type;
  late TransactionCategory _selectedCategory;
  late DateTime _selectedDate;
  late String _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController =
        TextEditingController(text: t != null ? t.amount.toString() : '');
    _type = t?.type ?? widget.initialType ?? TransactionType.expense;
    _selectedCategory = t?.category ?? TransactionCategory.food;
    _selectedDate = t?.date ?? DateTime.now();
    _selectedAccountId =
        t?.accountId ?? widget.ref.read(selectedAccountIdProvider);
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    HapticFeedback.lightImpact();

    if (widget.transaction != null) {
      final updated = widget.transaction!.copyWith(
        title: title,
        amount: amount,
        type: _type,
        category: _selectedCategory,
        date: _selectedDate,
        accountId: _selectedAccountId,
      );
      widget.ref.read(financesProvider.notifier).updateTransaction(updated);
    } else {
      final newTx = FinancialTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        type: _type,
        date: _selectedDate,
        category: _selectedCategory,
        accountId: _selectedAccountId,
      );
      widget.ref.read(financesProvider.notifier).addTransaction(newTx);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.transaction != null
                    ? 'Editar Transacción'
                    : 'Nueva Transacción',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _label('Tipo de movimiento'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      title: 'Ingreso',
                      icon: LucideIcons.arrowDownLeft,
                      color: Colors.green,
                      isSelected: _type == TransactionType.income,
                      onTap: () =>
                          setState(() => _type = TransactionType.income),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      title: 'Gasto',
                      icon: LucideIcons.arrowUpRight,
                      color: Colors.red,
                      isSelected: _type == TransactionType.expense,
                      onTap: () =>
                          setState(() => _type = TransactionType.expense),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _label('Cuenta / Destino'),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, child) {
                  final accounts = ref.watch(accountsProvider);
                  return SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        final isSelected = _selectedAccountId == account.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedAccountId = account.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  account.icon,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  account.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _label('¿En qué se gastó?'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                autofocus: widget.transaction == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecor('ej. Suscripción Netflix'),
              ),
              const SizedBox(height: 16),
              _label('Monto'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                decoration: _inputDecor('0.00', prefix: '\$ '),
              ),
              const SizedBox(height: 16),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.calendar,
                                    size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    DateFormat('d MMM yyyy', 'es')
                                        .format(_selectedDate),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.clock,
                                    size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('HH:mm', 'es')
                                      .format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
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
              const SizedBox(height: 24),
              _label('Categoría'),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: TransactionCategory.values.length,
                  itemBuilder: (context, index) {
                    final cat = TransactionCategory.values[index];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withOpacity(0.1)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? cat.color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat.icon,
                                color: isSelected
                                    ? cat.color
                                    : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? cat.color
                                    : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.transaction != null
                        ? 'Guardar Cambios'
                        : 'Registrar Transacción',
                    style: TextStyle(
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
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          letterSpacing: 0.3,
        ),
      );

  InputDecoration _inputDecor(String hint, {String? prefix}) => InputDecoration(
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}


class _TypeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? color : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAccountSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddAccountSheet({required this.ref});

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  late TextEditingController _nameController;
  AccountType _selectedType = AccountType.general;
  IconData _selectedIcon = LucideIcons.wallet;
  late Color _selectedColor;

  final List<IconData> _availableIcons = [
    LucideIcons.wallet,
    LucideIcons.landmark,
    LucideIcons.creditCard,
    LucideIcons.banknote,
    LucideIcons.coins,
    LucideIcons.piggyBank,
    LucideIcons.shoppingBag,
    LucideIcons.briefcase,
    LucideIcons.home,
  ];

  List<Color> get _availableColors => [
    Theme.of(context).colorScheme.primary,
    const Color(0xFF10B981), // Emerald
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink
    const Color(0xFF14B8A6), // Teal
    const Color(0xFF64748B), // Slate
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // we'll initialize _selectedColor in didChangeDependencies or build
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedColor = Theme.of(context).colorScheme.primary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    HapticFeedback.lightImpact();

    final newAccount = FinancialAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    widget.ref.read(manualAccountsProvider.notifier).addAccount(newAccount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nueva Cuenta',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            'Nombre de la cuenta',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Ej. Banco, Efectivo...',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Icono y Color',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableColors.length,
              itemBuilder: (context, index) {
                final color = _availableColors[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(LucideIcons.check,
                            size: 20, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _saveAccount,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Crear Cuenta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

