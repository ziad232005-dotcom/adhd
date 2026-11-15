import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentChild {
  final int id;
  final String name;
  final int age;
  final String grade;
  final String? imagePath;

  const ParentChild({
    required this.id,
    required this.name,
    required this.age,
    required this.grade,
    this.imagePath,
  });

  ParentChild copyWith({
    String? name,
    int? age,
    String? grade,
    String? imagePath,
    bool clearImage = false,
  }) {
    return ParentChild(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      imagePath: clearImage ? null : imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'grade': grade,
        'imagePath': imagePath,
      };

  factory ParentChild.fromJson(Map<String, dynamic> json) {
    return ParentChild(
      id: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
      grade: json['grade'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }
}

class ParentReminder {
  final int id;
  final String title;
  final DateTime dueAt;
  final bool done;

  const ParentReminder({
    required this.id,
    required this.title,
    required this.dueAt,
    this.done = false,
  });

  ParentReminder copyWith({bool? done}) {
    return ParentReminder(
      id: id,
      title: title,
      dueAt: dueAt,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueAt': dueAt.toIso8601String(),
        'done': done,
      };

  factory ParentReminder.fromJson(Map<String, dynamic> json) {
    return ParentReminder(
      id: json['id'] as int,
      title: json['title'] as String,
      dueAt: DateTime.parse(json['dueAt'] as String),
      done: json['done'] as bool? ?? false,
    );
  }
}

class ParentProfile {
  final String name;
  final String email;
  final String phone;

  const ParentProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
  });

  ParentProfile copyWith({String? name, String? email, String? phone}) {
    return ParentProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

/// Parent-side data: profile, children list and reminders.
/// Stored on the device until the backend accounts API exists.
class ParentStore extends ChangeNotifier {
  ParentStore._();

  static final ParentStore instance = ParentStore._();

  static const _storageKey = 'mazid_parent_state_v1';

  final List<ParentChild> children = [];
  final List<ParentReminder> reminders = [];
  ParentProfile profile = const ParentProfile();
  int selectedChildIndex = 0;
  DateTime? notificationsReadAt;

  int _nextChildId = 1;
  int _nextReminderId = 1;

  ParentChild? get selectedChild {
    if (children.isEmpty) return null;
    final index = selectedChildIndex.clamp(0, children.length - 1);
    return children[index];
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;

      children
        ..clear()
        ..addAll(
          (json['children'] as List<dynamic>? ?? []).map(
            (item) => ParentChild.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          ),
        );

      reminders
        ..clear()
        ..addAll(
          (json['reminders'] as List<dynamic>? ?? []).map(
            (item) => ParentReminder.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          ),
        );
      _sortReminders();

      final profileJson = json['profile'];
      if (profileJson is Map) {
        profile = ParentProfile.fromJson(
          Map<String, dynamic>.from(profileJson),
        );
      }

      selectedChildIndex = json['selectedChildIndex'] as int? ?? 0;
      _nextChildId = json['nextChildId'] as int? ?? (children.length + 1);
      _nextReminderId =
          json['nextReminderId'] as int? ?? (reminders.length + 1);

      final readAt = json['notificationsReadAt'] as String?;
      notificationsReadAt = readAt == null ? null : DateTime.tryParse(readAt);

      notifyListeners();
    } catch (e) {
      debugPrint('Could not load parent data: $e');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode({
        'children': children.map((c) => c.toJson()).toList(),
        'reminders': reminders.map((r) => r.toJson()).toList(),
        'profile': profile.toJson(),
        'selectedChildIndex': selectedChildIndex,
        'nextChildId': _nextChildId,
        'nextReminderId': _nextReminderId,
        'notificationsReadAt': notificationsReadAt?.toIso8601String(),
      }),
    );
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  void _sortReminders() {
    reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  // ---- Children ----

  void addChild({
    required String name,
    required int age,
    required String grade,
    String? imagePath,
  }) {
    children.add(
      ParentChild(
        id: _nextChildId++,
        name: name.trim(),
        age: age,
        grade: grade,
        imagePath: imagePath,
      ),
    );
    selectedChildIndex = children.length - 1;
    _changed();
  }

  void updateChild(ParentChild updated) {
    final index = children.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    children[index] = updated;
    _changed();
  }

  void deleteChild(int id) {
    children.removeWhere((c) => c.id == id);
    if (selectedChildIndex >= children.length) {
      selectedChildIndex = children.isEmpty ? 0 : children.length - 1;
    }
    _changed();
  }

  void selectChild(int index) {
    if (index < 0 || index >= children.length) return;
    selectedChildIndex = index;
    _changed();
  }

  // ---- Reminders ----

  void addReminder({required String title, required DateTime dueAt}) {
    reminders.add(
      ParentReminder(
        id: _nextReminderId++,
        title: title.trim(),
        dueAt: dueAt,
      ),
    );
    _sortReminders();
    _changed();
  }

  void toggleReminder(int id) {
    final index = reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    reminders[index] = reminders[index].copyWith(
      done: !reminders[index].done,
    );
    _changed();
  }

  void deleteReminder(int id) {
    reminders.removeWhere((r) => r.id == id);
    _changed();
  }

  // ---- Profile / notifications ----

  void updateProfile(ParentProfile value) {
    profile = value;
    _changed();
  }

  void markNotificationsRead() {
    notificationsReadAt = DateTime.now();
    _changed();
  }
}
