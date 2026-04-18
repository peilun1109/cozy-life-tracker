import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../widgets/adaptive_entry_image.dart';
import '../widgets/cute_card.dart';

class MobileReviewScreen extends StatefulWidget {
  const MobileReviewScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<MobileReviewScreen> createState() => _MobileReviewScreenState();
}

class _MobileReviewScreenState extends State<MobileReviewScreen> {
  late final Future<Map<String, int>> _moodStatsFuture;
  late final Future<List<DateTime>> _activeDatesFuture;

  @override
  void initState() {
    super.initState();
    final month = DateTime.now();
    _moodStatsFuture = widget.appState.monthMoodStats(month);
    _activeDatesFuture = widget.appState.monthActiveDates(month);
  }

  @override
  Widget build(BuildContext context) {
    final monthEntries = widget.appState.entries.where((entry) {
      final now = DateTime.now();
      return entry.createdAt.year == now.year && entry.createdAt.month == now.month;
    }).toList();
    final monthPhotos = monthEntries
        .expand((entry) => entry.imagePaths)
        .take(8)
        .toList();
    final monthGoals = widget.appState.goals;
    final avgProgress = monthGoals.isEmpty
        ? 0
        : (monthGoals.map((goal) => goal.progress).reduce((a, b) => a + b) /
                monthGoals.length)
            .round();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        CuteCard(
          backgroundColor: const Color(0xFFFFF0E3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('M 月').format(DateTime.now())}回顧',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '把這個月的生活碎片和前進的痕跡放在一起，看起來會很溫柔。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: '本月紀錄',
                      value: '${monthEntries.length}',
                      hint: '篇',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: '平均進度',
                      value: '$avgProgress',
                      hint: '%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<Map<String, int>>(
          future: _moodStatsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? const <String, int>{};
            return CuteCard(
              backgroundColor: const Color(0xFFE9F7FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本月心情統計',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (stats.isEmpty)
                    Text(
                      '這個月還沒有標記心情，之後記錄時可以順手選一下。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: stats.entries
                          .map(
                            (entry) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text('${entry.key} ${entry.value} 次'),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<DateTime>>(
          future: _activeDatesFuture,
          builder: (context, snapshot) {
            final activeDates = snapshot.data ?? const <DateTime>[];
            return CuteCard(
              backgroundColor: const Color(0xFFE8F7EE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本月活躍日期',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (activeDates.isEmpty)
                    Text(
                      '還沒有留下本月的足跡。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeDates
                          .map(
                            (date) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(DateFormat('M/d').format(date)),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        CuteCard(
          backgroundColor: const Color(0xFFFFEAF1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '本月目標進度',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (monthGoals.isEmpty)
                Text(
                  '還沒有設定目標，可以先放一個想照顧的生活方向。',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Column(
                  children: monthGoals.take(4).map((goal) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(goal.title)),
                              Text('${goal.progress}%'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: goal.progress / 100,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.58),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CuteCard(
          backgroundColor: const Color(0xFFFFF7D9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '本月照片牆',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (monthPhotos.isEmpty)
                Text(
                  '這個月還沒有放進照片，之後可以試著留下幾個生活畫面。',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthPhotos.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: buildAdaptiveEntryImage(monthPhotos[index]),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CuteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '年回顧預覽',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: '本年紀錄',
                      value: '${widget.appState.yearlyEntryCount}',
                      hint: '篇',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: '本年目標',
                      value: '${widget.appState.yearlyGoalCount}',
                      hint: '個',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '之後可以再補更多年度整理內容，像是最常出現的心情、照片精選、最有記憶點的月份。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall,
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: hint,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
