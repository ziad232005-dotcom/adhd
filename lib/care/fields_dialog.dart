import 'package:flutter/material.dart';

/// One text field of [showFieldsDialog].
class DialogField {
  const DialogField(
    this.label, {
    this.hint = '',
    this.required = false,
    this.maxLines = 1,
    this.initial = '',
    this.keyboardType,
  });

  final String label;
  final String hint;
  final bool required;
  final int maxLines;
  final String initial;
  final TextInputType? keyboardType;
}

/// Asks for a few lines of text. Returns the trimmed answers in order,
/// or null when cancelled.
Future<List<String>?> showFieldsDialog(
  BuildContext context, {
  required String title,
  required List<DialogField> fields,
  String saveLabel = 'Save',
}) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _FieldsDialog(
      title: title,
      fields: fields,
      saveLabel: saveLabel,
    ),
  );
}

/// Owns its controllers so they are disposed together with the dialog.
class _FieldsDialog extends StatefulWidget {
  const _FieldsDialog({
    required this.title,
    required this.fields,
    required this.saveLabel,
  });

  final String title;
  final List<DialogField> fields;
  final String saveLabel;

  @override
  State<_FieldsDialog> createState() => _FieldsDialogState();
}

class _FieldsDialogState extends State<_FieldsDialog> {
  late final List<TextEditingController> _controllers = [
    for (final f in widget.fields) TextEditingController(text: f.initial),
  ];

  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final answers = [for (final c in _controllers) c.text.trim()];

    for (var i = 0; i < answers.length; i++) {
      if (widget.fields[i].required && answers[i].isEmpty) {
        setState(() => _error = 'Please fill in “${widget.fields[i].label}”.');
        return;
      }
    }
    Navigator.pop(context, answers);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.fields.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[i],
                  maxLines: widget.fields[i].maxLines,
                  keyboardType: widget.fields[i].keyboardType,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: widget.fields[i].label,
                    hintText: widget.fields[i].hint,
                  ),
                ),
              ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: Text(widget.saveLabel)),
      ],
    );
  }
}
