import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AppLifeMode {
  guerra,
  monje;

  String get title {
    switch (this) {
      case AppLifeMode.guerra:
        return 'Modo Guerra';
      case AppLifeMode.monje:
        return 'Modo Monje';
    }
  }

  String get tag {
    switch (this) {
      case AppLifeMode.guerra:
        return 'OFENSIVA TOTAL';
      case AppLifeMode.monje:
        return 'AISLAMIENTO ZEN';
    }
  }

  String get description {
    switch (this) {
      case AppLifeMode.guerra:
        return 'Foco implacable, conquista agresiva de objetivos y superación de límites diarios.';
      case AppLifeMode.monje:
        return 'Cero distracciones, disciplina profunda, ayuno de dopamina y serenidad estoica.';
    }
  }

  IconData get icon {
    switch (this) {
      case AppLifeMode.guerra:
        return LucideIcons.swords;
      case AppLifeMode.monje:
        return LucideIcons.shield;
    }
  }

  Color get color {
    switch (this) {
      case AppLifeMode.guerra:
        return const Color(0xFFEF4444); // Crimson red
      case AppLifeMode.monje:
        return const Color(0xFF6366F1); // Deep Indigo
    }
  }
}

final lifeModeProvider = StateNotifierProvider<LifeModeNotifier, AppLifeMode>((ref) {
  return LifeModeNotifier();
});

class LifeModeNotifier extends StateNotifier<AppLifeMode> {
  static const _key = 'app_life_mode';

  LifeModeNotifier() : super(AppLifeMode.guerra) {
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_key);
    if (modeString != null) {
      state = AppLifeMode.values.firstWhere(
        (m) => m.name == modeString,
        orElse: () => AppLifeMode.guerra,
      );
    }
  }

  Future<void> setMode(AppLifeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
