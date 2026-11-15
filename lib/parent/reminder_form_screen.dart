import 'package:flutter/material.dart';

import 'parent_store.dart';
import 'parent_ui.dart';

/// Opens the reminder page. Returns true when a reminder was saved
/// or deleted.
Future<bool> openReminderForm(
  BuildContext context, {
  ParentReminder? reminder,
  String? initialTitle,
}) async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => ReminderFormScreen(
        reminder: reminder,
        initialTitle: initialTitle,
      ),
    ),
  );

  return result == true;
}

/// Page to create a reminder, or edit one when [reminder] is given.
class ReminderFormScreen extends StatefulWidget {
  final ParentReminder? reminder;
  final String? initialTitle;

  const ReminderFormScreen({
    super.key,
    this.reminder,
    this.initialTitle,
  });

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = ParentStore.instance;

  late final TextEditingController _titleController;
  late DateTime _date;
  late TimeOfDay _time;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();

    final reminder = widget.reminder;
    final start =
        reminder?.dueAt ?? DateTime.now().add(const Duration(hours: 1));

    _titleController = TextEditingController(
      text: reminder?.title ?? widget.initialTitle ?? '',
    );
    _date = DateTime(start.year, start.month, start.day);
    _time = TimeOfDay.fromDateTime(start);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  DateTime get _dueAt => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final firstDate = _date.isBefore(todayOnly) ? _date : todayOnly;

    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: firstDate,
      lastDate: todayOnly.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _setQuick(DateTime value) {
    setState(() {
      _date = DateTime(value.year, value.month, value.day);
      _time = TimeOfDay.fromDateTime(value);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _dueAt.isBefore(DateTime.now())) {
      showParentSnack(context, 'Please choose a time in the future.');
      return;
    }

    final title = _titleController.text.trim();

    if (_isEditing) {
      _store.updateReminder(
        id: widget.reminder!.id,
        title: title,
        dueAt: _dueAt,
      );
    } else {
      _store.addReminder(title: title, dueAt: _dueAt);
    }

    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('"${widget.reminder!.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: ParentUi.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    _store.deleteReminder(widget.reminder!.id);
    Navigator.pop(context, true);
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ParentCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: ParentUi.purple),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: ParentUi.muted, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ParentUi.dark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: ParentUi.muted,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tonight = DateTime(now.year, now.month, now.day, 20);
    final tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 8);

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(
        context,
        _isEditing ? 'Edit Reminder' : 'New Reminder',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'What should we remind you about?',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reminder.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _pickerTile(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: parentDayLabel(_date),
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              _pickerTile(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: _time.format(context),
                onTap: _pickTime,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('In 1 hour'),
                    onPressed: () =>
                        _setQuick(DateTime.now().add(const Duration(hours: 1))),
                  ),
                  if (tonight.isAfter(now))
                    ActionChip(
                      label: const Text('Tonight 8 PM'),
                      onPressed: () => _setQuick(tonight),
                    ),
                  ActionChip(
                    label: const Text('Tomorrow 8 AM'),
                    onPressed: () => _setQuick(tomorrowMorning),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ParentUi.purple,
                  ),
                  onPressed: _save,
                  child: Text(
                    _isEditing ? 'Save changes' : 'Save reminder',
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: ParentUi.red,
                  ),
                  label: const Text(
                    'Delete reminder',
                    style: TextStyle(color: ParentUi.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
