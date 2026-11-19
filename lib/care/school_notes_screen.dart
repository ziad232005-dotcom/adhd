import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_stores.dart';
import 'medications_screen.dart';

/// All notes the child's Shadow Teachers sent, newest first.
class SchoolNotesScreen extends StatelessWidget {
  const SchoolNotesScreen({super.key, required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'From school'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: schoolNoteStore,
          builder: (context, _) {
            final notes = schoolNoteStore.of(child.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                if (notes.isEmpty)
                  const ParentCard(
                    child: Text(
                      'No notes yet. When your child’s Shadow Teacher sends '
                      'a note, it appears here. To receive notes, connect a '
                      'Shadow Teacher in Support Team and allow “Focus & '
                      'behavior”.',
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
