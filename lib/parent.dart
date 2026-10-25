import 'add_task.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'child.dart';
import 'tasks.dart';
import 'screens/track_behavior.dart';
import 'screens/ask_ai.dart';
import 'screens/progress.dart';
import 'add_routine.dart';
import 'add_activity_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_calendar_page.dart';
import 'view_routine.dart';
//اللوان ال انا مستخدمها في Dashboard parent
const Color primaryPurple = Color(0xFF7566D9);
const Color dashboardBackground = Color(0xFFFAF8FF);
const Color darkPurple = Color(0xFF30285E);
const Color softPurple = Color(0xFFF0EDFF);
//بيانات ال child  ال بتظهر علي dashboard parent 
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

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Routines
  final List<Map<String, dynamic>> routine = [];
  bool _routinesLoaded = false;

  // Activities — independent from routines
  final List<Map<String, dynamic>> activities = [];
  bool _activitiesLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadActivities();
    _loadRoutines();
  }
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

  // =========================
  // LOAD ROUTINES
  // =========================

  Future<void> _loadRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoutines = prefs.getString('parent_routines');

    if (!mounted) return;

    try {
      final List<dynamic> decoded = savedRoutines == null
          ? <dynamic>[]
          : jsonDecode(savedRoutines) as List<dynamic>;

final loadedRoutines = decoded.map((item) {
  final map = Map<String, dynamic>.from(item as Map);

  final iconCode = map['iconCode'];

map['icon'] = _iconFromCodePoint(iconCode);

  final storedColor = map['colorValue'];

  final int colorValue = storedColor is int
      ? storedColor
      : primaryPurple.toARGB32();

  map['color'] = Color(colorValue);

  return map;
}).toList();

      setState(() {
        routine
          ..clear()
          ..addAll(loadedRoutines);

        _sortRoutines();
        _routinesLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading routines: $e');

      if (!mounted) return;

      setState(() {
        _routinesLoaded = true;
      });
    }
  }

IconData _iconFromCodePoint(dynamic codePoint) {
  switch (codePoint) {
    case 0xe318:
      return Icons.check_circle_outline_rounded;
    default:
      return Icons.check_circle_outline_rounded;
  }
}

  // Newest routines first
  void _sortRoutines() {
    routine.sort((a, b) {
      final dateA = DateTime.tryParse(
        a['createdAt']?.toString() ?? '',
      );

      final dateB = DateTime.tryParse(
        b['createdAt']?.toString() ?? '',
      );

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });
  }

  // =========================
  // SAVE ROUTINES
  // =========================

Future<void> _saveRoutines() async {
  final prefs = await SharedPreferences.getInstance();

  final serializableRoutines = routine.map((item) {
    final map = Map<String, dynamic>.from(item);

    final icon = map.remove('icon');
    final color = map.remove('color');

    map['iconCode'] = icon is IconData
        ? icon.codePoint
        : Icons.check_circle_outline_rounded.codePoint;

    map['colorValue'] = color is Color
        ? color.toARGB32()
        : primaryPurple.toARGB32();

    return map;
  }).toList();

  await prefs.setString(
    'parent_routines',
    jsonEncode(serializableRoutines),
  );
}

  // =========================
  // LOAD ACTIVITIES
  // =========================

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();

    final savedActivities = prefs.getString(
      'parent_upcoming_activities',
    );

    if (!mounted) return;

    try {
      final List<dynamic> decoded = savedActivities == null
          ? <dynamic>[]
          : jsonDecode(savedActivities) as List<dynamic>;

      setState(() {
        activities
          ..clear()
          ..addAll(
            decoded.map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );

        _activitiesLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading activities: $e');

      if (!mounted) return;

      setState(() {
        _activitiesLoaded = true;
      });
    }
  }

Future<void> _saveActivities() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'parent_upcoming_activities',
    jsonEncode(activities),
  );
}



  DashboardChild get selectedChild => children[selectedChildIndex];
//تغير صوره البروفايل بتاع الطفل 
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
//بتعرض رساله للحاجات ال لسه مخلصتش  اسفل الشاشه 
  void _showMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title — coming soon')),
    );
  }
  

