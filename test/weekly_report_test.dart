import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/care/care_models.dart';
import 'package:adhd/child.dart';
import 'package:adhd/reports/weekly_pdf.dart';
import 'package:adhd/reports/weekly_stats.dart';

TaskCompletion done(DateTime at, {String title = 'Brush teeth'}) =>
    TaskCompletion(
      taskId: 1,
      taskTitle: title,
      completedAt: at,
      pointsEarned: 10,
    );

WeekStats stats(
  ReportWeek week, {
  List<TaskCompletion> completions = const [],
  List<FocusSession> focus = const [],
  List<MoodEntry> moods = const [],
  List<DailyLog> logs = const [],
  List<TriggerEntry> triggers = const [],
  List<SchoolNote> notes = const [],
}) =>
    WeekStats.collect(
      week: week,
      completions: completions,
      focus: focus,
      moods: moods,
      dailyLogs: logs,
      triggers: triggers,
      notes: notes,
    );

void main() {
  // Friday 20 Nov 2026: this week is 14 to 20 Nov, the one before 7 to 13.
  final today = DateTime(2026, 11, 20, 15);
  final thisWeek = ReportWeek.endingOn(today);
  final lastWeek = thisWeek.previous;

  group('Report week', () {
    test('covers seven days ending today', () {
      expect(thisWeek.start, DateTime(2026, 11, 14));
      expect(thisWeek.end, DateTime(2026, 11, 21));
      expect(thisWeek.days, hasLength(7));
      expect(thisWeek.contains(DateTime(2026, 11, 20, 23, 59)), isTrue);
      expect(thisWeek.contains(DateTime(2026, 11, 21)), isFalse);
      expect(thisWeek.contains(DateTime(2026, 11, 13, 23)), isFalse);
    });

    test('the week before ends where this one starts', () {
      expect(lastWeek.start, DateTime(2026, 11, 7));
      expect(lastWeek.end, thisWeek.start);
      expect(ReportWeek.endingOn(today, weeksAgo: 1).start, lastWeek.start);
    });
  });

  group('Week stats', () {
    test('counts only what happened in the week', () {
      final s = stats(
        thisWeek,
        completions: [
          done(DateTime(2026, 11, 15, 9)),
          done(DateTime(2026, 11, 15, 18), title: 'Homework'),
          done(DateTime(2026, 11, 17, 9)),
          done(DateTime(2026, 11, 10, 9)), // last week
        ],
        focus: [
          FocusSession(
            durationMinutes: 25,
            completedAt: DateTime(2026, 11, 16, 10),
          ),
        ],
        moods: [
          MoodEntry(mood: 'Happy', recordedAt: DateTime(2026, 11, 15, 8)),
          MoodEntry(mood: 'Sad', recordedAt: DateTime(2026, 11, 16, 8)),
          MoodEntry(mood: 'Calm', recordedAt: DateTime(2026, 11, 17, 8)),
        ],
        logs: [
          DailyLog(day: DateTime(2026, 11, 15), sleepHours: 8, meals: {'Lunch'}),
          DailyLog(day: DateTime(2026, 11, 16), sleepHours: 6, meals: {'Lunch', 'Dinner', 'Breakfast'}),
        ],
        triggers: [
          TriggerEntry(when: DateTime(2026, 11, 16, 17), trigger: 'Screen time ended'),
        ],
      );

      expect(s.tasksDone, 3);
      expect(s.points, 30);
      expect(s.activeDays, 2);
      expect(s.focusMinutes, 25);
      expect(s.moodCheckIns, 3);
      expect(s.positiveMoodPercent, closeTo(66.7, 0.1));
      expect(s.sleepAverage, 7);
      expect(s.mealsPerDay, 2);
      expect(s.hardMoments, 1);
      expect(s.topTasks.first, ('Brush teeth', 2));
      expect(s.dayRows, hasLength(7));
      expect(s.dayRows[1].tasks, 2); // Sunday 15 Nov
      expect(s.hasData, isTrue);
    });

    test('an empty week has no data', () {
      final s = stats(thisWeek);

      expect(s.hasData, isFalse);
      expect(s.positiveMoodPercent, isNull);
      expect(s.sleepAverage, isNull);
    });
  });

  group('Weekly comparison', () {
    WeekStats week(
      ReportWeek w, {
      int tasks = 0,
      int hard = 0,
      String mood = 'Happy',
    }) =>
        stats(
          w,
          completions: [
            for (var i = 0; i < tasks; i++)
              done(DateTime(w.start.year, w.start.month, w.start.day + i % 7, 9)),
          ],
          moods: [
            MoodEntry(mood: mood, recordedAt: w.start.add(const Duration(hours: 8))),
          ],
          triggers: [
            for (var i = 0; i < hard; i++)
              TriggerEntry(when: w.start.add(Duration(hours: 10 + i)), trigger: 'x$i'),
          ],
        );

    test('more tasks and fewer hard moments is progress', () {
      final c = WeeklyComparison.compare(
        week(thisWeek, tasks: 10, hard: 1),
        week(lastWeek, tasks: 4, hard: 3),
      );

      expect(c.trend, WeeklyTrend.improved);
      expect(c.betterCount, greaterThanOrEqualTo(2));
      expect(c.worseCount, 0);
    });

    test('fewer tasks and more hard moments is a harder week', () {
      final c = WeeklyComparison.compare(
        week(thisWeek, tasks: 2, hard: 4, mood: 'Angry'),
        week(lastWeek, tasks: 9, hard: 1),
      );

      expect(c.trend, WeeklyTrend.worse);
    });

    test('small differences count as the same', () {
      final c = WeeklyComparison.compare(
        week(thisWeek, tasks: 5),
        week(lastWeek, tasks: 6),
      );

      expect(c.trend, WeeklyTrend.stable);
    });

    test('without records in the week before there is no comparison', () {
      final c = WeeklyComparison.compare(week(thisWeek, tasks: 5), stats(lastWeek));

      expect(c.trend, WeeklyTrend.noPrevious);
    });

    test('lower is better only for hard moments', () {
      final hard = WeeklyComparison.compare(
        week(thisWeek, hard: 0),
        week(lastWeek, hard: 2),
      ).metrics.firstWhere((m) => m.label == 'Hard moments');

      expect(hard.trend, MetricTrend.better);
    });
  });

  group('Weekly PDF', () {
    test('creates a PDF', () async {
      final bytes = File('fonts/Cairo-Regular.ttf').readAsBytesSync();
      final comparison = WeeklyComparison.compare(
        stats(thisWeek, completions: [done(DateTime(2026, 11, 15, 9))]),
        stats(lastWeek, completions: [done(DateTime(2026, 11, 8, 9))]),
      );

      final pdf = await WeeklyPdf.build(
        childName: 'Omar',
        childAge: 8,
        comparison: comparison,
        fontData: ByteData.sublistView(bytes),
      );

      expect(String.fromCharCodes(pdf.take(4)), '%PDF');
    });
  });
}
