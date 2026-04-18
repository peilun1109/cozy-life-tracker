import 'package:flutter/material.dart';

import 'screens/web_shell_v5.dart';
import 'services/image_storage_service.dart';
import 'services/reminder_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class ShiguangjiWebApp extends StatefulWidget {
  const ShiguangjiWebApp({super.key});

  @override
  State<ShiguangjiWebApp> createState() => _ShiguangjiWebAppState();
}

class _ShiguangjiWebAppState extends State<ShiguangjiWebApp> {
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
      title: '拾光機',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: _isReady
          ? WebShellV5(appState: _appState)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
