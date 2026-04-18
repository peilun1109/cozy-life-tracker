import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/cute_card.dart';

class MobileGoalsScreen extends StatelessWidget {
  const MobileGoalsScreen({
    super.key,
    required this.appState,
    required this.onCreate,
  });

  final AppState appState;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final goals = appState.goals;

    if (goals.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          CuteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的目標',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '先放一個想慢慢完成的願望吧，進度可以手動調整，不用給自己太大壓力。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onCreate,
                  child: const Text('新增第一個目標'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final goal = goals[index];
        final linkedEntries = goal.id == null
            ? const <String>[]
            : appState
                .entriesForGoal(goal.id!)
                .take(3)
                .map((entry) => entry.content)
                .toList();

        return CuteCard(
          backgroundColor: _goalBackground(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal.description.isEmpty ? '慢慢來也很好。' : goal.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showGoalEditorSheet(
                          context,
                          appState: appState,
                          initialGoal: goal,
                        );
                      } else if (value == 'delete' && goal.id != null) {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('刪除目標'),
                                content: Text('要刪除「${goal.title}」嗎？相關聯的紀錄不會一起消失。'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('刪除'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirmed) {
                          await appState.deleteGoal(goal.id!);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('編輯')),
                      PopupMenuItem(value: 'delete', child: Text('刪除')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label:
                        '開始 ${DateFormat('M/d').format(goal.startDate)}',
                  ),
                  _InfoChip(
                    icon: Icons.flag_rounded,
                    label: '截止 ${DateFormat('M/d').format(goal.endDate)}',
                  ),
                  _InfoChip(
                    icon: Icons.hourglass_bottom_rounded,
                    label: goal.daysLeft >= 0
                        ? '剩 ${goal.daysLeft} 天'
                        : '已超過 ${goal.daysLeft.abs()} 天',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '進度 ${goal.progress}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    _progressHint(goal.progress),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: goal.progress / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: goal.progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '${goal.progress}%',
                onChanged: (value) {
                  appState.saveGoal(goal.copyWith(progress: value.round()));
                },
              ),
              const SizedBox(height: 8),
              Text(
                '相關生活紀錄',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (linkedEntries.isEmpty)
                Text(
                  '目前還沒有和這個目標綁定的紀錄。',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Column(
                  children: linkedEntries
                      .map(
                        (content) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(Icons.favorite_rounded, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showGoalEditorSheet(
  BuildContext context, {
  required AppState appState,
  Goal? initialGoal,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _GoalEditorSheet(
      appState: appState,
      initialGoal: initialGoal,
    ),
  );
}

class _GoalEditorSheet extends StatefulWidget {
  const _GoalEditorSheet({
    required this.appState,
    this.initialGoal,
  });

  final AppState appState;
  final Goal? initialGoal;

  @override
  State<_GoalEditorSheet> createState() => _GoalEditorSheetState();
}

class _GoalEditorSheetState extends State<_GoalEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    final goal = widget.initialGoal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: goal?.description ?? '');
    _startDate = goal?.startDate ?? DateTime.now();
    _endDate = goal?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _progress = (goal?.progress ?? 0).toDouble();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool isStart,
  }) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked.isBefore(_startDate) ? _startDate : picked;
      }
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    await widget.appState.saveGoal(
      Goal(
        id: widget.initialGoal?.id,
        title: title,
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        progress: _progress.round(),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGoal != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: CuteCard(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? '編輯目標' : '新增目標',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '目標名稱',
                  hintText: '像是：六月前恢復規律運動',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '補充說明',
                  hintText: '寫下你為什麼想完成它，會更有陪伴感。',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(
                        '開始 ${DateFormat('M/d').format(_startDate)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.flag_rounded),
                      label: Text(
                        '截止 ${DateFormat('M/d').format(_endDate)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '目前進度 ${_progress.round()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _progress,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_progress.round()}%',
                onChanged: (value) => setState(() => _progress = value),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? '儲存變更' : '建立目標'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

Color _goalBackground(int index) {
  const colors = [
    Color(0xFFFFF1D8),
    Color(0xFFE8F5FF),
    Color(0xFFE6F8ED),
    Color(0xFFFFE7EE),
  ];
  return colors[index % colors.length];
}

String _progressHint(int progress) {
  if (progress >= 100) {
    return '已完成，好棒';
  }
  if (progress >= 70) {
    return '快要達標了';
  }
  if (progress >= 30) {
    return '穩穩前進中';
  }
  return '先從小步開始';
}
