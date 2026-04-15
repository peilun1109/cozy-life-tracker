import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_settings.dart';
import '../models/entry.dart';
import '../models/goal.dart';
import '../repositories/entry_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/image_storage_service.dart';
import '../services/reminder_service.dart';

enum AppSection { home, entries, goals, review, settings }

class AppState extends ChangeNotifier {
  AppState({
    required ImageStorageService imageStorageService,
    required ReminderService reminderService,
  })  : _imageStorageService = imageStorageService,
        _reminderService = reminderService;

  final EntryRepository _entryRepository = EntryRepository();
  final GoalRepository _goalRepository = GoalRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final ImageStorageService _imageStorageService;
  final ReminderService _reminderService;

  AppSection selectedSection = AppSection.home;
  List<Entry> entries = const [];
  List<Goal> goals = const [];
  AppSettings settings = AppSettings.defaults();
  int yearlyEntryCount = 0;
  int yearlyGoalCount = 0;
  bool isBusy = false;
  void Function()? onReminderRequested;

  Future<void> initialize() async {
    await refreshAll();
  }

  Future<void> refreshAll() async {
    isBusy = true;
    notifyListeners();

    entries = await _entryRepository.fetchEntries();
    goals = await _goalRepository.fetchGoals();
    settings = await _settingsRepository.fetchSettings();
    yearlyEntryCount =
        await _entryRepository.fetchEntryCountForYear(DateTime.now().year);
    yearlyGoalCount =
        await _goalRepository.fetchGoalCountForYear(DateTime.now().year);
    _startReminderWatcher();

    isBusy = false;
    notifyListeners();
  }

  void selectSection(AppSection section) {
    selectedSection = section;
    notifyListeners();
  }

  Future<void> saveEntry(Entry draft) async {
    final persistedPaths =
        await _imageStorageService.persistImagePaths(draft.imagePaths);
    await _entryRepository.upsertEntry(draft.copyWith(imagePaths: persistedPaths));
    await refreshAll();
  }

  Future<void> deleteEntry(int id) async {
    await _entryRepository.deleteEntry(id);
    await refreshAll();
  }

  Future<void> saveGoal(Goal goal) async {
    await _goalRepository.upsertGoal(goal);
    await refreshAll();
  }

  Future<void> deleteGoal(int id) async {
    await _goalRepository.deleteGoal(id);
    await refreshAll();
  }

  Future<void> saveSettings(AppSettings newSettings) async {
    settings = newSettings;
    await _settingsRepository.updateSettings(newSettings);
    _startReminderWatcher();
    notifyListeners();
  }

  List<Entry> recentEntries({int limit = 3}) => entries.take(limit).toList();

  List<Goal> focusGoals({int limit = 3}) {
    final sorted = [...goals]..sort((a, b) => a.endDate.compareTo(b.endDate));
    return sorted.take(limit).toList();
  }

  List<Goal> countdownGoals({int limit = 4}) {
    final sorted = [...goals]
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return sorted.take(limit).toList();
  }

  List<Goal> goalsDueOn(DateTime date) {
    return goals.where((goal) {
      return goal.endDate.year == date.year &&
          goal.endDate.month == date.month &&
          goal.endDate.day == date.day;
    }).toList();
  }

  List<Entry> entriesForGoal(int goalId) {
    return entries.where((entry) => entry.goalId == goalId).toList();
  }

  Future<Map<String, int>> monthMoodStats(DateTime month) {
    return _entryRepository.fetchMoodStatsForMonth(month);
  }

  Future<List<DateTime>> monthActiveDates(DateTime month) {
    return _entryRepository.fetchActiveDatesInMonth(month);
  }

  String greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return '早安，今天也慢慢把日子過成喜歡的樣子吧。';
    }
    if (hour < 18) {
      return '午安，留一點時間給自己，記住今天的小亮點。';
    }
    return '晚安前，來替今天留下一小段溫柔紀錄吧。';
  }

  String formattedReminderTime() {
    final parts = settings.reminderTime.split(':');
    if (parts.length != 2) {
      return settings.reminderTime;
    }
    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return DateFormat('a hh:mm', 'zh_TW').format(date);
  }

  void _startReminderWatcher() {
    _reminderService.start(
      enabled: settings.reminderEnabled,
      reminderTime: settings.reminderTime,
      onReminder: () => onReminderRequested?.call(),
    );
  }

  @override
  void dispose() {
    _reminderService.stop();
    super.dispose();
  }
}
