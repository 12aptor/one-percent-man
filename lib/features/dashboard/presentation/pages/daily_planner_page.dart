import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../notes/presentation/pages/notes_page.dart' show TasksPage;

class DailyPlannerPage extends StatelessWidget {
  const DailyPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.calendar, size: 18),
                    SizedBox(width: 8),
                    Text('Horario', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.clipboardList, size: 18),
                    SizedBox(width: 8),
                    Text('Tareas', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SchedulePage(),
            TasksPage(),
          ],
        ),
      ),
    );
  }
}

