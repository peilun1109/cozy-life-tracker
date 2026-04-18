import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import '../widgets/cute_card.dart';
import 'mobile_entries_screen_clean.dart';
import 'mobile_goals_screen_clean.dart';
import 'mobile_home_screen_clean.dart';
import 'mobile_review_screen_clean.dart';
import 'mobile_settings_screen_clean.dart';

class WebShellV2 extends StatefulWidget {
  const WebShellV2({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WebShellV2> createState() => _WebShellV2State();
}

class _WebShellV2State extends State<WebShellV2> {
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFCFA), Color(0xFFF6FBFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                      child: _ContentFrame(
                        child: _buildBody(),
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
        return MobileHomeScreenClean(appState: widget.appState);
      case AppSection.entries:
        return _PageScaffold(
          title: '生活紀錄',
          subtitle: '把今天的心情、文字和照片收進自己的小空間。',
          actionLabel: '新增紀錄',
          onAction: _openEntryEditor,
          child: MobileEntriesScreenClean(
            appState: widget.appState,
            onEditEntry: _openEntryEditor,
          ),
        );
      case AppSection.goals:
        return _PageScaffold(
          title: '目標',
          subtitle: '不是工作清單，而是想慢慢照顧好的生活方向。',
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
          subtitle: '用比較溫柔的方式，看見最近的生活軌跡。',
          child: MobileReviewScreenClean(appState: widget.appState),
        );
      case AppSection.settings:
        return _PageScaffold(
          title: '設定',
          subtitle: '先保留最基本的提醒設定，讓每天的記錄更容易養成。',
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
    final items = <({AppSection section, IconData icon, String label})>[
      (section: AppSection.home, icon: Icons.home_rounded, label: 'Home'),
      (section: AppSection.entries, icon: Icons.menu_book_rounded, label: 'Entries'),
      (section: AppSection.goals, icon: Icons.flag_rounded, label: 'Goals'),
      (section: AppSection.review, icon: Icons.auto_awesome_rounded, label: 'Review'),
      (section: AppSection.settings, icon: Icons.tune_rounded, label: 'Settings'),
    ];

    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        border: Border(
          right: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '暖暖生活手帳',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '個人的生活紀錄與目標追蹤空間',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          for (final item in items) ...[
            _SidebarButton(
              icon: item.icon,
              label: item.label,
              selected: currentSection == item.section,
              onTap: () => onSelect(item.section),
            ),
            const SizedBox(height: 10),
          ],
          const Spacer(),
          CuteCard(
            backgroundColor: const Color(0xFFFFF1D8),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小提醒',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('這版先以 Web 驗證方向為主，之後再決定要不要同步做手機版。'),
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
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFE7EE) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentFrame extends StatelessWidget {
  const _ContentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
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
