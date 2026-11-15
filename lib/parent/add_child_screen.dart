import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'parent_store.dart';
import 'parent_ui.dart';

const List<String> kChildGrades = [
  'Not in school',
  'Preschool',
  'KG 1',
  'KG 2',
  'Grade 1',
  'Grade 2',
  'Grade 3',
  'Grade 4',
  'Grade 5',
  'Grade 6',
  'Grade 7',
  'Grade 8',
  'Grade 9',
  'Grade 10',
  'Grade 11',
  'Grade 12',
];

/// Adds a child, or edits one when [child] is given.
class AddChildScreen extends StatefulWidget {
  final ParentChild? child;

  const AddChildScreen({super.key, this.child});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = ParentStore.instance;
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late String _grade;
  String? _imagePath;

  bool get _isEditing => widget.child != null;

  @override
  void initState() {
    super.initState();
    final child = widget.child;
    _nameController = TextEditingController(text: child?.name ?? '');
    _ageController = TextEditingController(
      text: child == null ? '' : '${child.age}',
    );
    _grade = kChildGrades.contains(child?.grade)
        ? child!.grade
        : kChildGrades[4];
    _imagePath = child?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );
      if (picked == null || !mounted) return;
      setState(() => _imagePath = picked.path);
    } catch (_) {
      if (!mounted) return;
      showParentSnack(context, 'Could not select the photo');
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());

    if (_isEditing) {
      _store.updateChild(
        widget.child!.copyWith(
          name: name,
          age: age,
          grade: _grade,
          imagePath: _imagePath,
          clearImage: _imagePath == null,
        ),
      );
    } else {
      _store.addChild(
        name: name,
        age: age,
        grade: _grade,
        imagePath: _imagePath,
      );
    }

    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove child?'),
        content: Text(
          'Remove ${widget.child!.name} from your children list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: ParentUi.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    _store.deleteChild(widget.child!.id);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(
        context,
        _isEditing ? 'Edit Child' : 'Add Child',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: ParentUi.soft,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imagePath != null
                            ? Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.face_rounded,
                                  size: 56,
                                  color: ParentUi.purple,
                                ),
                              )
                            : const Icon(
                                Icons.face_rounded,
                                size: 56,
                                color: ParentUi.purple,
                              ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: ParentUi.purple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_imagePath != null)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _imagePath = null),
                    child: const Text('Remove photo'),
                  ),
                ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Child name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the child name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (value) {
                  final age = int.tryParse(value?.trim() ?? '');
                  if (age == null) return 'Please enter the age.';
                  if (age < 1 || age > 18) {
                    return 'Age must be between 1 and 18.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _grade,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: [
                  for (final grade in kChildGrades)
                    DropdownMenuItem(value: grade, child: Text(grade)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _grade = value);
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ParentUi.purple,
                  ),
                  onPressed: _save,
                  child: Text(_isEditing ? 'Save changes' : 'Add child'),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: ParentUi.red,
                  ),
                  label: const Text(
                    'Remove child',
                    style: TextStyle(color: ParentUi.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
