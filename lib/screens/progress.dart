import 'package:flutter/material.dart';

import '../child.dart';
import '../parent/parent_insights.dart';
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import '../parent/weekly_bar_chart.dart';
import '../reports/reports_screen.dart';

/// Child progress for the parent, calculated from the child's real
/// activity (completed tasks, points, streak and focus sessions).
class ProgressScreen extends StatelessWidget {
  /// Set to false when the screen is shown as a tab.
  final bool showBack;

  const ProgressScreen({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;
    final store = ParentStore.instance;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(
        context,
        'Child Progress',
        showBack: showBack,
        actions: [
          IconButton(
            tooltip: 'Reports',
            icon: const Icon(Icons.folder_rounded, color: ParentUi.dark),
            onPressed: () => openSelectedChildReports(context),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([data, store]),
          builder: (context, _) {
            final insights = ParentInsights(data);
            final childName = store.selectedChild?.name;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                _buildWelcomeCard(childName, insights),
                const SizedBox(height: 24),
                const Text(
                  'Progress Overview',
                  style: TextStyle(
                    color: ParentUi.dark,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.task_alt_rounded,
                        title: 'Completed',
                        value: '${data.totalTasksCompleted}',
                        subtitle: 'Tasks in total',
                        color: const Color(0xFFE9F8F0),
                        iconColor: const Color(0xFF39A875),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.stars_rounded,
                        title: 'Earned',
                        value: '${data.points}',
                        subtitle: 'Points',
                        color: const Color(0xFFFFF1D6),
                        iconColor: const Color(0xFFE5A72D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department_rounded,
                        title: 'Consistency',
                        value: '${insights.streakDays}',
                        subtitle: 'Days in a row',
                        color: const Color(0xFFFFEAF1),
                        iconColor: const Color(0xFFE77D9E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.track_changes_rounded,
                        title: 'Weekly score',
                        value: '${insights.weeklyScorePercent}%',
                        subtitle: 'Of possible tasks',
                        color: ParentUi.soft,
                        iconColor: ParentUi.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _buildWeeklyProgress(insights),
                const SizedBox(height: 22),
                _buildAchievements(insights),
                const SizedBox(height: 22),
                _buildEncouragementCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String? childName, ParentInsights insights) {
    final headline = insights.thisWeekCompletions == 0
        ? 'Every journey starts with one step'
        : "Look how far ${childName ?? 'your child'} has come!";
    final message = insights.thisWeekCompletions == 0
        ? 'Add tasks and let your child complete the first one to see '
            'progress here.'
        : '${insights.thisWeekCompletions} tasks completed in the last '
            '7 days. Keep celebrating the effort.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7566D9), Color(0xFF9A8DEB)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFE6A3),
            size: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: ParentUi.dark,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(ParentInsights insights) {
    return ParentCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Activity',
            style: TextStyle(
              color: ParentUi.dark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tasks completed each day',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          WeeklyBarChart(
            days: insights.lastDays(),
            ratios: insights.dailyRatios,
            counts: insights.dailyCompletions,
            height: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(ParentInsights insights) {
    final achievements = insights.achievements;

    return ParentCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Achievements',
            style: TextStyle(
              color: ParentUi.dark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            const Text(
              'Achievements unlock as your child completes tasks, '
              'builds a streak and finishes focus sessions.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.5,
              ),
            )
          else
            for (var i = 0; i < achievements.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _buildAchievementItem(achievements[i]),
            ],
        ],
      ),
    );
  }

  Widget _buildAchievementItem(ParentAchievement a) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: a.color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(a.icon, color: ParentUi.dark, size: 24),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: const TextStyle(
                  color: ParentUi.dark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                a.description,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF39A875),
          size: 21,
        ),
      ],
    );
  }

  Widget _buildEncouragementCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: ParentUi.soft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: ParentUi.purple, size: 29),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress, not perfection',
                  style: TextStyle(
                    color: ParentUi.dark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Celebrate effort and small improvements every day.',
                  style: TextStyle(
                    color: ParentUi.dark,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
