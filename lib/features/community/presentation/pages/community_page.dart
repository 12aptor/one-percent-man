import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/community_provider.dart';
import '../../domain/models/community_post.dart';

// ─── Sticker packs ──────────────────────────
const _stickerPacks = {
  'Motivación': ['🔥', '💪', '🦁', '⚡', '🚀', '🎯', '🏆', '🧠', '💡', '⚔️'],
  'Apoyo': ['❤️', '🫂', '👊', '🤜', '🙌', '🤝', '🙏', '💯', '✅', '🫡'],
  'Humor': ['😂', '😎', '😈', '💀', '🤣', '🎭', '🤦', '🙈', '🎪', '👻'],
  'Reacción': ['📈', '💸', '⚙️', '🛡️', '🎖️', '🌊', '🐉', '🃏', '🎸', '🌟'],
};

// ─── Image color options ─────────────────────
const _imageBgs = [
  '#1E293B', '#0F172A', '#312E81', '#064E3B',
  '#7C2D12', '#701A75', '#1E3A5F', '#422006',
];
const _imageEmojis = [
  '💸', '💪', '🏆', '🔥', '🧠', '📈', '⚡', '🦁',
  '🎯', '🚀', '👊', '🌟', '💡', '⚔️', '🛡️', '🎖️',
];

// ─── Helpers ─────────────────────────────────
Color _hexColor(String hex) {
  return Color(int.parse(hex.replaceFirst('#', '0xFF')));
}

// ═════════════════════════════════════════════
// Main Community Page
// ═════════════════════════════════════════════
class CommunityPage extends ConsumerWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPosts = ref.watch(communityProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    final posts = selectedCat == 'all'
        ? allPosts
        : allPosts.where((p) => p.categoryId == selectedCat).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _CategoryBar()),
          if (posts.isEmpty)
            SliverFillRemaining(child: _buildEmpty(context, selectedCat))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _PostCard(post: posts[i]),
                  childCount: posts.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community_fab',
        onPressed: () => _showCreatePost(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(LucideIcons.edit, color: Colors.white),
        label: const Text('Nuevo post',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Consejo de Hombres',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text('Comparte, aprende y crece',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.search, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, String cat) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤫', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text('Nada por aquí aún',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black)),
          const SizedBox(height: 8),
          Text('Sé el primero en publicar en esta categoría',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showCreatePost(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(ref: ref),
    );
  }
}

