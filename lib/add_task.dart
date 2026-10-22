import 'package:flutter/material.dart';
import 'child.dart';

const Color taskPurple = Color(0xFF7566D9);
const Color taskDarkPurple = Color(0xFF30285E);
const Color taskBackground = Color(0xFFFAF8FF);

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');

  String _category = 'Study';
  String _when = 'Today';
  int _minutes = 15;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final points = int.tryParse(_pointsController.text.trim());

    if (points == null || points <= 0) return;

    setState(() => _isSaving = true);

    try {
      ChildAppState.instance.addTask(
        title: _titleController.text.trim(),
        subtitle: _descriptionController.text.trim().isEmpty
            ? 'Complete this task to earn points.'
            : _descriptionController.text.trim(),
        points: points,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add task: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: taskBackground,
      appBar: AppBar(
        backgroundColor: taskBackground,
        foregroundColor: taskDarkPurple,
        elevation: 0,
        title: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      color: taskPurple,
                      size: 35,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Small steps make a difference!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: taskDarkPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a simple task to help your child get started.',
                      style: TextStyle(
                        color: Color(0xFF817C98),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              _label('TASK NAME'),
              const SizedBox(height: 9),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  hint: 'e.g. Finish homework',
                  icon: Icons.edit_note_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _label('DESCRIPTION'),
              const SizedBox(height: 9),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _decoration(
                  hint: 'Describe the first step...',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 20),

              _label('CATEGORY'),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _decoration(
                  hint: 'Choose category',
                  icon: Icons.category_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: 'Study', child: Text('Study')),
                  DropdownMenuItem(value: 'Routine', child: Text('Routine')),
                  DropdownMenuItem(value: 'Home', child: Text('Home')),
                  DropdownMenuItem(value: 'Play', child: Text('Play')),
                  DropdownMenuItem(
                    value: 'Self-care',
                    child: Text('Self-care'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              _label('WHEN'),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: _when,
                decoration: _decoration(
                  hint: 'Choose when',
                  icon: Icons.calendar_today_rounded,
                ),
                items: const [
                  DropdownMenuItem(value: 'Today', child: Text('Today')),
                  DropdownMenuItem(value: 'Tomorrow', child: Text('Tomorrow')),
                  DropdownMenuItem(
                    value: 'This week',
                    child: Text('This week'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _when = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              _label('ESTIMATED TIME'),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E2F8)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: taskPurple,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$_minutes minutes',
                        style: const TextStyle(
                          color: taskDarkPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _minutes > 5
                          ? () => setState(() => _minutes -= 5)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      onPressed: _minutes < 120
                          ? () => setState(() => _minutes += 5)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _label('REWARD POINTS'),
              const SizedBox(height: 9),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: _decoration(
                  hint: '10',
                  icon: Icons.stars_rounded,
                ),
                validator: (value) {
                  final points = int.tryParse(value ?? '');
                  if (points == null || points <= 0) {
                    return 'Enter points greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F8F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF27966F),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Make the first step easy',
                            style: TextStyle(
                              color: Color(0xFF236B53),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Example: Open the assignment brief, then choose one question to start with.',
                            style: TextStyle(
                              color: Color(0xFF397C66),
                              height: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: taskPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: taskDarkPurple,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: taskPurple),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8E2F8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8E2F8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: taskPurple, width: 1.5),
      ),
    );
  }
}
