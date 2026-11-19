import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assessments/cars_store.dart';
import '../assessments/tova_record.dart';
import '../child.dart';
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_stores.dart';
import 'doctor_report.dart';

/// One page with everything a doctor may ask for. The parent copies it
/// as text and sends it.
class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen> {
  @override
  void initState() {
    super.initState();
    loadChildRecords(widget.child.id);
  }

  String _text() {
    final id = widget.child.id;
    final tasks = ChildAppState.instance;
    final sameChild = tasks.activeChildId == id;

    return DoctorReport.build(
      DoctorReportData(
        childName: widget.child.name,
        childAge: widget.child.age,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Doctor report'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            carsStore,
            tovaStore,
            medicationStore,
            appointmentStore,
            dailyLogStore,
            triggerStore,
            schoolNoteStore,
          ]),
          builder: (context, _) {
            final text = _text();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                ParentCard(
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                      color: ParentUi.dark,
                      height: 1.5,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report copied. Paste it in a message.'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: ParentUi.purple,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy report'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
