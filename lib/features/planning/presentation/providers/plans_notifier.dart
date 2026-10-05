import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/plan_model.dart';

const _kPlansKey = 'plans_v1';

class PlansState {
  final List<Plan> plans;
  final bool isLoaded;

  const PlansState({
    this.plans = const [],
    this.isLoaded = false,
  });

  PlansState copyWith({
    List<Plan>? plans,
    bool? isLoaded,
  }) {
    return PlansState(
      plans: plans ?? this.plans,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class PlansNotifier extends StateNotifier<PlansState> {
  SharedPreferences? _prefs;

  PlansNotifier() : super(const PlansState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final plansJson = _prefs!.getStringList(_kPlansKey) ?? [];
    
    final plans = plansJson.map((s) => Plan.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = PlansState(plans: plans, isLoaded: true);
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kPlansKey,
      state.plans.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  Future<void> addPlan(Plan plan) async {
    state = state.copyWith(plans: [plan, ...state.plans]);
    await _persist();
  }

  Future<void> updatePlan(Plan updated) async {
    state = state.copyWith(
      plans: [for (final p in state.plans) p.id == updated.id ? updated : p],
    );
    await _persist();
  }

  Future<void> deletePlan(String id) async {
    state = state.copyWith(
      plans: state.plans.where((p) => p.id != id).toList(),
    );
    await _persist();
  }
}

final plansNotifierProvider =
    StateNotifierProvider<PlansNotifier, PlansState>((ref) {
  return PlansNotifier();
});

