import 'package:flutter/material.dart';
import 'core/app_colors.dart';
class ActivityCalendarPage extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  final Future<void> Function() onSaveActivities;
  final Future<Map<String, dynamic>?> Function() onAddActivity;

  const ActivityCalendarPage({
    super.key,
    required this.activities,
    required this.onSaveActivities,
    required this.onAddActivity,
  });

  @override
  State<ActivityCalendarPage> createState() =>
      _ActivityCalendarPageState();
}

class _ActivityCalendarPageState extends State<ActivityCalendarPage> {
  late DateTime _selectedDay;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _visibleMonth = DateTime(
      _selectedDay.year,
      _selectedDay.month,
    );
  }

  DateTime _activityDate(Map<String, dynamic> activity) {
    return DateTime.parse(activity['dateTime'] as String);
  }

  List<Map<String, dynamic>> get _selectedDayActivities {
    final items = widget.activities.where((activity) {
      final date = _activityDate(activity);

      return date.year == _selectedDay.year &&
          date.month == _selectedDay.month &&
          date.day == _selectedDay.day;
    }).toList();

    items.sort(
      (a, b) => _activityDate(a).compareTo(_activityDate(b)),
    );

    return items;
  }

  bool _hasActivities(DateTime day) {
    return widget.activities.any((activity) {
      final date = _activityDate(activity);

      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    });
  }

  Future<void> _addActivity() async {
    final result = await widget.onAddActivity();

    if (result == null || !mounted) return;

    setState(() {
      _selectedDay = _activityDate(result);
      _visibleMonth = DateTime(
        _selectedDay.year,
        _selectedDay.month,
      );
    });
  }

  Future<void> _deleteActivity(
    Map<String, dynamic> activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete activity?'),
        content: Text(
          'Do you want to delete "${activity['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      widget.activities.remove(activity);
    });

    await widget.onSaveActivities();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Activity Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _buildCalendarCard(),
            const SizedBox(height: 26),
            _buildActivitiesHeader(),
            const SizedBox(height: 14),
            _buildSelectedDayActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final firstDay = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    // Monday = 0, Sunday = 6.
    final leadingDays = firstDay.weekday - 1;
    final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAE5FA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textDark,
                ),
              ),
              Expanded(
                child: Text(
                  '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingDays + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                dayNumber,
              );

              final selected =
                  day.year == _selectedDay.year &&
                  day.month == _selectedDay.month &&
                  day.day == _selectedDay.day;

              final today = _isSameDay(day, DateTime.now());
              final hasActivities = _hasActivities(day);

              return InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () {
                  setState(() => _selectedDay = day);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : today
                            ? AppColors.softPurple
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    border: today && !selected
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textDark,
                          fontWeight: selected || today
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasActivities
                              ? selected
                                  ? Colors.white
                                  : AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: AppColors.primary,
              ),
              SizedBox(width: 7),
              Text(
                'Days with activities',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily activities',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${_selectedDay.day} ${_monthName(_selectedDay.month)} '
                '${_selectedDay.year}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _addActivity,
          tooltip: 'Add activity',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.softPurple,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }

  Widget _buildSelectedDayActivities() {
    final items = _selectedDayActivities;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAE5FA)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No activities for this day',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap + to plan an activity.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((activity) {
        final date = _activityDate(activity);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAE5FA)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String? ?? 'Activity',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      TimeOfDay.fromDateTime(date).format(context),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((activity['description'] as String? ?? '')
                        .isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        activity['description'] as String,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete activity',
                onPressed: () => _deleteActivity(activity),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFCB6575),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return names[month - 1];
  }
}
