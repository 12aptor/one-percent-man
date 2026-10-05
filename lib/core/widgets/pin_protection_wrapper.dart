import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/security_provider.dart';

class PinProtectionWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const PinProtectionWrapper({super.key, required this.child});

  @override
  ConsumerState<PinProtectionWrapper> createState() => _PinProtectionWrapperState();
}

class _PinProtectionWrapperState extends ConsumerState<PinProtectionWrapper> {
  String _enteredPin = '';
  bool _isError = false;

  void _handleKeyPress(String value) {
    if (_enteredPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += value;
        _isError = false;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _backspace() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() {
    final security = ref.read(securityProvider);
    if (_enteredPin == security.pin) {
      HapticFeedback.mediumImpact();
      ref.read(securityProvider.notifier).authenticate(_enteredPin);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
      // Show shake animation or something? Simple error state for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityProvider);

    if (!security.isPinEnabled || security.isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Header
            const Icon(LucideIcons.lock, size: 48, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Área Protegida',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isError ? 'PIN incorrecto. Intenta de nuevo.' : 'Ingresa tu PIN para continuar',
              style: TextStyle(
                color: _isError ? Colors.red : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isActive = index < _enteredPin.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).dividerColor,
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ] : null,
                  ),
                );
              }),
            ),
            
            const Spacer(flex: 2),
            
            // Number Pad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  _buildRow(['1', '2', '3']),
                  const SizedBox(height: 24),
                  _buildRow(['4', '5', '6']),
                  const SizedBox(height: 24),
                  _buildRow(['7', '8', '9']),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 64), // Placeholder for alignment
                      _buildNumberButton('0'),
                      _buildIconButton(LucideIcons.delete, _backspace),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // Exit button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _handleKeyPress(number),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Icon(icon, size: 28),
      ),
    );
  }
}
