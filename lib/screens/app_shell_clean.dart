import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import '../widgets/sidebar_clean.dart';
import 'entries_page.dart';
import 'goals_page.dart';
import 'home_page.dart';
import 'review_page.dart';
import 'settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    widget.appState.onReminderRequested = _showReminderDialog;
  }

  @override
  void dispose() {
    widget.appState.onReminderRequested = null;
    super.dispose();
  }

  Future<void> _showReminderDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今天的小提醒'),
        content: const Text('來寫下一點今天發生的事吧，也可以順手放上照片。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('晚點再說'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.appState.selectSection(AppSection.entries);
              _openEntryEditor();
            },
            child: const Text('現在記錄'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEntryEditor([Entry? entry]) async {
    await showEntryEditor(context, widget.appState, existing: entry);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return Scaffold(
          body: Row(
            children: [
              Sidebar(
                currentSection: widget.appState.selectedSection,
                onSelect: widget.appState.selectSection,
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFFCFA), Color(0xFFF6FBFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildBody(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (widget.appState.selectedSection) {
      case AppSection.home:
        return HomeScreen(appState: widget.appState);
      case AppSection.entries:
        return EntriesScreen(
          appState: widget.appState,
          onCreateEntry: () => _openEntryEditor(),
          onEditEntry: _openEntryEditor,
        );
      case AppSection.goals:
        return GoalsScreen(appState: widget.appState);
      case AppSection.review:
        return ReviewScreen(appState: widget.appState);
      case AppSection.settings:
        return SettingsScreen(appState: widget.appState);
    }
  }
}
