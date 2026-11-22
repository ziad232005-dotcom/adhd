import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../add_task.dart';
import '../assessments/assessments_screen.dart';
import '../care/care_section.dart';
import '../child.dart';
import '../link/child_qr_screen.dart';
import '../manage_rewards.dart';
import '../screens/track_behavior.dart';
import '../shadows/shadow_directory_screen.dart';
import '../tova/tova_hub_screen.dart';
import 'add_child_screen.dart';
import 'note_dialog.dart';
import 'parent_insights.dart';
import 'parent_store.dart';
import 'parent_ui.dart';
import '../reports/reports_screen.dart';

/// Everything about one child: tasks, points, rewards, observations
/// and mood. Opening it selects the child, so every other tab follows.
class ChildDetailScreen extends StatefulWidget {
  final int childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  final _store = ParentStore.instance;
  final _data = ChildAppState.instance;

  @override
  void initState() {
    super.initState();

    // Selecting notifies other screens, so it must not run while this
    // screen is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _store.children.indexWhere((c) => c.id == widget.childId);
      if (index != -1) _store.selectChild(index);
    });
  }

  ParentChild? get _child {
    for (final child in _store.children) {
      if (child.id == widget.childId) return child;
    }
    return null;
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _edit(ParentChild child) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddChildScreen(child: child)),
    );

    if (mounted && _child == null) Navigator.pop(context);
  }

  Widget _avatar(ParentChild child) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: ParentUi.soft,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: child.imagePath != null
          ? Image.file(
              File(child.imagePath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.face_rounded,
                size: 42,
                color: ParentUi.purple,
              ),
            )
          : const Icon(
              Icons.face_rounded,
              size: 42,
              color: ParentUi.purple,
            ),
    );
  }

  Future<void> _changePin(ParentChild child) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => _PinDialog(current: child.pin),
    );

    if (pin == null || !mounted) return;
    _store.updateChild(child.copyWith(pin: pin));
  }

  Future<void> _editNote(ParentChild child) async {
    final note = await NoteDialog.show(
      context,
      current: _data.parentNote,
      name: child.name,
    );
    if (note == null || !mounted) return;
    _data.setParentNote(note);
  }

  /// Where the parent hands the phone to the child: shows the child's
  /// PIN and opens the child's own screen.
  Widget _childMode(ParentChild child) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${child.name}’s PIN: ${child.pin}',
                  style: const TextStyle(
                    color: ParentUi.dark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _changePin(child),
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: ParentUi.purple,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _open(ChildLoginScreen(child: child)),
            icon: const Icon(Icons.child_care_rounded),
            label: Text('Open ${child.name}’s screen'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: ParentUi.purple,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: ParentUi.purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _open(ChildQrScreen(child: child)),
            icon: const Icon(Icons.qr_code_2_rounded),
            label: Text('QR for ${child.name}’s own phone'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: ParentUi.purple,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: ParentUi.purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _editNote(child),
            icon: const Icon(Icons.favorite_border_rounded),
            label: Text('Message for ${child.name}'),
          ),
        ],
      ),
    );
  }

  Widget _title(String text, {String? action, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ParentUi.dark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (action != null)
            TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: ParentCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: ParentUi.purple, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: ParentUi.dark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ParentUi.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text) {
    return ParentCard(
      child: Text(
        text,
        style: const TextStyle(
          color: ParentUi.muted,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _tasks() {
    if (_data.tasks.isEmpty) {
      return _empty('No tasks yet. Tap "Add task" to create the first one.');
    }

    return ParentCard(
      child: Column(
        children: [
          for (final task in _data.tasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Icon(
                    _data.isCompleted(task)
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _data.isCompleted(task)
                        ? ParentUi.green
                        : const Color(0xFFB8B2CC),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: ParentUi.dark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: _data.isCompleted(task)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    '${task.points} pts',
                    style: const TextStyle(
                      color: ParentUi.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _rewards() {
    if (_data.rewards.isEmpty) {
      return _empty('No rewards yet. Tap "Manage" to create one.');
    }

    return Column(
      children: [
        for (final reward in _data.rewards)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ParentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reward.title,
                          style: const TextStyle(
                            color: ParentUi.dark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_data.hasAchievedReward(reward))
                        const Icon(
                          Icons.check_circle_rounded,
                          color: ParentUi.green,
                          size: 20,
                        )
                      else
                        Text(
                          '${_data.points}/${reward.targetPoints}',
                          style: const TextStyle(
                            color: ParentUi.muted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: reward.targetPoints <= 0
                          ? 0
                          : (_data.points / reward.targetPoints)
                              .clamp(0.0, 1.0),
                      backgroundColor: ParentUi.soft,
                      color: ParentUi.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _observations() {
    final items = _data.observations.take(5).toList();

    if (items.isEmpty) {
      return _empty('No observations yet. Use Track Behavior to add one.');
    }

    return ParentCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  items[i].type == 'task'
                      ? Icons.check_circle_outline_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: ParentUi.purple,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].title,
                        style: const TextStyle(
                          color: ParentUi.dark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].description,
                        style: const TextStyle(
                          color: ParentUi.muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parentTimeAgo(items[i].timestamp),
                        style: const TextStyle(
                          color: ParentUi.purple,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _moods() {
    final items = _data.moodHistory.take(5).toList();

    if (items.isEmpty) {
      return _empty('No mood check-ins yet.');
    }

    return ParentCard(
      child: Column(
        children: [
          for (final entry in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.mood_rounded,
                    color: ParentUi.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.mood,
                      style: const TextStyle(
                        color: ParentUi.dark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    parentTimeAgo(entry.recordedAt),
                    style: const TextStyle(
                      color: ParentUi.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_data, _store]),
      builder: (context, _) {
        final child = _child;

        if (child == null) {
          return Scaffold(
            backgroundColor: ParentUi.background,
            appBar: parentAppBar(context, 'Child'),
            body: const ParentEmptyState(
              icon: Icons.child_care_rounded,
              title: 'Child not found',
              message: 'This child was removed.',
            ),
          );
        }

        // Wait until this child's data has been loaded.
        final ready = _data.activeChildId == child.id;
        final insights = ParentInsights(_data);

        return Scaffold(
          backgroundColor: ParentUi.background,
          appBar: parentAppBar(
            context,
            child.name,
            actions: [
              IconButton(
                tooltip: 'Edit child',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: ParentUi.dark,
                ),
                onPressed: () => _edit(child),
              ),
            ],
          ),
          body: SafeArea(
            child: !ready
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                    children: [
                      ParentCard(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            _avatar(child),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      color: ParentUi.dark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${child.age} years old • ${child.grade}',
                                    style: const TextStyle(
                                      color: ParentUi.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _stat(
                            Icons.stars_rounded,
                            '${_data.points}',
                            'Points',
                          ),
                          const SizedBox(width: 10),
                          _stat(
                            Icons.task_alt_rounded,
                            '${_data.completedCount}/${_data.tasks.length}',
                            'Tasks done',
                          ),
                          const SizedBox(width: 10),
                          _stat(
                            Icons.local_fire_department_rounded,
                            '${insights.streakDays}',
                            'Day streak',
                          ),
                          const SizedBox(width: 10),
                          _stat(
                            Icons.timer_outlined,
                            '${insights.todayFocusMinutes} m',
                            'Focus today',
                          ),
                        ],
                      ),
                      _title('Child mode'),
                      _childMode(child),
                      _title('Tests'),
                      ParentCard(
                        onTap: () =>
                            _open(AssessmentsScreen(child: child)),
                        child: const Row(
                          children: [
                            Icon(Icons.fact_check_rounded,
                                color: ParentUi.purple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'CARS questionnaire',
                                style: TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: ParentUi.muted),
                          ],
                        ),
                      ),
                      ParentCard(
                        onTap: () => _open(TovaHubScreen(child: child)),
                        child: const Row(
                          children: [
                            Icon(Icons.center_focus_strong_rounded,
                                color: ParentUi.purple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'TOVA attention test',
                                style: TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: ParentUi.muted),
                          ],
                        ),
                      ),
                      _title(
                        'Tasks',
                        action: 'Add task',
                        onTap: () => _open(const AddTaskScreen()),
                      ),
                      _tasks(),
                      _title(
                        'Rewards',
                        action: 'Manage',
                        onTap: () => _open(const ManageRewardsScreen()),
                      ),
                      _rewards(),
                      _title(
                        'Recent observations',
                        action: 'Track',
                        onTap: () => _open(const TrackBehaviorScreen()),
                      ),
                      _observations(),
                      _title('Mood'),
                      _moods(),
                      _title('Care'),
                      CareSection(child: child),
                      _title('Shadow Teachers'),
                      ParentCard(
                        onTap: () => _open(const ShadowDirectoryScreen()),
                        child: const Row(
                          children: [
                            Icon(Icons.school_rounded, color: ParentUi.purple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Find a verified Shadow Teacher',
                                style: TextStyle(
                                  color: ParentUi.dark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: ParentUi.muted),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ParentUi.purple,
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: ParentUi.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => _open(ReportsScreen(child: child)),
                        icon: const Icon(Icons.folder_rounded),
                        label: Text("${child.name}'s reports"),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Asks for a new 4-digit PIN. Owns its controller so it is disposed
/// together with the dialog.
class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.current});

  final String current;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.current);

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();

    if (!ParentChild.isValidPin(value)) {
      setState(() => _error = 'Enter exactly 4 digits.');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Child PIN'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        maxLength: 4,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: '4-digit PIN',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