//مخصصه في ان هي بتبني ال dashboard بتجمع الاقسام
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
body: SafeArea(
  child: selectedNavIndex == 0
      ? CustomScrollView(
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
                _buildSectionTitle(
  "Today's Routine",
  'View routine',
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewRoutineScreen(
          routines: routine,
          onSave: _saveRoutines,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  },
),
                  const SizedBox(height: 14),
                  _buildRoutineCard(),
                  const SizedBox(height: 28),
               
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'Upcoming Activities',
      style: TextStyle(
        color: darkPurple,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    TextButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityCalendarPage(
              activities: activities,
              onSaveActivities: _saveActivities,
              onAddActivity: () async {
                final result =
                    await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddActivityPage(),
                  ),
                );

                if (result == null || !mounted) return null;

                setState(() {
                  activities.add(result);
                  activities.sort((a, b) {
                    final dateA =
                        DateTime.parse(a['dateTime'] as String);
                    final dateB =
                        DateTime.parse(b['dateTime'] as String);
                    return dateA.compareTo(dateB);
                  });
                });

                await _saveActivities();
                return result;
              },
            ),
          ),
        );

        if (mounted) setState(() {});
      },
      child: const Text(
        'View calendar',
        style: TextStyle(
          color: primaryPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
),

                  const SizedBox(height: 14),
                  _buildActivities(),
                  const SizedBox(height: 28),
_buildSectionTitle(
  'Recent Observations',
  'View all',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AllObservationsScreen(),
      ),
    );
  },
),
_buildObservationCard(),
                  const SizedBox(height: 14),
                  _buildObservationCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Progress Highlights', 'Weekly report'),
                  const SizedBox(height: 14),
                  _buildProgressCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Reminders', 'View all'),
                  const SizedBox(height: 14),
                  _buildReminders(),
                ]),
              ),
            ),
          ],
        )
      : selectedNavIndex == 1
          ? const ParentTasksScreen()
          : selectedNavIndex == 2
              ? const ProgressScreen()
              : const Center(
                  child: Text('Parent Profile'),
                ),
),
floatingActionButton: selectedNavIndex == 0
    ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildTasksScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF7566D9),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.child_care_rounded),
        label: const Text('Child View'),
      )
    : selectedNavIndex == 1
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTaskScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF7566D9),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Task'),
          )
        : null,

bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  
//مخصصه للجزء العلوي للشاشه 
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
//بتعرض تحيه حسب الوقت
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
//بيانات الطفل ال موجوده في ال parent
  Widget _buildChildProfile() {
    final child = selectedChild;
final childData = ChildAppState.instance;
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
AnimatedBuilder(
  animation: childData,
  builder: (context, _) {
    final totalTasks = childData.tasks.length;

    final completedTasks = childData.tasks.where((task) {
      return childData.isCompleted(task);
    }).length;

    return Row(
      children: [
        Expanded(
          child: _miniStat(
            icon: Icons.task_alt_rounded,
            label: 'Tasks done',
            value: '$completedTasks / $totalTasks',
          ),
        ),
        Container(
          width: 1,
          height: 38,
          color: const Color(0xFFECE7F5),
        ),
        Expanded(
          child: _miniStat(
            icon: Icons.bolt_rounded,
            label: 'Focus time',
            value: 'Not tracked',
          ),
        ),
      ],
    );
  },
),
        ],
      ),
    );
  }
//لو مفيش صوره للطفل بتعرض ايقونه 
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

