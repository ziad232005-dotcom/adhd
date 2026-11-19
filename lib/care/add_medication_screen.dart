import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import 'care_form.dart';
import 'care_models.dart';
import 'care_stores.dart';

/// Full page to add a medicine for a child.
class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _times = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _times.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await medicationStore.add(
      widget.child.id,
      Medication(
        name: _name.text.trim(),
        dose: _dose.text.trim(),
        times: _times.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CareFormPage(
      title: 'Add medicine',
      formKey: _formKey,
      onSave: _save,
      children: [
        CareTextField(controller: _name, label: 'Medicine name', required: true),
        CareTextField(controller: _dose, label: 'Dose', hint: 'e.g. 10 mg'),
        CareTextField(
          controller: _times,
          label: 'Times',
          hint: 'e.g. 08:00, 20:00',
        ),
      ],
    );
  }
}
