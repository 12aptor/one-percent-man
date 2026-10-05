import 'package:flutter/material.dart';

// ─── Category ───────────────────────────────
class CommunityCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;

  const CommunityCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

const communityCategories = [
  CommunityCategory(id: 'all',      label: 'Todo',       emoji: '🌐', color: Color(0xFF4F46E5)),
  CommunityCategory(id: 'mentalidad', label: 'Mentalidad', emoji: '🧠', color: Color(0xFF6366F1)),
  CommunityCategory(id: 'finanzas', label: 'Finanzas',   emoji: '💰', color: Color(0xFF10B981)),
  CommunityCategory(id: 'salud',    label: 'Salud',      emoji: '💪', color: Color(0xFFEF4444)),
  CommunityCategory(id: 'relaciones', label: 'Relaciones', emoji: '🤝', color: Color(0xFFF59E0B)),
  CommunityCategory(id: 'proposito', label: 'Propósito',  emoji: '🎯', color: Color(0xFF8B5CF6)),
  CommunityCategory(id: 'estilo',   label: 'Estilo',     emoji: '⚡', color: Color(0xFF0EA5E9)),
];

// ─── Comment ────────────────────────────────
class PostComment {
  final String id;
  final String authorName;
  final String authorInitials;
  final Color authorColor;
  final String content;
  final String? sticker;       // emoji sticker
  final String? imageBg;       // hex color as fake "image"
  final String? imageEmoji;    // emoji shown on colored bg
  int likes;
  bool likedByMe;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.authorColor,
    required this.content,
    this.sticker,
    this.imageBg,
    this.imageEmoji,
    this.likes = 0,
    this.likedByMe = false,
    required this.createdAt,
  });

  PostComment copyWith({
    int? likes,
    bool? likedByMe,
  }) =>
      PostComment(
        id: id,
        authorName: authorName,
        authorInitials: authorInitials,
        authorColor: authorColor,
        content: content,
        sticker: sticker,
        imageBg: imageBg,
        imageEmoji: imageEmoji,
        likes: likes ?? this.likes,
        likedByMe: likedByMe ?? this.likedByMe,
        createdAt: createdAt,
      );
}

// ─── Post ───────────────────────────────────
class CommunityPost {
  final String id;
  final String authorName;
  final String authorInitials;
  final Color authorColor;
  final String categoryId;
  final String content;
  final String? imageBg;      // simulated image background color hex
  final String? imageEmoji;   // emoji shown over image bg
  int likes;
  bool likedByMe;
  final List<PostComment> comments;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.authorColor,
    required this.categoryId,
    required this.content,
    this.imageBg,
    this.imageEmoji,
    this.likes = 0,
    this.likedByMe = false,
    List<PostComment>? comments,
    required this.createdAt,
  }) : comments = comments ?? [];

  CommunityPost copyWith({
    int? likes,
    bool? likedByMe,
    List<PostComment>? comments,
  }) =>
      CommunityPost(
        id: id,
        authorName: authorName,
        authorInitials: authorInitials,
        authorColor: authorColor,
        categoryId: categoryId,
        content: content,
        imageBg: imageBg,
        imageEmoji: imageEmoji,
        likes: likes ?? this.likes,
        likedByMe: likedByMe ?? this.likedByMe,
        comments: comments ?? this.comments,
        createdAt: createdAt,
      );

  String timeAgo() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}

