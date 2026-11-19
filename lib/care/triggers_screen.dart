import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_models.dart';
import 'care_stores.dart';
import 'fields_dialog.dart';
import 'medications_screen.dart';

/// Hard moments: what came before, what the child did, what helped.
/// The summary at the top counts the most common triggers.
class TriggersScreen extends StatefulWidget {
  const TriggersScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<TriggersScreen> createState() => _TriggersScreenState();
}

class _TriggersScreenState extends State<TriggersScreen> {
  int get _id => widget.child.id;

  @override
  void initState() {
    super.initState();
    triggerStore.load(_id);
  }

  Future<void> _add() async {
    final answers = await showFieldsDialog(
      context,
      title: 'Log a hard moment',
      fields: const [
        DialogField(
          'What happened just before?',
          hint: 'e.g. screen time ended',
          required: true,
        ),
        DialogField('What did your child do?', hint: 'e.g. screamed, cried'),
        DialogField('What helped?', hint: 'e.g. a hug, quiet room'),
      ],
    );
    if (answers == null) return;

    await triggerStore.add(
      _id,
      TriggerEntry(
        when: DateTime.now(),
        trigger: answers[0],
        behavior: answers[1],
        helped: answers[2],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Triggers'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ParentUi.purple,
        foregroundColor: Colors.white,
        onPressed: _add,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log moment'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: triggerStore,
          builder: (context, _) {
            final entries = triggerStore.of(_id);
            final common = commonTriggers(entries);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              children: [
                if (entries.isEmpty)
                  const ParentCard(
                    child: Text(
                      'Nothing logged yet. After a hard moment, write what '
                      'came before it. Patterns appear after a few entries.',
                      style: TextStyle(color: ParentUi.muted, height: 1.45),
                    ),
                  ),
                if (common.isNotEmpty)
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Most common triggers',
                          style: TextStyle(
                            color: ParentUi.dark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final e in common.take(3))
                          Text(
                            '${e.value}× ${e.key}',
                            style: const TextStyle(color: ParentUi.purple),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                for (final entry in entries)
                  ParentCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.trigger,
                                style: const TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (entry.behavior.isNotEmpty)
                                Text('Did: ${entry.behavior}'),
                              if (entry.helped.isNotEmpty)
                                Text('Helped: ${entry.helped}'),
                              Text(
                                '${formatDate(entry.when)} ${formatTime(entry.when)}',
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
                          onPressed: () => triggerStore.removeWhere(
                            _id,
                            (e) => e.id == entry.id,
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

/// Triggers that were logged more than once, most common first. Texts
/// are compared ignoring case and spaces at the ends.
List<MapEntry<String, int>> commonTriggers(List<TriggerEntry> entries) {
  final counts = <String, int>{};
  final labels = <String, String>{};

  for (final entry in entries) {
    final key = entry.trigger.trim().toLowerCase();
    labels.putIfAbsent(key, () => entry.trigger.trim());
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final list = [
    for (final e in counts.entries)
      if (e.value > 1) MapEntry(labels[e.key]!, e.value),
  ]..sort((a, b) => b.value.compareTo(a.value));

  return list;
}
