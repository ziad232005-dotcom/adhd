import 'package:flutter/material.dart';

/// Asks for the parent's 6 digits. The dialog owns its text field, so the
/// field is only disposed after the dialog has fully closed.
class ParentCodeDialog extends StatefulWidget {
  const ParentCodeDialog({super.key, required this.action});

  /// The label of the confirm button.
  final String action;

  /// What the parent typed, or null when the dialog was cancelled.
  static Future<String?> show(BuildContext context, String action) {
    return showDialog<String>(
      context: context,
      builder: (_) => ParentCodeDialog(action: action),
    );
  }

  @override
  State<ParentCodeDialog> createState() => _ParentCodeDialogState();
}

class _ParentCodeDialogState extends State<ParentCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Parent code'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        onSubmitted: (_) => _done(),
        decoration: const InputDecoration(
          hintText: 'The 6 digits shown on the parent phone',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _done, child: Text(widget.action)),
      ],
    );
  }
}
