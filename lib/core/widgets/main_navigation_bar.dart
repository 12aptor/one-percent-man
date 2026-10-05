import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../providers/security_provider.dart';

// Definimos el provider de navegación aquí para que sea accesible globalmente
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationBar extends ConsumerStatefulWidget {
  const MainNavigationBar({super.key});

  @override
  ConsumerState<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends ConsumerState<MainNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isMoreOpen = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleMore() {
    setState(() {
      _isMoreOpen = !_isMoreOpen;
      if (_isMoreOpen) {
        _rotationController.forward();
        _showMoreMenu();
      } else {
        _rotationController.reverse();
      }
    });
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return _MoreBottomSheet(
          onItemSelected: (index) {
            final current = ref.read(navigationIndexProvider);
            if (current == 2 || current == 3) {
              ref.read(securityProvider.notifier).lock();
            }
            ref.read(navigationIndexProvider.notifier).state = index;
            Navigator.of(context).pop();
            _closeMore();
          },
          onClose: _closeMore,
        );
      },
    ).then((_) {
      if (_isMoreOpen) {
        _closeMore();
      }
    });
  }

  void _closeMore() {
    if (mounted) {
      setState(() {
        _isMoreOpen = false;
        _rotationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 8,
        right: 8,
        bottom: bottomPadding + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _NavItem(
            icon: LucideIcons.calendar,
            label: "Horario",
            isActive: selectedIndex == 0 && !_isMoreOpen,
            onTap: () {
              final current = ref.read(navigationIndexProvider);
              if (current == 2 || current == 3) ref.read(securityProvider.notifier).lock();
              ref.read(navigationIndexProvider.notifier).state = 0;
            },
          ),
          _NavItem(
            icon: LucideIcons.clipboardList,
            label: "Tareas",
            isActive: selectedIndex == 1 && !_isMoreOpen,
            onTap: () {
              final current = ref.read(navigationIndexProvider);
              if (current == 2 || current == 3) ref.read(securityProvider.notifier).lock();
              ref.read(navigationIndexProvider.notifier).state = 1;
            },
          ),
          _NavItem(
            icon: LucideIcons.target,
            label: "Metas",
            isActive: selectedIndex == 2 && !_isMoreOpen,
            onTap: () {
              // No locking when entering Metas, only when leaving
              ref.read(navigationIndexProvider.notifier).state = 2;
            },
          ),
          _NavItem(
            icon: LucideIcons.wallet,
            label: "Finanzas",
            isActive: selectedIndex == 3 && !_isMoreOpen,
            onTap: () {
              // No locking when entering Finanzas, only when leaving
              ref.read(navigationIndexProvider.notifier).state = 3;
            },
          ),
          // Botón "+" minimalista
          GestureDetector(
            onTap: _toggleMore,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isMoreOpen
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).dividerColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * (math.pi / 2),
                        child: Icon(
                          _isMoreOpen ? LucideIcons.x : LucideIcons.moreHorizontal,
                          color: _isMoreOpen
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  "MÁS".toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: _isMoreOpen
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 20 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      blurRadius: 0,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),
            Icon(
              icon,
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreBottomSheet extends StatelessWidget {
  final Function(int) onItemSelected;
  final VoidCallback onClose;

  const _MoreBottomSheet({
    required this.onItemSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const premiumCurve = Cubic(0.32, 0.72, 0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 0,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 40,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 400),
        curve: premiumCurve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value * 40),
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32), // Reducido un poco de 40 a 32
              _MoreMenuItem(
                icon: LucideIcons.activity,
                title: "Auditoría de Vida",
                subtitle: "Análisis profundo de hábitos",
                color: const Color(0xFF10B981),
                onTap: () => onItemSelected(4),
              ),
              const SizedBox(height: 12), // Reducido un poco de 16 a 12
              _MoreMenuItem(
                icon: LucideIcons.user,
                title: "Perfil",
                subtitle: "Configuración y estadísticas",
                color: const Color(0xFFF59E0B),
                onTap: () => onItemSelected(5),
              ),
              const SizedBox(height: 12), // Reducido un poco de 16 a 12
              _MoreMenuItem(
                icon: LucideIcons.brainCircuit,
                title: "Lluvia de Ideas",
                subtitle: "Captura pensamientos rápidos",
                color: const Color(0xFF8B5CF6),
                onTap: () => onItemSelected(6),
              ),
              const SizedBox(height: 12),
              _MoreMenuItem(
                icon: LucideIcons.map,
                title: "Planificación",
                subtitle: "Traza el camino al éxito",
                color: const Color(0xFF3B82F6),
                onTap: () => onItemSelected(7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

