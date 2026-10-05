import 'dart:convert';

class PlanObjective {
  final String id;
  final String title;
  final bool isCompleted;

  PlanObjective({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  PlanObjective copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return PlanObjective(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory PlanObjective.fromJson(Map<String, dynamic> json) => PlanObjective(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class PlanLearning {
  final String id;
  final String text;
  final DateTime createdAt;

  PlanLearning({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  PlanLearning copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
  }) {
    return PlanLearning(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PlanLearning.fromJson(Map<String, dynamic> json) => PlanLearning(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class MissionAction {
  final String id;
  final String content;
  final String description;
  final bool isDaily;
  final Map<String, bool> tracking; // date (yyyy-MM-dd) -> completed

  MissionAction({
    required this.id,
    required this.content,
    this.description = '',
    this.isDaily = true,
    this.tracking = const {},
  });

  MissionAction copyWith({
    String? id,
    String? content,
    String? description,
    bool? isDaily,
    Map<String, bool>? tracking,
  }) {
    return MissionAction(
      id: id ?? this.id,
      content: content ?? this.content,
      description: description ?? this.description,
      isDaily: isDaily ?? this.isDaily,
      tracking: tracking ?? this.tracking,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'description': description,
        'isDaily': isDaily,
        'tracking': tracking,
      };

  factory MissionAction.fromJson(Map<String, dynamic> json) => MissionAction(
        id: json['id'] as String,
        content: json['content'] as String,
        description: json['description'] as String? ?? '',
        isDaily: json['isDaily'] as bool? ?? true,
        tracking: (json['tracking'] as Map?)?.cast<String, bool>() ?? {},
      );
}

class Plan {
  final String id;
  final String title;
  final String description;
  final String hell;
  final String heaven;
  final List<PlanObjective> objectives;
  final List<MissionAction> missions;
  final List<PlanLearning> learnings;
  final List<String> attachedIdeaIds;
  final DateTime createdAt;

  Plan({
    required this.id,
    required this.title,
    this.description = '',
    this.hell = '',
    this.heaven = '',
    this.objectives = const [],
    this.missions = const [],
    this.learnings = const [],
    this.attachedIdeaIds = const [],
    required this.createdAt,
  });

  Plan copyWith({
    String? id,
    String? title,
    String? description,
    String? hell,
    String? heaven,
    List<PlanObjective>? objectives,
    List<MissionAction>? missions,
    List<PlanLearning>? learnings,
    List<String>? attachedIdeaIds,
    DateTime? createdAt,
  }) {
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hell: hell ?? this.hell,
      heaven: heaven ?? this.heaven,
      objectives: objectives ?? this.objectives,
      missions: missions ?? this.missions,
      learnings: learnings ?? this.learnings,
      attachedIdeaIds: attachedIdeaIds ?? this.attachedIdeaIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'hell': hell,
        'heaven': heaven,
        'objectives': objectives.map((o) => o.toJson()).toList(),
        'missions': missions.map((m) => m.toJson()).toList(),
        'learnings': learnings.map((l) => l.toJson()).toList(),
        'attachedIdeaIds': attachedIdeaIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        hell: json['hell'] as String? ?? '',
        heaven: json['heaven'] as String? ?? '',
        objectives: (json['objectives'] as List?)
                ?.map((o) => PlanObjective.fromJson(o as Map<String, dynamic>))
                .toList() ??
            [],
        missions: (json['missions'] as List?)
                ?.map((m) => MissionAction.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        learnings: (json['learnings'] as List?)
                ?.map((l) => PlanLearning.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
        attachedIdeaIds: (json['attachedIdeaIds'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}



