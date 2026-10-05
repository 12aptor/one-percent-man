import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/ideas_notifier.dart';
import '../../domain/models/idea_model.dart';

class BrainstormingPage extends ConsumerWidget {
  const BrainstormingPage({super.key});

  void _showIdeaForm(BuildContext context, WidgetRef ref, {Idea? idea}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IdeaFormSheet(idea: idea),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ideasNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.lightbulb,
                            color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lluvia de Ideas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                            ),
                          ),
                          Text(
                            'Captura cada destello de genio',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // New Idea Trigger
                  GestureDetector(
                    onTap: () => _showIdeaForm(context, ref),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Row(
                        children: [
                          Icon(LucideIcons.pencil,
                              size: 18, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                          SizedBox(width: 12),
                          Text(
                            'Escribe una nueva idea...',
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 15),
                          ),
                          Spacer(),
                          Icon(LucideIcons.plus,
                              size: 20, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (!state.isLoaded)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.ideas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.brain,
                        size: 64,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Tu mente está despejada',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.withOpacity(0.5),
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: state.ideas.length,
                itemBuilder: (context, index) {
                  final idea = state.ideas[index];
                  return _IdeaCard(
                    idea: idea,
                    onEdit: () => _showIdeaForm(context, ref, idea: idea),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'brainstorming_fab',
        onPressed: () => _showIdeaForm(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}

class _IdeaFormSheet extends ConsumerStatefulWidget {
  final Idea? idea;
  const _IdeaFormSheet({this.idea});

  @override
  ConsumerState<_IdeaFormSheet> createState() => _IdeaFormSheetState();
}

class _IdeaFormSheetState extends ConsumerState<_IdeaFormSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.idea?.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) return;

    if (widget.idea != null) {
      ref.read(ideasNotifierProvider.notifier).updateIdea(
            widget.idea!.copyWith(content: _controller.text.trim()),
          );
    } else {
      ref.read(ideasNotifierProvider.notifier).addIdea(_controller.text.trim());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.idea == null ? 'Nueva Idea' : 'Editar Idea',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _save,
                icon: Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Escribe tu idea aquí...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              ),
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdeaCard extends ConsumerWidget {
  final Idea idea;
  final VoidCallback onEdit;
  const _IdeaCard({required this.idea, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate a soft pastel color based on the idea ID
    final hue = (idea.id.hashCode % 360).toDouble();
    final cardColor = HSLColor.fromAHSL(1, hue, 0.6, 0.95).toColor();
    final accentColor = HSLColor.fromAHSL(1, hue, 0.6, 0.4).toColor();

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              idea.content,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM').format(idea.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: accentColor.withOpacity(0.7),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showOptions(context, ref),
                  child: Icon(
                    LucideIcons.moreVertical,
                    size: 16,
                    color: accentColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: const Text('Editar idea'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text('Eliminar idea',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(ideasNotifierProvider.notifier).deleteIdea(idea.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

