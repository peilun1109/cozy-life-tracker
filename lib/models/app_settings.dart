class AppSettings {
  const AppSettings({
    required this.reminderEnabled,
    required this.reminderTime,
    this.weeklyPlans = const {},
  });

  final bool reminderEnabled;
  final String reminderTime;
  final Map<String, List<String>> weeklyPlans;

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_time': reminderTime,
      'weekly_plans': weeklyPlans,
    };
  }

  AppSettings copyWith({
    bool? reminderEnabled,
    String? reminderTime,
    Map<String, List<String>>? weeklyPlans,
  }) {
    return AppSettings(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyPlans: weeklyPlans ?? this.weeklyPlans,
    );
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    final rawPlans = map['weekly_plans'];
    final weeklyPlans = <String, List<String>>{};
    if (rawPlans is Map) {
      for (final entry in rawPlans.entries) {
        final value = entry.value;
        if (value is List) {
          weeklyPlans[entry.key.toString()] =
              value.map((item) => item.toString()).toList();
        }
      }
    }

    return AppSettings(
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderTime: map['reminder_time'] as String? ?? '21:00',
      weeklyPlans: weeklyPlans,
    );
  }

  factory AppSettings.defaults() {
    return const AppSettings(
      reminderEnabled: true,
      reminderTime: '21:00',
    );
  }
}
