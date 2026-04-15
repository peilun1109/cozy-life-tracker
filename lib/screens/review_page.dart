import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/adaptive_entry_image.dart';
import '../widgets/cute_card.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthEntries = appState.entries.where((entry) {
      return entry.createdAt.year == now.year &&
          entry.createdAt.month == now.month;
    }).toList();
    final monthPhotos =
        monthEntries.expand((entry) => entry.imagePaths).take(8).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('回顧小宇宙', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('把生活感與成長感都留在同一頁，溫柔地回頭看看自己。'),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, int>>(
            future: appState.monthMoodStats(now),
            builder: (context, moodSnapshot) {
              return FutureBuilder<List<DateTime>>(
                future: appState.monthActiveDates(now),
                builder: (context, activeSnapshot) {
                  final moodStats = moodSnapshot.data ?? {};
                  final activeDates = activeSnapshot.data ?? [];
                  final monthGoalSummary = appState.goals
                      .map((goal) => '${goal.title} ${goal.progress}%')
                      .toList();

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ReviewCard(
                              title: '月回顧',
                              color: AppTheme.blush,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _StatLine('本月紀錄數量', '${monthEntries.length} 篇'),
                                  _StatLine(
                                    '本月活躍日期',
                                    activeDates.isEmpty
                                        ? '還沒有資料'
                                        : activeDates
                                            .map((date) => DateFormat('d').format(date))
                                            .join('、'),
                                  ),
                                  _StatLine(
                                    '本月心情統計',
                                    moodStats.isEmpty
                                        ? '還沒有心情資料'
                                        : moodStats.entries
                                            .map((entry) => '${entry.key} ${entry.value}')
                                            .join(' ・ '),
                                  ),
                                  _StatLine(
                                    '本月目標進度摘要',
                                    monthGoalSummary.isEmpty
                                        ? '還沒有目標'
                                        : monthGoalSummary.join(' / '),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ReviewCard(
                              title: '本月照片牆',
                              color: AppTheme.sky,
                              child: monthPhotos.isEmpty
                                  ? const Text('本月還沒有照片，等你把小片段放進來。')
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: monthPhotos
                                          .map(
                                            (path) => ClipRRect(
                                              borderRadius: BorderRadius.circular(18),
                                              child: buildAdaptiveEntryImage(
                                                imagePath: path,
                                                width: 108,
                                                height: 108,
                                                fit: BoxFit.cover,
                                                errorChild: Container(
                                                  width: 108,
                                                  height: 108,
                                                  alignment: Alignment.center,
                                                  color: const Color(0xFFF5EDE7),
                                                  child: const Text('照片'),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ReviewCard(
                        title: '年回顧',
                        color: AppTheme.mint,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MiniSummary(
                              title: '本年紀錄總數',
                              value: '${appState.yearlyEntryCount}',
                            ),
                            _MiniSummary(
                              title: '本年目標數量',
                              value: '${appState.yearlyGoalCount}',
                            ),
                            _MiniSummary(
                              title: '今年最常出現的心情',
                              value: moodStats.entries.isEmpty
                                  ? '待累積'
                                  : moodStats.entries.first.key,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.child,
    required this.color,
  });

  final String title;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      backgroundColor: color.withValues(alpha: 0.58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  const _MiniSummary({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
