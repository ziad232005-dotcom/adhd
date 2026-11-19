import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/assessments/cars_models.dart';
import 'package:adhd/assessments/tova_record.dart';
import 'package:adhd/care/care_models.dart';
import 'package:adhd/care/care_stores.dart';
import 'package:adhd/care/doctor_report.dart';
import 'package:adhd/care/triggers_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Per-child records', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('records are kept per child and survive a reload', () async {
      await forgetChildRecords(1);
      await forgetChildRecords(2);

      await medicationStore.add(1, Medication(name: 'Med A', dose: '10 mg'));
      await medicationStore.add(1, Medication(name: 'Med B'));

      expect(medicationStore.of(1).first.name, 'Med B');
      expect(medicationStore.of(2), isEmpty);

      await medicationStore.load(1);
      expect(medicationStore.of(1), hasLength(2));
    });

    test('put replaces a record and removeWhere deletes it', () async {
      await forgetChildRecords(1);

      final med = Medication(name: 'Med A');
      await medicationStore.add(1, med);
      await medicationStore.put(
        1,
        med.copyWith(active: false),
        same: (e) => e.id == med.id,
      );

      expect(medicationStore.of(1), hasLength(1));
      expect(medicationStore.of(1).first.active, isFalse);

      await medicationStore.removeWhere(1, (e) => e.id == med.id);
      expect(medicationStore.of(1), isEmpty);
    });

    test('one daily log per day', () async {
      await forgetChildRecords(1);
      final day = DateTime(2026, 11, 20);

      await dailyLogStore.put(
        1,
        DailyLog(day: day, sleepHours: 7),
        same: (e) => e.sameDay(day),
      );
      await dailyLogStore.put(
        1,
        DailyLog(day: day, sleepHours: 9, meals: {'Lunch'}),
        same: (e) => e.sameDay(day),
      );

      expect(dailyLogStore.of(1), hasLength(1));
      expect(dailyLogStore.of(1).first.sleepHours, 9);
    });

    test('forgetting a child removes all of its records', () async {
      await medicationStore.add(1, Medication(name: 'Med A'));
      await forgetChildRecords(1);

      expect(medicationStore.of(1), isEmpty);
    });

    test('invalid saved records are ignored', () {
      expect(Medication.fromJson({'name': ''}), isNull);
      expect(Appointment.fromJson({'title': 'x', 'when': 'bad'}), isNull);
      expect(TriggerEntry.fromJson({'when': '2026-01-01'}), isNull);
      expect(SchoolNote.fromJson({'text': 'hi'}), isNull);
    });
  });

  group('Triggers', () {
    test('only repeated triggers count, ignoring case', () {
      final now = DateTime(2026, 11, 20);
      final list = [
        TriggerEntry(when: now, trigger: 'Screen time ended'),
        TriggerEntry(when: now, trigger: 'screen time ended '),
        TriggerEntry(when: now, trigger: 'Loud noise'),
      ];

      final common = commonTriggers(list);

      expect(common, hasLength(1));
      expect(common.first.key, 'Screen time ended');
      expect(common.first.value, 2);
    });
  });

  group('Doctor report', () {
    final now = DateTime(2026, 11, 20, 12);

    test('says what is missing when nothing was done', () {
      final text = DoctorReport.build(
        DoctorReportData(childName: 'Omar', childAge: 8, generatedAt: now),
      );

      expect(text, contains('Omar (age 8)'));
      expect(text, contains('Not taken yet.'));
      expect(text, contains('Not done yet.'));
      expect(text, contains('None listed.'));
      expect(text, contains('not a diagnosis'));
    });

    test('includes the results and logs that exist', () {
      final text = DoctorReport.build(
        DoctorReportData(
          childName: 'Omar',
          childAge: 8,
          generatedAt: now,
          cars: CarsResult(
            takenAt: now,
            scores: [3, ...List.filled(14, 2)],
            note: 'Avoids eye contact',
          ),
          tova: TovaRecord(
            takenAt: now,
            modeTitle: 'Standard Practice',
            trials: 40,
            completed: true,
            hits: 10,
            omissions: 2,
            commissions: 1,
            anticipatory: 0,
            accuracyPct: 91,
            meanRtMs: 420,
          ),
          medications: [
            Medication(name: 'Med A', dose: '10 mg', times: '08:00'),
            Medication(name: 'Old', active: false),
          ],
          appointments: [
            Appointment(
              title: 'Dr. Hana',
              kind: AppointmentKind.doctor,
              when: DateTime(2026, 12, 1),
            ),
          ],
          dailyLogs: [
            DailyLog(day: now, sleepHours: 8, meals: {'Lunch', 'Dinner'}),
          ],
          schoolNotes: [SchoolNote(teacherName: 'Mona', text: 'Focused well')],
        ),
      );

      expect(text, contains('31/60'));
      expect(text, contains('Relating to People'));
      expect(text, contains('Avoids eye contact'));
      expect(text, contains('accuracy 91%'));
      expect(text, contains('Med A (10 mg, 08:00)'));
      expect(text, isNot(contains('Old')));
      expect(text, contains('Dr. Hana'));
      expect(text, contains('Average sleep'));
      expect(text, contains('2 of 3'));
      expect(text, contains('Mona: Focused well'));
    });
  });
}
