import 'dart:typed_data';

import 'package:flutter/services.dart' show ByteData, rootBundle;

import '../assessments/cars_models.dart';
import '../assessments/cars_pdf.dart';
import '../assessments/cars_store.dart';
import '../assessments/tova_pdf.dart';
import '../assessments/tova_record.dart';
import '../care/care_stores.dart';
import '../care/doctor_pdf.dart';
import '../care/doctor_report.dart';
import '../child.dart';
import '../parent/parent_store.dart';
import 'report_library.dart';
import 'weekly_pdf.dart';
import 'weekly_stats.dart';

/// Builds each kind of report PDF for a child and puts it in the child's
/// reports folder ([ReportLibrary]). Saving never throws: a report that
/// cannot be stored must not break the screen that asked for it.
class ReportBuilder {
  const ReportBuilder._();

  static Future<ByteData> _font() => rootBundle.load('fonts/Cairo-Regular.ttf');

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _day(DateTime d) => '${_two(d.day)}/${_two(d.month)}';
  static String _stamp(DateTime d) => '${d.year}${_two(d.month)}${_two(d.day)}';

  /// Loads everything a report may read for [child].
  static Future<void> prepare(ParentChild child) async {
    await ChildAppState.instance.switchChild(child.id);
    await loadChildRecords(child.id);
    await ReportLibrary.instance.load(child.id);
  }

  // Weekly -----------------------------------------------------------------

  static WeekStats _stats(ParentChild child, ReportWeek week) {
    final data = ChildAppState.instance;

    return WeekStats.collect(
      week: week,
      completions: data.completionHistory,
      focus: data.focusSessions,
      moods: data.moodHistory,
      dailyLogs: dailyLogStore.of(child.id),
      triggers: triggerStore.of(child.id),
      notes: schoolNoteStore.of(child.id),
    );
  }

  /// The last 7 days, compared with the 7 days before. Needs [prepare].
  static Future<Uint8List> weeklyBytes(ParentChild child) async {
    final week = ReportWeek.endingOn(DateTime.now());

    return WeeklyPdf.build(
      childName: child.name,
      childAge: child.age,
      comparison: WeeklyComparison.compare(
        _stats(child, week),
        _stats(child, week.previous),
      ),
      fontData: await _font(),
    );
  }

  /// One weekly file per calendar week; opening Reports again in the same
  /// week brings it up to date. Needs [prepare].
  static Future<SavedReport?> saveWeekly(ParentChild child) async {
    try {
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final week = ReportWeek.endingOn(now);

      return await ReportLibrary.instance.save(
        childId: child.id,
        kind: ReportKind.weekly,
        key: _stamp(monday),
        title: 'Week of ${_day(week.start)} to ${_day(now)}',
        bytes: await weeklyBytes(child),
      );
    } catch (_) {
      return null;
    }
  }

  // CARS -------------------------------------------------------------------

  static Future<SavedReport?> saveCars(
    ParentChild child,
    CarsResult result,
  ) async {
    try {
      final bytes = await CarsPdf.build(
        childName: child.name,
        childAge: child.age,
        current: result,
        history: carsStore.of(child.id),
        fontData: await _font(),
      );

      return await ReportLibrary.instance.save(
        childId: child.id,
        kind: ReportKind.cars,
        key: '${result.takenAt.millisecondsSinceEpoch}',
        title: 'CARS, ${_day(result.takenAt)}/${result.takenAt.year}',
        bytes: bytes,
        createdAt: result.takenAt,
      );
    } catch (_) {
      return null;
    }
  }

  // TOVA -------------------------------------------------------------------

  static Future<SavedReport?> saveTova(
    int childId,
    String childName,
    int childAge,
    TovaRecord record,
  ) async {
    try {
      final bytes = await TovaPdf.build(
        childName: childName,
        childAge: childAge,
        current: record,
        history: tovaStore.of(childId),
        fontData: await _font(),
      );

      return await ReportLibrary.instance.save(
        childId: childId,
        kind: ReportKind.tova,
        key: '${record.takenAt.millisecondsSinceEpoch}',
        title: 'TOVA ${record.modeTitle}, ${_day(record.takenAt)}',
        bytes: bytes,
        createdAt: record.takenAt,
      );
    } catch (_) {
      return null;
    }
  }

  // Doctor -----------------------------------------------------------------

  static DoctorReportData doctorData(ParentChild child) {
    final id = child.id;
    final tasks = ChildAppState.instance;
    final sameChild = tasks.activeChildId == id;

    return DoctorReportData(
      childName: child.name,
      childAge: child.age,
      generatedAt: DateTime.now(),
      cars: carsStore.latest(id),
      tova: tovaStore.latest(id),
      tasksDone: sameChild ? tasks.completedCount : 0,
      tasksTotal: sameChild ? tasks.tasks.length : 0,
      moods: sameChild
          ? [
              for (final m in tasks.moodHistory.take(5))
                '${m.mood} (${m.recordedAt.day}/${m.recordedAt.month})',
            ]
          : const [],
      medications: medicationStore.of(id),
      appointments: appointmentStore.of(id),
      dailyLogs: dailyLogStore.of(id).take(7).toList(),
      triggers: triggerStore.of(id),
      schoolNotes: schoolNoteStore.of(id),
    );
  }

  /// Creates today's doctor report and stores it. Making it again on the
  /// same day replaces it. Needs [prepare]. Returns null if it failed.
  static Future<SavedReport?> saveDoctor(ParentChild child) async {
    try {
      final data = doctorData(child);
      final bytes = await DoctorPdf.build(data: data, fontData: await _font());

      return await ReportLibrary.instance.save(
        childId: child.id,
        kind: ReportKind.doctor,
        key: _stamp(data.generatedAt),
        title: 'For the doctor, ${_day(data.generatedAt)}/'
            '${data.generatedAt.year}',
        bytes: bytes,
      );
    } catch (_) {
      return null;
    }
  }
}
