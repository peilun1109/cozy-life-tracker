import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../state/app_state.dart';
import '../widgets/cute_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('設定', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('先放基本提醒設定，之後可以再慢慢長出更多個人化選項。'),
          const SizedBox(height: 20),
          CuteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  value: appState.settings.reminderEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('開啟每日提醒'),
                  subtitle: const Text('在固定時間提醒我回來寫一點今天的生活紀錄'),
                  onChanged: (value) => appState.saveSettings(
                    appState.settings.copyWith(reminderEnabled: value),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('每日提醒時間'),
                  subtitle: Text(appState.formattedReminderTime()),
                  trailing: ElevatedButton(
                    onPressed: () => _pickTime(context),
                    child: const Text('修改時間'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'MVP 說明：目前先以 App 內固定時間提醒流程為主，後續可再接真正的桌面系統通知與點擊導頁。',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final parts = appState.settings.reminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 21,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) {
      return;
    }

    final nextSettings = AppSettings(
      reminderEnabled: appState.settings.reminderEnabled,
      reminderTime:
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
    );
    await appState.saveSettings(nextSettings);
  }
}
