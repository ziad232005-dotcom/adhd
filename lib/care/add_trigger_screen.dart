import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import 'care_form.dart';
import 'care_models.dart';
import 'care_stores.dart';

/// Full page to log a hard moment.
class AddTriggerScreen extends StatefulWidget {
  const AddTriggerScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<AddTriggerScreen> createState() => _AddTriggerScreenState();
}

class _AddTriggerScreenState extends State<AddTriggerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trigger = TextEditingController();
  final _behavior = TextEditingController();
  final _helped = TextEditingController();

  @override
  void dispose() {
    _trigger.dispose();
    _behavior.dispose();
    _helped.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await triggerStore.add(
      widget.child.id,
      TriggerEntry(
        when: DateTime.now(),
        trigger: _trigger.text.trim(),
        behavior: _behavior.text.trim(),
        helped: _helped.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CareFormPage(
      title: 'Log a hard moment',
      formKey: _formKey,
      onSave: _save,
      children: [
        CareTextField(
          controller: _trigger,
          label: 'What happened just before?',
          hint: 'e.g. screen time ended',
          required: true,
          maxLines: 2,
        ),
        CareTextField(
          controller: _behavior,
          label: 'What did your child do?',
          hint: 'e.g. screamed, cried',
          maxLines: 2,
        ),
        CareTextField(
          controller: _helped,
          label: 'What helped?',
          hint: 'e.g. a hug, a quiet room',
          maxLines: 2,
        ),
      ],
    );
  }
}
