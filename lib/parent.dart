import 'add_task.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'child.dart';
import 'screens/daily_routine.dart';
import 'screens/track_behavior.dart';
import 'screens/ask_ai.dart';
import 'screens/progress.dart';

const Color primaryPurple = Color(0xFF7566D9);
const Color dashboardBackground = Color(0xFFFAF8FF);
const Color darkPurple = Color(0xFF30285E);
const Color softPurple = Color(0xFFF0EDFF);

class DashboardChild {
  final String name;
  final int age;
  final String grade;
  final String? imagePath;

  const DashboardChild({
    required this.name,
    required this.age,
    required this.grade,
    this.imagePath,
  });

  DashboardChild copyWith({String? imagePath}) {
    return DashboardChild(
      name: name,
      age: age,
      grade: grade,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int selectedChildIndex = 0;
  int selectedNavIndex = 0;

  final ImagePicker _imagePicker = ImagePicker();

final List<DashboardChild> children = [
  const DashboardChild(
    name: 'Alex',
    age: 9,
    grade: 'Grade 4',
  ),
  const DashboardChild(
    name: 'Maya',
    age: 7,
    grade: 'Grade 2',
  ),
];

  DashboardChild get selectedChild => children[selectedChildIndex];

  Future<void> _changeChildPhoto() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (pickedImage == null || !mounted) return;

      setState(() {
        children[selectedChildIndex] = selectedChild.copyWith(
          imagePath: pickedImage.path,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child photo updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select the photo')),
      );
    }
  }

  void _showMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title — coming soon')),
    );
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildGreeting(),
                  const SizedBox(height: 22),
                  _buildChildSelector(),
                  const SizedBox(height: 14),
                  _buildChildProfile(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Today's Overview", 'See details'),
                  const SizedBox(height: 14),
                  _buildOverviewCards(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Quick Actions', 'View all'),
                  const SizedBox(height: 14),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Today's Routine", 'View routine'),
                  const SizedBox(height: 14),
                  _buildRoutineCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Upcoming Activities', 'View calendar'),
                  const SizedBox(height: 14),
                  _buildActivities(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Recent Observations', 'View all'),
                  const SizedBox(height: 14),
                  _buildObservationCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Progress Highlights', 'Weekly report'),
                  const SizedBox(height: 14),
                  Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProgressScreen(),
        ),
      );
    },
    icon: const Icon(Icons.insights_rounded),
    label: const Text('View Full Progress'),
  ),
),

_buildProgressCard(),
                  _buildProgressCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Reminders', 'View all'),
                  const SizedBox(height: 14),
                  _buildReminders(),
                ]),
              ),
            ),
          ],
        ),
      ),
            floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildTasksScreen(),
      ),
    );
  },
  backgroundColor: primaryPurple,
  foregroundColor: Colors.white,
  icon: const Icon(Icons.child_care_rounded),
  label: const Text('Child View'),
),

