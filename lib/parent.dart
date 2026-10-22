import 'package:flutter/material.dart';
// ============================================================
// PARENT DASHBOARD
// ============================================================

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState
    extends State<ParentDashboardScreen> {
  int selectedTab = 0;

  // Temporary sample data. No backend is used.
  final String parentName = 'Jamie';

  final List<Map<String, dynamic>> children = [
    {
      'name': 'Alex',
      'initial': 'A',
      'age': 9,
      'grade': 'Grade 4',
      'focusAreas': ['Focus', 'Daily routines', 'Schoolwork'],
      'tasksDone': 3,
      'totalTasks': 6,
      'streak': 5,
      'focusSessions': 1,
    },
    {
      'name': 'Maya',
      'initial': 'M',
      'age': 7,
      'grade': 'Grade 2',
      'focusAreas': ['Focus', 'Mood'],
      'tasksDone': 2,
      'totalTasks': 5,
      'streak': 3,
      'focusSessions': 1,
    },
  ];

  int selectedChildIndex = 0;

  final List<Map<String, dynamic>> routines = [
    {
      'title': 'Morning routine',
      'time': '7:30 AM',
      'details': '4 steps',
      'done': true,
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'title': 'Homework warm-up',
      'time': '10:00 AM',
      'details': '15 min',
      'done': true,
      'icon': Icons.menu_book_outlined,
    },
    {
      'title': 'Reading time',
      'time': '4:00 PM',
      'details': '20 min',
      'done': false,
      'icon': Icons.auto_stories_outlined,
    },
    {
      'title': 'Wind-down routine',
      'time': '8:00 PM',
      'details': '3 steps',
      'done': false,
      'icon': Icons.nightlight_outlined,
    },
  ];

  final List<Map<String, dynamic>> activities = [
    {
      'title': 'Reading time',
      'subtitle': 'Today · 4:00 PM · with a parent',
      'icon': Icons.menu_book_outlined,
    },
    {
      'title': 'Focus session',
      'subtitle': 'Today · 5:30 PM · 25 min',
      'icon': Icons.timer_outlined,
    },
    {
      'title': 'Follow-up with Dr. Sarah Morgan',
      'subtitle': 'Thu 22 Oct · 5:30 PM',
      'icon': Icons.calendar_month_outlined,
    },
  ];

  final List<Map<String, dynamic>> observations = [
    {
      'author': 'Teacher · Ms. Layla',
      'date': 'Thu 15 Oct',
      'text':
          'Stayed with the reading task for 12 minutes after one short reminder.',
      'category': 'Focus',
      'icon': Icons.school_outlined,
    },
    {
      'author': 'You · Parent check-in',
      'date': 'Fri 16 Oct',
      'text':
          'Morning routine went smoothly with the picture checklist.',
      'category': 'Routines',
      'icon': Icons.home_outlined,
    },
  ];

  final List<Map<String, dynamic>> reminders = [
    {
      'title': 'Wind-down routine',
      'subtitle': 'Today · 8:00 PM',
      'action': 'Snooze',
      'icon': Icons.notifications_none,
    },
    {
      'title': 'Weekly report is ready',
      'subtitle': '11–17 Oct',
      'action': 'Open',
      'icon': Icons.insert_chart_outlined,
    },
    {
      'title': 'Questions for Thursday’s visit',
      'subtitle': 'Dr. Sarah Morgan · 22 Oct',
      'action': 'Add',
      'icon': Icons.event_note_outlined,
    },
  ];

  Map<String, dynamic> get currentChild =>
      children[selectedChildIndex];

  int get completedRoutines =>
      routines.where((item) => item['done'] == true).length;

  void showFeatureMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature screen will be implemented next.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void selectChild(int index) {
    setState(() {
      selectedChildIndex = index;
    });
  }

  void addChild() {
    showFeatureMessage('Add child');
  }

  @override
  Widget build(BuildContext context) {
    final child = currentChild;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(),

              const SizedBox(height: 24),

              // GREETING
              Text(
                'Good morning, $parentName',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF30285E),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${_formattedDate()} · ${child['name']}’s day at a glance',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 18),

              // CHILD SELECTOR
              _buildChildSelector(),

              const SizedBox(height: 16),

              // CHILD OVERVIEW
              _buildChildOverview(child),

              const SizedBox(height: 24),

              // QUICK ACTIONS
              _buildSectionTitle('Quick actions'),

              const SizedBox(height: 12),

              _buildQuickActions(),

              const SizedBox(height: 26),

              // UPCOMING ACTIVITIES
              _buildSectionTitle(
                'Upcoming activities',
                action: 'See all',
                onAction: () =>
                    showFeatureMessage('Upcoming activities'),
              ),

              const SizedBox(height: 12),

              ...activities.map(_buildActivityCard),

              const SizedBox(height: 26),

              // TODAY'S ROUTINE
              _buildSectionTitle(
                'Today’s routine',
                action: 'Manage',
                onAction: () => showFeatureMessage('Manage routine'),
              ),

              const SizedBox(height: 12),

              _buildRoutineCard(),

              const SizedBox(height: 26),

              // RECENT OBSERVATIONS
              _buildSectionTitle(
                'Recent observations',
                action: 'See all',
                onAction: () =>
                    showFeatureMessage('All observations'),
              ),

              const SizedBox(height: 12),

              ...observations.map(_buildObservationCard),

              const SizedBox(height: 12),

              const Text(
                'Observations are notes from you and your child’s '
                'teachers. They describe what was seen and are not '
                'an assessment.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 26),

              // PROGRESS HIGHLIGHTS
              _buildSectionTitle(
                'Progress highlights',
                action: 'Reports',
                onAction: () => showFeatureMessage('Reports'),
              ),

              const SizedBox(height: 12),

              _buildProgressHighlights(child),

              const SizedBox(height: 26),

              // REMINDERS
              _buildSectionTitle(
                'Reminders',
                action: 'Manage',
                onAction: () => showFeatureMessage('Manage reminders'),
              ),

              const SizedBox(height: 12),

              ...reminders.map(_buildReminderCard),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'MΛZID supports everyday routines. It doesn’t '
                  'diagnose or treat any condition. Names and figures '
                  'shown are sample content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAE5FF),

        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });

          if (index != 0) {
            final features = [
              'Home',
              'Tasks',
              'AI Help',
              'Specialist',
              'Reports',
            ];

            showFeatureMessage(features[index]);
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Help',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Specialist',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined),
            selectedIcon: Icon(Icons.insert_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFF7566D9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'b',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MΛZID',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF30285E),
                ),
              ),
              Text(
                'ADHD PARENT SUPPORT',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.7,
                  color: Color(0xFF7566D9),
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () => showFeatureMessage('Notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF30285E),
          ),
        ),

        CircleAvatar(
          radius: 19,
          backgroundColor: const Color(0xFFEAE5FF),
          child: Text(
            parentName[0],
            style: const TextStyle(
              color: Color(0xFF7566D9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CHILD SELECTOR
  // ------------------------------------------------------------

  Widget _buildChildSelector() {
    return Row(
      children: [
        ...List.generate(children.length, (index) {
          final child = children[index];
          final isSelected = selectedChildIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => selectChild(index),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEAE5FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF7566D9)
                        : const Color(0xFFE7E3F2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFF7566D9),
                      child: Text(
                        child['initial'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      child['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF30285E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const Spacer(),

        IconButton(
          tooltip: 'Add child',
          onPressed: addChild,
          icon: const Icon(
            Icons.add_circle_outline,
            color: Color(0xFF7566D9),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CHILD OVERVIEW
  // ------------------------------------------------------------

  Widget _buildChildOverview(Map<String, dynamic> child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7566D9),
            Color(0xFF9587EA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  child['initial'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age ${child['age']} · ${child['grade']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () =>
                    showFeatureMessage('${child['name']} profile'),
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: (child['focusAreas'] as List<String>)
                .map(
                  (area) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      area,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _buildChildStat(
                '${child['tasksDone']} of ${child['totalTasks']}',
                'Tasks today',
              ),
              _buildChildStat(
                '${child['streak']} days',
                'Check-in streak',
              ),
              _buildChildStat(
                '${child['focusSessions']} session',
                'Focus today',
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  showFeatureMessage('${child['name']} profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                shape: const StadiumBorder(),
              ),
              child: Text('View ${child['name']}’s profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF30285E),
            ),
          ),
        ),

        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: Color(0xFF7566D9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------
  // QUICK ACTIONS
  // ------------------------------------------------------------

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Add task',
        'icon': Icons.add_task,
        'color': const Color(0xFFEAE5FF),
      },
      {
        'title': 'Check-in',
        'icon': Icons.favorite_border,
        'color': const Color(0xFFDDF7ED),
      },
      {
        'title': 'Ask AI',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFFFE8D9),
      },
      {
        'title': 'Book visit',
        'icon': Icons.calendar_month_outlined,
        'color': const Color(0xFFFFE6EE),
      },
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: InkWell(
            onTap: () => showFeatureMessage(action['title'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: action['color'] as Color,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: const Color(0xFF7566D9),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF30285E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------------------------
  // UPCOMING ACTIVITIES
  // ------------------------------------------------------------

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDE9F7)),
      ),
      child: ListTile(
        onTap: () =>
            showFeatureMessage(activity['title'] as String),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE5FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            activity['icon'] as IconData,
            color: const Color(0xFF7566D9),
          ),
        ),
        title: Text(
          activity['title'] as String,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF30285E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            activity['subtitle'] as String,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF7566D9),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TODAY'S ROUTINE
  // ------------------------------------------------------------

  Widget _buildRoutineCard() {
    final progress = completedRoutines / routines.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9F7)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completedRoutines of ${routines.length} steps done',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF30285E),
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF7566D9),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFEDE9F7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7566D9),
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...routines.map(_buildRoutineItem),
        ],
      ),
    );
  }

  Widget _buildRoutineItem(Map<String, dynamic> routine) {
    final done = routine['done'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: done
                  ? const Color(0xFFDDF7ED)
                  : const Color(0xFFEAE5FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              routine['icon'] as IconData,
              color: done
                  ? const Color(0xFF299B77)
                  : const Color(0xFF7566D9),
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF30285E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${routine['time']} · ${routine['details']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: done
                  ? const Color(0xFFDDF7ED)
                  : const Color(0xFFF0EDF8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              done ? 'Done' : 'To do',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: done
                    ? const Color(0xFF218260)
                    : const Color(0xFF7566D9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RECENT OBSERVATIONS
  // ------------------------------------------------------------

  Widget _buildObservationCard(
    Map<String, dynamic> observation,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDE9F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                observation['icon'] as IconData,
                color: const Color(0xFF7566D9),
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  observation['author'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF30285E),
                  ),
                ),
              ),
              Text(
                observation['date'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            observation['text'] as String,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF514B6D),
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE5FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                observation['category'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF7566D9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROGRESS HIGHLIGHTS
  // ------------------------------------------------------------

  Widget _buildProgressHighlights(
    Map<String, dynamic> child,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            icon: Icons.timer_outlined,
            title: 'Focus sessions',
            value: '${child['focusSessions'] + 8}',
            subtitle: '2 more than last week',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildProgressCard(
            icon: Icons.check_circle_outline,
            title: 'Tasks done',
            value: '75%',
            subtitle: '24 of 32 this week',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE9F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF7566D9),
            size: 23,
          ),

          const SizedBox(height: 9),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF30285E),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF7566D9),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMINDERS
  // ------------------------------------------------------------

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9F7)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAE5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reminder['icon'] as IconData,
              color: const Color(0xFF7566D9),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF30285E),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  reminder['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () =>
                showFeatureMessage(reminder['action'] as String),
            child: Text(
              reminder['action'] as String,
              style: const TextStyle(
                color: Color(0xFF7566D9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DATE
  // ------------------------------------------------------------

  String _formattedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];

    final now = DateTime.now();

    return '${weekdays[now.weekday - 1]}, '
        '${now.day} ${months[now.month - 1]}';
  }
}