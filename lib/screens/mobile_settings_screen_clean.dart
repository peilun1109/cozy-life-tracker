import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/cute_card.dart';

class MobileSettingsScreenClean extends StatelessWidget {
  const MobileSettingsScreenClean({
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
                '\u63d0\u9192\u8a2d\u5b9a',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '\u56fa\u5b9a\u4e00\u500b\u6642\u9593\uff0c\u8b93\u81ea\u5df1\u6bcf\u5929\u90fd\u7559\u4e0b\u4e00\u9ede\u751f\u6d3b\u75d5\u8de1\u3002',
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
                title: const Text('\u958b\u555f\u6bcf\u65e5\u63d0\u9192'),
                subtitle: const Text(
                  '\u5230\u6642\u9593\u6642\u6703\u8df3\u51fa\u63d0\u9192\uff0c\u5e36\u4f60\u56de\u5230\u65b0\u589e\u7d00\u9304\u3002',
                ),
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
                title: const Text('\u63d0\u9192\u6642\u9593'),
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
                '\u76ee\u524d\u539f\u578b\u8aaa\u660e',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                '\u8cc7\u6599\u76ee\u524d\u5148\u5b58\u653e\u5728\u672c\u6a5f\u88dd\u7f6e\uff0c\u9069\u5408\u500b\u4eba\u6e2c\u8a66\u8207\u539f\u578b\u9a57\u8b49\u3002',
              ),
              const SizedBox(height: 8),
              const Text(
                '\u4e4b\u5f8c\u5982\u679c\u8981\u8de8\u88dd\u7f6e\u540c\u6b65\uff0c\u518d\u63a5\u96f2\u7aef\u5e33\u865f\u8207\u5f8c\u7aef\u670d\u52d9\u3002',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