Widget _buildSectionTitle(
  String title,
  String action, {
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

//بتعرض ملخص اليوم
Widget _buildOverviewCards() {
  final childData = ChildAppState.instance;

  return AnimatedBuilder(
    animation: childData,
    builder: (context, child) {
      // عدد المهام المكتملة اليوم
      final completedTasks = childData.tasks.where((task) {
        return childData.isCompleted(task);
      }).length;

      // إجمالي المهام
      final totalTasks = childData.tasks.length;

      // عدد عناصر الروتين المكتملة
      final completedRoutine = routine.where((item) {
        return item['completed'] == true;
      }).length;

      // إجمالي عناصر الروتين
      final totalRoutine = routine.length;

      // نسبة إنجاز المهام
      final taskProgress = totalTasks == 0
          ? 0.0
          : (completedTasks / totalTasks).clamp(0.0, 1.0);

      // نسبة إنجاز الروتين
      final routineProgress = totalRoutine == 0
          ? 0.0
          : (completedRoutine / totalRoutine).clamp(0.0, 1.0);

      return Row(
        children: [
          Expanded(
            child: _overviewCard(
              icon: Icons.checklist_rounded,
              title: 'Tasks',
              value: '$completedTasks/$totalTasks',
              subtitle: 'Completed',
              progress: taskProgress,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _overviewCard(
              icon: Icons.calendar_month_rounded,
              title: 'Routine',
              value: '$completedRoutine/$totalRoutine',
              subtitle: 'Activities',
              progress: routineProgress,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _overviewCard(
              icon: Icons.psychology_alt_rounded,
              title: 'Focus',
              value: '--',
              subtitle: 'No sessions',
              progress: 0.0,
            ),
          ),
        ],
      );
    },
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
      const Color(0xFFECE8FF),
    ),
    (
      'Ask AI',
      Icons.psychology_alt_rounded,
      const Color(0xFFE4F7EB),
    ),
  ];

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: actions.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
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

            case 'Ask AI':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AskAIScreen(),
                ),
              );
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
              Icon(
                action.$2,
                color: primaryPurple,
                size: 25,
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
              onPressed: () async {
                final result =
                    await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddRoutineScreen(),
                  ),
                );

                if (result == null || !mounted) return;

                setState(() {
                  routine.insert(0, {
                    ...result,
                    'createdAt': DateTime.now().toIso8601String(),
                  });
                  _sortRoutines();
                });

                await _saveRoutines();
              },
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

        if (!_routinesLoaded)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: primaryPurple,
              ),
            ),
          )
        else ...[
          for (int i = 0; i < routine.length && i < 3; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEFEAFB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    routine[i]['icon'] is IconData
                        ? routine[i]['icon'] as IconData
                        : Icons.check_circle_outline_rounded,
                    color: routine[i]['color'] is Color
                        ? routine[i]['color'] as Color
                        : primaryPurple,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine[i]['title']?.toString() ?? 'Routine',
                          style: TextStyle(
                            color: darkPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: routine[i]['completed'] == true
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
                              color: routine[i]['color'] is Color
                                  ? routine[i]['color'] as Color
                                  : primaryPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              routine[i]['time']?.toString() ?? '',
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
                    onPressed: () async {
                      setState(() {
                        routine[i]['completed'] =
                            !(routine[i]['completed'] == true);
                      });
                      await _saveRoutines();
                    },
                    icon: Icon(
                      routine[i]['completed'] == true
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: routine[i]['completed'] == true
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
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showRoutineDialog(
                          title: routine[i]['title']?.toString(),
                          time: routine[i]['time']?.toString(),
                        );
                      } else if (value == 'delete') {
                        setState(() {
                          routine.removeAt(i);
                        });
                        await _saveRoutines();
                      } else if (value == 'reminder') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reminder selected for '
                              '${routine[i]['title']}',
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
      ],
    ),
  );
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
  tileColor: Colors.transparent,
  splashColor: primaryPurple.withValues(alpha: 0.10),
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

    if (!context.mounted) return;

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
final routineTitle = titleController.text.trim();

final formattedTime = selectedTime.format(context);

setState(() {
  if (title == null) {
    // Add a new routine
    routine.add({
      'title': routineTitle,
      'time': formattedTime,
      'completed': false,
      'icon': Icons.star_rounded,
      'color': primaryPurple,
    });
  } else {
    // Update the existing routine
    final index = routine.indexWhere(
      (item) => item['title'] == title,
    );

    if (index != -1) {
      routine[index]['title'] = routineTitle;
      routine[index]['time'] = formattedTime;
    }
  }
});

