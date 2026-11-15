import 'package:flutter/material.dart';

import '../child.dart';

class ParentAchievement {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const ParentAchievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Statistics calculated from the child's real activity (tasks, focus
/// sessions and mood check-ins). No sample values.
class ParentInsights {
  final ChildAppState data;

  const ParentInsights(this.data);

  static const weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The last [days] calendar days, oldest first, ending today.
  List<DateTime> lastDays([int days = 7]) {
    final today = _dayOf(DateTime.now());
    return List.generate(
      days,
      (i) => today.subtract(Duration(days: days - 1 - i)),
    );
  }

  int _completionsOn(DateTime day) {
    return data.completionHistory
        .where((r) => _dayOf(r.completedAt) == day)
        .length;
  }

  /// Completed tasks for each of the last 7 days (oldest first).
  List<int> get dailyCompletions =>
      lastDays().map(_completionsOn).toList();

  /// Daily value from 0 to 1, relative to the number of tasks assigned.
  List<double> get dailyRatios {
    final total = data.tasks.length;
    return dailyCompletions.map((count) {
      if (total == 0) return 0.0;
      return (count / total).clamp(0.0, 1.0);
    }).toList();
  }

  int get thisWeekCompletions =>
      dailyCompletions.fold(0, (sum, v) => sum + v);

  int get lastWeekCompletions {
    final today = _dayOf(DateTime.now());
    final start = today.subtract(const Duration(days: 13));
    final end = today.subtract(const Duration(days: 7));
    return data.completionHistory.where((r) {
      final day = _dayOf(r.completedAt);
      return !day.isBefore(start) && !day.isAfter(end);
    }).length;
  }

  /// Change versus last week in percent, or null when there is no base.
  int? get weekChangePercent {
    if (lastWeekCompletions == 0) return null;
    return (((thisWeekCompletions - lastWeekCompletions) /
                lastWeekCompletions) *
            100)
        .round();
  }

  String get weekChangeLabel {
    final change = weekChangePercent;
    if (change == null) {
      return thisWeekCompletions == 0 ? '--' : 'New';
    }
    return change >= 0 ? '+$change%' : '$change%';
  }

  /// Consecutive days with at least one completed task.
  int get streakDays {
    var day = _dayOf(DateTime.now());
    if (_completionsOn(day) == 0) {
      day = day.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (_completionsOn(day) > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get weeklyFocusMinutes {
    final start = _dayOf(DateTime.now()).subtract(const Duration(days: 6));
    return data.focusSessions
        .where((s) => !_dayOf(s.completedAt).isBefore(start))
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get todayFocusMinutes {
    final today = _dayOf(DateTime.now());
    return data.focusSessions
        .where((s) => _dayOf(s.completedAt) == today)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Share of the week's possible task completions that were done.
  int get weeklyScorePercent {
    final possible = data.tasks.length * 7;
    if (possible == 0) return 0;
    return ((thisWeekCompletions / possible) * 100).clamp(0, 100).round();
  }

  List<MoodEntry> get weeklyMoods {
    final start = _dayOf(DateTime.now()).subtract(const Duration(days: 6));
    return data.moodHistory
        .where((m) => !_dayOf(m.recordedAt).isBefore(start))
        .toList();
  }

  /// Most frequent mood this week, or null.
  String? get topMoodThisWeek {
    final moods = weeklyMoods;
    if (moods.isEmpty) return null;

    final counts = <String, int>{};
    for (final entry in moods) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }

    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  List<ParentAchievement> get achievements {
    final list = <ParentAchievement>[];
    final total = data.totalTasksCompleted;

    if (total >= 1) {
      list.add(const ParentAchievement(
        icon: Icons.flag_rounded,
        title: 'First Step',
        description: 'Completed the first task',
        color: Color(0xFFE9F8F0),
      ));
    }
    if (total >= 10) {
      list.add(const ParentAchievement(
        icon: Icons.star_rounded,
        title: 'Super Star',
        description: 'Completed 10 tasks',
        color: Color(0xFFFFF1D6),
      ));
    }
    if (streakDays >= 3) {
      list.add(ParentAchievement(
        icon: Icons.local_fire_department_rounded,
        title: 'On a Roll',
        description: '$streakDays days in a row',
        color: const Color(0xFFFFEAF1),
      ));
    }
    if (data.totalFocusMinutes >= 30) {
      list.add(ParentAchievement(
        icon: Icons.self_improvement_rounded,
        title: 'Focus Hero',
        description: '${data.totalFocusMinutes} minutes of focus',
        color: const Color(0xFFF0EDFF),
      ));
    }

    final reached = data.rewards.where(data.hasAchievedReward).length;
    if (reached > 0) {
      list.add(ParentAchievement(
        icon: Icons.card_giftcard_rounded,
        title: 'Reward Unlocked',
        description: '$reached reward${reached == 1 ? '' : 's'} reached',
        color: const Color(0xFFFFEAF1),
      ));
    }

    return list;
  }
}
