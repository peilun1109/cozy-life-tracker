import 'dart:async';

class ReminderService {
  Timer? _timer;
  DateTime? _lastTriggeredAt;

  void start({
    required bool enabled,
    required String reminderTime,
    required ReminderCallback onReminder,
  }) {
    stop();
    if (!enabled) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now();
      final parts = reminderTime.split(':');
      if (parts.length != 2) {
        return;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) {
        return;
      }

      final alreadyTriggeredToday = _lastTriggeredAt != null &&
          _lastTriggeredAt!.year == now.year &&
          _lastTriggeredAt!.month == now.month &&
          _lastTriggeredAt!.day == now.day;

      if (!alreadyTriggeredToday && now.hour == hour && now.minute == minute) {
        _lastTriggeredAt = now;
        onReminder();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

typedef ReminderCallback = void Function();
