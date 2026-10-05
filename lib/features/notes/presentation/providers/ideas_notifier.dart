import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/idea_model.dart';

const _kIdeasKey = 'ideas_v1';

class IdeasState {
  final List<Idea> ideas;
  final bool isLoaded;

  const IdeasState({
    this.ideas = const [],
    this.isLoaded = false,
  });

  IdeasState copyWith({
    List<Idea>? ideas,
    bool? isLoaded,
  }) {
    return IdeasState(
      ideas: ideas ?? this.ideas,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class IdeasNotifier extends StateNotifier<IdeasState> {
  SharedPreferences? _prefs;

  IdeasNotifier() : super(const IdeasState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final ideasJson = _prefs!.getStringList(_kIdeasKey) ?? [];
    
    final ideas = ideasJson.map((s) => Idea.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = IdeasState(ideas: ideas, isLoaded: true);
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _kIdeasKey,
      state.ideas.map((i) => jsonEncode(i.toJson())).toList(),
    );
  }

  Future<void> addIdea(String content) async {
    if (content.trim().isEmpty) return;
    
    final newIdea = Idea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(ideas: [newIdea, ...state.ideas]);
    await _persist();
  }

  Future<void> updateIdea(Idea updated) async {
    state = state.copyWith(
      ideas: [for (final i in state.ideas) i.id == updated.id ? updated : i],
    );
    await _persist();
  }

  Future<void> deleteIdea(String id) async {
    state = state.copyWith(
      ideas: state.ideas.where((i) => i.id != id).toList(),
    );
    await _persist();
  }

  Future<void> toggleArchive(String id) async {
    state = state.copyWith(
      ideas: [
        for (final i in state.ideas)
          if (i.id == id) i.copyWith(isArchived: !i.isArchived) else i
      ],
    );
    await _persist();
  }
}

final ideasNotifierProvider =
    StateNotifierProvider<IdeasNotifier, IdeasState>((ref) {
  return IdeasNotifier();
});

