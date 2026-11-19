import 'package:flutter/material.dart';

import '../care/care_models.dart';
import '../care/care_stores.dart';
import '../care/medications_screen.dart';
import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// A Shadow Teacher writes a short note about the child's day at school.
/// The parent reads it on the child's page. Needs the parent's
/// "Focus & behavior" permission.
class SchoolNoteScreen extends StatefulWidget {
  const SchoolNoteScreen({super.key, required this.connection});

  final TeacherConnection connection;

  @override
  State<SchoolNoteScreen> createState() => _SchoolNoteScreenState();
}

class _SchoolNoteScreenState extends State<SchoolNoteScreen> {
  final _controller = TextEditingController();

  int get _childId => widget.connection.childId;

  @override
  void initState() {
    super.initState();
    schoolNoteStore.load(_childId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _teacherName =>
      ShadowStore.instance.myApplication?.fullName ?? 'Shadow Teacher';

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ShadowUi.snack(context, 'Write a note first.');
      return;
    }

    await schoolNoteStore.add(
      _childId,
      SchoolNote(teacherName: _teacherName, text: text),
    );

    _controller.clear();
    if (mounted) ShadowUi.snack(context, 'Note sent to the parent.');
  }

  @override
  Widget build(BuildContext context) {
    final connection = widget.connection;
    final allowed = connection.status == ConnectionStatus.active &&
        connection.permissions[SharePermission.behavior.key] == true;

    return ShadowScaffold(
      title: connection.childName,
      body: [
        if (!allowed)
          const ShadowNote.warning(
            'The parent has not allowed notes about focus and behavior. '
            'Ask them to turn it on in the child’s Support Team.',
          )
        else ...[
          ShadowTextField(
            controller: _controller,
            label: 'Today at school',
            hint: 'e.g. Focused well in math, needed a break at recess',
            maxLines: 4,
            required: false,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          MazidPrimaryButton(label: 'Send note to parent', onPressed: _save),
          const SizedBox(height: 22),
          const ShadowSectionTitle('Notes you sent'),
          AnimatedBuilder(
            animation: schoolNoteStore,
            builder: (context, _) {
              final mine = schoolNoteStore
                  .of(_childId)
                  .where((n) => n.teacherName == _teacherName)
                  .toList();

              if (mine.isEmpty) {
                return const Text(
                  'No notes yet.',
                  style: TextStyle(color: MazidColors.textMuted),
                );
              }

              return Column(
                children: [
                  for (final note in mine)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ShadowCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.text),
                            const SizedBox(height: 6),
                            Text(
                              formatDate(note.writtenAt),
                              style: const TextStyle(
                                color: MazidColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
