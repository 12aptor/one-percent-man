import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/plans_notifier.dart';
import '../../domain/models/plan_model.dart';
import '../../../notes/presentation/providers/ideas_notifier.dart';

class PlanDetailPage extends ConsumerWidget {
  final String planId;
  const PlanDetailPage({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plansNotifierProvider);
    final plan = state.plans.firstWhere((p) => p.id == planId,
        orElse: () =>
            Plan(id: '', title: 'Not Found', createdAt: DateTime.now()));

    if (plan.id == '') {
      return const Scaffold(body: Center(child: Text('Plan no encontrado')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(plan.title,
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showEditPlanDialog(context, ref, plan),
            icon: const Icon(LucideIcons.pencil, size: 20),
          ),
          IconButton(
            onPressed: () {
              ref.read(plansNotifierProvider.notifier).deletePlan(plan.id);
              Navigator.pop(context);
            },
            icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildDescription(context, ref, plan),
          const SizedBox(height: 32),
          _buildEngineSection(context, ref, plan),
          const SizedBox(height: 32),
          _buildObjectivesSection(context, ref, plan),
          const SizedBox(height: 32),
          _buildMissionsSection(context, ref, plan),
          const SizedBox(height: 32),
          _buildLearningsSection(context, ref, plan),
          const SizedBox(height: 32),
          _buildIdeasSection(context, ref, plan),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'plan_detail_fab',
        onPressed: () => _showAddMenu(context, ref, plan),
        child: const Icon(LucideIcons.plus),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showAddMenu(BuildContext context, WidgetRef ref, Plan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.target, color: Colors.blue),
              title: const Text('Nuevo Objetivo'),
              onTap: () {
                Navigator.pop(context);
                _showAddObjectiveDialog(context, ref, plan);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.zap, color: Colors.amber),
              title: const Text('Nueva Misión'),
              onTap: () {
                Navigator.pop(context);
                _showAddMissionDialog(context, ref, plan);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.bookOpen, color: Colors.green),
              title: const Text('Nuevo Aprendizaje'),
              onTap: () {
                Navigator.pop(context);
                _showAddLearningDialog(context, ref, plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, IconData icon, Color color, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3)),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildDescription(BuildContext context, WidgetRef ref, Plan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Descripción', LucideIcons.fileText, Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            plan.description.isEmpty
                ? 'Añade una descripción sobre esta meta.'
                : plan.description,
            style: TextStyle(
                color: plan.description.isEmpty
                    ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                    : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildEngineSection(BuildContext context, WidgetRef ref, Plan plan) {
    return GestureDetector(
      onTap: () => _showEditEngineDialog(context, ref, plan),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // ── PAIN ROW ────────────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra lateral roja
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(LucideIcons.alertTriangle,
                                    size: 13, color: Color(0xFFEF4444)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SI NO ACTÚAS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFEF4444),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            plan.hell.isEmpty
                                ? 'Describe qué ocurrirá si no tomas acción...'
                                : plan.hell,
                            style: TextStyle(
                              fontSize: 14,
                              color: plan.hell.isEmpty
                                  ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                                  : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                              height: 1.55,
                              fontWeight: plan.hell.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── DIVIDER ─────────────────────────────────────────────────
            Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),

            // ── HEAVEN ROW ──────────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra lateral verde
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF22C55E),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(LucideIcons.star,
                                    size: 13, color: Color(0xFF22C55E)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CUANDO LO LOGRES',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF22C55E),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              Icon(LucideIcons.pencil,
                                  size: 13,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.withOpacity(0.4)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            plan.heaven.isEmpty
                                ? 'Describe tu vida cuando hayas logrado esto...'
                                : plan.heaven,
                            style: TextStyle(
                              fontSize: 14,
                              color: plan.heaven.isEmpty
                                  ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                                  : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                              height: 1.55,
                              fontWeight: plan.heaven.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildObjectivesSection(BuildContext context, WidgetRef ref, Plan plan) {
    final completed = plan.objectives.where((o) => o.isCompleted).length;
    final total = plan.objectives.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Objetivos',
          LucideIcons.target,
          Colors.blue,
          trailing: total > 0
              ? Text('$completed/$total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue))
              : IconButton(
                  onPressed: () => _showAddObjectiveDialog(context, ref, plan),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        ),
        if (total > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAddObjectiveDialog(context, ref, plan),
                child: Icon(LucideIcons.plus, size: 18, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        if (plan.objectives.isEmpty)
          _buildEmptyHint(context, 'Sin objetivos aún. Pulsa + para añadir.')
        else
          ...plan.objectives.map((obj) => _ObjectiveItem(
                objective: obj,
                onToggle: () {
                  final newObjectives = plan.objectives.map((o) => o.id == obj.id ? o.copyWith(isCompleted: !o.isCompleted) : o).toList();
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(objectives: newObjectives));
                },
                onDelete: () {
                  final newObjectives = plan.objectives.where((o) => o.id != obj.id).toList();
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(objectives: newObjectives));
                },
                onEdit: () => _showAddObjectiveDialog(context, ref, plan, existing: obj),
              )),
      ],
    );
  }

  Widget _buildEmptyHint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 13)),
    );
  }

  Widget _buildMissionsSection(BuildContext context, WidgetRef ref, Plan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Misiones',
          LucideIcons.zap,
          Colors.amber.shade700,
          trailing: IconButton(
            onPressed: () => _showAddMissionDialog(context, ref, plan),
            icon: const Icon(LucideIcons.plus, size: 18),
            color: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: 10),
        if (plan.missions.isEmpty)
          _buildEmptyHint(context, 'Sin misiones aún. Pulsa + para añadir.')
        else
          ...plan.missions.map((mission) => _MissionItem(
                mission: mission,
                onDelete: () {
                  final newMissions = plan.missions.where((m) => m.id != mission.id).toList();
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(missions: newMissions));
                },
                onEdit: () => _showAddMissionDialog(context, ref, plan, existing: mission),
                onToggleDate: (date) {
                  final newTracking = Map<String, bool>.from(mission.tracking);
                  DateTime normalizedDate = date;
                  if (!mission.isDaily) {
                    normalizedDate = date.subtract(Duration(days: date.weekday - 1));
                  }
                  final dateStr = DateFormat('yyyy-MM-dd').format(normalizedDate);
                  newTracking[dateStr] = !(newTracking[dateStr] ?? false);
                  final newMissions = plan.missions.map((m) => m.id == mission.id ? m.copyWith(tracking: newTracking) : m).toList();
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(missions: newMissions));
                },
              )),
      ],
    );
  }

  Widget _buildLearningsSection(BuildContext context, WidgetRef ref, Plan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Aprendizajes',
          LucideIcons.bookOpen,
          Colors.green,
          trailing: IconButton(
            onPressed: () => _showAddLearningDialog(context, ref, plan),
            icon: const Icon(LucideIcons.plus, size: 18),
            color: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: 10),
        if (plan.learnings.isEmpty)
          _buildEmptyHint(context, 'Sin aprendizajes aún. Pulsa + para añadir.')
        else
          ...plan.learnings.map((learning) => _LearningItem(
                learning: learning,
                onDelete: () {
                  final newLearnings = plan.learnings.where((l) => l.id != learning.id).toList();
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(learnings: newLearnings));
                },
                onEdit: () => _showAddLearningDialog(context, ref, plan, existing: learning),
              )),
      ],
    );
  }

  void _showAddObjectiveDialog(BuildContext context, WidgetRef ref, Plan plan, {PlanObjective? existing}) {
    final ctrl = TextEditingController(text: existing?.title);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(existing == null ? 'Nuevo Objetivo' : 'Editar Objetivo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ej: Conseguir un local',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) return;
                  final newObj = existing?.copyWith(title: ctrl.text.trim()) ?? 
                    PlanObjective(id: DateTime.now().millisecondsSinceEpoch.toString(), title: ctrl.text.trim());
                  
                  List<PlanObjective> newObjectives;
                  if (existing == null) {
                    newObjectives = [...plan.objectives, newObj];
                  } else {
                    newObjectives = plan.objectives.map((o) => o.id == existing.id ? newObj : o).toList();
                  }
                  
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(objectives: newObjectives));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Guardar Objetivo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMissionDialog(BuildContext context, WidgetRef ref, Plan plan, {MissionAction? existing}) {
    final titleCtrl = TextEditingController(text: existing?.content);
    final descCtrl = TextEditingController(text: existing?.description);
    bool isDaily = existing?.isDaily ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(existing == null ? 'Nueva Misión' : 'Editar Misión', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Misión',
                  hintText: 'Ej: Educarme 2h',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Frecuencia:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Diaria'),
                    selected: isDaily,
                    onSelected: (val) => setState(() => isDaily = true),
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(color: isDaily ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Semanal'),
                    selected: !isDaily,
                    onSelected: (val) => setState(() => isDaily = false),
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(color: !isDaily ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final newMission = existing?.copyWith(
                      content: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      isDaily: isDaily,
                    ) ?? MissionAction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      content: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      isDaily: isDaily,
                    );

                    List<MissionAction> newMissions;
                    if (existing == null) {
                      newMissions = [...plan.missions, newMission];
                    } else {
                      newMissions = plan.missions.map((m) => m.id == existing.id ? newMission : m).toList();
                    }

                    ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(missions: newMissions));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Guardar Misión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLearningDialog(BuildContext context, WidgetRef ref, Plan plan, {PlanLearning? existing}) {
    final ctrl = TextEditingController(text: existing?.text);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(existing == null ? 'Nuevo Aprendizaje' : 'Editar Aprendizaje',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ej: Es mejor delegar...',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) return;
                  final newLearn = existing?.copyWith(text: ctrl.text.trim()) ?? 
                    PlanLearning(id: DateTime.now().millisecondsSinceEpoch.toString(), text: ctrl.text.trim(), createdAt: DateTime.now());
                  
                  List<PlanLearning> newLearnings;
                  if (existing == null) {
                    newLearnings = [...plan.learnings, newLearn];
                  } else {
                    newLearnings = plan.learnings.map((l) => l.id == existing.id ? newLearn : l).toList();
                  }
                  
                  ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(learnings: newLearnings));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Guardar Aprendizaje', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMission(WidgetRef ref, Plan plan, String missionId) {
    final newMissions = plan.missions.where((m) => m.id != missionId).toList();
    ref.read(plansNotifierProvider.notifier).updatePlan(plan.copyWith(missions: newMissions));
    HapticFeedback.mediumImpact();
  }

  void _showEditEngineDialog(BuildContext context, WidgetRef ref, Plan plan) {
    final antiCtrl = TextEditingController(text: plan.hell);
    final visCtrl = TextEditingController(text: plan.heaven);

    InputDecoration inputDecor(String hint) => InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Editar Motor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text('¿Qué pasaría si no actúas?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                  controller: antiCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: inputDecor('Ej: Pierdo mi departamento')),
              const SizedBox(height: 24),
              Text('Cual es tu destino ideal?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                  controller: visCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: inputDecor('Ej: Me compro el coche de mis sueños')),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(plansNotifierProvider.notifier).updatePlan(
                      plan.copyWith(
                        hell: antiCtrl.text.trim(),
                        heaven: visCtrl.text.trim(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Guardar Motor',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdeasSection(BuildContext context, WidgetRef ref, Plan plan) {
    final ideasState = ref.watch(ideasNotifierProvider);
    final attachedIdeas = ideasState.ideas
        .where((idea) => plan.attachedIdeaIds.contains(idea.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Ideas Vinculadas',
          LucideIcons.lightbulb,
          Colors.amber.shade700,
          trailing: TextButton.icon(
            onPressed: () => _showLinkIdeaDialog(context, ref, plan),
            icon: const Icon(LucideIcons.link, size: 13),
            label: const Text('Vincular', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary, padding: EdgeInsets.zero),
          ),
        ),
        const SizedBox(height: 10),
        if (attachedIdeas.isEmpty)
          _buildEmptyHint(context, 'Vincula ideas de tu "Lluvia de Ideas" para inspirarte.')
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachedIdeas.length,
              itemBuilder: (context, index) {
                final idea = attachedIdeas[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Text(
                    idea.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showEditPlanDialog(BuildContext context, WidgetRef ref, Plan plan) {
    final titleController = TextEditingController(text: plan.title);
    final descController = TextEditingController(text: plan.description);

    InputDecoration inputDecor(String hint) => InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        );

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            ),
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Editar Plan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            label('Título del Plan'),
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: inputDecor('Ej: Lanzamiento de producto'),
            ),
            const SizedBox(height: 16),
            label('Descripción'),
            TextField(
              controller: descController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: inputDecor('Describe los objetivos de este plan...'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    HapticFeedback.lightImpact();
                    ref.read(plansNotifierProvider.notifier).updatePlan(
                          plan.copyWith(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Guardar Cambios',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkIdeaDialog(BuildContext context, WidgetRef ref, Plan plan) {
    final ideasState = ref.read(ideasNotifierProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Vincular Idea',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ideasState.ideas.length,
                itemBuilder: (context, index) {
                  final idea = ideasState.ideas[index];
                  final isLinked = plan.attachedIdeaIds.contains(idea.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(idea.content,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Icon(
                        isLinked
                            ? LucideIcons.checkCircle2
                            : LucideIcons.circle,
                        color: isLinked
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final newIds = List<String>.from(plan.attachedIdeaIds);
                      if (isLinked) {
                        newIds.remove(idea.id);
                      } else {
                        newIds.add(idea.id);
                      }
                      ref.read(plansNotifierProvider.notifier).updatePlan(
                            plan.copyWith(attachedIdeaIds: newIds),
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveItem extends StatelessWidget {
  final PlanObjective objective;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ObjectiveItem({
    required this.objective,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Checkbox(
            value: objective.isCompleted,
            onChanged: (val) => onToggle(),
            activeColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              objective.title,
              style: TextStyle(
                fontSize: 14,
                decoration: objective.isCompleted ? TextDecoration.lineThrough : null,
                color: objective.isCompleted ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
              ),
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(LucideIcons.pencil, size: 14)),
          IconButton(onPressed: onDelete, icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent)),
        ],
      ),
    );
  }
}

class _MissionItem extends StatelessWidget {
  final MissionAction mission;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(DateTime) onToggleDate;

  const _MissionItem({
    required this.mission,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Normalize date to start of week if weekly
    DateTime normalize(DateTime d) {
      if (mission.isDaily) return d;
      return d.subtract(Duration(days: d.weekday - 1));
    }

    final List<DateTime> displayDates;
    if (mission.isDaily) {
      displayDates = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));
    } else {
      // Show last 12 weeks for weekly missions
      displayDates = List.generate(12, (i) {
        final d = now.subtract(Duration(days: (11 - i) * 7));
        return d.subtract(Duration(days: d.weekday - 1)); // Start of week
      });
    }

    // Calculate stats based on the displayed period
    final relevantKeys = displayDates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toSet();
    final completedCount = mission.tracking.entries
        .where((e) => relevantKeys.contains(e.key) && e.value)
        .length;
    final totalUnits = displayDates.length;
    final percentage = totalUnits == 0 ? 0 : (completedCount / totalUnits * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.content, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (mission.description.isNotEmpty)
                      Text(mission.description, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (mission.isDaily ? Colors.blue : Colors.purple).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mission.isDaily ? 'DIARIA' : 'SEMANAL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: mission.isDaily ? Colors.blue : Colors.purple),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: onEdit, icon: const Icon(LucideIcons.pencil, size: 16)),
              IconButton(onPressed: onDelete, icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.isDaily ? 'Últimos 30 días' : 'Últimas 12 semanas', 
                        style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: displayDates.map((date) {
                        final dateStr = DateFormat('yyyy-MM-dd').format(date);
                        final isCompleted = mission.tracking[dateStr] ?? false;
                        
                        // For daily, check if it's today. For weekly, check if it's the current week.
                        bool isCurrent;
                        if (mission.isDaily) {
                          isCurrent = DateFormat('yyyy-MM-dd').format(now) == dateStr;
                        } else {
                          final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
                          isCurrent = DateFormat('yyyy-MM-dd').format(currentWeekStart) == dateStr;
                        }

                        return GestureDetector(
                          onTap: () => onToggleDate(date),
                          child: Container(
                            width: mission.isDaily ? 12 : 24, // Weekly boxes are a bit larger
                            height: 12,
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green : Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(2),
                              border: isCurrent ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.2) : Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                  Text('Cumplimiento', style: TextStyle(fontSize: 8, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearningItem extends StatelessWidget {
  final PlanLearning learning;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _LearningItem({
    required this.learning,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lightbulb, size: 16, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(learning.text, style: TextStyle(fontSize: 13))),
          IconButton(onPressed: onEdit, icon: const Icon(LucideIcons.pencil, size: 14)),
          IconButton(onPressed: onDelete, icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent)),
        ],
      ),
    );
  }
}


