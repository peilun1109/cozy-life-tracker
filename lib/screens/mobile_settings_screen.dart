import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../state/app_state.dart';
import '../widgets/cute_card.dart';

class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        CuteCard(
          backgroundColor: const Color(0xFFFFF0E5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '提醒設定',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '固定一個時間，讓自己每天都留下一點生活痕跡。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CuteCard(
          child: Column(
            children: [
              SwitchListTile(
                value: appState.settings.reminderEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('開啟每日提醒'),
                subtitle: const Text('到時間時會跳出提醒，帶你回到新增紀錄。'),
                onChanged: (enabled) {
                  appState.saveSettings(
                    appState.settings.copyWith(reminderEnabled: enabled),
                  );
                },
              ),
              const Divider(height: 28),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('提醒時間'),
                subtitle: Text(appState.formattedReminderTime()),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final parts = appState.settings.reminderTime.split(':');
                  final initialTime = TimeOfDay(
                    hour: int.tryParse(parts.first) ?? 21,
                    minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                  );

                  final picked = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                  );

                  if (picked == null) {
                    return;
                  }

                  await appState.saveSettings(
                    appState.settings.copyWith(
                      reminderTime:
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CuteCard(
          backgroundColor: const Color(0xFFEAF6FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '目前原型說明',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Text('資料目前先存放在本機裝置，適合個人測試與原型驗證。'),
              const SizedBox(height: 8),
              const Text('之後如果要跨裝置同步，再接雲端帳號與後端服務。'),
            ],
          ),
        ),
      ],
    );
  }
}
