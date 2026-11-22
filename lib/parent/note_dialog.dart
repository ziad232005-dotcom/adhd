import 'package:flutter/material.dart';

import '../child.dart' show ChildAppState;

/// Asks the parent for a short message the child sees on their home screen.
/// Returns the text (empty removes the message), or null when cancelled.
class NoteDialog extends StatefulWidget {
  const NoteDialog({super.key, required this.current, required this.name});

  final String current;
  final String name;

  static Future<String?> show(
    BuildContext context, {
    required String current,
    required String name,
  }) =>
      showDialog<String>(
        context: context,
        builder: (_) => NoteDialog(current: current, name: name),
      );

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.current);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Message for ${widget.name}'),
      content: TextField(
        controller: _controller,
        maxLength: ChildAppState.maxNoteLength,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'For example: I am proud of you today',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
