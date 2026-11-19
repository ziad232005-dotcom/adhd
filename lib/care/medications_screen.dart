import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_models.dart';
import 'care_stores.dart';
import 'fields_dialog.dart';

String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Medicines and appointments (doctor, therapy, school) of one child.
class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  int get _id => widget.child.id;

  @override
  void initState() {
    super.initState();
    medicationStore.load(_id);
    appointmentStore.load(_id);
  }

  Future<void> _addMedication() async {
    final answers = await showFieldsDialog(
      context,
      title: 'Add medicine',
      fields: const [
        DialogField('Medicine name', required: true),
        DialogField('Dose', hint: 'e.g. 10 mg'),
        DialogField('Times', hint: 'e.g. 08:00, 20:00'),
      ],
    );
    if (answers == null) return;

    await medicationStore.add(
      _id,
      Medication(name: answers[0], dose: answers[1], times: answers[2]),
    );
  }

  Future<void> _addAppointment() async {
    final answers = await showFieldsDialog(
      context,
      title: 'Add appointment',
      fields: const [
        DialogField('Title', hint: 'e.g. Dr. Hana follow-up', required: true),
      ],
      saveLabel: 'Next',
    );
    if (answers == null || !mounted) return;

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !mounted) return;

    final kind = await showModalBottomSheet<AppointmentKind>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final k in AppointmentKind.values)
              ListTile(
                title: Text(k.label),
                onTap: () => Navigator.pop(sheetContext, k),
              ),
          ],
        ),
      ),
    );
    if (kind == null) return;

    await appointmentStore.add(
      _id,
      Appointment(
        title: answers[0],
        kind: kind,
        when: DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      ),
    );
  }

  Widget _heading(String text, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ParentUi.dark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Medicines & appointments'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([medicationStore, appointmentStore]),
          builder: (context, _) {
            final medicines = medicationStore.of(_id);
            final appointments = appointmentStore.of(_id).toList()
              ..sort((a, b) => a.when.compareTo(b.when));

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                _heading('Medicines', 'Add', _addMedication),
                if (medicines.isEmpty)
                  const ParentCard(
                    child: Text(
                      'No medicines added.',
                      style: TextStyle(color: ParentUi.muted),
                    ),
                  ),
                for (final m in medicines)
                  ParentCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.bold,
                                  decoration: m.active
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                [m.dose, m.times]
                                    .where((e) => e.isNotEmpty)
                                    .join(' • '),
                                style: const TextStyle(
                                  color: ParentUi.muted,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: m.active,
                          onChanged: (value) => medicationStore.put(
                            _id,
                            m.copyWith(active: value),
                            same: (e) => e.id == m.id,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => medicationStore.removeWhere(
                            _id,
                            (e) => e.id == m.id,
                          ),
                        ),
                      ],
                    ),
                  ),
                _heading('Appointments', 'Add', _addAppointment),
                if (appointments.isEmpty)
                  const ParentCard(
                    child: Text(
                      'No appointments added.',
                      style: TextStyle(color: ParentUi.muted),
                    ),
                  ),
                for (final a in appointments)
                  ParentCard(
                    child: Row(
                      children: [
                        Checkbox(
                          value: a.done,
                          onChanged: (value) => appointmentStore.put(
                            _id,
                            a.copyWith(done: value ?? false),
                            same: (e) => e.id == a.id,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                style: TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.bold,
                                  decoration: a.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              Text(
                                '${a.kind.label} • ${formatDate(a.when)} '
                                '${formatTime(a.when)}',
                                style: const TextStyle(
                                  color: ParentUi.muted,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => appointmentStore.removeWhere(
                            _id,
                            (e) => e.id == a.id,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Reminders on the phone are not set up yet. These lists '
                  'are for you and for the doctor report.',
                  style: TextStyle(color: ParentUi.muted, fontSize: 12.5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
