import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';
import 'mobile_entries_screen_v2.dart';
import 'mobile_goals_screen_clean.dart';
import 'mobile_review_screen_clean.dart';
import 'mobile_settings_screen_clean.dart';
import 'web_home_v6.dart';

class WebShellV7 extends StatefulWidget {
  const WebShellV7({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WebShellV7> createState() => _WebShellV7State();
}

class _WebShellV7State extends State<WebShellV7> {
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
        content: const Text('今天也值得留下片段。現在就打開新增紀錄，把心情和小事收進拾光機。'),
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
                colors: [Color(0xFFFFFCF8), Color(0xFFF8F3EE), Color(0xFFF6F8FB)],
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
                      padding: const EdgeInsets.fromLTRB(22, 22, 28, 22),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1320),
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
        return WebHomeV6(appState: widget.appState);
      case AppSection.entries:
        return _PageScaffold(
          title: '生活紀錄',
          subtitle: '把今天的心情、文字與照片慢慢收進來，之後回頭看會很有感。',
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
          subtitle: '把想靠近的事情放在眼前，用溫柔一點的節奏慢慢前進。',
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
          subtitle: '把本月留下的光和片段攤開看看，整理生活，也整理自己。',
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
      (section: AppSection.home, icon: Icons.home_rounded, label: '首頁', hint: '今日總覽'),
      (section: AppSection.entries, icon: Icons.menu_book_rounded, label: '生活紀錄', hint: '文字與照片'),
      (section: AppSection.goals, icon: Icons.flag_rounded, label: '目標', hint: '慢慢靠近'),
      (section: AppSection.review, icon: Icons.auto_awesome_rounded, label: '回顧', hint: '月與年'),
      (section: AppSection.settings, icon: Icons.tune_rounded, label: '設定', hint: '提醒與偏好'),
    ];

    return Container(
      width: 292,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        border: const Border(
          right: BorderSide(color: AppTheme.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3F1), Color(0xFFFBF6EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '拾光機',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cocoa,
                    fontFamily: 'Georgia',
                    fontFamilyFallback: ['Times New Roman', 'Noto Serif TC', 'serif'],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '把日常、目標和回頭會想翻看的片段，慢慢收進自己的時間裡。',
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
            backgroundColor: const Color(0xFFFFF8F1),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日小提醒', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('先留下短短一句話也很好。那些看似普通的日子，回頭看都會發光。'),
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
      color: selected ? const Color(0xFFF9EBEE) : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFFF7F8) : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? const Color(0xFFE4C8D1) : AppTheme.line,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppTheme.accent : AppTheme.body,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppTheme.cocoa,
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
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
        const SizedBox(height: 22),
        Expanded(child: child),
      ],
    );
  }
}
