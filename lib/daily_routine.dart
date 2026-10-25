import 'package:flutter/material.dart';

const Color _primaryPurple = Color(0xFF7566D9);
const Color _darkPurple = Color(0xFF30285E);
const Color _background = Color(0xFFFAF8FF);
const Color _softPurple = Color(0xFFF0EDFF);

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  final List<_RoutineActivity> _activities = [
    _RoutineActivity(
      title: 'Wake Up',
      time: const TimeOfDay(hour: 7, minute: 0),
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFFFF1D6),
    ),
    _RoutineActivity(
      title: 'Breakfast',
      time: const TimeOfDay(hour: 7, minute: 30),
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFE9F8F0),
    ),
    _RoutineActivity(
      title: 'Study Time',
      time: const TimeOfDay(hour: 9, minute: 0),
      icon: Icons.menu_book_rounded,
      color: const Color(0xFFF0EDFF),
    ),
    _RoutineActivity(
      title: 'Play Time',
      time: const TimeOfDay(hour: 16, minute: 0),
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFFFFEAF1),
    ),
    _RoutineActivity(
      title: 'Bedtime',
      time: const TimeOfDay(hour: 20, minute: 30),
      icon: Icons.bedtime_rounded,
      color: const Color(0xFFE8F0FF),
    ),
  ];

  int get _completedCount =>
      _activities.where((activity) => activity.isCompleted).length;

  Future<void> _addActivity() async {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<_RoutineActivity>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Add Activity',
                style: TextStyle(
                  color: _darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Activity name',
                      hintText: 'e.g. Homework',
                      prefixIcon: const Icon(
                        Icons.edit_rounded,
                        color: _primaryPurple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(
                        'Time: ${selectedTime.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryPurple,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();

                    if (title.isEmpty) return;

                    Navigator.pop(
                      dialogContext,
                      _RoutineActivity(
                        title: title,
                        time: selectedTime,
                        icon: Icons.event_note_rounded,
                        color: _softPurple,
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      _activities.add(result);
      _activities.sort((a, b) {
        final aMinutes = a.time.hour * 60 + a.time.minute;
        final bMinutes = b.time.hour * 60 + b.time.minute;
        return aMinutes.compareTo(bMinutes);
      });
    });
  }

  Future<void> _deleteActivity(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text(
          'Do you want to delete "${_activities[index].title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _activities.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _activities.isEmpty
        ? 0.0
        : _completedCount / _activities.length;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _darkPurple,
          ),
        ),
        title: const Text(
          'Daily Routine',
          style: TextStyle(
            color: _darkPurple,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Schedule",
                  style: TextStyle(
                    color: _darkPurple,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_activities.length} activities',
                  style: const TextStyle(
                    color: _primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_activities.isEmpty)
              _buildEmptyState()
            else
              ...List.generate(
                _activities.length,
                (index) => _buildActivityCard(
                  _activities[index],
                  index,
                ),
              ),
            const SizedBox(height: 22),
            _buildProgressCard(progress),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addActivity,
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7566D9),
            Color(0xFF9A8DEB),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Small steps,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'big achievements!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_completedCount of ${_activities.length} activities completed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.calendar_month_rounded,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(_RoutineActivity activity, int index) {
    return Dismissible(
      key: ObjectKey(activity),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteActivity(index);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: activity.isCompleted
                ? const Color(0xFFD9F0E1)
                : const Color(0xFFEFEAFB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              activity.icon,
              color: _primaryPurple,
             size: 26,
             ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      color: _darkPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: activity.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    activity.time.format(context),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: activity.isCompleted,
              activeColor: _primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() {
                  activity.isCompleted = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEAFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFE5A72D),
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                "Today's Progress",
                style: TextStyle(
                  color: _darkPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: _softPurple,
              valueColor: const AlwaysStoppedAnimation<Color>(
                _primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _activities.isEmpty
                ? 'Add activities to start your routine.'
                : '${(progress * 100).round()}% completed — keep going!',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: _primaryPurple,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No activities yet',
            style: TextStyle(
              color: _darkPurple,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tap Add Activity to build your daily routine.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _RoutineActivity {
_RoutineActivity({
  required this.title,
  required this.time,
  required this.icon,
  required this.color,
}) : isCompleted = false;

  final String title;
  final TimeOfDay time;
  final IconData icon;
  final Color color;
  bool isCompleted;
}
