// ignore_for_file: unnecessary_non_null_assertion

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/entry.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class WebHomeV3 extends StatefulWidget {
  const WebHomeV3({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WebHomeV3> createState() => _WebHomeV3State();
}

class _WebHomeV3State extends State<WebHomeV3> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final focusGoals = widget.appState.focusGoals();
    final countdownGoals = widget.appState.countdownGoals(limit: 3);
    final recentEntries = widget.appState.recentEntries();
    final upcomingWeek =
        List.generate(7, (index) => DateTime(now.year, now.month, now.day + index));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            dateText: DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(now),
            greetingText: _greetingText(),
            totalEntries: widget.appState.entries.length,
            activeGoals: widget.appState.goals.length,
            onNewEntry: () => widget.appState.selectSection(AppSection.entries),
            onReview: () => widget.appState.selectSection(AppSection.review),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    _SectionCard(
                      title: '生活出席小日曆',
                      subtitle: '保留 GitHub 風格的節奏感，但把色調換成更溫柔的生活版本。',
                      accentColor: AppTheme.blush,
                      child: _EntryHeatmap(entries: widget.appState.entries),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: '未來一週安排',
                      subtitle: '一週維持一排，直接在每一天的小卡片裡新增生活安排。',
                      accentColor: AppTheme.sky,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 10.0;
                          final cardWidth =
                              ((constraints.maxWidth - gap * 6) / 7)
                                  .clamp(92.0, 180.0);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: upcomingWeek
                                .map(
                                  (date) => Padding(
                                    padding: EdgeInsets.only(
                                      right: date == upcomingWeek.last ? 0 : gap,
                                    ),
                                    child: SizedBox(
                                      width: cardWidth,
                                      child: _UpcomingDayCard(
                                        date: date,
                                        items: widget.appState.weeklyPlansOn(date),
                                        dueGoals: widget.appState.goalsDueOn(date),
                                        onAdd: () => _openWeeklyPlanEditor(date),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _SectionCard(
                      title: '本週焦點',
                      subtitle: '首頁先只留最重要的幾件事，其他內容交給各自頁面。',
                      accentColor: AppTheme.peach,
                      child: Column(
                        children: [
                          _MiniStatCard(
                            title: '優先目標',
                            value: '${focusGoals.length}',
                            note: focusGoals.isEmpty
                                ? '還沒有設定'
                                : focusGoals.first.title,
                          ),
                          const SizedBox(height: 12),
                          _MiniStatCard(
                            title: '最近倒數',
                            value: '${countdownGoals.length}',
                            note: countdownGoals.isEmpty
                                ? '沒有即將到期'
                                : countdownGoals.first.title,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: '最近的生活紀錄',
                      subtitle: '保留少量摘要就好，避免首頁太擠。',
                      accentColor: AppTheme.mint,
                      child: recentEntries.isEmpty
                          ? const _EmptyText('還沒有任何紀錄，今天可以先寫下一篇。')
                          : Column(
                              children: recentEntries
                                  .map((entry) => _RecentEntryTile(entry: entry))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openWeeklyPlanEditor(DateTime date) async {
    final existing = widget.appState.weeklyPlansOn(date);
    final updated = await showDialog<List<String>>(
      context: context,
      builder: (context) => _WeeklyPlanEditorDialog(
        date: date,
        initialItems: existing,
      ),
    );

    if (updated != null) {
      await widget.appState.saveWeeklyPlansOn(date, updated);
    }
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return '早安，今天也留一點位置給自己的感受。';
    }
    if (hour < 18) {
      return '午安，把今天慢慢過成你喜歡的樣子。';
    }
    return '晚上好，記得把今天的小片段收進拾光機裡。';
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.dateText,
    required this.greetingText,
    required this.totalEntries,
    required this.activeGoals,
    required this.onNewEntry,
    required this.onReview,
  });

  final String dateText;
  final String greetingText;
  final int totalEntries;
  final int activeGoals;
  final VoidCallback onNewEntry;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF2DDE5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  '把日常過成會想回頭翻看的樣子',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                      ),
                ),
                const SizedBox(height: 10),
                Text(greetingText, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: onNewEntry,
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('新增今天紀錄'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('查看本月回顧'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _HeroInfoCard(
                  label: '累積紀錄',
                  value: '$totalEntries',
                  icon: Icons.favorite_rounded,
                ),
                const SizedBox(height: 12),
                _HeroInfoCard(
                  label: '進行中目標',
                  value: '$activeGoals',
                  icon: Icons.flag_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroInfoCard extends StatelessWidget {
  const _HeroInfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4EC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.cocoa),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                Text(value, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      backgroundColor: Colors.white.withValues(alpha: 0.88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.note,
  });

  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  const _RecentEntryTile({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.mood ?? '🙂', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('M/d HH:mm').format(entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingDayCard extends StatelessWidget {
  const _UpcomingDayCard({
    required this.date,
    required this.items,
    required this.dueGoals,
    required this.onAdd,
  });

  final DateTime date;
  final List<String> items;
  final List<Goal> dueGoals;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final lines = [
      ...items,
      ...dueGoals.map((goal) => '目標截止：${goal.title}'),
    ];

    return SizedBox(
      width: 164,
      child: CuteCard(
        backgroundColor: const Color(0xFFFFF8FB),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('M/d E', 'zh_TW').format(date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (lines.isEmpty)
              Text(
                '先留白，或加一件想做的小事。',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...lines.take(3).map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $line',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
            if (lines.length > 3)
              Text(
                '+${lines.length - 3} 更多',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(items.isEmpty ? '新增安排' : '編輯'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryHeatmap extends StatelessWidget {
  const _EntryHeatmap({required this.entries});

  final List<Entry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <DateTime, int>{};
    for (final entry in entries) {
      final key = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }

    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = end.subtract(const Duration(days: 139));
    final alignedStart = start.subtract(Duration(days: start.weekday % 7));
    final totalDays = end.difference(alignedStart).inDays + 1;
    final columns = <List<DateTime>>[];

    for (var offset = 0; offset < totalDays; offset += 7) {
      final week = <DateTime>[];
      for (var day = 0; day < 7; day++) {
        final date = alignedStart.add(Duration(days: offset + day));
        if (!date.isAfter(end)) {
          week.add(date);
        }
      }
      columns.add(week);
    }

    final monthLabels = <String>[];
    int? previousMonth;
    for (final week in columns) {
      final firstDate = week.first;
      if (previousMonth != firstDate.month) {
        monthLabels.add(DateFormat('M月').format(firstDate));
        previousMonth = firstDate.month;
      } else {
        monthLabels.add('');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: monthLabels
                    .map(
                      (label) => SizedBox(
                        width: 18,
                        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns
                    .map((week) => _HeatmapWeek(week: week, counts: counts))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('最近 20 週的生活活躍度', style: Theme.of(context).textTheme.bodyMedium),
            Row(
              children: [
                Text('少', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                ...const [
                  Color(0xFFF8EEF2),
                  Color(0xFFF4C9D8),
                  Color(0xFFE897B0),
                ].map(
                  (color) => Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('多', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatmapWeek extends StatelessWidget {
  const _HeatmapWeek({
    required this.week,
    required this.counts,
  });

  final List<DateTime> week;
  final Map<DateTime, int> counts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        children: List.generate(7, (index) {
          final date = index < week.length ? week[index] : null;
          final count = date == null ? 0 : (counts[date] ?? 0);
          final label = date == null
              ? ''
              : '${DateFormat('M/d').format(date!)}：$count 篇紀錄';

          return Tooltip(
            message: label,
            child: Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: date == null ? Colors.transparent : _heatColor(count),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _heatColor(int count) {
    if (count <= 0) {
      return const Color(0xFFF8EEF2);
    }
    if (count <= 2) {
      return const Color(0xFFF4C9D8);
    }
    return const Color(0xFFE897B0);
  }
}

class _WeeklyPlanEditorDialog extends StatefulWidget {
  const _WeeklyPlanEditorDialog({
    required this.date,
    required this.initialItems,
  });

  final DateTime date;
  final List<String> initialItems;

  @override
  State<_WeeklyPlanEditorDialog> createState() => _WeeklyPlanEditorDialogState();
}

class _WeeklyPlanEditorDialogState extends State<_WeeklyPlanEditorDialog> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialItems.isEmpty ? [''] : widget.initialItems;
    _controllers = seed.map((item) => TextEditingController(text: item)).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('編輯 ${DateFormat('M/d E', 'zh_TW').format(widget.date)}'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < _controllers.length; index++) ...[
                TextField(
                  controller: _controllers[index],
                  decoration: InputDecoration(
                    labelText: '安排 ${index + 1}',
                    hintText: '像是：晚上散步 20 分鐘',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _controllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('再加一項'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _controllers
                  .map((controller) => controller.text.trim())
                  .where((item) => item.isNotEmpty)
                  .toList(),
            );
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyLarge);
  }
}
