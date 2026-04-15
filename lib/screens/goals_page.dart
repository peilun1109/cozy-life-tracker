import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('目標小花園', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('把想前進的方向放在這裡，不急，穩穩地長大就很好。'),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showGoalEditor(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增目標'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: appState.goals.isEmpty
              ? const Center(child: Text('目前還沒有目標，先種下一顆小種子吧。'))
              : ListView.separated(
                  itemCount: appState.goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final goal = appState.goals[index];
                    final relatedEntries =
                        goal.id == null ? const [] : appState.entriesForGoal(goal.id!);

                    return CuteCard(
                      backgroundColor: index.isEven
                          ? AppTheme.mint.withValues(alpha: 0.54)
                          : AppTheme.peach.withValues(alpha: 0.58),
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
                                    Text(goal.title, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    Text(goal.description.isEmpty ? '還沒有補充說明。' : goal.description),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('剩餘 ${goal.daysLeft} 天'),
                                  Text('進度 ${goal.progress}%'),
                                ],
                              ),
                              IconButton(
                                onPressed: () => _showGoalEditor(context, existing: goal),
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              IconButton(
                                onPressed: () => _confirmDelete(context, goal.id!),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: LinearProgressIndicator(
                              value: goal.progress / 100,
                              minHeight: 14,
                              backgroundColor: Colors.white.withValues(alpha: 0.6),
                              color: const Color(0xFFF7AFC9),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              Chip(label: Text('開始 ${DateFormat('yyyy/M/d').format(goal.startDate)}')),
                              Chip(label: Text('截止 ${DateFormat('yyyy/M/d').format(goal.endDate)}')),
                              Chip(label: Text('關聯紀錄 ${relatedEntries.length} 篇')),
                            ],
                          ),
                          if (relatedEntries.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text('與這個目標有關的紀錄', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: relatedEntries
                                  .take(4)
                                  .map<Widget>(
                                    (entry) => Chip(
                                      label: Text(
                                        entry.content,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showGoalEditor(BuildContext context, {Goal? existing}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _GoalEditorDialog(appState: appState, existing: existing),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('刪除這個目標？'),
            content: const Text('相關聯的紀錄會保留，但不再關聯到這個目標。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('刪除'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      await appState.deleteGoal(id);
    }
  }
}

class _GoalEditorDialog extends StatefulWidget {
  const _GoalEditorDialog({
    required this.appState,
    this.existing,
  });

  final AppState appState;
  final Goal? existing;

  @override
  State<_GoalEditorDialog> createState() => _GoalEditorDialogState();
}

class _GoalEditorDialogState extends State<_GoalEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late double _progress;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _startDate = existing?.startDate ?? DateTime.now();
    _endDate = existing?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _progress = (existing?.progress ?? 0).toDouble();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? '新增目標' : '編輯目標'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '目標名稱'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '目標說明',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: '開始日期',
                      value: _startDate,
                      onPick: (date) => setState(() => _startDate = date),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: '截止日期',
                      value: _endDate,
                      onPick: (date) => setState(() => _endDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('手動進度 ${_progress.round()}%'),
              ),
              Slider(
                value: _progress,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: const Color(0xFFF7AFC9),
                onChanged: (value) => setState(() => _progress = value),
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
        ElevatedButton(
          onPressed: _save,
          child: const Text('儲存'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final goal = Goal(
      id: widget.existing?.id,
      title: title,
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      progress: _progress.round(),
    );
    await widget.appState.saveGoal(goal);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: value,
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(DateFormat('yyyy/M/d').format(value)),
      ),
    );
  }
}
