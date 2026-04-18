import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../widgets/adaptive_entry_image.dart';
import '../widgets/cute_card.dart';

class MobileReviewScreenClean extends StatefulWidget {
  const MobileReviewScreenClean({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<MobileReviewScreenClean> createState() =>
      _MobileReviewScreenCleanState();
}

class _MobileReviewScreenCleanState extends State<MobileReviewScreenClean> {
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
    final now = DateTime.now();
    final monthEntries = widget.appState.entries.where((entry) {
      return entry.createdAt.year == now.year && entry.createdAt.month == now.month;
    }).toList();
    final monthPhotos =
        monthEntries.expand((entry) => entry.imagePaths).take(8).toList();
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
                '${DateFormat('M \u6708').format(now)}\u56de\u9867',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '\u628a\u9019\u500b\u6708\u7684\u751f\u6d3b\u788e\u7247\u548c\u524d\u9032\u7684\u75d5\u8de1\u653e\u5728\u4e00\u8d77\uff0c\u770b\u8d77\u4f86\u6703\u5f88\u6eab\u67d4\u3002',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: '\u672c\u6708\u7d00\u9304',
                      value: '${monthEntries.length}',
                      hint: '\u7bc7',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: '\u5e73\u5747\u9032\u5ea6',
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
                    '\u672c\u6708\u5fc3\u60c5\u7d71\u8a08',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (stats.isEmpty)
                    Text(
                      '\u9019\u500b\u6708\u9084\u6c92\u6709\u6a19\u8a18\u5fc3\u60c5\uff0c\u4e4b\u5f8c\u8a18\u9304\u6642\u53ef\u4ee5\u9806\u624b\u9078\u4e00\u4e0b\u3002',
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
                              child: Text('${entry.key} ${entry.value} \u6b21'),
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
                    '\u672c\u6708\u6d3b\u8e8d\u65e5\u671f',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (activeDates.isEmpty)
                    Text(
                      '\u9084\u6c92\u6709\u7559\u4e0b\u672c\u6708\u7684\u8db3\u8de1\u3002',
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
                '\u672c\u6708\u76ee\u6a19\u9032\u5ea6',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (monthGoals.isEmpty)
                Text(
                  '\u9084\u6c92\u6709\u8a2d\u5b9a\u76ee\u6a19\uff0c\u53ef\u4ee5\u5148\u653e\u4e00\u500b\u60f3\u7167\u9867\u7684\u751f\u6d3b\u65b9\u5411\u3002',
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
                '\u672c\u6708\u7167\u7247\u7246',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (monthPhotos.isEmpty)
                Text(
                  '\u9019\u500b\u6708\u9084\u6c92\u6709\u653e\u9032\u7167\u7247\uff0c\u4e4b\u5f8c\u53ef\u4ee5\u8a66\u8457\u7559\u4e0b\u5e7e\u500b\u751f\u6d3b\u756b\u9762\u3002',
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
                      child: buildAdaptiveEntryImage(
                        imagePath: monthPhotos[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
                '\u5e74\u56de\u9867\u9810\u89bd',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: '\u672c\u5e74\u7d00\u9304',
                      value: '${widget.appState.yearlyEntryCount}',
                      hint: '\u7bc7',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: '\u672c\u5e74\u76ee\u6a19',
                      value: '${widget.appState.yearlyGoalCount}',
                      hint: '\u500b',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '\u4e4b\u5f8c\u53ef\u4ee5\u518d\u88dc\u66f4\u591a\u5e74\u5ea6\u6574\u7406\u5167\u5bb9\uff0c\u50cf\u662f\u6700\u5e38\u51fa\u73fe\u7684\u5fc3\u60c5\u3001\u7167\u7247\u7cbe\u9078\u3001\u6700\u6709\u8a18\u61b6\u9ede\u7684\u6708\u4efd\u3002',
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
