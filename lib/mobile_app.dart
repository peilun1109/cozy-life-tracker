import 'package:flutter/material.dart';

import 'screens/mobile_shell.dart';
import 'services/image_storage_service.dart';
import 'services/reminder_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class CozyLifeMobileApp extends StatefulWidget {
  const CozyLifeMobileApp({super.key});

  @override
  State<CozyLifeMobileApp> createState() => _CozyLifeMobileAppState();
}

class _CozyLifeMobileAppState extends State<CozyLifeMobileApp> {
  late final AppState _appState;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      imageStorageService: createImageStorageService(),
      reminderService: ReminderService(),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    await _appState.initialize();
    if (mounted) {
      setState(() => _isReady = true);
    }
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '暖暖生活手帳',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: _isReady
          ? MobileShell(appState: _appState)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
