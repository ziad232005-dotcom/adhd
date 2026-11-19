import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_form.dart';
import 'care_models.dart';
import 'care_stores.dart';
import 'medications_screen.dart';

/// Full page to add a doctor, therapy or school appointment.
class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();

  AppointmentKind _kind = AppointmentKind.doctor;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await appointmentStore.add(
      widget.child.id,
      Appointment(
        title: _title.text.trim(),
        kind: _kind,
        when: DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CareFormPage(
      title: 'Add appointment',
      formKey: _formKey,
      onSave: _save,
      children: [
        CareTextField(
          controller: _title,
          label: 'Title',
          hint: 'e.g. Dr. Hana follow-up',
          required: true,
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Type',
            style: TextStyle(color: ParentUi.muted, fontSize: 12.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Wrap(
            spacing: 8,
            children: [
              for (final kind in AppointmentKind.values)
                ChoiceChip(
                  label: Text(kind.label),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
        ),
        CarePickerTile(
          icon: Icons.event_rounded,
          label: formatDate(_date),
          onTap: _pickDate,
        ),
        CarePickerTile(
          icon: Icons.schedule_rounded,
          label: _time.format(context),
          onTap: _pickTime,
        ),
      ],
    );
  }
}
