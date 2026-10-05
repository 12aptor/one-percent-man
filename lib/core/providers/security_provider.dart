import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityState {
  final bool isPinEnabled;
  final String? pin;
  final bool isAuthenticated;

  SecurityState({
    this.isPinEnabled = false,
    this.pin,
    this.isAuthenticated = false,
  });

  SecurityState copyWith({
    bool? isPinEnabled,
    String? pin,
    bool? isAuthenticated,
  }) {
    return SecurityState(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pin: pin ?? this.pin,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier() : super(SecurityState()) {
    _loadSettings();
  }

  static const _pinEnabledKey = 'pin_enabled';
  static const _pinKey = 'user_pin';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_pinEnabledKey) ?? false;
    final savedPin = prefs.getString(_pinKey);
    state = state.copyWith(isPinEnabled: isEnabled, pin: savedPin);
  }

  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    await prefs.setBool(_pinEnabledKey, true);
    state = state.copyWith(isPinEnabled: true, pin: newPin, isAuthenticated: true);
  }

  Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, false);
    state = state.copyWith(isPinEnabled: false, isAuthenticated: false);
  }

  void authenticate(String enteredPin) {
    if (enteredPin == state.pin) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  void lock() {
    state = state.copyWith(isAuthenticated: false);
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});
