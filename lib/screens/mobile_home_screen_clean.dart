import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class MobileHomeScreenClean extends StatelessWidget {
  const MobileHomeScreenClean({
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
      physics: const BouncingScrollPhysics(),
      children: [
        CuteCard(
          backgroundColor: const Color(0xFFFFF1F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                '今天也一起好好生活',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                _greetingText(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              const Text('🍓', style: TextStyle(fontSize: 34)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '目前最想照顧的目標',
          subtitle: '最多顯示 3 個，先把注意力留給現在最重要的方向。',
          color: AppTheme.peach,
          child: focusGoals.isEmpty
              ? const Text('還沒有設定目標，先放一個最近想慢慢完成的願望吧。')
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
                          subtitle: Text(
                            goal.daysLeft >= 0
                                ? '還有 ${goal.daysLeft} 天'
                                : '已超過 ${goal.daysLeft.abs()} 天',
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '倒數中的小提醒',
          subtitle: '把快到期的目標放在前面，提醒自己溫柔但不要忘記。',
          color: AppTheme.mint,
          child: appState.countdownGoals().isEmpty
              ? const Text('目前沒有進行中的倒數目標。')
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
                                    Text(
                                      goal.title,
                                      style: Theme.of(context).textTheme.titleMedium,
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
        const SizedBox(height: 16),
        _SectionCard(
          title: '未來一週的生活節奏',
          subtitle: '每一天都用小卡片看，不做成表格式的壓力清單。',
          color: AppTheme.sky,
          child: Column(
            children: List.generate(7, (index) {
              final date = DateTime.now().add(Duration(days: index));
              final dueGoals = appState.goalsDueOn(date);
              final line = dueGoals.isEmpty
                  ? '沒有硬性安排，保留一點空白也很好。'
                  : dueGoals.map((goal) => '目標截止：${goal.title}').join('、');
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE9F4FF),
                  child: Text(DateFormat('d').format(date)),
                ),
                title: Text(DateFormat('M/d E', 'zh_TW').format(date)),
                subtitle: Text(index == 0 ? '今天先照顧好自己。' : line),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '最近的生活紀錄',
          subtitle: '看看這幾天留下來的片段。',
          color: const Color(0xFFFFF6D9),
          child: recentEntries.isEmpty
              ? const Text('還沒有任何紀錄，第一篇就從今天的心情開始。')
              : Column(
                  children: recentEntries
                      .map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            entry.mood ?? '🙂',
                            style: const TextStyle(fontSize: 22),
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
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return '早安，今天也留一點位置給自己的感受。';
    }
    if (hour < 18) {
      return '午安，慢慢把今天過成你喜歡的樣子。';
    }
    return '晚上好，記得把今天的小片段收進手帳裡。';
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
