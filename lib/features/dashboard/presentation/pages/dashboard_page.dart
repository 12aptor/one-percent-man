import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/security_provider.dart';
import '../../../../core/widgets/main_navigation_bar.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../notes/presentation/pages/notes_page.dart' show TasksPage;
import '../../../finances/presentation/pages/finances_page.dart';
import '../../../time_tracking/presentation/pages/time_tracking_page.dart';
import '../../../goals/presentation/pages/goals_page.dart';
import '../../../streaks/presentation/pages/streaks_page.dart' show ProfilePage;
import '../../../notes/presentation/pages/brainstorming_page.dart';
import '../../../planning/presentation/pages/planning_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Lock security when app goes to background
      ref.read(securityProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    final List<Widget> pages = [
      const SchedulePage(), // Index 0: Horario
      const TasksPage(), // Index 1: Tareas
      const GoalsPage(), // Index 2: Metas
      const FinancesPage(), // Index 3: Finanzas
      const TimeTrackingPage(), // Index 4: Auditoría de Vida (en el menú "Más")
      const ProfilePage(), // Index 5: Perfil (en el menú "Más")
      const BrainstormingPage(), // Index 6: Lluvia de Ideas (en el menú "Más")
      const PlanningPage(), // Index 7: Planificación (en el menú "Más")
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}