// ─── Category filter bar ─────────────────────
class _CategoryBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: communityCategories.length,
        itemBuilder: (_, i) {
          final cat = communityCategories[i];
          final isSelected = selected == cat.id;
          return GestureDetector(
            onTap: () => ref.read(selectedCategoryProvider.notifier).state =
                cat.id,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? cat.color : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected ? cat.color : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Text(cat.emoji,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                    ),
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

// ─── Post Card ───────────────────────────────
class _PostCard extends ConsumerStatefulWidget {
  final CommunityPost post;
  const _PostCard({required this.post});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeCtrl;
  late Animation<double> _likeAnim;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _likeAnim = Tween<double>(begin: 1, end: 1.4).animate(
        CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  void _like() {
    HapticFeedback.lightImpact();
    ref.read(communityProvider.notifier).toggleLike(widget.post.id);
    _likeCtrl.forward(from: 0);
  }

  CommunityCategory get _cat => communityCategories
      .firstWhere((c) => c.id == widget.post.categoryId,
          orElse: () => communityCategories.first);

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(communityProvider)
        .firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);

    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: post.authorColor,
                    child: Text(post.authorInitials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(post.timeAgo(),
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                      ],
                    ),
                  ),
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _cat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${_cat.emoji} ${_cat.label}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _cat.color),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Text(
                post.content,
                style: TextStyle(
                    fontSize: 15, height: 1.5, color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black),
              ),
            ),

            // Optional image
            if (post.imageBg != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: _ImagePlaceholder(
                    bgHex: post.imageBg!, emoji: post.imageEmoji),
              ),

            // Action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  // Like
                  GestureDetector(
                    onTap: _like,
                    child: AnimatedBuilder(
                      animation: _likeAnim,
                      builder: (_, child) => Transform.scale(
                        scale: _likeAnim.value,
                        child: child,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            post.likedByMe
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: post.likedByMe
                                ? Colors.red.shade400
                                : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text('${post.likes}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: post.likedByMe
                                      ? Colors.red.shade400
                                      : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Comments — opens sheet
                  GestureDetector(
                    onTap: () => _openComments(context),
                    child: Row(
                      children: [
                        Icon(LucideIcons.messageCircle,
                            size: 20, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                        const SizedBox(width: 5),
                        Text('${post.comments.length}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Share
                  GestureDetector(
                    onTap: () {},
                    child: Icon(LucideIcons.share2,
                        size: 18, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                  ),
                ],
              ),
            ),

            // Preview of last comment
            if (post.comments.isNotEmpty) ...[
              Divider(height: 1, color: Theme.of(context).dividerColor),
              GestureDetector(
                onTap: () => _openComments(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: post.comments.last.authorColor,
                        child: Text(
                          post.comments.last.authorInitials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.comments.last.sticker != null
                              ? '${post.comments.last.sticker}  ${post.comments.last.content}'
                              : post.comments.last.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                        ),
                      ),
                      Text('Ver todos (${post.comments.length})',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(postId: widget.post.id, ref: ref),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.flag,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              title: const Text('Reportar publicación'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(LucideIcons.trash2, color: Colors.red.shade400),
              title: Text('Eliminar',
                  style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                ref
                    .read(communityProvider.notifier)
                    .deletePost(widget.post.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image Placeholder widget ─────────────────
class _ImagePlaceholder extends StatelessWidget {
  final String bgHex;
  final String? emoji;
  const _ImagePlaceholder({required this.bgHex, this.emoji});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 160,
        width: double.infinity,
        color: _hexColor(bgHex),
        alignment: Alignment.center,
        child: emoji != null
            ? Text(emoji!, style: const TextStyle(fontSize: 52))
            : null,
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Comments Bottom Sheet
// ═════════════════════════════════════════════
class _CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  final WidgetRef ref;
  const _CommentsSheet({required this.postId, required this.ref});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _selectedSticker;
  String? _selectedImageBg;
  String? _selectedImageEmoji;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  CommunityPost get _post => ref.read(communityProvider).firstWhere(
        (p) => p.id == widget.postId,
      );

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty && _selectedSticker == null && _selectedImageBg == null) {
      return;
    }

    final comment = PostComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'John Doe',
      authorInitials: 'JD',
      authorColor: Theme.of(context).colorScheme.primary,
      content: text,
      sticker: _selectedSticker,
      imageBg: _selectedImageBg,
      imageEmoji: _selectedImageEmoji,
      createdAt: DateTime.now(),
    );

    ref.read(communityProvider.notifier).addComment(widget.postId, comment);
    setState(() {
      _ctrl.clear();
      _selectedSticker = null;
      _selectedImageBg = null;
      _selectedImageEmoji = null;
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showStickerPicker() async {
    final sticker = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StickerPickerSheet(),
    );
    if (sticker != null) setState(() => _selectedSticker = sticker);
  }

  void _showImagePicker() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImagePickerSheet(),
    );
    if (result != null) {
      setState(() {
        _selectedImageBg = result['bg'];
        _selectedImageEmoji = result['emoji'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityProvider);
    final post = posts.firstWhere((p) => p.id == widget.postId,
        orElse: () => _post);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${post.comments.length} comentarios',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),

            // Post snippet
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: post.authorColor,
                    child: Text(post.authorInitials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),

            // Comments list
            Expanded(
              child: post.comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💬', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 12),
                          Text('Sé el primero en responder',
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: post.comments.length,
                      itemBuilder: (_, i) => _CommentRow(
                        comment: post.comments[i],
                        postId: widget.postId,
                      ),
                    ),
            ),

            Divider(height: 1, color: Theme.of(context).dividerColor),

            // Reply input
            _buildReplyBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBox() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sticker / image preview
          if (_selectedSticker != null || _selectedImageBg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (_selectedSticker != null)
                    _PreviewChip(
                      label: _selectedSticker!,
                      onRemove: () =>
                          setState(() => _selectedSticker = null),
                    ),
                  if (_selectedImageBg != null)
                    _PreviewChip(
                      label: '${_selectedImageEmoji ?? '🖼'} Imagen',
                      color: _hexColor(_selectedImageBg!),
                      onRemove: () => setState(() {
                        _selectedImageBg = null;
                        _selectedImageEmoji = null;
                      }),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              // Sticker button
              _InputIconBtn(
                icon: '😄',
                onTap: _showStickerPicker,
              ),
              const SizedBox(width: 6),
              // Image button
              _InputIconBtn(
                icon: '🖼',
                onTap: _showImagePicker,
              ),
              const SizedBox(width: 8),
              // Text field
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.send,
                      size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Single Comment Row ───────────────────────
class _CommentRow extends ConsumerStatefulWidget {
  final PostComment comment;
  final String postId;
  const _CommentRow({required this.comment, required this.postId});

  @override
  ConsumerState<_CommentRow> createState() => _CommentRowState();
}

class _CommentRowState extends ConsumerState<_CommentRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _anim = Tween<double>(begin: 1, end: 1.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }


  void _toggleLike() {
    HapticFeedback.lightImpact();
    ref
        .read(communityProvider.notifier)
        .toggleCommentLike(widget.postId, widget.comment.id);
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityProvider);
    final post =
        posts.firstWhere((p) => p.id == widget.postId, orElse: () {
      // post deleted – return dummy
      return CommunityPost(
          id: '', authorName: '', authorInitials: '',
          authorColor: Colors.grey, categoryId: '', content: '',
          createdAt: DateTime.now());
    });
    final comment = post.comments.firstWhere(
        (c) => c.id == widget.comment.id,
        orElse: () => widget.comment);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: comment.authorColor,
            child: Text(comment.authorInitials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                          fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Sticker
                if (comment.sticker != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(comment.sticker!,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                if (comment.content.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Text(comment.content,
                        style: const TextStyle(fontSize: 14, height: 1.4)),
                  ),
                // Image in comment
                if (comment.imageBg != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 100,
                      width: 160,
                      color: _hexColor(comment.imageBg!),
                      alignment: Alignment.center,
                      child: Text(
                        comment.imageEmoji ?? '🖼',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                // Like on comment
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, child) =>
                        Transform.scale(scale: _anim.value, child: child),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          comment.likedByMe
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 14,
                          color: comment.likedByMe
                              ? Colors.red.shade400
                              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        if (comment.likes > 0)
                          Text('${comment.likes}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: comment.likedByMe
                                      ? Colors.red.shade400
                                      : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ═════════════════════════════════════════════
// Create Post Sheet
// ═════════════════════════════════════════════
class _CreatePostSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreatePostSheet({required this.ref});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _ctrl = TextEditingController();
  String _selectedCat = 'mentalidad';
  String? _imageBg;
  String? _imageEmoji;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _publish() {
    if (_ctrl.text.trim().isEmpty) return;

    widget.ref.read(communityProvider.notifier).addPost(
          CommunityPost(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            authorName: 'John Doe',
            authorInitials: 'JD',
            authorColor: Theme.of(context).colorScheme.primary,
            categoryId: _selectedCat,
            content: _ctrl.text.trim(),
            imageBg: _imageBg,
            imageEmoji: _imageEmoji,
            createdAt: DateTime.now(),
          ),
        );
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImagePickerSheet(),
    );
    if (result != null) {
      setState(() {
        _imageBg = result['bg'];
        _imageEmoji = result['emoji'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text('JD',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                    const SizedBox(width: 10),
                    const Text('John Doe',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Text area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 17, height: 1.5),
                      decoration: InputDecoration(
                        hintText:
                            '¿Qué quieres compartir con el consejo?',
                        hintStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 17),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // Image preview
                  if (_imageBg != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            color: _hexColor(_imageBg!),
                            alignment: Alignment.center,
                            child: Text(
                              _imageEmoji ?? '🖼',
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _imageBg = null;
                              _imageEmoji = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              child: const Icon(LucideIcons.x,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Theme.of(context).dividerColor),

          // Bottom toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category selector
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Categoría',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                ),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: communityCategories.length - 1, // skip 'all'
                    itemBuilder: (_, i) {
                      final cat = communityCategories[i + 1];
                      final isSel = _selectedCat == cat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCat = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? cat.color
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color:
                                    isSel ? cat.color : Theme.of(context).dividerColor),
                          ),
                          child: Text(
                            '${cat.emoji} ${cat.label}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSel
                                  ? Colors.white
                                  : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Image button
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          children: [
                            Text('🖼️',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text('Imagen',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Publish button
                    ElevatedButton(
                      onPressed: _publish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Publicar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Sticker Picker Sheet
// ═════════════════════════════════════════════
class _StickerPickerSheet extends StatefulWidget {
  @override
  State<_StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends State<_StickerPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
        length: _stickerPacks.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packs = _stickerPacks.entries.toList();

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          TabBar(
            controller: _tabCtrl,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs:
                packs.map((e) => Tab(text: e.key)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: packs.map((pack) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: pack.value.length,
                  itemBuilder: (_, i) {
                    final emoji = pack.value[i];
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, emoji),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Image Picker Sheet
// ═════════════════════════════════════════════
class _ImagePickerSheet extends StatefulWidget {
  @override
  State<_ImagePickerSheet> createState() => _ImagePickerSheetState();
}

class _ImagePickerSheetState extends State<_ImagePickerSheet> {
  String _selectedBg = _imageBgs[0];
  String _selectedEmoji = _imageEmojis[0];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
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
          const SizedBox(height: 16),
          // Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 100,
              color: _hexColor(_selectedBg),
              alignment: Alignment.center,
              child: Text(_selectedEmoji,
                  style: const TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Fondo',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _imageBgs.map((hex) {
                final isSel = _selectedBg == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBg = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _hexColor(hex),
                      shape: BoxShape.circle,
                      border: isSel
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary, width: 2.5)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Emoji',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _imageEmojis.map((e) {
                final isSel = _selectedEmoji == e;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSel
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSel
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(e,
                        style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(
                  context, {'bg': _selectedBg, 'emoji': _selectedEmoji}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Usar esta imagen',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small helper widgets ─────────────────────
class _PreviewChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onRemove;
  const _PreviewChip({required this.label, this.color, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.15) ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color ?? Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(LucideIcons.x,
                size: 12, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _InputIconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _InputIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: Text(icon, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

