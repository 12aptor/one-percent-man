import 'dart:convert';

class Idea {
  final String id;
  final String content;
  final DateTime createdAt;
  final bool isArchived;

  const Idea({
    required this.id,
    required this.content,
    required this.createdAt,
    this.isArchived = false,
  });

  Idea copyWith({
    String? content,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Idea(
      id: id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'isArchived': isArchived,
      };

  factory Idea.fromJson(Map<String, dynamic> json) => Idea(
        id: json['id'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isArchived: json['isArchived'] as bool? ?? false,
      );
}

