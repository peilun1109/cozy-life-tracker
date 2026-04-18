import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/cute_card.dart';

class MobileGoalsScreenClean extends StatelessWidget {
  const MobileGoalsScreenClean({
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
                Text('\u6211\u7684\u76ee\u6a19',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  '\u5148\u653e\u4e00\u500b\u60f3\u6162\u6162\u5b8c\u6210\u7684\u9858\u671b\u5427\uff0c\u9032\u5ea6\u53ef\u4ee5\u624b\u52d5\u8abf\u6574\uff0c\u4e0d\u7528\u7d66\u81ea\u5df1\u592a\u5927\u58d3\u529b\u3002',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onCreate,
                  child: const Text('\u65b0\u589e\u7b2c\u4e00\u500b\u76ee\u6a19'),
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
                        Text(goal.title,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          goal.description.isEmpty
                              ? '\u6162\u6162\u4f86\u4e5f\u5f88\u597d\u3002'
                              : goal.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showGoalEditorSheetClean(
                          context,
                          appState: appState,
                          initialGoal: goal,
                        );
                      } else if (value == 'delete' && goal.id != null) {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('\u522a\u9664\u76ee\u6a19'),
                                content: Text(
                                  '\u8981\u522a\u9664\u300c${goal.title}\u300d\u55ce\uff1f\u76f8\u95dc\u806f\u7684\u7d00\u9304\u4e0d\u6703\u4e00\u8d77\u6d88\u5931\u3002',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('\u53d6\u6d88'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('\u522a\u9664'),
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
                      PopupMenuItem(value: 'edit', child: Text('\u7de8\u8f2f')),
                      PopupMenuItem(value: 'delete', child: Text('\u522a\u9664')),
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
                        '\u958b\u59cb ${DateFormat('M/d').format(goal.startDate)}',
                  ),
                  _InfoChip(
                    icon: Icons.flag_rounded,
                    label:
                        '\u622a\u6b62 ${DateFormat('M/d').format(goal.endDate)}',
                  ),
                  _InfoChip(
                    icon: Icons.hourglass_bottom_rounded,
                    label: goal.daysLeft >= 0
                        ? '\u5269 ${goal.daysLeft} \u5929'
                        : '\u5df2\u8d85\u904e ${goal.daysLeft.abs()} \u5929',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text('\u9032\u5ea6 ${goal.progress}%',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(_progressHint(goal.progress),
                      style: Theme.of(context).textTheme.bodySmall),
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
              Text('\u76f8\u95dc\u751f\u6d3b\u7d00\u9304',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (linkedEntries.isEmpty)
                Text(
                  '\u76ee\u524d\u9084\u6c92\u6709\u548c\u9019\u500b\u76ee\u6a19\u7d81\u5b9a\u7684\u7d00\u9304\u3002',
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

Future<void> showGoalEditorSheetClean(
  BuildContext context, {
  required AppState appState,
  Goal? initialGoal,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _GoalEditorSheetClean(
      appState: appState,
      initialGoal: initialGoal,
    ),
  );
}

class _GoalEditorSheetClean extends StatefulWidget {
  const _GoalEditorSheetClean({
    required this.appState,
    this.initialGoal,
  });

  final AppState appState;
  final Goal? initialGoal;

  @override
  State<_GoalEditorSheetClean> createState() => _GoalEditorSheetCleanState();
}

class _GoalEditorSheetCleanState extends State<_GoalEditorSheetClean> {
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

  Future<void> _pickDate({required bool isStart}) async {
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
                isEditing ? '\u7de8\u8f2f\u76ee\u6a19' : '\u65b0\u589e\u76ee\u6a19',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '\u76ee\u6a19\u540d\u7a31',
                  hintText: '\u50cf\u662f\uff1a\u516d\u6708\u524d\u6062\u5fa9\u898f\u5f8b\u904b\u52d5',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '\u88dc\u5145\u8aaa\u660e',
                  hintText:
                      '\u5beb\u4e0b\u4f60\u70ba\u4ec0\u9ebc\u60f3\u5b8c\u6210\u5b83\uff0c\u6703\u66f4\u6709\u966a\u4f34\u611f\u3002',
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
                        '\u958b\u59cb ${DateFormat('M/d').format(_startDate)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.flag_rounded),
                      label: Text(
                        '\u622a\u6b62 ${DateFormat('M/d').format(_endDate)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '\u76ee\u524d\u9032\u5ea6 ${_progress.round()}%',
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
                  child: Text(
                    isEditing
                        ? '\u5132\u5b58\u8b8a\u66f4'
                        : '\u5efa\u7acb\u76ee\u6a19',
                  ),
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
  const _InfoChip({required this.icon, required this.label});

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
    return '\u5df2\u5b8c\u6210\uff0c\u597d\u68d2';
  }
  if (progress >= 70) {
    return '\u5feb\u8981\u9054\u6a19\u4e86';
  }
  if (progress >= 30) {
    return '\u7a69\u7a69\u524d\u9032\u4e2d';
  }
  return '\u5148\u5f9e\u5c0f\u6b65\u958b\u59cb';
}
