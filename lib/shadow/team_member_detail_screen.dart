import 'package:flutter/material.dart';

import '../child.dart';
import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import '../parent/parent_insights.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'teacher_profile_screen.dart';
import '../parent/parent_store.dart';

/// What the parent sees about one Shadow Teacher on the child's team:
/// profile, what they can access, today's activity of the child (only
/// the parts the parent allowed) and the button to revoke access.
class TeamMemberDetailScreen extends StatefulWidget {
  const TeamMemberDetailScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  State<TeamMemberDetailScreen> createState() =>
      _TeamMemberDetailScreenState();
}

class _TeamMemberDetailScreenState extends State<TeamMemberDetailScreen> {
  final _store = ShadowStore.instance;
  final _data = ChildAppState.instance;

  Future<void> _revoke(TeacherConnection c, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const CircleAvatar(
          radius: 28,
          backgroundColor: MazidColors.errorSoft,
          child: Icon(Icons.warning_amber_rounded, color: MazidColors.error),
        ),
        title: Text('Revoke $name’s access?'),
        content: Text(
          '$name will immediately lose access to ${c.childName}’s tasks, '
          'reports and notes. Past reports stay in ${c.childName}’s history.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: MazidColors.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    _store.revoke(c.id);
    ShadowUi.snack(context, 'Access revoked');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, _data]),
      builder: (context, _) {
        final c = _store.connectionById(widget.connectionId);

        if (c == null || c.status != ConnectionStatus.active) {
          return ShadowScaffold(
            title: 'Team member',
            children: const [
              SizedBox(height: 40),
              Center(child: Text('This person is no longer on the team.')),
            ],
          );
        }

        final teacher = _store.listingById(c.teacherId);
        final name = teacher?.name ?? 'Shadow Teacher';

        // Child data is loaded for the selected child only.
        final childReady = _data.activeChildId == c.childId;
        final insights = ParentInsights(_data);

        return ShadowScaffold(
          title: name,
          children: [
            ShadowCard(
              child: Row(
                children: [
                  ShadowAvatar(initials: teacher?.initials ?? 'ST', size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: MazidColors.textDark,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Shadow Teacher',
                          style: TextStyle(
                            color: MazidColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ShadowBadge.connection(c.status),
                ],
              ),
            ),
            const ShadowSectionTitle('What they can see'),
            ShadowCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (final p in SharePermission.all)
                    ShadowPermissionTile(
                      title: p.title,
                      subtitle: p.subtitle,
                      value: c.permissions[p.key] ?? false,
                      onChanged: (v) {
                        final next = Map<String, bool>.of(c.permissions)
                          ..[p.key] = v;
                        _store.updatePermissions(c.id, next);
                      },
                    ),
                ],
              ),
            ),
            ShadowSectionTitle('${c.childName}’s day'),
            if (!childReady)
              const ShadowNote(
                'Open this child from your dashboard to see today’s activity.',
              )
            else
              _activity(c, insights),
            const ShadowSectionTitle('Reports'),
            const ShadowCard(
              child: Text(
                'Reports written by this teacher will appear here.',
                style: TextStyle(
                  color: MazidColors.textMuted,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (teacher != null)
              MazidOutlineButton(
                label: 'View professional profile',
                borderColor: MazidColors.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeacherProfileScreen(
                      teacher: teacher,
                      child: _childFor(c),
                    ),
                  ),
                ),
              ),
          ],
          bottom: MazidOutlineButton(
            label: 'Revoke access',
            borderColor: MazidColors.error,
            onPressed: () => _revoke(c, name),
          ),
        );
      },
    );
  }

  ParentChild _childFor(TeacherConnection c) {
    for (final child in ParentStore.instance.children) {
      if (child.id == c.childId) return child;
    }
    return ParentStore.instance.children.first;
  }

  Widget _activity(TeacherConnection c, ParentInsights insights) {
    final canTasks = c.permissions['tasks'] == true;
    final canBehavior = c.permissions['behavior'] == true;
    final canMood = c.permissions['mood'] == true;

    if (!canTasks && !canBehavior && !canMood) {
      return const ShadowNote(
        'Turn on a permission above to share part of the child’s day.',
      );
    }

    final mood = insights.topMoodThisWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (canBehavior)
              _Tile('${insights.todayFocusMinutes} min', 'Focus today'),
            if (canBehavior && canMood) const SizedBox(width: 10),
            if (canMood) _Tile(mood ?? '—', 'Mood this week'),
            if ((canBehavior || canMood) && canTasks)
              const SizedBox(width: 10),
            if (canTasks)
              _Tile(
                '${_data.completedCount}/${_data.tasks.length}',
                'Tasks today',
              ),
          ],
        ),
        if (canTasks) ...[
          const SizedBox(height: 12),
          ShadowCard(
            child: Column(
              children: [
                for (final task in _data.tasks)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _data.isCompleted(task)
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: _data.isCompleted(task)
                              ? MazidColors.success
                              : MazidColors.border,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              color: MazidColors.textBody,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Text(
                          _data.isCompleted(task) ? 'Done' : 'To do',
                          style: TextStyle(
                            color: _data.isCompleted(task)
                                ? MazidColors.success
                                : MazidColors.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ShadowCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MazidColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MazidColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
