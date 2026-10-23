import 'package:flutter/material.dart';
import 'add_task.dart';
import 'child.dart';

const Color tasksPurple = Color(0xFF7566D9);
const Color tasksDarkPurple = Color(0xFF30285E);
const Color tasksBackground = Color(0xFFFAF8FF);
const Color tasksSoftPurple = Color(0xFFF0EDFF);

class ParentTasksScreen extends StatefulWidget {
  const ParentTasksScreen({super.key});

  @override
  State<ParentTasksScreen> createState() => _ParentTasksScreenState();
}

class _ParentTasksScreenState extends State<ParentTasksScreen> {
  final ChildAppState data = ChildAppState.instance;

  @override
  void initState() {
    super.initState();
    data.addListener(_onTasksChanged);
  }

  @override
  void dispose() {
    data.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() {
    if (mounted) setState(() {});
  }



  void _deleteTask(ChildTask task) {
    if (data.isCompleted(task)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completed tasks cannot be deleted from this screen.',
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
           data.deleteTask(task);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   final tasks = data.tasks;

final totalTasks = tasks.length;
final completedCount = tasks.where(data.isCompleted).length;
final availableCount = totalTasks - completedCount;

final completionRate =
    totalTasks == 0 ? 0.0 : completedCount / totalTasks;

final totalPoints = data.points;
final weeklyCompleted = data.weeklyCompletedCount;
final weeklyPoints = data.weeklyPoints;

    return Scaffold(
      backgroundColor: tasksBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 26),
                  _buildWelcome(),
const SizedBox(height: 22),

_buildSummary(
  completedCount,
  availableCount,
  completionRate,
),

const SizedBox(height: 18),

_buildStatistics(
  totalTasks: totalTasks,
  totalPoints: totalPoints,
  weeklyCompleted: weeklyCompleted,
  weeklyPoints: weeklyPoints,
),

const SizedBox(height: 28),


                  if (tasks.isEmpty)
                    _buildEmptyState()
                  else
                    for (final task in tasks) ...[
                      _buildTaskCard(task),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 12),
                  _buildTip(),
                ]),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(
            'images/image.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.checklist_rounded,
              color: tasksPurple,
              size: 29,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MΛZID',
                style: TextStyle(
                  color: tasksDarkPurple,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'ADHD Parent Support',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.checklist_rounded,
            color: tasksPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Management',
          style: TextStyle(
            color: tasksDarkPurple,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Organize your child’s tasks and celebrate every small win.',
          style: TextStyle(
            color: tasksDarkPurple.withValues(alpha: 0.65),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(
    int completed,
    int remaining,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7566D9), Color(0xFF998BEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: tasksPurple.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryNumber('$completed', 'Completed'),
              const SizedBox(width: 30),
              _summaryNumber('$remaining', 'Remaining'),
              const Spacer(),
              SizedBox(
                width: 65,
                height: 65,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryNumber(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
Widget _buildStatistics({
  required int totalTasks,
  required int totalPoints,
  required int weeklyCompleted,
  required int weeklyPoints,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Task Statistics',
        style: TextStyle(
          color: tasksDarkPurple,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),

      const SizedBox(height: 14),

      Row(
        children: [
          Expanded(
            child: _statCard(
              title: 'Total Tasks',
              value: '$totalTasks',
              icon: Icons.checklist_rounded,
              color: tasksPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              title: 'Total Points',
              value: '$totalPoints',
              icon: Icons.stars_rounded,
              color: const Color(0xFFE5A14C),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: _statCard(
              title: 'Weekly Completed',
              value: '$weeklyCompleted',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF29A987),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              title: 'Weekly Points',
              value: '$weeklyPoints',
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF5B91D6),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _statCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFECE7FA),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          value,
          style: const TextStyle(
            color: tasksDarkPurple,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF89849F),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTaskCard(ChildTask task) {
    final completed = data.isCompleted(task);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0xFFBDEBDD)
              : const Color(0xFFECE7FA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFE2F8F0)
                  : tasksSoftPurple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              task.icon,
              color: completed
                  ? const Color(0xFF29A987)
                  : tasksPurple,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

Text(
  task.title,
  style: TextStyle(
    decoration: data.isCompleted(task)
        ? TextDecoration.lineThrough
        : TextDecoration.none,
    decorationThickness: 1.0,
    color: data.isCompleted(task) ? Colors.grey : null,
  ),
),

                const SizedBox(height: 5),
                Text(
                  task.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF89849F),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: Color(0xFFFFB547),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.points} points',
                      style: const TextStyle(
                        color: tasksDarkPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (completed) ...[
                      const SizedBox(width: 9),
                      const Text(
                        'Completed',
                        style: TextStyle(
                          color: Color(0xFF29A987),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: completed ? 'Already completed' : 'Delete task',
                onPressed: () => _deleteTask(task),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: completed
                      ? const Color(0xFFD8D4E4)
                      : Colors.redAccent,
                  size: 21,
                ),
              ),
              
IconButton(
  tooltip: completed ? 'Task completed' : 'Mark as completed',
  onPressed: completed
      ? null
      : () {
          data.completeTask(task);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${task.title} completed!'),
              backgroundColor: const Color(0xFF29A987),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
  icon: Icon(
    completed
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded,
    color: completed
        ? const Color(0xFF29A987)
        : const Color(0xFFB8B2CC),
    size: 27,
  ),
)


            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE7FA)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 48,
            color: tasksPurple,
          ),
          SizedBox(height: 12),
          Text(
            'No tasks yet',
            style: TextStyle(
              color: tasksDarkPurple,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Tap Add Task to create your first task.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF89849F),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFE5A14C),
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: Break larger tasks into small, achievable steps to help your child stay focused.',
              style: TextStyle(
                color: Color(0xFF765A38),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