bottomNavigationBar: _buildBottomNavigation(),
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
  Icons.psychology_alt_rounded,
  color: primaryPurple,
  size: 30,
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
                  color: darkPurple,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'ADHD Parent Support',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        _circleButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _showMessage('Notifications'),
        ),
        const SizedBox(width: 10),
        _circleButton(
          icon: Icons.person_outline_rounded,
          onTap: () => _showMessage('Parent profile'),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting! 👋',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          "Small steps make a big difference. Let's make today count.",
          style: TextStyle(
            color: Color(0xFF817C98),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildChildSelector() {
    return Row(
      children: [
        const Text(
          'Your children',
          style: TextStyle(
            color: darkPurple,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showMessage('Add child'),
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: primaryPurple, size: 19),
              SizedBox(width: 5),
              Text(
                'Add child',
                style: TextStyle(
                  color: primaryPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChildProfile() {
    final child = selectedChild;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECE7FF)),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _changeChildPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: softPurple,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: child.imagePath != null
                          ? Image.file(
                              File(child.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _defaultChildAvatar(),
                            )
                          : _defaultChildAvatar(),
                    ),
                    Positioned(
                      right: 3,
                      bottom: 3,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        color: darkPurple,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${child.age} years old • ${child.grade}',
                      style: const TextStyle(
                        color: Color(0xFF817C98),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _changeChildPhoto,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: primaryPurple,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Change photo',
                            style: TextStyle(
                              color: primaryPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: primaryPurple,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF0EDFA), height: 1),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.task_alt_rounded,
                  label: 'Tasks done',
                  value: '3 / 5',
                ),
              ),
              Container(width: 1, height: 38, color: const Color(0xFFECE7F5)),
              Expanded(
                child: _miniStat(
                  icon: Icons.bolt_rounded,
                  label: 'Focus time',
                  value: '45 min',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultChildAvatar() {
    return const Center(
      child: Icon(
        Icons.face_rounded,
        size: 55,
        color: primaryPurple,
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: primaryPurple, size: 21),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF89849F),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String action) {
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: darkPurple,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          if (action == 'Weekly report') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProgressScreen(),
              ),
            );
          } else {
            _showMessage(action);
          }
        },
        child: Text(
          action,
          style: const TextStyle(
            color: primaryPurple,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            icon: Icons.checklist_rounded,
            title: 'Tasks',
            value: '3/5',
            subtitle: 'Completed',
            progress: 0.6,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _overviewCard(
            icon: Icons.calendar_month_rounded,
            title: 'Routine',
            value: '4/6',
            subtitle: 'Activities',
            progress: 0.67,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _overviewCard(
            icon: Icons.psychology_alt_rounded,
            title: 'Focus',
            value: '45m',
            subtitle: 'Today',
            progress: 0.75,
          ),
        ),
      ],
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEFEAFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryPurple, size: 23),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF918BA8),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: softPurple,
              valueColor: const AlwaysStoppedAnimation(primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        'Track Behavior',
        Icons.track_changes_rounded,
        const Color(0xFFF0EDFF),
      ),
      (
        'Daily Routine',
        Icons.calendar_month_rounded,
        const Color(0xFFE9F8F0),
      ),
      (
        'Ask AI',
        Icons.auto_awesome_rounded,
        const Color(0xFFFFF1E5),
      ),
      (
        'Add Task',
        Icons.add_task_rounded,
        const Color(0xFFFFEAF1),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        childAspectRatio: 2.35,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return InkWell(
          borderRadius: BorderRadius.circular(17),
onTap: () {
  switch (action.$1) {
    case 'Track Behavior':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TrackBehaviorScreen(),
        ),
      );
      break;

case 'Daily Routine':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const DailyRoutineScreen(),
    ),
  );
  break;

    case 'Ask AI':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AskAIScreen(),
        ),
      );
      break;

    case 'Add Task':
      _openAddTaskPage();
      break;
  }
},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFEFEAFB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: action.$3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.$2,
                    color: primaryPurple,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action.$1,
                    style: const TextStyle(
                      color: darkPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutineCard() {
  final routine = [
    {
      'title': 'Morning routine',
      'time': '07:30 AM',
      'completed': true,
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFFB547),
      'background': const Color(0xFFFFF6E7),
    },
    {
      'title': 'Homework time',
      'time': '04:00 PM',
      'completed': true,
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF7566D9),
      'background': const Color(0xFFF0EDFF),
    },
    {
      'title': 'Reading time',
      'time': '06:00 PM',
      'completed': false,
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xFF36BFA6),
      'background': const Color(0xFFE8FAF5),
    },
  ];

  return _whiteCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Routine',
              style: TextStyle(
                color: darkPurple,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: () => _showRoutineDialog(),
              icon: const Icon(
                Icons.add_circle_rounded,
                color: primaryPurple,
                size: 27,
              ),
              tooltip: 'Add routine',
            ),
          ],
        ),
        const SizedBox(height: 8),

        for (int i = 0; i < routine.length; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: routine[i]['background'] as Color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (routine[i]['color'] as Color).withAlpha(45),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: (routine[i]['color'] as Color).withAlpha(30),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    routine[i]['icon'] as IconData,
                    color: routine[i]['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine[i]['title'] as String,
                        style: TextStyle(
                          color: darkPurple,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration:
                              routine[i]['completed'] as bool
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: routine[i]['color'] as Color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            routine[i]['time'] as String,
                            style: const TextStyle(
                              color: Color(0xFF89849F),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      routine[i]['completed'] =
                          !(routine[i]['completed'] as bool);
                    });
                  },
                  icon: Icon(
                    routine[i]['completed'] as bool
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: routine[i]['completed'] as bool
                        ? const Color(0xFF36BFA6)
                        : const Color(0xFFB8B2CC),
                  ),
                  tooltip: 'Mark as completed',
                ),

                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF89849F),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showRoutineDialog(
                        title: routine[i]['title'] as String,
                        time: routine[i]['time'] as String,
                      );
                    } else if (value == 'delete') {
                      setState(() {
                        routine.removeAt(i);
                      });
                    } else if (value == 'reminder') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reminder selected for ${routine[i]['title']}',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit routine'),
                    ),
                    PopupMenuItem(
                      value: 'reminder',
                      child: Text('Set reminder'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete routine'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (routine.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No routines yet. Tap + to add one!',
                style: TextStyle(
                  color: Color(0xFF89849F),
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
Future<void> _openAddTaskPage() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const AddTaskScreen(),
    ),
  );

  if (!mounted) return;

  if (result == true) {
    setState(() {});
  }
}
Future<void> _showRoutineDialog({
  String? title,
  String? time,
}) async {
  final titleController = TextEditingController(text: title ?? '');
  TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 30);

  if (time != null) {
    try {
      selectedTime = TimeOfDay(
        hour: int.parse(time.split(':')[0]) +
            (time.toUpperCase().contains('PM') &&
                    int.parse(time.split(':')[0]) != 12
                ? 12
                : 0),
        minute: int.parse(time.split(':')[1].split(' ')[0]),
      );
    } catch (_) {
      selectedTime = const TimeOfDay(hour: 7, minute: 30);
    }
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(
              title == null ? 'Add Routine' : 'Edit Routine',
              style: const TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Routine name',
                    prefixIcon: const Icon(
                      Icons.edit_rounded,
                      color: primaryPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.access_time_rounded,
                    color: primaryPurple,
                  ),
                  title: const Text('Routine time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );

                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a routine name.'),
                      ),
                    );
                    return;
                  }

                  // This dialog currently collects the data.
                  // Connect it to a shared routine list to persist changes.
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        title == null
                            ? 'Routine details entered. Connect the shared list to save it.'
                            : 'Routine details edited. Connect the shared list to save it.',
                      ),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  titleController.dispose();
}
  Widget _buildActivities() {
    return Column(
      children: [
        _activityTile(
          icon: Icons.menu_book_rounded,
          title: 'Reading practice',
          subtitle: 'Today • 4:30 PM',
          color: const Color(0xFFECE8FF),
        ),
        const SizedBox(height: 10),
        _activityTile(
          icon: Icons.sports_soccer_rounded,
          title: 'Outdoor play',
          subtitle: 'Tomorrow • 5:00 PM',
          color: const Color(0xFFE4F7EB),
        ),
      ],
    );
  }

  Widget _activityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return _whiteCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryPurple, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF89849F),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard() {
    return _whiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFFE5A14C),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Positive progress today',
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your child completed a task with fewer reminders.',
                  style: TextStyle(
                    color: Color(0xFF817C98),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Today • 10:30 AM',
                  style: TextStyle(
                    color: primaryPurple,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly consistency',
                  style: TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '+12%',
                style: TextStyle(
                  color: Color(0xFF39A879),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Routine completion compared with last week',
            style: TextStyle(
              color: Color(0xFF89849F),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _progressBar('Mon', 0.55),
              _progressBar('Tue', 0.75),
              _progressBar('Wed', 0.45),
              _progressBar('Thu', 0.85),
              _progressBar('Fri', 0.65),
              _progressBar('Sat', 0.9),
              _progressBar('Sun', 0.6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar(String day, double value) {
    return Column(
      children: [
        Container(
          width: 19,
          height: 75,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: softPurple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            heightFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            color: Color(0xFF89849F),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildReminders() {
    return Column(
      children: [
        _reminderTile(
          icon: Icons.medication_outlined,
          title: 'Medication reminder',
          subtitle: 'Today • 7:00 PM',
        ),
        const SizedBox(height: 10),
        _reminderTile(
          icon: Icons.event_note_rounded,
          title: 'Prepare for tomorrow',
          subtitle: 'Today • 8:00 PM',
        ),
      ],
    );
  }

  Widget _reminderTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return _whiteCard(
      child: Row(
        children: [
          Icon(icon, color: primaryPurple, size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF89849F),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.notifications_active_outlined,
            color: primaryPurple,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAFB)),
      ),
      child: child,
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(icon, color: darkPurple, size: 22),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.checklist_rounded, 'Tasks'),
      (Icons.insights_rounded, 'Progress'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return NavigationBar(
      height: 70,
      backgroundColor: Colors.white,
      indicatorColor: softPurple,
      selectedIndex: selectedNavIndex,
      onDestinationSelected: (index) {
        setState(() => selectedNavIndex = index);

        if (index != 0) {
          _showMessage(items[index].$2);
        }
      },
      destinations: [
        for (int i = 0; i < items.length; i++)
          NavigationDestination(
            icon: Icon(items[i].$1),
            label: items[i].$2,
          ),
      ],
    );
  }
}

