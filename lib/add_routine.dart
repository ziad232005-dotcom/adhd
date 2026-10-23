
import 'package:flutter/material.dart';

const Color primaryPurple = Color(0xFF7566D9);
const Color darkPurple = Color(0xFF30285E);
const Color routineBackground = Color(0xFFFAF8FF);

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Morning Routine',
      'task': 'Brush teeth, wash face, and get dressed.',
      'duration': 15,
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFFB547),
    },
    {
      'title': 'School Preparation',
      'task': 'Check the school bag and prepare books.',
      'duration': 10,
      'icon': Icons.backpack_rounded,
      'color': const Color(0xFF7566D9),
    },
    {
      'title': 'Homework Time',
      'task': 'Complete the first three homework questions.',
      'duration': 15,
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF36BFA6),
    },
    {
      'title': 'Reading Time',
      'task': 'Read two pages with a parent.',
      'duration': 10,
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xFFE5A14C),
    },
    {
      'title': 'Physical Activity',
      'task': 'Play outside or do a simple physical activity.',
      'duration': 20,
      'icon': Icons.sports_soccer_rounded,
      'color': const Color(0xFFE879A9),
    },
    {
      'title': 'Bedtime Routine',
      'task': 'Brush teeth and prepare clothes for tomorrow.',
      'duration': 15,
      'icon': Icons.bedtime_rounded,
      'color': const Color(0xFF7C83E8),
    },
  ];

  String? _selectedActivity;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 30);
  int _duration = 15;
  bool _repeatDaily = true;
  bool _reminderEnabled = true;

  final Set<int> _selectedDays = {0, 1, 2, 3, 4, 5, 6};

  final List<String> _dayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _selectActivity(String? title) {
    setState(() {
      _selectedActivity = title;

      if (title != null) {
        final activity = _activities.firstWhere(
          (item) => item['title'] == title,
        );

        _titleController.text = activity['title'] as String;
        _taskController.text = activity['task'] as String;
        _duration = activity['duration'] as int;
      } else {
        _titleController.clear();
        _taskController.clear();
        _duration = 15;
      }
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveRoutine() {
    if (!_formKey.currentState!.validate()) return;

    if (!_repeatDaily && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one day for this routine.'),
        ),
      );
      return;
    }

    final routine = <String, dynamic>{
      'title': _titleController.text.trim(),
      'task': _taskController.text.trim(),
      'time': _selectedTime.format(context),
      'duration': _duration,
      'repeatDaily': _repeatDaily,
      'days': _repeatDaily
          ? List<int>.generate(7, (index) => index)
          : _selectedDays.toList()..sort(),
      'reminder': _reminderEnabled,
      'completed': false,
      'icon': _selectedIcon(),
      'color': _selectedColor(),
    };

    Navigator.pop(context, routine);
  }

  IconData _selectedIcon() {
    if (_selectedActivity != null) {
      final activity = _activities.firstWhere(
        (item) => item['title'] == _selectedActivity,
      );
      return activity['icon'] as IconData;
    }
    return Icons.check_circle_outline_rounded;
  }

  Color _selectedColor() {
    if (_selectedActivity != null) {
      final activity = _activities.firstWhere(
        (item) => item['title'] == _selectedActivity,
      );
      return activity['color'] as Color;
    }
    return primaryPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: routineBackground,
      appBar: AppBar(
        backgroundColor: routineBackground,
        foregroundColor: darkPurple,
        elevation: 0,
        title: const Text(
          'Add Routine',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build a daily routine',
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Choose an activity and make it fit your child’s day.',
                  style: TextStyle(
                    color: Color(0xFF817C98),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),

                _sectionLabel('Choose an activity'),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final activity in _activities)
                      _activityChip(
                        title: activity['title'] as String,
                        icon: activity['icon'] as IconData,
                      ),
                    _activityChip(
                      title: 'Custom Activity',
                      icon: Icons.add_rounded,
                      custom: true,
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                _sectionLabel('Activity details'),
                const SizedBox(height: 12),

                _fieldLabel('Activity name'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: 'e.g. Finish a school assignment',
                    icon: Icons.edit_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter an activity name.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),
                _fieldLabel('What should your child do?'),
                TextFormField(
                  controller: _taskController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hint: 'Describe the task in simple, clear steps.',
                    icon: Icons.format_list_bulleted_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add a short description of the task.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),
                _sectionLabel('Schedule'),
                const SizedBox(height: 12),

                _fieldLabel('Start time'),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedTime.format(context),
                            style: const TextStyle(
                              color: darkPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: primaryPurple,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _fieldLabel('Duration'),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [5, 10, 15, 20, 30, 45, 60].map((minutes) {
                    final selected = _duration == minutes;

                    return ChoiceChip(
                      label: Text('$minutes min'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _duration = minutes);
                      },
                      selectedColor: const Color(0xFFE7E1FF),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? primaryPurple : darkPurple,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(
                        color: selected
                            ? primaryPurple
                            : const Color(0xFFECE7FF),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 25),
                _sectionLabel('Repeat'),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: _boxDecoration(),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Every day',
                          style: TextStyle(
                            color: darkPurple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Repeat this activity daily',
                          style: TextStyle(
                            color: Color(0xFF817C98),
                            fontSize: 12,
                          ),
                        ),
                        activeThumbColor: primaryPurple,
                        value: _repeatDaily,
                        onChanged: (value) {
                          setState(() => _repeatDaily = value);
                        },
                      ),
                      if (!_repeatDaily) ...[
                        const Divider(color: Color(0xFFECE7FF)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            final selected = _selectedDays.contains(index);

                            return FilterChip(
                              label: Text(_dayNames[index]),
                              selected: selected,
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedDays.add(index);
                                  } else {
                                    _selectedDays.remove(index);
                                  }
                                });
                              },
                              selectedColor: const Color(0xFFE7E1FF),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected
                                    ? primaryPurple
                                    : darkPurple,
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? primaryPurple
                                    : const Color(0xFFECE7FF),
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  decoration: _boxDecoration(),
                  child: SwitchListTile(
                    title: const Text(
                      'Reminder',
                      style: TextStyle(
                        color: darkPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Show a reminder for this activity',
                      style: TextStyle(
                        color: Color(0xFF817C98),
                        fontSize: 12,
                      ),
                    ),
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: primaryPurple,
                    ),
                    activeThumbColor: primaryPurple,
                    value: _reminderEnabled,
                    onChanged: (value) {
                      setState(() => _reminderEnabled = value);
                    },
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveRoutine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Save Routine',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF817C98),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityChip({
    required String title,
    required IconData icon,
    bool custom = false,
  }) {
    final selected = custom
        ? _selectedActivity == null
        : _selectedActivity == title;

    return InkWell(
      onTap: () => _selectActivity(custom ? null : title),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7E1FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? primaryPurple
                : const Color(0xFFECE7FF),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: primaryPurple),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? primaryPurple : darkPurple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkPurple,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: darkPurple,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA6A0B8),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: primaryPurple, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFECE7FF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFECE7FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryPurple, width: 1.4),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFECE7FF)),
    );
  }
}

