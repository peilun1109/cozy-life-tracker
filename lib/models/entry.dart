class Entry {
  const Entry({
    this.id,
    required this.content,
    this.mood,
    required this.createdAt,
    this.goalId,
    this.imagePaths = const [],
  });

  final int? id;
  final String content;
  final String? mood;
  final DateTime createdAt;
  final int? goalId;
  final List<String> imagePaths;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'content': content,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
      'goal_id': goalId,
    };
  }

  Map<String, Object?> toStorageMap() {
    return {
      ...toMap(),
      'image_paths': imagePaths,
    };
  }

  Entry copyWith({
    int? id,
    String? content,
    String? mood,
    DateTime? createdAt,
    int? goalId,
    List<String>? imagePaths,
  }) {
    return Entry(
      id: id ?? this.id,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      goalId: goalId ?? this.goalId,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  factory Entry.fromMap(
    Map<String, Object?> map, {
    List<String> imagePaths = const [],
  }) {
    return Entry(
      id: map['id'] as int?,
      content: map['content'] as String,
      mood: map['mood'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      goalId: map['goal_id'] as int?,
      imagePaths: imagePaths,
    );
  }

  factory Entry.fromStorageMap(Map<String, Object?> map) {
    final dynamic rawPaths = map['image_paths'];
    return Entry(
      id: map['id'] as int?,
      content: map['content'] as String,
      mood: map['mood'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      goalId: map['goal_id'] as int?,
      imagePaths: rawPaths is List
          ? rawPaths.map((item) => item.toString()).toList()
          : const [],
    );
  }
}