Navigator.pop(dialogContext);
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
  if (!_activitiesLoaded) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(
          color: primaryPurple,
        ),
      ),
    );
  }

  return Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () async {
  final result = await Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(
      builder: (context) => const AddActivityPage(),
    ),
  );

  if (result == null || !mounted) return;

  setState(() {
    activities.add(result);

    activities.sort((a, b) {
      final dateA = DateTime.parse(a['dateTime'] as String);
      final dateB = DateTime.parse(b['dateTime'] as String);
      return dateA.compareTo(dateB);
    });
  });

  await _saveActivities();
},
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Add activity'),
        ),
      ),

      if (activities.isEmpty)
        _whiteCard(
          child: const Column(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 40,
                color: primaryPurple,
              ),
              SizedBox(height: 10),
              Text(
                'No upcoming activities',
                style: TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Add an activity to get started.',
                style: TextStyle(
                  color: Color(0xFF89849F),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
      else
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final date = DateTime.parse(activity['dateTime'] as String);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _whiteCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: softPurple,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: const TextStyle(
                            color: darkPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${_activityDateLabel(date)} • '
                          '${TimeOfDay.fromDateTime(date).format(context)}',
                          style: const TextStyle(
                            color: Color(0xFF89849F),
                            fontSize: 11,
                          ),
                        ),
                        if ((activity['description'] as String? ?? '')
                            .isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            activity['description'] as String,
                            style: const TextStyle(
                              color: Color(0xFF817C98),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        setState(() {
                          activities.removeAt(index);
                        });

                        await _saveActivities();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete activity'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
    ],
  );
}

String _activityDateLabel(DateTime date) {
  final now = DateTime.now();

  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day) {
    return 'Today';
  }

  final tomorrow = now.add(const Duration(days: 1));

  if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return 'Tomorrow';
  }

  return '${date.day}/${date.month}/${date.year}';
}


Widget _buildObservationCard() {
  final data = ChildAppState.instance;

  return AnimatedBuilder(
    animation: data,
    builder: (context, child) {
      if (data.observations.isEmpty) {
        return _whiteCard(
          child: const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFE5A14C),
                size: 25,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No observations yet',
                      style: TextStyle(
                        color: darkPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your child’s activities will appear here.',
                      style: TextStyle(
                        color: Color(0xFF817C98),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final observations = data.observations.take(3).toList();

      return Column(
        children: observations.map((observation) {
          final isTask = observation.type == 'task';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _whiteCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isTask
                          ? const Color(0xFFE3F7EF)
                          : const Color(0xFFFFF0E2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      isTask
                          ? Icons.check_circle_outline_rounded
                          : Icons.lightbulb_outline_rounded,
                      color: isTask
                          ? const Color(0xFF43B89C)
                          : const Color(0xFFE5A14C),
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          observation.title,
                          style: const TextStyle(
                            color: darkPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          observation.description,
                          style: const TextStyle(
                            color: Color(0xFF817C98),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _formatObservationTime(observation.timestamp),
                          style: const TextStyle(
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
            ),
          );
        }).toList(),
      );
    },
  );
}

String _formatObservationTime(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inSeconds < 60) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }

  if (now.year == timestamp.year &&
      now.month == timestamp.month &&
      now.day == timestamp.day) {
    return 'Today • ${TimeOfDay.fromDateTime(timestamp).format(context)}';
  }

  return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
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
  return NavigationBar(
    selectedIndex: selectedNavIndex,
    onDestinationSelected: (index) {
      if (index == 3) {
        _showMessage('Parent profile');
        return;
      }

      setState(() {
        selectedNavIndex = index;
      });
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.checklist_outlined),
        selectedIcon: Icon(Icons.checklist_rounded),
        label: 'Tasks',
      ),
      NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights_rounded),
        label: 'Progress',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ],
  );
}


}

class AllObservationsScreen extends StatelessWidget {
  const AllObservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'All Observations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: data,
        builder: (context, child) {
final observations = data.observations;
          if (observations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 60,
                      color: Color(0xFF9B8FF0),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No observations yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your child’s activities will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF817C98),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: observations.length,
            itemBuilder: (context, index) {
              final observation = observations[index];
              final isTask = observation.type == 'task';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: isTask
                            ? const Color(0xFFE3F7EF)
                            : const Color(0xFFFFF0E2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isTask
                            ? Icons.check_circle_outline_rounded
                            : Icons.lightbulb_outline_rounded,
                        color: isTask
                            ? const Color(0xFF43B89C)
                            : const Color(0xFFE5A14C),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            observation.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkPurple,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            observation.description,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Color(0xFF817C98),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            '${observation.timestamp.day}/'
                            '${observation.timestamp.month}/'
                            '${observation.timestamp.year}'
                            ' • '
                            '${TimeOfDay.fromDateTime(observation.timestamp).format(context)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
