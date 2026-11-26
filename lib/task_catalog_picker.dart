import 'package:flutter/material.dart';

import 'child.dart';
import 'task_catalog.dart';

const Color _purple = Color(0xFF7566D9);
const Color _dark = Color(0xFF30285E);

/// Ready-made tasks grouped by category. One tap adds a task to the child.
class TaskCatalogPicker extends StatefulWidget {
  const TaskCatalogPicker({super.key});

  @override
  State<TaskCatalogPicker> createState() => _TaskCatalogPickerState();
}

class _TaskCatalogPickerState extends State<TaskCatalogPicker> {
  final ChildAppState _data = ChildAppState.instance;
  String _category = taskCategories.first;

  bool _added(CatalogTask task) =>
      _data.tasks.any((item) => item.title == task.title);

  void _add(CatalogTask task) {
    if (_added(task)) return;
    _data.addTask(
      title: task.title,
      subtitle: task.subtitle,
      points: task.points,
      minutes: task.minutes,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} added'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _data,
      builder: (context, _) {
        final items =
            taskCatalog.where((task) => task.category == _category).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: taskCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final name = taskCategories[index];
                  return ChoiceChip(
                    label: Text(name),
                    selected: name == _category,
                    selectedColor: _purple,
                    labelStyle: TextStyle(
                      color: name == _category ? Colors.white : _dark,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => setState(() => _category = name),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            for (final task in items)
              Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: const TextStyle(
                      color: _dark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${task.subtitle}\n+${task.points} points'
                    '${task.minutes == null ? '' : ' • ${task.minutes} min'}',
                  ),
                  isThreeLine: true,
                  trailing: _added(task)
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF43B89C))
                      : IconButton(
                          tooltip: 'Add ${task.title}',
                          onPressed: () => _add(task),
                          icon: const Icon(Icons.add_circle_rounded,
                              color: _purple, size: 30),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}
