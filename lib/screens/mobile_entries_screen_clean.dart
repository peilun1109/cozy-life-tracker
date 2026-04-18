import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/entry.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/adaptive_entry_image.dart';
import '../widgets/cute_card.dart';

class MobileEntriesScreenClean extends StatelessWidget {
  const MobileEntriesScreenClean({
    super.key,
    required this.appState,
    required this.onEditEntry,
  });

  final AppState appState;
  final ValueChanged<Entry> onEditEntry;

  @override
  Widget build(BuildContext context) {
    if (appState.entries.isEmpty) {
      return const Center(
        child: Text('還沒有任何生活紀錄，先寫下今天的一小段心情吧。'),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: appState.entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = appState.entries[index];
        final relatedGoal = _goalForEntry(entry);

        return CuteCard(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(entry.mood ?? '🙂', style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
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
                  if (entry.id != null)
                    IconButton(
                      onPressed: () =>
                          _confirmDelete(context, entry.id!, appState),
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
                const SizedBox(height: 12),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imagePaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, imageIndex) {
                      final path = entry.imagePaths[imageIndex];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: buildAdaptiveEntryImage(
                          imagePath: path,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                          errorChild: Container(
                            width: 112,
                            height: 112,
                            alignment: Alignment.center,
                            color: const Color(0xFFF6EFEA),
                            child: const Text('圖片讀取失敗'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Goal? _goalForEntry(Entry entry) {
    for (final goal in appState.goals) {
      if (goal.id == entry.goalId) {
        return goal;
      }
    }
    return null;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    int id,
    AppState appState,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('刪除這篇紀錄'),
            content: const Text('刪除後就不會保留在列表裡了，要繼續嗎？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
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

Future<void> showEntryEditorSheetClean(
  BuildContext context, {
  required AppState appState,
  Entry? existing,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EntryEditorSheetClean(
      appState: appState,
      existing: existing,
    ),
  );
}

class _EntryEditorSheetClean extends StatefulWidget {
  const _EntryEditorSheetClean({
    required this.appState,
    this.existing,
  });

  final AppState appState;
  final Entry? existing;

  @override
  State<_EntryEditorSheetClean> createState() => _EntryEditorSheetCleanState();
}

class _EntryEditorSheetCleanState extends State<_EntryEditorSheetClean> {
  static const _moods = ['🙂', '😌', '🥳', '😴', '🥹', '🤍', '🌧️'];

  late final TextEditingController _contentController;
  late String? _mood;
  late int? _goalId;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.existing?.content ?? '');
    _mood = widget.existing?.mood;
    _goalId = widget.existing?.goalId;
    _images = [...?widget.existing?.imagePaths];
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7C7C0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing == null ? '新增生活紀錄' : '編輯生活紀錄',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '今天想留下什麼？',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('選擇圖片'),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final path = _images[index];
                      return Stack(
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
                            top: 6,
                            right: 6,
                            child: InkWell(
                              onTap: () => setState(() => _images.removeAt(index)),
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
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('儲存紀錄'),
                ),
              ),
            ],
          ),
        ),
      ),
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
      _images.addAll(
        result.files.map(_platformFileToStoredImage).whereType<String>(),
      );
    });
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    await widget.appState.saveEntry(
      Entry(
        id: widget.existing?.id,
        content: content,
        mood: _mood,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
        goalId: _goalId,
        imagePaths: _images,
      ),
    );

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
