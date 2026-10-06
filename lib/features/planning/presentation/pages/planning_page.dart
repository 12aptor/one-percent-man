import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/plans_notifier.dart';
import '../../domain/models/plan_model.dart';
import '../../domain/models/plan_templates.dart';
import 'plan_detail_page.dart';

class PlanningPage extends ConsumerWidget {
  const PlanningPage({super.key});

  void _createNewPlan(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlanFormSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plansNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Planificación',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: state.plans.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: state.plans.length,
              itemBuilder: (context, index) {
                final plan = state.plans[index];
                return _PlanCard(plan: plan);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'planning_fab',
        onPressed: () => _createNewPlan(context, ref),
        label: const Text('Nuevo Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(LucideIcons.plus),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.target, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin planes activos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primer plan estratégico para empezar a forjar tu disciplina.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _createNewPlan(context, ref),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Crear mi primer plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(planId: plan.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.flame, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          DateFormat('dd MMMM, yyyy').format(plan.createdAt),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, size: 20),
                ],
              ),
              if (plan.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  plan.description,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatItem(label: 'Objetivos', value: '${plan.objectives.length}', icon: LucideIcons.target),
                  const SizedBox(width: 24),
                  _StatItem(label: 'Misiones', value: '${plan.missions.length}', icon: LucideIcons.checkSquare),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _PlanFormSheet extends StatefulWidget {
  final WidgetRef ref;
  const _PlanFormSheet({required this.ref});

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _useTemplate(Plan template) {
    HapticFeedback.mediumImpact();
    final newPlan = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
    widget.ref.read(plansNotifierProvider.notifier).addPlan(newPlan);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailPage(planId: newPlan.id),
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    final newPlan = Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      createdAt: DateTime.now(),
      missions: [],
    );

    widget.ref.read(plansNotifierProvider.notifier).addPlan(newPlan);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailPage(planId: newPlan.id),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) => InputDecoration(
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleSmall?.color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final guerraTemplates = PlanTemplates.guerraTemplates;
    final monjeTemplates = PlanTemplates.monjeTemplates;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 0,
        right: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
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
                decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'Nuevo Plan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.sparkles, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text('PRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Sección Modo Guerra
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(LucideIcons.swords, size: 16, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  _label('MODO GUERRA (Ofensiva)'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildTemplateList(guerraTemplates, [
              Colors.red.shade400,
              Colors.orange.shade400,
              Colors.blue.shade400,
            ], [
              LucideIcons.dumbbell,
              LucideIcons.trendingUp,
              LucideIcons.shieldCheck,
            ]),

            const SizedBox(height: 24),

            // Sección Modo Monje
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(LucideIcons.moon, size: 16, color: Colors.purple.shade300),
                  const SizedBox(width: 8),
                  _label('MODO MONJE (Retiro)'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildTemplateList(monjeTemplates, [
              Colors.purple.shade300,
              Colors.indigo.shade300,
              Colors.teal.shade300,
            ], [
              LucideIcons.target,
              LucideIcons.brain,
              LucideIcons.bookOpen,
            ]),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('O crear desde cero'),
                  TextField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecor('Título del Plan'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecor('Descripción corta...'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Crear Personalizado',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildTemplateList(List<Plan> templates, List<Color> colors, List<IconData> icons) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final t = templates[index];
          return GestureDetector(
            onTap: () => _useTemplate(t),
            child: Container(
              width: 145,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[index % icons.length], color: colors[index % colors.length], size: 22),
                  const SizedBox(height: 10),
                  Text(
                    t.title.split(':').last.trim(),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

