class AppSettings {
  const AppSettings({
    required this.reminderEnabled,
    required this.reminderTime,
  });

  final bool reminderEnabled;
  final String reminderTime;

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_time': reminderTime,
    };
  }

  AppSettings copyWith({
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return AppSettings(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderTime: map['reminder_time'] as String? ?? '21:00',
    );
  }

  factory AppSettings.defaults() {
    return const AppSettings(
      reminderEnabled: true,
      reminderTime: '21:00',
    );
  }
}
