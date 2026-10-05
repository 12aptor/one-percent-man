import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/goal.dart';

const _kGoalsKey = 'goals_v1';

class GoalsNotifier extends StateNotifier<List<Goal>> {
  SharedPreferences? _prefs;

  GoalsNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonList = _prefs!.getStringList(_kGoalsKey) ?? [];
    
    if (jsonList.isEmpty) {
      // Default goals if empty
      state = [
        Goal(
          id: '1',
          title: 'Ahorro para Casa',
          unit: GoalUnit.money,
          target: 100000,
          current: 32500,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          deadline: DateTime.now().add(const Duration(days: 365)),
        ),
        Goal(
          id: '2',
          title: 'Leer este año',
          unit: GoalUnit.books,
          target: 12,
          current: 4,
          createdAt: DateTime(DateTime.now().year, 1, 1),
          deadline: DateTime(DateTime.now().year, 12, 31),
        ),
      ];
      await _persist();
    } else {
      state = jsonList.map((s) => Goal.fromJsonString(s)).toList();
    }
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kGoalsKey,
      state.map((g) => g.toJsonString()).toList(),
    );
  }

  Future<void> addGoal(Goal goal) async {
    state = [goal, ...state];
    await _persist();
  }

  Future<void> updateGoal(Goal updated) async {
    state = [
      for (final g in state) if (g.id == updated.id) updated else g,
    ];
    await _persist();
  }

  Future<void> deleteGoal(String id) async {
    state = state.where((g) => g.id != id).toList();
    await _persist();
  }

  /// Adds [amount] to the current progress of a goal.
  Future<void> addProgress(String id, double amount) async {
    state = [
      for (final g in state)
        if (g.id == id)
          g.copyWith(current: (g.current + amount).clamp(0, g.target * 2))
        else
          g,
    ];
    await _persist();
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier();
});

