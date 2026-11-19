import 'package:flutter/material.dart';

import '../parent/parent_ui.dart';

/// A full page with a form and a Save button at the bottom. Used by every
/// "add" page in the Care section.
class CareFormPage extends StatelessWidget {
  const CareFormPage({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
    this.saveLabel = 'Save',
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, title),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: children,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: ParentUi.purple,
                  shape: const StadiumBorder(),
                ),
                child: Text(saveLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded text field for [CareFormPage].
class CareTextField extends StatelessWidget {
  const CareTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.required = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                ? 'Please fill this in.'
                : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: ParentUi.border),
          ),
        ),
      ),
    );
  }
}

/// A tappable row that shows a chosen value (date, time...).
class CarePickerTile extends StatelessWidget {
  const CarePickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ParentCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: ParentUi.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: ParentUi.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ParentUi.muted),
          ],
        ),
      ),
    );
  }
}
