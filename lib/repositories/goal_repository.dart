import 'dart:convert';

import '../models/goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalRepository {
  static const _goalsKey = 'goals_json';

  Future<List<Goal>> fetchGoals() async {
    final goals = await _readGoals();
    goals.sort((a, b) => a.endDate.compareTo(b.endDate));
    return goals;
  }

  Future<int> upsertGoal(Goal goal) async {
    final goals = await _readGoals();
    final nextId = goal.id ?? _nextId(goals.map((item) => item.id ?? 0));
    final savedGoal = goal.copyWith(id: nextId);
    final index = goals.indexWhere((item) => item.id == nextId);
    if (index >= 0) {
      goals[index] = savedGoal;
    } else {
      goals.add(savedGoal);
    }
    await _writeGoals(goals);
    return nextId;
  }

  Future<void> deleteGoal(int id) async {
    final goals = await _readGoals();
    goals.removeWhere((goal) => goal.id == id);
    await _writeGoals(goals);
  }

  Future<int> fetchGoalCountForYear(int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final goals = await _readGoals();
    return goals
        .where((goal) => goal.startDate.isAfter(start.subtract(const Duration(seconds: 1))) && goal.startDate.isBefore(end))
        .length;
  }

  Future<List<Goal>> _readGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null || raw.isEmpty) {
      return <Goal>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Goal.fromMap(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<void> _writeGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      goals.map((goal) => goal.toMap()).toList(),
    );
    await prefs.setString(_goalsKey, encoded);
  }

  int _nextId(Iterable<int> ids) {
    if (ids.isEmpty) {
      return 1;
    }
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }
}
