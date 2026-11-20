import '../care/care_models.dart';
import '../child.dart';

/// Seven days, from [start] (inclusive) to [end] (exclusive).
class ReportWeek {
  const ReportWeek(this.start, this.end);

  /// The 7 days that finish on the day of [lastDay]. With [weeksAgo] set
  /// to 1 it is the week before, and so on.
  factory ReportWeek.endingOn(DateTime lastDay, {int weeksAgo = 0}) {
    final day = DateTime(lastDay.year, lastDay.month, lastDay.day - 7 * weeksAgo);

    return ReportWeek(
      DateTime(day.year, day.month, day.day - 6),
      DateTime(day.year, day.month, day.day + 1),
    );
  }

  final DateTime start;
  final DateTime end;

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  /// The seven days, oldest first.
  List<DateTime> get days => [
        for (var i = 0; i < 7; i++)
          DateTime(start.year, start.month, start.day + i),
      ];

  ReportWeek get previous => ReportWeek(
        DateTime(start.year, start.month, start.day - 7),
        start,
      );
}

/// Everything one child did and felt in a week.
class WeekStats {
  const WeekStats({
    required this.week,
    required this.tasksDone,
    required this.activeDays,
    required this.points,
    required this.focusMinutes,
    required this.moodCheckIns,
    required this.positiveMoods,
    required this.sleepAverage,
    required this.mealsPerDay,
    required this.hardMoments,
    required this.schoolNotes,
    required this.topTasks,
    required this.moodCounts,
    required this.triggerTexts,
    required this.noteTexts,
    required this.dayRows,
  });

  static const positiveMoodNames = {'Happy', 'Calm'};

  final ReportWeek week;
  final int tasksDone;
  final int activeDays;
  final int points;
  final int focusMinutes;
  final int moodCheckIns;
  final int positiveMoods;

  /// Hours, or null when no sleep was logged.
  final double? sleepAverage;

  /// Meals eaten well per logged day (0 to 3), or null without logs.
  final double? mealsPerDay;
  final int hardMoments;
  final int schoolNotes;

  /// Most completed tasks, as (title, count).
  final List<(String, int)> topTasks;
  final Map<String, int> moodCounts;
  final List<String> triggerTexts;
  final List<String> noteTexts;
  final List<DayRow> dayRows;

  /// Share of happy or calm check-ins (0 to 100), or null without any.
  double? get positiveMoodPercent =>
      moodCheckIns == 0 ? null : 100 * positiveMoods / moodCheckIns;

  /// False when nothing at all was recorded in the week.
  bool get hasData =>
      tasksDone > 0 ||
      focusMinutes > 0 ||
      moodCheckIns > 0 ||
      sleepAverage != null ||
      hardMoments > 0 ||
      schoolNotes > 0;

