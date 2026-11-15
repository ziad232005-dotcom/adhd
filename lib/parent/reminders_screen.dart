import 'package:flutter/material.dart';

import 'parent_store.dart';
import 'parent_ui.dart';

/// Opens the dialog used to create a reminder. Returns true when saved.
Future<bool> showAddReminderDialog(
  BuildContext context, {
  String? title,
  DateTime? dueAt,
}) async {
  final titleController = TextEditingController(text: title ?? '');
  var date = dueAt ?? DateTime.now();
  var time = TimeOfDay.fromDateTime(
    dueAt ?? DateTime.now().add(const Duration(hours: 1)),
  );

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'New Reminder',
              style: TextStyle(
                color: ParentUi.dark,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Reminder',
                    prefixIcon: Icon(Icons.edit_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_rounded,
                    color: ParentUi.purple,
                  ),
                  title: const Text('Date'),
                  subtitle: Text(parentDayLabel(date)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => date = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.access_time_rounded,
                    color: ParentUi.purple,
                  ),
                  title: const Text('Time'),
                  subtitle: Text(time.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      setDialogState(() => time = picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ParentUi.purple,
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) {
                    showParentSnack(
                      dialogContext,
                      'Please enter a reminder.',
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  final text = titleController.text.trim();
  titleController.dispose();

  if (saved != true) return false;

  ParentStore.instance.addReminder(
    title: text,
    dueAt: DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ),
  );
  return true;
}

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
        onPressed: () => showAddReminderDialog(context),
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
                onAction: () => showAddReminderDialog(context),
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
