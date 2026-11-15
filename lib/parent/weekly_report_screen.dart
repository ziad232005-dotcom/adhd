import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../child.dart';
import 'parent_insights.dart';
import 'parent_store.dart';
import 'parent_ui.dart';

/// Seven bars for the last 7 days. Today is highlighted.
class WeeklyBarChart extends StatelessWidget {
  final List<DateTime> days;
  final List<double> ratios;
  final List<int> counts;
  final double height;

  const WeeklyBarChart({
    super.key,
    required this.days,
    required this.ratios,
    required this.counts,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (index) {
          final isToday = index == days.length - 1;
          final ratio = ratios[index];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${counts[index]}',
                    style: const TextStyle(
                      color: ParentUi.dark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ParentUi.soft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: ratio == 0 ? 0.04 : ratio,
                        widthFactor: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? ParentUi.purple
                                : const Color(0xFFC9C1F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ParentInsights.weekdayLabels[days[index].weekday - 1],
                    style: const TextStyle(
                      color: ParentUi.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  String _summary(ParentInsights insights, ChildAppState data) {
    final child = ParentStore.instance.selectedChild;
    final name = child?.name ?? 'Your child';
    final mood = insights.topMoodThisWeek ?? 'not recorded';

    return 'MΛZID weekly report — $name\n'
        'Tasks completed: ${insights.thisWeekCompletions}\n'
        'Points earned: ${data.weeklyPoints}\n'
        'Focus time: ${insights.weeklyFocusMinutes} min\n'
        'Streak: ${insights.streakDays} day(s)\n'
        'Most common mood: $mood\n'
        'Change vs last week: ${insights.weekChangeLabel}';
  }

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(
        context,
        'Weekly Report',
        actions: [
          IconButton(
            tooltip: 'Copy summary',
            icon: const Icon(Icons.copy_rounded, color: ParentUi.dark),
            onPressed: () async {
              final insights = ParentInsights(data);
              await Clipboard.setData(
                ClipboardData(text: _summary(insights, data)),
              );
              if (!context.mounted) return;
              showParentSnack(context, 'Report summary copied');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: data,
          builder: (context, _) {
            final insights = ParentInsights(data);
            final days = insights.lastDays();
            final first = days.first;
            final last = days.last;
            final achievements = insights.achievements;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                Text(
                  '${first.day}/${first.month} – ${last.day}/${last.month}',
                  style: const TextStyle(
                    color: ParentUi.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.task_alt_rounded,
                        value: '${insights.thisWeekCompletions}',
                        label: 'Tasks done',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.stars_rounded,
                        value: '${data.weeklyPoints}',
                        label: 'Points earned',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.timer_outlined,
                        value: '${insights.weeklyFocusMinutes} min',
                        label: 'Focus time',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.local_fire_department_rounded,
                        value: '${insights.streakDays}',
                        label: 'Day streak',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ParentCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tasks per day',
                              style: TextStyle(
                                color: ParentUi.dark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            insights.weekChangeLabel,
                            style: TextStyle(
                              color: (insights.weekChangePercent ?? 0) >= 0
                                  ? ParentUi.green
                                  : ParentUi.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Compared with the previous 7 days',
                        style: TextStyle(
                          color: ParentUi.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 18),
                      WeeklyBarChart(
                        days: days,
                        ratios: insights.dailyRatios,
                        counts: insights.dailyCompletions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ParentCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mood_rounded,
                        color: ParentUi.purple,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mood this week',
                              style: TextStyle(
                                color: ParentUi.dark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              insights.topMoodThisWeek == null
                                  ? 'No check-ins yet'
                                  : 'Most often "${insights.topMoodThisWeek}" '
                                      '(${insights.weeklyMoods.length} '
                                      'check-ins)',
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
                const SizedBox(height: 16),
                ParentCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          color: ParentUi.dark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (achievements.isEmpty)
                        const Text(
                          'Achievements appear as your child completes '
                          'tasks and focus sessions.',
                          style: TextStyle(
                            color: ParentUi.muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        )
                      else
                        for (final a in achievements)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: a.color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    a.icon,
                                    color: ParentUi.dark,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title,
                                        style: const TextStyle(
                                          color: ParentUi.dark,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        a.description,
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

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ParentUi.purple, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: ParentUi.dark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: ParentUi.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
