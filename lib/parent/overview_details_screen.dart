import 'package:flutter/material.dart';

import '../child.dart';
import 'parent_insights.dart';
import 'parent_ui.dart';

/// "See details" page for Today's Overview.
class OverviewDetailsScreen extends StatelessWidget {
  /// Routine items from the dashboard (title, time, completed).
  final List<Map<String, dynamic>> routines;

  const OverviewDetailsScreen({super.key, required this.routines});

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: ParentUi.dark,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row({
    required bool done,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: done ? ParentUi.green : const Color(0xFFB8B2CC),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ParentUi.dark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(color: ParentUi.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, "Today's Overview"),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: data,
          builder: (context, _) {
            final insights = ParentInsights(data);
            final doneRoutine =
                routines.where((r) => r['completed'] == true).length;
            final todaySessions = data.focusSessions.where((s) {
              final now = DateTime.now();
              return s.completedAt.year == now.year &&
                  s.completedAt.month == now.month &&
                  s.completedAt.day == now.day;
            }).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              children: [
                _sectionTitle('Tasks  ${data.completedCount}/${data.tasks.length}'),
                ParentCard(
                  child: data.tasks.isEmpty
                      ? const Text(
                          'No tasks yet. Add one from the Tasks tab.',
                          style: TextStyle(
                            color: ParentUi.muted,
                            fontSize: 13,
                          ),
                        )
                      : Column(
                          children: [
                            for (final task in data.tasks)
                              _row(
                                done: data.isCompleted(task),
                                title: task.title,
                                trailing: '${task.points} pts',
                              ),
                          ],
                        ),
                ),
                _sectionTitle('Routine  $doneRoutine/${routines.length}'),
                ParentCard(
                  child: routines.isEmpty
                      ? const Text(
                          'No routine items yet. Tap + on the Daily '
                          'Routine card to add one.',
                          style: TextStyle(
                            color: ParentUi.muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        )
                      : Column(
                          children: [
                            for (final item in routines)
                              _row(
                                done: item['completed'] == true,
                                title: item['title']?.toString() ?? 'Routine',
                                trailing: item['time']?.toString() ?? '',
                              ),
                          ],
                        ),
                ),
                _sectionTitle('Focus & mood'),
                ParentCard(
                  child: Column(
                    children: [
                      _infoLine(
                        Icons.psychology_alt_rounded,
                        'Focus today',
                        insights.todayFocusMinutes == 0
                            ? 'No sessions'
                            : '${insights.todayFocusMinutes} min '
                                '($todaySessions session'
                                '${todaySessions == 1 ? '' : 's'})',
                      ),
                      const Divider(height: 22),
                      _infoLine(
                        Icons.mood_rounded,
                        'Latest mood',
                        data.mood ?? 'Not checked in yet',
                      ),
                      const Divider(height: 22),
                      _infoLine(
                        Icons.stars_rounded,
                        'Total points',
                        '${data.points}',
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

  Widget _infoLine(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: ParentUi.purple, size: 22),
        const SizedBox(width: 12),
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
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
