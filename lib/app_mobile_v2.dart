import 'package:flutter/material.dart';

import 'screens/mobile_shell_clean.dart';
import 'services/image_storage_service.dart';
import 'services/reminder_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class CozyLifeMobileAppV2 extends StatefulWidget {
  const CozyLifeMobileAppV2({super.key});

  @override
  State<CozyLifeMobileAppV2> createState() => _CozyLifeMobileAppV2State();
}

class _CozyLifeMobileAppV2State extends State<CozyLifeMobileAppV2> {
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
      title: '\u6696\u6696\u751f\u6d3b\u624b\u5e33',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: _isReady
          ? MobileShellClean(appState: _appState)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
