import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/entry.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class WebHomeV2 extends StatelessWidget {
  const WebHomeV2({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(now);
    final focusGoals = appState.focusGoals();
    final countdownGoals = appState.countdownGoals();
    final recentEntries = appState.recentEntries();
    final upcomingWeek = List.generate(
      7,
      (index) => now.add(Duration(days: index)),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(
            dateText: dateText,
            greetingText: _greetingText(),
            totalEntries: appState.entries.length,
            activeGoals: appState.goals.length,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _SectionCard(
                      title: '生活出席小日曆',
                      subtitle: '像 GitHub 的紀錄牆，但換成比較柔軟的生活節奏。',
                      color: const Color(0xFFFFF6D9),
                      child: _EntryHeatmap(entries: appState.entries),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: '未來一週的日常安排',
                      subtitle: '先看每天的小提醒，不用被正式行事曆壓著走。',
                      color: AppTheme.sky,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: upcomingWeek
                            .map(
                              (date) => _UpcomingDayCard(
                                date: date,
                                dueGoals: appState.goalsDueOn(date),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _SectionCard(
                      title: '目前最想照顧的目標',
                      subtitle: '把現在最重要的 3 個方向放在眼前就夠了。',
                      color: AppTheme.peach,
                      child: focusGoals.isEmpty
                          ? const _EmptyText('還沒有目標，先放一個最近想慢慢完成的小願望吧。')
                          : Column(
                              children: focusGoals
                                  .map((goal) => _GoalSummaryTile(goal: goal))
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: '正在倒數的提醒',
                      subtitle: '快到期的事情放前面，但語氣還是要可愛一點。',
                      color: AppTheme.mint,
                      child: countdownGoals.isEmpty
                          ? const _EmptyText('目前沒有倒數中的事件或目標。')
                          : Column(
                              children: countdownGoals
                                  .map((goal) => _CountdownTile(goal: goal))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: '最近的生活紀錄',
            subtitle: '看看自己這幾天留下了哪些片段。',
            color: const Color(0xFFFFEEF3),
            child: recentEntries.isEmpty
                ? const _EmptyText('還沒有任何紀錄，今天就可以先寫一篇。')
                : Row(
                    children: recentEntries
                        .map(
                          (entry) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: entry == recentEntries.last ? 0 : 12,
                              ),
                              child: _RecentEntryCard(entry: entry),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return '早安，今天也留一點位置給自己的感受。';
    }
    if (hour < 18) {
      return '午安，把今天慢慢過成你喜歡的樣子。';
    }
    return '晚上好，記得把今天的小片段收進生活手帳裡。';
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.dateText,
    required this.greetingText,
    required this.totalEntries,
    required this.activeGoals,
  });

  final String dateText;
  final String greetingText;
  final int totalEntries;
  final int activeGoals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEEF3), Color(0xFFE9F5FF), Color(0xFFFFF5DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  '陪你記住日常，也陪你慢慢往前',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                      ),
                ),
                const SizedBox(height: 12),
                Text(greetingText, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroStat(
                      label: '累積紀錄',
                      value: '$totalEntries',
                      color: const Color(0xFFFFF9EC),
                    ),
                    _HeroStat(
                      label: '進行中目標',
                      value: '$activeGoals',
                      color: const Color(0xFFEFF9F2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1.1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 30,
                      right: 34,
                      child: _Bubble(
                        color: const Color(0xFFFFD8E6),
                        size: 64,
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 34,
                      child: _Bubble(
                        color: const Color(0xFFD7F3E3),
                        size: 78,
                      ),
                    ),
                    Positioned(
                      top: 58,
                      left: 40,
                      child: Text(
                        '☁️',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Positioned(
                      bottom: 44,
                      right: 42,
                      child: Text(
                        '🍓',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Text(
                      'Life\nJournal',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 30,
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      backgroundColor: color.withValues(alpha: 0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

class _GoalSummaryTile extends StatelessWidget {
  const _GoalSummaryTile({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Text('${goal.progress}%'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: goal.progress / 100,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            goal.daysLeft >= 0 ? '還有 ${goal.daysLeft} 天' : '已超過 ${goal.daysLeft.abs()} 天',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CountdownTile extends StatelessWidget {
  const _CountdownTile({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE7F0),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${goal.daysLeft}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '截止日 ${DateFormat('M/d').format(goal.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
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
    required this.dueGoals,
  });

  final DateTime date;
  final List<Goal> dueGoals;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: CuteCard(
        backgroundColor: Colors.white.withValues(alpha: 0.84),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('M/d E', 'zh_TW').format(date),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (dueGoals.isEmpty)
              Text('留白也很好。', style: Theme.of(context).textTheme.bodyMedium)
            else
              ...dueGoals.take(3).map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• ${goal.title}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _RecentEntryCard extends StatelessWidget {
  const _RecentEntryCard({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      backgroundColor: Colors.white.withValues(alpha: 0.84),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.mood ?? '🙂', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('M/d HH:mm').format(entry.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 36),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: monthLabels
                          .map(
                            (label) => SizedBox(
                              width: 18,
                              child: Text(
                                label,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
            ),
          ],
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
                  Color(0xFFF7E6EC),
                  Color(0xFFF9C7D8),
                  Color(0xFFF29FBC),
                  Color(0xFFE979A2),
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
          return Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: date == null ? Colors.transparent : _heatColor(count),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Color _heatColor(int count) {
    if (count <= 0) {
      return const Color(0xFFF7E6EC);
    }
    if (count == 1) {
      return const Color(0xFFF9C7D8);
    }
    if (count == 2) {
      return const Color(0xFFF29FBC);
    }
    return const Color(0xFFE979A2);
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
