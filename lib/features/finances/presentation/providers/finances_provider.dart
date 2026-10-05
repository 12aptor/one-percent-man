import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/transaction.dart';
import '../../../../features/goals/presentation/providers/goals_provider.dart';
import '../../../../features/goals/domain/models/goal.dart';

const _kFinancesKey = 'finances_v1';
const _kAccountsKey = 'manual_accounts_v1';

// Provider for the currently active account ID
final selectedAccountIdProvider = StateProvider<String>((ref) => 'main');

class ManualAccountsNotifier extends StateNotifier<List<FinancialAccount>> {
  SharedPreferences? _prefs;

  ManualAccountsNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonList = _prefs!.getStringList(_kAccountsKey) ?? [];
    if (jsonList.isNotEmpty) {
      state = jsonList.map((s) => FinancialAccount.fromJson(jsonDecode(s))).toList();
    }
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kAccountsKey,
      state.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<void> addAccount(FinancialAccount account) async {
    state = [...state, account];
    await _persist();
  }

  Future<void> deleteAccount(String id) async {
    state = state.where((a) => a.id != id).toList();
    await _persist();
  }
}

final manualAccountsProvider =
    StateNotifierProvider<ManualAccountsNotifier, List<FinancialAccount>>((ref) {
  return ManualAccountsNotifier();
});

// Reactive provider that generates accounts based on Financial Goals and manual accounts
final accountsProvider = Provider<List<FinancialAccount>>((ref) {
  final goals = ref.watch(goalsProvider);
  final manualAccounts = ref.watch(manualAccountsProvider);

  final mainAccount = FinancialAccount(
    id: 'main',
    name: 'Billetera Principal',
    type: AccountType.general,
    icon: LucideIcons.wallet,
    color: AppColors.accent,
  );

  final savingsAccounts = goals
      .where((g) => g.unit == GoalUnit.money)
      .map((g) {
    return FinancialAccount(
      id: g.id,
      name: g.title,
      type: AccountType.savings,
      icon: LucideIcons.piggyBank,
      color: g.unit.color,
      goalId: g.id,
    );
  }).toList();

  return [mainAccount, ...manualAccounts, ...savingsAccounts];
});


class FinancesNotifier extends StateNotifier<List<FinancialTransaction>> {
  SharedPreferences? _prefs;

  FinancesNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonList = _prefs!.getStringList(_kFinancesKey) ?? [];

    if (jsonList.isEmpty) {
      // Default transactions
      state = [
        FinancialTransaction(
          id: '1',
          title: 'Salario',
          amount: 3500.0,
          type: TransactionType.income,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: TransactionCategory.salary,
          accountId: 'main',
        ),
        FinancialTransaction(
          id: '2',
          title: 'Supermercado',
          amount: 250.0,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: TransactionCategory.food,
          accountId: 'main',
        ),
      ];
      await _persist();
    } else {
      state = jsonList.map((s) => FinancialTransaction.fromJsonString(s)).toList();
    }
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kFinancesKey,
      state.map((t) => t.toJsonString()).toList(),
    );
  }

  Future<void> addTransaction(FinancialTransaction transaction) async {
    state = [...state, transaction];
    await _persist();
  }

  Future<void> updateTransaction(FinancialTransaction updated) async {
    state = [
      for (final t in state) if (t.id == updated.id) updated else t,
    ];
    await _persist();
  }

  Future<void> deleteTransaction(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _persist();
  }

  Future<void> deleteTransactionsByAccountId(String accountId) async {
    state = state.where((t) => t.accountId != accountId).toList();
    await _persist();
  }
}

final financesProvider =
    StateNotifierProvider<FinancesNotifier, List<FinancialTransaction>>((ref) {
  return FinancesNotifier();
});

// Helper provider to get only transactions of the selected account
final filteredTransactionsProvider = Provider<List<FinancialTransaction>>((ref) {
  final transactions = ref.watch(financesProvider);
  final selectedId = ref.watch(selectedAccountIdProvider);
  return transactions.where((t) => t.accountId == selectedId).toList();
});

final balanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.fold(0.0, (sum, t) {
    if (t.type == TransactionType.income) {
      return sum + t.amount;
    } else {
      return sum - t.amount;
    }
  });
});

final incomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.fold(0.0, (sum, t) {
    if (t.type == TransactionType.income) {
      return sum + t.amount;
    }
    return sum;
  });
});

final expenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.fold(0.0, (sum, t) {
    if (t.type == TransactionType.expense) {
      return sum + t.amount;
    }
    return sum;
  });
});


