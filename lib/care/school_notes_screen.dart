import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'add_school_note_screen.dart';
import 'care_stores.dart';
import 'medications_screen.dart';

/// What the child's teachers or the school told the parent, newest first.
class SchoolNotesScreen extends StatelessWidget {
  const SchoolNotesScreen({super.key, required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'School notes'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ParentUi.purple,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddSchoolNoteScreen(child: child),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add note'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: schoolNoteStore,
          builder: (context, _) {
            final notes = schoolNoteStore.of(child.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              children: [
                if (notes.isEmpty)
                  const ParentCard(
                    child: Text(
                      'No notes yet. Write down what the teacher or the '
                      'school tells you about your child, so it goes into '
                      'the doctor report.',
                      style: TextStyle(color: ParentUi.muted, height: 1.45),
                    ),
                  ),
                for (final note in notes)
                  ParentCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.text,
                                style: const TextStyle(
                                  color: ParentUi.dark,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${note.teacherName} • '
                                '${formatDate(note.writtenAt)}',
                                style: const TextStyle(
                                  color: ParentUi.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => schoolNoteStore.removeWhere(
                            child.id,
                            (e) => e.id == note.id,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
