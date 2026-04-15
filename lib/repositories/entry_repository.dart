import 'dart:convert';

import '../models/entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryRepository {
  static const _entriesKey = 'entries_json';

  Future<List<Entry>> fetchEntries() async {
    final entries = await _readEntries();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<int> upsertEntry(Entry entry) async {
    final entries = await _readEntries();
    final nextId = entry.id ?? _nextId(entries.map((item) => item.id ?? 0));
    final savedEntry = entry.copyWith(id: nextId);

    final index = entries.indexWhere((item) => item.id == nextId);
    if (index >= 0) {
      entries[index] = savedEntry;
    } else {
      entries.add(savedEntry);
    }

    await _writeEntries(entries);
    return nextId;
  }

  Future<void> deleteEntry(int id) async {
    final entries = await _readEntries();
    entries.removeWhere((entry) => entry.id == id);
    await _writeEntries(entries);
  }

  Future<List<DateTime>> fetchActiveDatesInMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final entries = await _readEntries();
    return entries
        .where((entry) => entry.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) && entry.createdAt.isBefore(end))
        .map((entry) => entry.createdAt)
        .toList();
  }

  Future<Map<String, int>> fetchMoodStatsForMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final entries = await _readEntries();
    final stats = <String, int>{};
    for (final entry in entries) {
      if (entry.mood == null) {
        continue;
      }
      if (entry.createdAt.isBefore(start) || !entry.createdAt.isBefore(end)) {
        continue;
      }
      stats.update(entry.mood!, (value) => value + 1, ifAbsent: () => 1);
    }
    return stats;
  }

  Future<int> fetchEntryCountForYear(int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final entries = await _readEntries();
    return entries
        .where((entry) => entry.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) && entry.createdAt.isBefore(end))
        .length;
  }

  Future<List<Entry>> _readEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) {
      return <Entry>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Entry.fromStorageMap(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<void> _writeEntries(List<Entry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      entries.map((entry) => entry.toStorageMap()).toList(),
    );
    await prefs.setString(_entriesKey, encoded);
  }

  int _nextId(Iterable<int> ids) {
    if (ids.isEmpty) {
      return 1;
    }
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }
}
