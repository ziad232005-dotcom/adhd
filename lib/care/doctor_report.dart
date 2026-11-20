import '../assessments/cars_models.dart';
import '../assessments/tova_record.dart';
import 'care_models.dart';
import 'medications_screen.dart';
import 'triggers_screen.dart';

/// Everything the doctor report is made from.
class DoctorReportData {
  const DoctorReportData({
    required this.childName,
    required this.childAge,
    required this.generatedAt,
    this.cars,
    this.tova,
    this.tasksDone = 0,
    this.tasksTotal = 0,
    this.moods = const [],
    this.medications = const [],
    this.appointments = const [],
    this.dailyLogs = const [],
    this.triggers = const [],
    this.schoolNotes = const [],
  });

  final String childName;
  final int childAge;
  final DateTime generatedAt;
  final CarsResult? cars;
  final TovaRecord? tova;
  final int tasksDone;
  final int tasksTotal;

  /// Recent moods, newest first, as `Mood (date)` texts.
  final List<String> moods;
  final List<Medication> medications;
  final List<Appointment> appointments;
  final List<DailyLog> dailyLogs;
  final List<TriggerEntry> triggers;
  final List<SchoolNote> schoolNotes;
}

/// Builds the plain-text report a parent can copy and send to a doctor.
class DoctorReport {
  const DoctorReport._();

  static String build(DoctorReportData d) {
    final b = StringBuffer()
      ..writeln('MΛZID report for ${d.childName} (age ${d.childAge})')
      ..writeln('Created ${formatDate(d.generatedAt)}')
      ..writeln()
      ..writeln('Parent-reported information, not a diagnosis.');

    _section(b, 'CARS questionnaire');
    final cars = d.cars;
    if (cars == null) {
      b.writeln('Not taken yet.');
    } else {
      b
        ..writeln('${formatDate(cars.takenAt)}: ${cars.total}/'
            '${CarsQuestionnaire.maxScore} (${cars.band.label})')
        ..writeln('Areas rated 3 or 4: ${_highAreas(cars)}');
      if (cars.note.isNotEmpty) b.writeln('Parent note: ${cars.note}');
    }

    _section(b, 'TOVA-style attention activity');
    final tova = d.tova;
    if (tova == null) {
      b.writeln('Not done yet.');
    } else {
      b
        ..writeln('${formatDate(tova.takenAt)}: ${tova.modeTitle}, '
            '${tova.trials} trials'
            '${tova.completed ? '' : ' (stopped early)'}')
        ..writeln('Hits ${tova.hits}, omissions ${tova.omissions}, '
            'wrong presses ${tova.commissions}, '
            'accuracy ${tova.accuracyPct.round()}%')
        ..writeln(tova.meanRtMs == null
            ? 'Mean response time: not available'
            : 'Mean response time: ${tova.meanRtMs!.round()} ms')
        ..writeln('Prototype activity: not normative TOVA scores.');
    }

    _section(b, 'Daily life');
    b.writeln('Tasks done today: ${d.tasksDone} of ${d.tasksTotal}');
    b.writeln(d.moods.isEmpty
        ? 'Mood: no check-ins yet.'
        : 'Recent moods: ${d.moods.join(', ')}');

    final logs = d.dailyLogs.where((l) => l.sleepHours != null).toList();
    if (logs.isNotEmpty) {
      final average =
          logs.fold<double>(0, (s, l) => s + l.sleepHours!) / logs.length;
      b.writeln('Average sleep (last ${logs.length} logged days): '
          '${average.toStringAsFixed(1)} h');
    }
    if (d.dailyLogs.isNotEmpty) {
      final meals =
          d.dailyLogs.fold<int>(0, (s, l) => s + l.meals.length);
      b.writeln('Meals eaten well: $meals of ${d.dailyLogs.length * 3} '
          'logged');
    }

    _section(b, 'Medicines');
    final active = d.medications.where((m) => m.active).toList();
    if (active.isEmpty) b.writeln('None listed.');
    for (final m in active) {
      final detail = [m.dose, m.times].where((e) => e.isNotEmpty).join(', ');
      b.writeln('- ${m.name}${detail.isEmpty ? '' : ' ($detail)'}');
    }

    final upcoming = d.appointments
        .where((a) => !a.done && a.when.isAfter(d.generatedAt))
        .toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    if (upcoming.isNotEmpty) {
      _section(b, 'Upcoming appointments');
      for (final a in upcoming.take(5)) {
        b.writeln('- ${formatDate(a.when)}: ${a.title} (${a.kind.label})');
      }
    }

    if (d.triggers.isNotEmpty) {
      _section(b, 'Triggers and hard moments');
      final common = commonTriggers(d.triggers);
      if (common.isNotEmpty) {
        b.writeln('Repeated: ${common.take(3).map((e) => '${e.value}× ${e.key}').join('; ')}');
      }
      for (final t in d.triggers.take(5)) {
        b.writeln('- ${formatDate(t.when)}: ${t.trigger}'
            '${t.behavior.isEmpty ? '' : ' → ${t.behavior}'}'
            '${t.helped.isEmpty ? '' : ' (helped: ${t.helped})'}');
      }
    }

    if (d.schoolNotes.isNotEmpty) {
      _section(b, 'School notes');
      for (final n in d.schoolNotes.take(5)) {
        b.writeln('- ${formatDate(n.writtenAt)}, ${n.teacherName}: ${n.text}');
      }
    }

    return b.toString().trimRight();
  }

  static String _highAreas(CarsResult cars) {
    final names = <String>[
      for (var i = 0; i < cars.scores.length; i++)
        if (cars.scores[i] >= 3) CarsQuestionnaire.items[i].title,
    ];
    return names.isEmpty ? 'none' : names.join(', ');
  }

  static void _section(StringBuffer b, String title) {
    b
      ..writeln()
      ..writeln(title.toUpperCase());
  }
}
