class Goal {
  const Goal({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.progress,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int progress;

  int get daysLeft => endDate.difference(DateTime.now()).inDays;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'progress': progress,
    };
  }

  Goal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
    );
  }

  factory Goal.fromMap(Map<String, Object?> map) {
    return Goal(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      progress: map['progress'] as int? ?? 0,
    );
  }
}
