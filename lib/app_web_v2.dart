import 'package:flutter/material.dart';

import 'screens/web_shell_v3.dart';
import 'services/image_storage_service.dart';
import 'services/reminder_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class CozyLifeWebAppV2 extends StatefulWidget {
  const CozyLifeWebAppV2({super.key});

  @override
  State<CozyLifeWebAppV2> createState() => _CozyLifeWebAppV2State();
}

class _CozyLifeWebAppV2State extends State<CozyLifeWebAppV2> {
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
          ? WebShellV3(appState: _appState)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
