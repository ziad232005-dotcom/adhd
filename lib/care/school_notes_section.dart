import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_stores.dart';
import 'medications_screen.dart';

/// The latest notes the child's Shadow Teachers wrote, shown to the
/// parent on the child's page.
class SchoolNotesSection extends StatelessWidget {
  const SchoolNotesSection({super.key, required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: schoolNoteStore,
      builder: (context, _) {
        final notes = schoolNoteStore.of(child.id).take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                'From school',
                style: TextStyle(
                  color: ParentUi.dark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (notes.isEmpty)
              const ParentCard(
                child: Text(
                  'Notes from your child’s Shadow Teacher appear here.',
                  style: TextStyle(color: ParentUi.muted),
                ),
              ),
            for (final note in notes)
              ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.text,
                      style: const TextStyle(color: ParentUi.dark, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${note.teacherName} • ${formatDate(note.writtenAt)}',
                      style: const TextStyle(
                        color: ParentUi.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
