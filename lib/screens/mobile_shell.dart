import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import 'mobile_entries_screen.dart';
import 'mobile_goals_screen.dart';
import 'mobile_home_screen.dart';
import 'mobile_review_screen.dart';
import 'mobile_settings_screen.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
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
    await showEntryEditorSheet(context, widget.appState, existing: entry);
  }

  Future<void> _openGoalEditor() async {
    await showGoalEditorSheet(context, widget.appState);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text('暖暖生活手帳'),
            actions: [
              IconButton(
                onPressed: widget.appState.refreshAll,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFCFA), Color(0xFFF6FBFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                child: _buildBody(),
              ),
            ),
          ),
          floatingActionButton: _buildFab(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: AppSection.values.indexOf(widget.appState.selectedSection),
            onDestinationSelected: (index) =>
                widget.appState.selectSection(AppSection.values[index]),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_rounded), label: '首頁'),
              NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: '紀錄'),
              NavigationDestination(icon: Icon(Icons.flag_rounded), label: '目標'),
              NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: '回顧'),
              NavigationDestination(icon: Icon(Icons.tune_rounded), label: '設定'),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildFab() {
    switch (widget.appState.selectedSection) {
      case AppSection.entries:
        return FloatingActionButton.extended(
          onPressed: _openEntryEditor,
          icon: const Icon(Icons.add_rounded),
          label: const Text('新增紀錄'),
        );
      case AppSection.goals:
        return FloatingActionButton.extended(
          onPressed: _openGoalEditor,
          icon: const Icon(Icons.flag_rounded),
          label: const Text('新增目標'),
        );
      default:
        return null;
    }
  }

  Widget _buildBody() {
    switch (widget.appState.selectedSection) {
      case AppSection.home:
        return MobileHomeScreen(appState: widget.appState);
      case AppSection.entries:
        return MobileEntriesScreen(
          appState: widget.appState,
          onEditEntry: _openEntryEditor,
        );
      case AppSection.goals:
        return MobileGoalsScreen(appState: widget.appState);
      case AppSection.review:
        return MobileReviewScreen(appState: widget.appState);
      case AppSection.settings:
        return MobileSettingsScreen(appState: widget.appState);
    }
  }
}
