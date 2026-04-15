import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/entry.dart';
import '../state/app_state.dart';
import '../widgets/adaptive_entry_image.dart';
import '../widgets/cute_card.dart';

class EntriesScreen extends StatelessWidget {
  const EntriesScreen({
    super.key,
    required this.appState,
    required this.onCreateEntry,
    required this.onEditEntry,
  });

  final AppState appState;
  final VoidCallback onCreateEntry;
  final ValueChanged<Entry> onEditEntry;

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
                  Text('生活紀錄', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('用文字、照片和心情，把每天的小片段慢慢收藏起來。'),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onCreateEntry,
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增紀錄'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: appState.entries.isEmpty
              ? const Center(child: Text('目前還沒有生活紀錄，先寫下今天的一小段吧。'))
              : ListView.separated(
                  itemCount: appState.entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final entry = appState.entries[index];
                    final relatedGoal = appState.goals
                        .where((goal) => goal.id == entry.goalId)
                        .cast<dynamic>()
                        .firstOrNull;

                    return CuteCard(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(entry.mood ?? '📝', style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat('yyyy/M/d HH:mm').format(entry.createdAt),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                onPressed: () => onEditEntry(entry),
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              IconButton(
                                onPressed: () => _confirmDelete(context, entry.id!, appState),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                          if (relatedGoal != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Chip(label: Text('關聯目標：${relatedGoal.title}')),
                            ),
                          Text(entry.content),
                          if (entry.imagePaths.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: entry.imagePaths
                                  .map(
                                    (path) => ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: buildAdaptiveEntryImage(
                                        imagePath: path,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorChild: Container(
                                          width: 120,
                                          height: 120,
                                          alignment: Alignment.center,
                                          color: const Color(0xFFF6EFEA),
                                          child: const Text('找不到圖片'),
                                        ),
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

  Future<void> _confirmDelete(
    BuildContext context,
    int id,
    AppState appState,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('刪除這篇紀錄？'),
            content: const Text('這會移除這篇內容與已保存的圖片資料。'),
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
      await appState.deleteEntry(id);
    }
  }
}

Future<void> showEntryEditor(
  BuildContext context,
  AppState appState, {
  Entry? existing,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _EntryEditorDialog(
      appState: appState,
      existing: existing,
    ),
  );
}

class _EntryEditorDialog extends StatefulWidget {
  const _EntryEditorDialog({
    required this.appState,
    this.existing,
  });

  final AppState appState;
  final Entry? existing;

  @override
  State<_EntryEditorDialog> createState() => _EntryEditorDialogState();
}

class _EntryEditorDialogState extends State<_EntryEditorDialog> {
  late final TextEditingController _contentController;
  late DateTime _createdAt;
  late String? _mood;
  late int? _goalId;
  late List<String> _images;

  static const _moods = ['😊', '🥰', '😌', '😴', '😵‍💫', '😭', '✨'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _contentController = TextEditingController(text: existing?.content ?? '');
    _createdAt = existing?.createdAt ?? DateTime.now();
    _mood = existing?.mood;
    _goalId = existing?.goalId;
    _images = [...?existing?.imagePaths];
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? '新增生活紀錄' : '編輯生活紀錄'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '今天想記下什麼？',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String?>(
                initialValue: _mood,
                decoration: const InputDecoration(labelText: '心情'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('先不選'),
                  ),
                  ..._moods.map(
                    (mood) => DropdownMenuItem<String?>(
                      value: mood,
                      child: Text(mood),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _mood = value),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int?>(
                initialValue: _goalId,
                decoration: const InputDecoration(labelText: '關聯目標'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('不關聯'),
                  ),
                  ...widget.appState.goals.map(
                    (goal) => DropdownMenuItem<int?>(
                      value: goal.id,
                      child: Text(goal.title),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _goalId = value),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('加入圖片'),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _images
                      .map(
                        (path) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: buildAdaptiveEntryImage(
                                imagePath: path,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorChild: Container(
                                  width: 110,
                                  height: 110,
                                  alignment: Alignment.center,
                                  color: const Color(0xFFF5EDE7),
                                  child: const Text('圖片'),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: InkWell(
                                onTap: () => setState(() => _images.remove(path)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
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

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (result == null) {
      return;
    }
    setState(() {
      _images.addAll(result.files.map(_platformFileToStoredImage).whereType<String>());
    });
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    final draft = Entry(
      id: widget.existing?.id,
      content: content,
      mood: _mood,
      createdAt: _createdAt,
      goalId: _goalId,
      imagePaths: _images,
    );

    await widget.appState.saveEntry(draft);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _platformFileToStoredImage(PlatformFile file) {
    if (file.bytes != null) {
      final extension = (file.extension ?? 'png').toLowerCase();
      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/png',
      };
      return 'data:$mimeType;base64,${base64Encode(file.bytes!)}';
    }
    return file.path;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
