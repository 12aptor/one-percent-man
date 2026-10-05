import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community_post.dart';

class CommunityNotifier extends StateNotifier<List<CommunityPost>> {
  CommunityNotifier()
      : super([
          CommunityPost(
            id: '1',
            authorName: 'Sebastián M.',
            authorInitials: 'SM',
            authorColor: const Color(0xFF6366F1),
            categoryId: 'mentalidad',
            content:
                '¿Cómo mantienen la disciplina cuando todo a su alrededor parece caer? Llevo 3 semanas en racha y siento que el entorno me jala hacia abajo.',
            likes: 47,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            comments: [
              PostComment(
                id: 'c1',
                authorName: 'Carlos A.',
                authorInitials: 'CA',
                authorColor: const Color(0xFFF59E0B),
                content:
                    'El entorno es un espejo de tus decisiones. Si cambias tú, cambia lo que toleras.',
                sticker: '🦁',
                likes: 12,
                createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              ),
              PostComment(
                id: 'c2',
                authorName: 'Diego F.',
                authorInitials: 'DF',
                authorColor: const Color(0xFF10B981),
                content:
                    'Yo uso la regla de los 5 segundos de Mel Robbins. Antes de ceder, cuento hasta 5 y actúo.',
                likes: 8,
                createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
              ),
            ],
          ),
          CommunityPost(
            id: '2',
            authorName: 'André P.',
            authorInitials: 'AP',
            authorColor: const Color(0xFF10B981),
            categoryId: 'finanzas',
            content:
                '¿Cuál fue la primera inversión que cambió tu mentalidad sobre el dinero? Para mí fue perder \$500 en cripto — aprendí más que en cualquier libro.',
            imageBg: '#1E293B',
            imageEmoji: '💸',
            likes: 89,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            comments: [
              PostComment(
                id: 'c3',
                authorName: 'Valentina R.',
                authorInitials: 'VR',
                authorColor: const Color(0xFF8B5CF6),
                content: 'Comprar acciones de Apple en el 2019. Desde ahí no paré de estudiar.',
                sticker: '📈',
                likes: 22,
                createdAt: DateTime.now().subtract(const Duration(hours: 4)),
              ),
            ],
          ),
          CommunityPost(
            id: '3',
            authorName: 'María L.',
            authorInitials: 'ML',
            authorColor: const Color(0xFFEF4444),
            categoryId: 'salud',
            content:
                'Día 100 en el gym. Sé que muchos se rinden. A los que están en la racha: ¿qué los mantiene? Para mí fue un foto del antes que guardé en la billetera.',
            imageBg: '#0F172A',
            imageEmoji: '💪',
            likes: 134,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            comments: [
              PostComment(
                id: 'c4',
                authorName: 'Andrés P.',
                authorInitials: 'AP',
                authorColor: const Color(0xFF10B981),
                content: '¡100 días! Eso es élite.',
                sticker: '🔥',
                likes: 31,
                createdAt:
                    DateTime.now().subtract(const Duration(hours: 20)),
              ),
              PostComment(
                id: 'c5',
                authorName: 'Pedro G.',
                authorInitials: 'PG',
                authorColor: const Color(0xFF0EA5E9),
                content:
                    'A mí me mantiene la identidad. No voy al gym para verme bien, voy porque SOY alguien que va al gym.',
                imageBg: '#7C3AED',
                imageEmoji: '🏆',
                likes: 45,
                createdAt:
                    DateTime.now().subtract(const Duration(hours: 18)),
              ),
            ],
          ),
          CommunityPost(
            id: '4',
            authorName: 'Luisa T.',
            authorInitials: 'LT',
            authorColor: const Color(0xFF0EA5E9),
            categoryId: 'proposito',
            content:
                'Hilo sobre propósito: Si te quitaran todo el dinero mañana, ¿seguirías haciendo lo que haces? Si la respuesta es no, quizás estás persiguiendo el dinero, no tu propósito.',
            likes: 211,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            comments: [],
          ),
        ]);

  void addPost(CommunityPost post) {
    state = [post, ...state];
  }

  void toggleLike(String postId) {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            likedByMe: !p.likedByMe,
            likes: p.likedByMe ? p.likes - 1 : p.likes + 1,
          )
        else
          p,
    ];
  }

  void addComment(String postId, PostComment comment) {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(comments: [...p.comments, comment])
        else
          p,
    ];
  }

  void toggleCommentLike(String postId, String commentId) {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            comments: [
              for (final c in p.comments)
                if (c.id == commentId)
                  c.copyWith(
                    likedByMe: !c.likedByMe,
                    likes: c.likedByMe ? c.likes - 1 : c.likes + 1,
                  )
                else
                  c,
            ],
          )
        else
          p,
    ];
  }

  void deletePost(String postId) {
    state = state.where((p) => p.id != postId).toList();
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, List<CommunityPost>>((ref) {
  return CommunityNotifier();
});

// Selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

