import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:one_percent_man/features/time_tracking/presentation/providers/time_tracking_provider.dart';
import 'package:one_percent_man/features/time_tracking/domain/models/time_log.dart';

class TimeTrackingPage extends ConsumerWidget {
  const TimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timeTrackingProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Auditoría de Vida',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(timeTrackingProvider.notifier).toggleMode(),
            icon: Icon(
              state.isPomodoroMode ? LucideIcons.timer : LucideIcons.timerReset,
              color: state.isPomodoroMode ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            ),
            tooltip: 'Cambiar Modo',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildModeToggle(context, ref, state),
          _buildMainTimer(context, ref, state),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Row(
              children: [
                Text(
                  'Categorías de Auditoría',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildCategoryGrid(context, ref, state),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: Row(
              children: [
                Text(
                  'Historial de hoy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildHistoryList(context, state),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context, WidgetRef ref, TimeTrackingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _ModeButton(
              label: 'Libre',
              isSelected: !state.isPomodoroMode,
              onTap: () {
                if (state.isPomodoroMode) ref.read(timeTrackingProvider.notifier).toggleMode();
              },
            ),
            _ModeButton(
              label: 'Pomodoro',
              isSelected: state.isPomodoroMode,
              onTap: () {
                if (!state.isPomodoroMode) ref.read(timeTrackingProvider.notifier).toggleMode();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTimer(BuildContext context, WidgetRef ref, TimeTrackingState state) {
    if (state.activeLog == null) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Icon(
              state.isPomodoroMode ? LucideIcons.hourglass : LucideIcons.timer, 
              size: 48, 
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
            ),
            const SizedBox(height: 16),
            Text(
              state.isPomodoroMode ? 'Modo Pomodoro Listo' : 'Seguimiento Libre',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.isPomodoroMode 
                ? '25 min de enfoque profundo para maximizar tu disciplina.'
                : 'Inicia el tiempo para auditar en qué inviertes tu vida.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 13),
            ),
            if (state.isPomodoroMode && state.completedRounds > 0) ...[
              const SizedBox(height: 16),
              _buildRoundsIndicator(context, state.completedRounds),
            ],
          ],
        ),
      );
    }

    final category = state.activeLog!.category;
    final displayTime = state.isPomodoroMode ? state.remainingTime : state.activeDuration;
    final totalPomodoroSeconds = _getPomodoroSeconds(state.pomodoroSession);
    final percent = state.isPomodoroMode 
        ? (state.remainingTime.inSeconds / totalPomodoroSeconds).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: category.color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 12,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: category.color,
            backgroundColor: category.color.withOpacity(0.1),
            animation: true,
            animateFromLastPercent: true,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isPomodoroMode)
                  Text(
                    state.pomodoroSession == PomodoroSession.work ? 'ENFOQUE' : 'DESCANSO',
                    style: TextStyle(
                      color: category.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(displayTime),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Icon(category.icon, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    category.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (state.isPomodoroMode)
                     _buildRoundsIndicator(context, state.completedRounds),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(timeTrackingProvider.notifier).stopTracking(),
            style: ElevatedButton.styleFrom(
              backgroundColor: category.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              elevation: 0,
            ),
            child: const Text('DETENER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundsIndicator(BuildContext context, int rounds) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isCompleted = index < (rounds % 4);
        final isCurrent = index == (rounds % 4);
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isCompleted 
                ? Theme.of(context).colorScheme.primary 
                : (isCurrent ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Theme.of(context).dividerColor),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  int _getPomodoroSeconds(PomodoroSession session) {
    switch (session) {
      case PomodoroSession.work: return 25 * 60;
      case PomodoroSession.shortBreak: return 5 * 60;
      case PomodoroSession.longBreak: return 15 * 60;
    }
  }

  Widget _buildCategoryGrid(BuildContext context, WidgetRef ref, TimeTrackingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        physics: const NeverScrollableScrollPhysics(),
        children: TimeCategory.values.map((cat) {
          final isSelected = state.activeLog?.category == cat;
          return InkWell(
            onTap: () => ref.read(timeTrackingProvider.notifier).startTracking(cat),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? cat.color.withOpacity(0.1) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? cat.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(cat.icon, color: isSelected ? cat.color : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? cat.color : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, TimeTrackingState state) {
    if (state.history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Aún no hay registros hoy',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: state.history.map((log) {
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: log.category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(log.category.icon, color: log.category.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.category.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${DateFormat('HH:mm').format(log.startTime)} - ${DateFormat('HH:mm').format(log.endTime!)}',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDuration(log.duration),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) return "${d.inHours}:$minutes:$seconds";
    return "$minutes:$seconds";
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

