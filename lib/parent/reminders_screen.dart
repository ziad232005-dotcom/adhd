import 'package:flutter/material.dart';

import 'parent_store.dart';
import 'parent_ui.dart';
import 'reminder_form_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ParentStore.instance;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Reminders'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ParentUi.purple,
        foregroundColor: Colors.white,
        onPressed: () => openReminderForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add reminder'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            if (store.reminders.isEmpty) {
              return ParentEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No reminders yet',
                message:
                    'Add reminders for medication, appointments or '
                    'tomorrow’s preparation.',
                actionLabel: 'Add reminder',
                onAction: () => openReminderForm(context),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              itemCount: store.reminders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final reminder = store.reminders[index];
                final overdue =
                    !reminder.done && reminder.dueAt.isBefore(DateTime.now());

                return Dismissible(
                  key: ValueKey('reminder_${reminder.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: ParentUi.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    store.deleteReminder(reminder.id);
                    showParentSnack(context, 'Reminder deleted');
                  },
                  child: ParentCard(
                    onTap: () => openReminderForm(
                      context,
                      reminder: reminder,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: reminder.done
                              ? 'Mark as not done'
                              : 'Mark as done',
                          onPressed: () => store.toggleReminder(reminder.id),
                          icon: Icon(
                            reminder.done
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: reminder.done
                                ? ParentUi.green
                                : const Color(0xFFB8B2CC),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.title,
                                style: TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  decoration: reminder.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                parentDateTimeLabel(context, reminder.dueAt),
                                style: TextStyle(
                                  color: overdue
                                      ? ParentUi.red
                                      : ParentUi.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () {
                            store.deleteReminder(reminder.id);
                            showParentSnack(context, 'Reminder deleted');
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: ParentUi.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