  static WeekStats collect({
    required ReportWeek week,
    required List<TaskCompletion> completions,
    required List<FocusSession> focus,
    required List<MoodEntry> moods,
    required List<DailyLog> dailyLogs,
    required List<TriggerEntry> triggers,
    required List<SchoolNote> notes,
  }) {
    final done = completions.where((c) => week.contains(c.completedAt)).toList();
    final sessions = focus.where((f) => week.contains(f.completedAt)).toList();
    final weekMoods = moods.where((m) => week.contains(m.recordedAt)).toList();
    final logs = dailyLogs.where((l) => week.contains(l.day)).toList();
    final hard = triggers.where((t) => week.contains(t.when)).toList();
    final weekNotes = notes.where((n) => week.contains(n.writtenAt)).toList();

    final taskCounts = <String, int>{};
    for (final c in done) {
      taskCounts[c.taskTitle] = (taskCounts[c.taskTitle] ?? 0) + 1;
    }
    final top = taskCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final moodCounts = <String, int>{};
    for (final m in weekMoods) {
      moodCounts[m.mood] = (moodCounts[m.mood] ?? 0) + 1;
    }

    final sleepLogs = logs.where((l) => l.sleepHours != null).toList();
    final sleepAverage = sleepLogs.isEmpty
        ? null
        : sleepLogs.fold<double>(0, (s, l) => s + l.sleepHours!) /
            sleepLogs.length;
    final mealsPerDay = logs.isEmpty
        ? null
        : logs.fold<int>(0, (s, l) => s + l.meals.length) / logs.length;

    final rows = [
      for (final day in week.days)
        DayRow(
          day: day,
          tasks: done.where((c) => _sameDay(c.completedAt, day)).length,
          mood: _lastMood(weekMoods, day),
          sleepHours: logs
              .where((l) => l.sameDay(day))
              .map((l) => l.sleepHours)
              .firstOrNull,
          meals: logs
              .where((l) => l.sameDay(day))
              .map((l) => l.meals.length)
              .firstOrNull,
          hardMoments: hard.where((t) => _sameDay(t.when, day)).length,
        ),
    ];

    return WeekStats(
      week: week,
      tasksDone: done.length,
      activeDays: rows.where((r) => r.tasks > 0).length,
      points: done.fold(0, (s, c) => s + c.pointsEarned),
      focusMinutes: sessions.fold(0, (s, f) => s + f.durationMinutes),
      moodCheckIns: weekMoods.length,
      positiveMoods:
          weekMoods.where((m) => positiveMoodNames.contains(m.mood)).length,
      sleepAverage: sleepAverage,
      mealsPerDay: mealsPerDay,
      hardMoments: hard.length,
      schoolNotes: weekNotes.length,
      topTasks: [for (final e in top.take(5)) (e.key, e.value)],
      moodCounts: moodCounts,
      triggerTexts: [for (final t in hard) t.trigger],
      noteTexts: [for (final n in weekNotes) '${n.teacherName}: ${n.text}'],
      dayRows: rows,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String? _lastMood(List<MoodEntry> moods, DateTime day) {
    final today = moods.where((m) => _sameDay(m.recordedAt, day)).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return today.isEmpty ? null : today.first.mood;
  }
}

/// One day of the week in the report table.
class DayRow {
  const DayRow({
    required this.day,
    required this.tasks,
    required this.mood,
    required this.sleepHours,
    required this.meals,
    required this.hardMoments,
  });

  final DateTime day;
  final int tasks;
  final String? mood;
  final double? sleepHours;
  final int? meals;
  final int hardMoments;
}

enum WeeklyTrend { noPrevious, improved, mixed, stable, worse }

enum MetricTrend { better, same, worse }

/// One measured thing, this week against the week before.
class MetricChange {
  const MetricChange({
    required this.label,
    required this.unit,
    required this.before,
    required this.after,
    required this.higherIsBetter,
    required this.tolerance,
  });

  final String label;
  final String unit;
  final double? before;
  final double? after;
  final bool higherIsBetter;

  /// Differences up to this size count as "the same".
  final double tolerance;

  bool get comparable => before != null && after != null;

  double get change => comparable ? after! - before! : 0;

  MetricTrend get trend {
    if (!comparable || change.abs() <= tolerance) return MetricTrend.same;
    final up = change > 0;
    return up == higherIsBetter ? MetricTrend.better : MetricTrend.worse;
  }
}

/// This week against the week before. Better and worse depend on the
/// metric: more tasks is better, more hard moments is worse.
class WeeklyComparison {
  WeeklyComparison._(this.current, this.previous, this.metrics, this.trend);

  final WeekStats current;
  final WeekStats previous;
  final List<MetricChange> metrics;
  final WeeklyTrend trend;

  factory WeeklyComparison.compare(WeekStats current, WeekStats previous) {
    MetricChange metric(
      String label,
      String unit,
      double? Function(WeekStats s) value, {
      bool higherIsBetter = true,
      double tolerance = 0,
    }) =>
        MetricChange(
          label: label,
          unit: unit,
          before: value(previous),
          after: value(current),
          higherIsBetter: higherIsBetter,
          tolerance: tolerance,
        );

    final metrics = [
      metric('Tasks completed', '', (s) => s.tasksDone.toDouble(),
          tolerance: 1),
      metric('Days with a task done', ' days', (s) => s.activeDays.toDouble()),
      metric('Focus time', ' min', (s) => s.focusMinutes.toDouble(),
          tolerance: 10),
      metric('Happy or calm moods', '%', (s) => s.positiveMoodPercent,
          tolerance: 10),
      metric('Average sleep', ' h', (s) => s.sleepAverage, tolerance: 0.5),
      metric('Meals eaten well per day', '', (s) => s.mealsPerDay,
          tolerance: 0.3),
      metric('Hard moments', '', (s) => s.hardMoments.toDouble(),
          higherIsBetter: false),
    ];

    final better = metrics.where((m) => m.trend == MetricTrend.better).length;
    final worse = metrics.where((m) => m.trend == MetricTrend.worse).length;

    final WeeklyTrend trend;
    if (!previous.hasData) {
      trend = WeeklyTrend.noPrevious;
    } else if (better > worse) {
      trend = WeeklyTrend.improved;
    } else if (worse > better) {
      trend = WeeklyTrend.worse;
    } else if (better > 0) {
      trend = WeeklyTrend.mixed;
    } else {
      trend = WeeklyTrend.stable;
    }

    return WeeklyComparison._(current, previous, metrics, trend);
  }

  int get betterCount =>
      metrics.where((m) => m.trend == MetricTrend.better).length;
  int get worseCount =>
      metrics.where((m) => m.trend == MetricTrend.worse).length;

  String get headline => switch (trend) {
        WeeklyTrend.noPrevious =>
          'No records in the week before, so there is nothing to compare '
              'with yet.',
        WeeklyTrend.improved =>
          'Progress this week: $betterCount things improved and '
              '$worseCount got worse.',
        WeeklyTrend.worse =>
          'A harder week: $worseCount things got worse and '
              '$betterCount improved.',
        WeeklyTrend.mixed =>
          'A mixed week: $betterCount things improved and $worseCount got '
              'worse.',
        WeeklyTrend.stable => 'About the same as the week before.',
      };
}
