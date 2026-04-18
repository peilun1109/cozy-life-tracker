import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class WebHomeV4 extends StatefulWidget {
  const WebHomeV4({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WebHomeV4> createState() => _WebHomeV4State();
}

class _WebHomeV4State extends State<WebHomeV4> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcomingWeek = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day + index),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: '未來一週安排',
            subtitle: '7 天固定同一排，每一天都能直接看到。',
            accentColor: AppTheme.sky,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final cardWidth =
                    ((constraints.maxWidth - gap * 6) / 7).clamp(120.0, 180.0);

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
      backgroundColor: Colors.white.withValues(alpha: 0.9),
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

    return CuteCard(
      backgroundColor: const Color(0xFFFFF8FB),
      padding: const EdgeInsets.all(14),
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
            Text('+${lines.length - 3} 更多', style: Theme.of(context).textTheme.bodySmall),
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
    );
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
