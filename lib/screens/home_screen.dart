import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(DateTime.now());
    final focusGoals = appState.focusGoals();
    final countdownGoals = appState.countdownGoals();
    final recentEntries = appState.recentEntries();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CuteCard(
            backgroundColor: const Color(0xFFFFF1F5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      Text(
                        '今天想留下什麼樣的心情？',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appState.greetingText(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Text('☁️🌼', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _SectionCard(
                      title: '目前的小目標',
                      subtitle: '先看 3 個最想溫柔推進的方向',
                      color: AppTheme.peach,
                      child: focusGoals.isEmpty
                          ? const _EmptyText('還沒有目標，先許下一個小小期待吧。')
                          : Column(
                              children: focusGoals
                                  .map(
                                    (goal) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.mint,
                                        child: Text('${goal.progress}%'),
                                      ),
                                      title: Text(goal.title),
                                      subtitle:
                                          Text('還有 ${goal.daysLeft} 天，進度 ${goal.progress}%'),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: '最近的生活紀錄',
                      subtitle: '最新 3 筆，回頭看看自己的日常',
                      color: AppTheme.sky,
                      child: recentEntries.isEmpty
                          ? const _EmptyText('今天還沒有留下紀錄，晚點來補上也很好。')
                          : Column(
                              children: recentEntries
                                  .map(
                                    (entry) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Text(
                                        entry.mood ?? '📝',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      title: Text(
                                        entry.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        DateFormat('M/d HH:mm').format(entry.createdAt),
                                      ),
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
                flex: 4,
                child: _SectionCard(
                  title: '倒數中的重要時刻',
                  subtitle: '把期待感留在身邊',
                  color: AppTheme.mint,
                  child: countdownGoals.isEmpty
                      ? const _EmptyText('先新增一個有截止日的目標，這裡就會出現倒數。')
                      : Column(
                          children: countdownGoals
                              .map(
                                (goal) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFE7F0),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${goal.daysLeft}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: AppTheme.cocoa,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              goal.title,
                                              style:
                                                  Theme.of(context).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '截止日 ${DateFormat('M/d').format(goal.endDate)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: '未來一週的小安排',
            subtitle: '每天一張卡片，不做成正式行事曆',
            color: const Color(0xFFFFF6D9),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 36) / 4;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(7, (index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final dueGoals = appState.goalsDueOn(date);
                    final tasks = <String>[
                      if (index == 0) '寫下一句今天的心情',
                      ...dueGoals.map((goal) => '目標截止：${goal.title}'),
                    ];

                    if (tasks.isEmpty) {
                      tasks.add('留白也很好，記得照顧自己。');
                    }

                    return SizedBox(
                      width: cardWidth.clamp(180.0, 260.0).toDouble(),
                      child: CuteCard(
                        backgroundColor: Colors.white.withOpacity(0.82),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('M/d E', 'zh_TW').format(date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            for (final task in tasks)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('• $task'),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
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
    required this.color,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      backgroundColor: color.withOpacity(0.65),
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

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyLarge);
  }
}
