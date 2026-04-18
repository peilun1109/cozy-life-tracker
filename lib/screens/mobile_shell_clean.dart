import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import 'mobile_entries_screen_clean.dart';
import 'mobile_goals_screen_clean.dart';
import 'mobile_home_screen_clean.dart';
import 'mobile_review_screen_clean.dart';
import 'mobile_settings_screen_clean.dart';

class MobileShellClean extends StatefulWidget {
  const MobileShellClean({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<MobileShellClean> createState() => _MobileShellCleanState();
}

class _MobileShellCleanState extends State<MobileShellClean> {
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
        title: const Text('記錄提醒'),
        content: const Text('現在是留下一點今天心情的時間，要直接新增一篇生活紀錄嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍後再說'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.appState.selectSection(AppSection.entries);
              _openEntryEditor();
            },
            child: const Text('立刻記錄'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEntryEditor([Entry? entry]) async {
    await showEntryEditorSheetClean(
      context,
      appState: widget.appState,
      existing: entry,
    );
  }

  Future<void> _openGoalEditor() async {
    await showGoalEditorSheetClean(
      context,
      appState: widget.appState,
    );
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
            selectedIndex:
                AppSection.values.indexOf(widget.appState.selectedSection),
            onDestinationSelected: (index) =>
                widget.appState.selectSection(AppSection.values[index]),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: '首頁',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_rounded),
                label: '紀錄',
              ),
              NavigationDestination(
                icon: Icon(Icons.flag_rounded),
                label: '目標',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_rounded),
                label: '回顧',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                label: '設定',
              ),
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
        return MobileHomeScreenClean(appState: widget.appState);
      case AppSection.entries:
        return MobileEntriesScreenClean(
          appState: widget.appState,
          onEditEntry: _openEntryEditor,
        );
      case AppSection.goals:
        return MobileGoalsScreenClean(
          appState: widget.appState,
          onCreate: _openGoalEditor,
        );
      case AppSection.review:
        return MobileReviewScreenClean(appState: widget.appState);
      case AppSection.settings:
        return MobileSettingsScreenClean(appState: widget.appState);
    }
  }
}
