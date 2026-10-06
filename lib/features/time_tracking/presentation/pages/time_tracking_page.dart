import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:one_percent_man/core/constants/app_colors.dart';
import 'package:one_percent_man/core/providers/life_mode_provider.dart';
import 'package:one_percent_man/features/time_tracking/domain/models/time_log.dart';
import 'package:one_percent_man/features/time_tracking/presentation/providers/time_tracking_provider.dart';

class TimeTrackingPage extends ConsumerWidget {
  const TimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timeTrackingProvider);
    final lifeMode = ref.watch(lifeModeProvider);

    // Filter activities depending on active life mode in profile
    final activities = AuditActivity.values.where((act) {
      if (lifeMode == AppLifeMode.guerra) {
        return !act.isMonkOnly;
      }
      return true; // Modo Monje has all Modo Guerra plus monk items
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Auditoría de Vida',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(timeTrackingProvider.notifier).toggleMode(),
            icon: Icon(
              state.isPomodoroMode ? LucideIcons.timer : LucideIcons.timerReset,
              color: state.isPomodoroMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            ),
            tooltip: state.isPomodoroMode ? 'Modo Pomodoro activo' : 'Modo Libre activo',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Libre vs Pomodoro Toggle
          _buildModeToggle(context, ref, state),

          // Main Timer / Active Session Card
          _buildMainTimer(context, ref, state),

          // Header for Activities
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.layoutGrid,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Actividades',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: lifeMode.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lifeMode.color.withOpacity(0.25)),
                  ),
                  child: Text(
                    '${activities.length} hábitos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: lifeMode.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activities Grid with Icons and Compact Labels
          _buildActivitiesGrid(context, ref, state, activities),

          // Historial de hoy
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.history, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Historial de hoy',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (state.history.isNotEmpty)
                  Text(
                    '${state.history.length} registros',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
              ],
            ),
          ),
          _buildHistoryList(context, state),
        ],
      ),
    );
  }


  Widget _buildModeToggle(BuildContext context, WidgetRef ref, TimeTrackingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
              icon: LucideIcons.timer,
              isSelected: !state.isPomodoroMode,
              onTap: () {
                if (state.isPomodoroMode) ref.read(timeTrackingProvider.notifier).toggleMode();
              },
            ),
            _ModeButton(
              label: 'Pomodoro (25m)',
              icon: LucideIcons.hourglass,
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
    if (state.activeActivity == null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isPomodoroMode ? LucideIcons.hourglass : LucideIcons.timer,
                size: 32,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.isPomodoroMode ? 'Modo Pomodoro Listo' : 'Cronómetro Libre Listo',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca Entrenar, Trabajar/Estudiar o Desarrollo para iniciar un tramo acumulable, o marca tus hábitos diarios.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final activity = state.activeActivity!;
    final totalSoFar = state.getTotalDuration(activity);
    final displayTime = state.isPomodoroMode ? state.remainingPomodoroTime : state.currentSegmentDuration;
    final totalPomodoroSeconds = _getPomodoroSeconds(state.pomodoroSession);
    final percent = state.isPomodoroMode
        ? (state.remainingPomodoroTime.inSeconds / totalPomodoroSeconds).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: activity.color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: activity.color.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 85,
            lineWidth: 10,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: activity.color,
            backgroundColor: activity.color.withOpacity(0.12),
            animation: false,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: activity.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: activity.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        state.isPomodoroMode
                            ? (state.pomodoroSession == PomodoroSession.work ? 'ENFOQUE' : 'DESCANSO')
                            : 'TRAMO ACTIVO',
                        style: TextStyle(
                          color: activity.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(displayTime),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(activity.icon, size: 14, color: activity.color),
                    const SizedBox(width: 4),
                    Text(
                      activity.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activity.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Accumulated time indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.layers, size: 13, color: activity.color),
                const SizedBox(width: 6),
                Text(
                  'Total acumulado hoy: ${_formatDuration(totalSoFar)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Turn off / stop button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(timeTrackingProvider.notifier).stopTracking(),
              icon: const Icon(LucideIcons.square, size: 16),
              label: const Text(
                'APAGAR Y FINALIZAR TRAMO',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: activity.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getPomodoroSeconds(PomodoroSession session) {
    switch (session) {
      case PomodoroSession.work:
        return 25 * 60;
      case PomodoroSession.shortBreak:
        return 5 * 60;
      case PomodoroSession.longBreak:
        return 15 * 60;
    }
  }

  Widget _buildActivitiesGrid(
    BuildContext context,
    WidgetRef ref,
    TimeTrackingState state,
    List<AuditActivity> activities,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 550 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth > 550 ? 1.08 : 0.98,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              final isRunning = state.activeActivity == activity;
              final isChecked = state.isSingleCheckDone(activity);
              final totalDuration = state.getTotalDuration(activity);

              return _ActivityButton(
                activity: activity,
                isRunning: isRunning,
                isChecked: isChecked,
                totalDuration: totalDuration,
                onTap: () {
                  ref.read(timeTrackingProvider.notifier).toggleActivity(activity);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, TimeTrackingState state) {
    if (state.history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.calendarCheck,
                size: 32,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Aún no hay registros hoy',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: state.history.map((log) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: log.activity.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(log.activity.icon, color: log.activity.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.activity.label,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      log.isSingleCheck
                          ? 'Completado a las ${DateFormat('HH:mm').format(log.timestamp)}'
                          : '${DateFormat('HH:mm').format(log.timestamp)} - ${log.endTime != null ? DateFormat('HH:mm').format(log.endTime!) : 'En curso'}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: log.isSingleCheck
                      ? const Color(0xFF10B981).withOpacity(0.12)
                      : log.activity.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.isSingleCheck ? '✓ HECHO' : _formatDuration(log.duration),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: log.isSingleCheck ? const Color(0xFF10B981) : log.activity.color,
                  ),
                ),
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

class _ActivityButton extends StatelessWidget {
  final AuditActivity activity;
  final bool isRunning;
  final bool isChecked;
  final Duration totalDuration;
  final VoidCallback onTap;

  const _ActivityButton({
    required this.activity,
    required this.isRunning,
    required this.isChecked,
    required this.totalDuration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = isRunning || (activity.isSingleCheck && isChecked);
    final borderColor = isRunning
        ? activity.color
        : (isChecked
            ? const Color(0xFF10B981)
            : Theme.of(context).dividerColor.withOpacity(0.6));

    final bgColor = isRunning
        ? activity.color.withOpacity(0.16)
        : (isChecked
            ? const Color(0xFF10B981).withOpacity(0.12)
            : Theme.of(context).cardColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isRunning
              ? [
                  BoxShadow(
                    color: activity.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Top-right status indicator
            Positioned(
              top: 0,
              right: 0,
              child: activity.isTimer
                  ? (isRunning
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: activity.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.power, size: 8, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'APAGAR',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.play, size: 8, color: Colors.grey),
                              SizedBox(width: 2),
                              Text(
                                'TRAMO',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ))
                  : (isChecked
                      ? const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF10B981))
                      : Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                          ),
                        )),
            ),

            // Center Content: Prominent Large Icon & Small Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  // Large prominent icon container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isRunning
                          ? activity.color
                          : (isChecked
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : activity.color.withOpacity(0.14)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isRunning
                            ? Colors.white.withOpacity(0.4)
                            : (isChecked
                                ? const Color(0xFF10B981).withOpacity(0.4)
                                : activity.color.withOpacity(0.25)),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      activity.icon,
                      size: 34,
                      color: isRunning
                          ? Colors.white
                          : (isChecked ? const Color(0xFF10B981) : activity.color),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Small activity title
                  Text(
                    activity.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isRunning
                          ? activity.color
                          : (isChecked
                              ? const Color(0xFF10B981)
                              : Theme.of(context).textTheme.displayLarge?.color),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Subtext
                  if (activity.isTimer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 10,
                          color: isRunning ? activity.color : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatCompactDuration(totalDuration),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: isRunning
                                ? activity.color
                                : (totalDuration.inSeconds > 0
                                    ? Theme.of(context).textTheme.displayLarge?.color
                                    : Colors.grey),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      isChecked ? '✓ Hecho hoy' : '1 sola vez',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                        color: isChecked ? const Color(0xFF10B981) : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompactDuration(Duration d) {
    if (d.inSeconds == 0) return '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) return "${d.inHours}h $minutes m";
    return "$minutes:$seconds";
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
