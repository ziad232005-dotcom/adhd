import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import 'care_form.dart';
import 'care_models.dart';
import 'care_stores.dart';

/// Full page to write down something the school or a teacher said.
class AddSchoolNoteScreen extends StatefulWidget {
  const AddSchoolNoteScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<AddSchoolNoteScreen> createState() => _AddSchoolNoteScreenState();
}

class _AddSchoolNoteScreenState extends State<AddSchoolNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _from = TextEditingController();
  final _text = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final from = _from.text.trim();
    await schoolNoteStore.add(
      widget.child.id,
      SchoolNote(
        teacherName: from.isEmpty ? 'School' : from,
        text: _text.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CareFormPage(
      title: 'Add a school note',
      formKey: _formKey,
      onSave: _save,
      children: [
        CareTextField(
          controller: _from,
          label: 'Who said it? (optional)',
          hint: 'e.g. Ms. Mona, class teacher',
        ),
        CareTextField(
          controller: _text,
          label: 'What did they say?',
          hint: 'e.g. Calm during math, hard to sit in art',
          required: true,
          maxLines: 4,
        ),
      ],
    );
  }
}
