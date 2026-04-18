import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import '../widgets/cute_card.dart';
import 'mobile_entries_screen_v2.dart';
import 'mobile_goals_screen_clean.dart';
import 'mobile_review_screen_clean.dart';
import 'mobile_settings_screen_clean.dart';
import 'web_home_v3.dart';

class WebShellV6 extends StatefulWidget {
  const WebShellV6({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WebShellV6> createState() => _WebShellV6State();
}

class _WebShellV6State extends State<WebShellV6> {
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
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記錄提醒'),
        content: const Text('今天也收集一點生活片段吧，現在就打開新增紀錄，把心情和小事寫下來。'),
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
            child: const Text('新增紀錄'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEntryEditor([Entry? entry]) async {
    await showEntryEditorSheetV2(
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFCFA), Color(0xFFF8FAFD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  _Sidebar(
                    currentSection: widget.appState.selectedSection,
                    onSelect: widget.appState.selectSection,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 24, 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: _buildBody(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (widget.appState.selectedSection) {
      case AppSection.home:
        return WebHomeV3(appState: widget.appState);
      case AppSection.entries:
        return _PageScaffold(
          title: '生活紀錄',
          subtitle: '把今天的心情、照片和片段慢慢收進來，之後回頭看會很有感。',
          actionLabel: '新增紀錄',
          onAction: _openEntryEditor,
          child: MobileEntriesScreenV2(
            appState: widget.appState,
            onEditEntry: _openEntryEditor,
          ),
        );
      case AppSection.goals:
        return _PageScaffold(
          title: '目標',
          subtitle: '把想完成的事放在眼前，用溫柔一點的節奏慢慢靠近。',
          actionLabel: '新增目標',
          onAction: _openGoalEditor,
          child: MobileGoalsScreenClean(
            appState: widget.appState,
            onCreate: _openGoalEditor,
          ),
        );
      case AppSection.review:
        return _PageScaffold(
          title: '回顧',
          subtitle: '把本月累積下來的生活痕跡攤開看看，整理心情也整理成長。',
          child: MobileReviewScreenClean(appState: widget.appState),
        );
      case AppSection.settings:
        return _PageScaffold(
          title: '設定',
          subtitle: '調整提醒時間與使用習慣，讓拾光機更貼近你的生活節奏。',
          child: MobileSettingsScreenClean(appState: widget.appState),
        );
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.currentSection,
    required this.onSelect,
  });

  final AppSection currentSection;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <({AppSection section, IconData icon, String label, String hint})>[
      (section: AppSection.home, icon: Icons.home_rounded, label: 'Home', hint: 'Overview'),
      (section: AppSection.entries, icon: Icons.menu_book_rounded, label: 'Entries', hint: '生活紀錄'),
      (section: AppSection.goals, icon: Icons.flag_rounded, label: 'Goals', hint: '目標追蹤'),
      (section: AppSection.review, icon: Icons.auto_awesome_rounded, label: 'Review', hint: '月與年回顧'),
      (section: AppSection.settings, icon: Icons.tune_rounded, label: 'Settings', hint: '提醒與偏好'),
    ];

    return Container(
      width: 276,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF1F5), Color(0xFFFAF7FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '拾光機',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '把生活裡的小片段、想完成的目標和回顧時刻，慢慢收進自己的節奏裡。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final item in items) ...[
            _SidebarButton(
              icon: item.icon,
              label: item.label,
              hint: item.hint,
              selected: currentSection == item.section,
              onTap: () => onSelect(item.section),
            ),
            const SizedBox(height: 10),
          ],
          const Spacer(),
          CuteCard(
            backgroundColor: const Color(0xFFFFF4E6),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日小提醒', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('寫一點點也很好，先留下一句話，回頭看就會變成今天的光。'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFE9F0) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: selected ? 0.9 : 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(hint, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(child: child),
      ],
    );
  }
}
