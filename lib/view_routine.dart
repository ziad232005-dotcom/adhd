import 'package:flutter/material.dart';
import 'core/app_colors.dart';
class ViewRoutineScreen extends StatefulWidget {
  final List<Map<String, dynamic>> routines;
  final Future<void> Function() onSave;

  const ViewRoutineScreen({
    super.key,
    required this.routines,
    required this.onSave,
  });

  @override
  State<ViewRoutineScreen> createState() => _ViewRoutineScreenState();
}

class _ViewRoutineScreenState extends State<ViewRoutineScreen> {
  late List<Map<String, dynamic>> _routines;

  @override
  void initState() {
    super.initState();

    // Use the same list supplied by the dashboard.
    _routines = widget.routines;
    _sortRoutines();
  }

  void _sortRoutines() {
    _routines.sort((a, b) {
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

  Future<void> _saveChanges() async {
    _sortRoutines();
    await widget.onSave();

    if (mounted) {
      setState(() {});
    }
  }

  IconData _getIcon(Map<String, dynamic> routine) {
    final icon = routine['icon'];

    if (icon is IconData) {
      return icon;
    }

    return Icons.check_circle_outline_rounded;
  }

  Color _getColor(Map<String, dynamic> routine) {
    final color = routine['color'];

    if (color is Color) {
      return color;
    }

    return AppColors.primary;
  }

  Future<void> _toggleCompleted(int index) async {
    setState(() {
      final current = _routines[index]['completed'] == true;
      _routines[index]['completed'] = !current;
    });

    await _saveChanges();
  }

  Future<void> _deleteRoutine(int index) async {
    final title = _routines[index]['title']?.toString() ?? 'this routine';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Routine?',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('Are you sure you want to delete "$title"?'),
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
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _routines.removeAt(index);
    });

    await _saveChanges();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Routine deleted successfully.')),
    );
  }

  Future<void> _editRoutine(int index) async {
    final routine = _routines[index];

    final titleController = TextEditingController(
      text: routine['title']?.toString() ?? '',
    );

    final timeController = TextEditingController(
      text: routine['time']?.toString() ?? '',
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Routine',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Routine Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Time',
                  hintText: '07:30 AM',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final title = titleController.text.trim();
                final time = timeController.text.trim();

                if (title.isEmpty || time.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Enter the routine name and time.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'title': title,
                  'time': time,
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    timeController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      _routines[index]['title'] = result['title'];
      _routines[index]['time'] = result['time'];
    });

    await _saveChanges();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Routine updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: AppColors.textDark,
        ),
        title: const Text(
          'My Routines',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: SafeArea(
        child: _routines.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Daily Routine',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${_routines.length} routines added',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _routines.length,
                      itemBuilder: (context, index) {
                        return _buildRoutineItem(index);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRoutineItem(int index) {
    final routine = _routines[index];
    final title = routine['title']?.toString() ?? 'Untitled Routine';
    final task = routine['task']?.toString() ?? '';
    final time = routine['time']?.toString() ?? 'No time set';
    final completed = routine['completed'] == true;
    final duration = routine['duration'];

    final icon = _getIcon(routine);
    final color = _getColor(routine);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0xFFBFE8DA)
              : const Color(0xFFECE8FA),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: completed
                            ? Colors.grey
                            : AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            time,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (duration is num) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.timelapse_rounded,
                            size: 15,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${duration.toInt()} min',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: completed ? 'Mark incomplete' : 'Mark completed',
                onPressed: () => _toggleCompleted(index),
                icon: Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: completed
                      ? const Color(0xFF36BFA6)
                      : AppColors.primary,
                  size: 27,
                ),
              ),
            ],
          ),
          if (task.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                task,
                style: const TextStyle(
                  color: Color(0xFF77738B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0EDFA)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editRoutine(index),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _deleteRoutine(index),
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFECE8FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No routines yet',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first routine from the dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
