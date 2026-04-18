import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final focusGoals = appState.focusGoals();
    final recentEntries = appState.recentEntries();
    final dateText = DateFormat('M 月 d 日 EEEE', 'zh_TW').format(DateTime.now());

    return ListView(
      children: [
        CuteCard(
          backgroundColor: const Color(0xFFFFF1F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('今天想留下什麼樣的心情？', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(_greetingText(), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              const Text('☁️🌷', style: TextStyle(fontSize: 34)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '正在陪伴你的目標',
          subtitle: '挑 3 個最重要的方向就好',
          color: AppTheme.peach,
          child: focusGoals.isEmpty
              ? const Text('還沒有目標，先種下一顆小種子吧。')
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
                          subtitle: Text('還有 ${goal.daysLeft} 天'),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '倒數中的重要時刻',
          subtitle: '把期待感放在今天也看得到的地方',
          color: AppTheme.mint,
          child: appState.countdownGoals().isEmpty
              ? const Text('先新增一個有截止日的目標，這裡就會出現倒數。')
              : Column(
                  children: appState.countdownGoals()
                      .map(
                        (goal) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.76),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE7F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${goal.daysLeft}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.cocoa,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text('截止日 ${DateFormat('M/d').format(goal.endDate)}'),
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
        const SizedBox(height: 16),
        _SectionCard(
          title: '未來一週的小安排',
          subtitle: '輕輕看一下，不做成壓力很大的行事曆',
          color: AppTheme.sky,
          child: Column(
            children: List.generate(7, (index) {
              final date = DateTime.now().add(Duration(days: index));
              final dueGoals = appState.goalsDueOn(date);
              final line = dueGoals.isEmpty
                  ? '留白也很好，記得照顧自己。'
                  : dueGoals.map((goal) => '目標截止：${goal.title}').join('、');
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE9F4FF),
                  child: Text(DateFormat('d').format(date)),
                ),
                title: Text(DateFormat('M/d E', 'zh_TW').format(date)),
                subtitle: Text(index == 0 ? '寫下一句今天的心情' : line),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '最近的生活紀錄',
          subtitle: '快速回頭看看自己最近的日常',
          color: const Color(0xFFFFF6D9),
          child: recentEntries.isEmpty
              ? const Text('今天還沒有留下紀錄，晚點來補上也很好。')
              : Column(
                  children: recentEntries
                      .map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(entry.mood ?? '📝', style: const TextStyle(fontSize: 22)),
                          title: Text(
                            entry.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(DateFormat('M/d HH:mm').format(entry.createdAt)),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return '早安，今天也慢慢把日子過成喜歡的樣子吧。';
    }
    if (hour < 18) {
      return '午安，留一點時間給自己，記住今天的小亮點。';
    }
    return '晚安前，來替今天留下一小段溫柔紀錄吧。';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      backgroundColor: color.withValues(alpha: 0.62),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
