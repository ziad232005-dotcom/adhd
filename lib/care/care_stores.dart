import '../assessments/cars_store.dart';
import '../assessments/child_records.dart';
import '../assessments/tova_record.dart';
import 'care_models.dart';

final medicationStore = ChildRecords<Medication>(
  keyPrefix: 'mazid_medications_child_',
  fromJson: Medication.fromJson,
  toJson: (item) => item.toJson(),
);

final appointmentStore = ChildRecords<Appointment>(
  keyPrefix: 'mazid_appointments_child_',
  fromJson: Appointment.fromJson,
  toJson: (item) => item.toJson(),
);

final dailyLogStore = ChildRecords<DailyLog>(
  keyPrefix: 'mazid_daily_logs_child_',
  fromJson: DailyLog.fromJson,
  toJson: (item) => item.toJson(),
);

final triggerStore = ChildRecords<TriggerEntry>(
  keyPrefix: 'mazid_triggers_child_',
  fromJson: TriggerEntry.fromJson,
  toJson: (item) => item.toJson(),
);

final schoolNoteStore = ChildRecords<SchoolNote>(
  keyPrefix: 'mazid_school_notes_child_',
  fromJson: SchoolNote.fromJson,
  toJson: (item) => item.toJson(),
);

/// Loads everything saved for a child.
Future<void> loadChildRecords(int childId) => Future.wait([
      carsStore.load(childId),
      tovaStore.load(childId),
      medicationStore.load(childId),
      appointmentStore.load(childId),
      dailyLogStore.load(childId),
      triggerStore.load(childId),
      schoolNoteStore.load(childId),
    ]);

/// Removes everything saved for a deleted child.
Future<void> forgetChildRecords(int childId) => Future.wait([
      carsStore.forget(childId),
      tovaStore.forget(childId),
      medicationStore.forget(childId),
      appointmentStore.forget(childId),
      dailyLogStore.forget(childId),
      triggerStore.forget(childId),
      schoolNoteStore.forget(childId),
    ]);
