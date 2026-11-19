import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assessments/cars_store.dart';
import '../child.dart';

class ParentChild {
  final int id;
  final String name;

  /// Date of birth. The age is always calculated from it.
  final DateTime? birthDate;

  /// Age saved before date of birth was collected (used until the parent
  /// adds the date of birth).
  final int? _savedAge;

  final String grade;
  final String? imagePath;

  /// 4-digit PIN the child types to open their own screen.
  final String pin;

  const ParentChild({
    required this.id,
    required this.name,
    this.birthDate,
    int? savedAge,
    required this.grade,
    this.imagePath,
    String? pin,
  })  : _savedAge = savedAge,
        pin = pin ?? _defaultPin;

  static const _defaultPin = '1234';

  /// True for exactly four digits.
  static bool isValidPin(String value) => RegExp(r'^\d{4}$').hasMatch(value);

  /// Full years between [birth] and [now].
  static int ageOn(DateTime birth, DateTime now) {
    var years = now.year - birth.year;
    final hadBirthday = now.month > birth.month ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) years--;
    return years < 0 ? 0 : years;
  }

  /// Current age in years.
  int get age {
    final birth = birthDate;
    if (birth == null) return _savedAge ?? 0;
    return ageOn(birth, DateTime.now());
  }

  ParentChild copyWith({
    String? name,
    DateTime? birthDate,
    String? grade,
    String? imagePath,
    String? pin,
    bool clearImage = false,
  }) {
    return ParentChild(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      savedAge: _savedAge,
      grade: grade ?? this.grade,
      imagePath: clearImage ? null : imagePath ?? this.imagePath,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate?.toIso8601String(),
        'age': _savedAge,
        'grade': grade,
        'imagePath': imagePath,
        'pin': pin,
      };

  factory ParentChild.fromJson(Map<String, dynamic> json) {
    final birth = json['birthDate'] as String?;

    return ParentChild(
      id: json['id'] as int,
      name: json['name'] as String,
      birthDate: birth == null ? null : DateTime.tryParse(birth),
      savedAge: json['age'] as int?,
      grade: json['grade'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      pin: json['pin'] as String?,
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

  /// Date of birth. The age is calculated from it.
  final DateTime? birthDate;
  final String gender;
  final String relationship;
  final String city;
  final String address;
  final String emergencyName;
  final String emergencyPhone;

  const ParentProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.birthDate,
    this.gender = '',
    this.relationship = '',
    this.city = '',
    this.address = '',
    this.emergencyName = '',
    this.emergencyPhone = '',
  });

  /// Current age in years, or null when no date of birth is set.
  int? get age {
    final birth = birthDate;
    if (birth == null) return null;
    return ParentChild.ageOn(birth, DateTime.now());
  }

  ParentProfile copyWith({
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? gender,
    String? relationship,
    String? city,
    String? address,
    String? emergencyName,
    String? emergencyPhone,
  }) {
    return ParentProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      city: city ?? this.city,
      address: address ?? this.address,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'birthDate': birthDate?.toIso8601String(),
        'gender': gender,
        'relationship': relationship,
        'city': city,
        'address': address,
        'emergencyName': emergencyName,
        'emergencyPhone': emergencyPhone,
      };

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? ''),
      gender: json['gender'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      emergencyName: json['emergencyName'] as String? ?? '',
      emergencyPhone: json['emergencyPhone'] as String? ?? '',
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
    try {
      await _write();
    } catch (e) {
      debugPrint('Could not save parent data: $e');
    }
  }

  Future<void> _write() async {
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

  /// Makes the tasks, rewards, points... follow the selected child.
  void _syncChildData() {
    unawaited(ChildAppState.instance.switchChild(selectedChild?.id));
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
    required DateTime birthDate,
    required String grade,
    String? imagePath,
  }) {
    children.add(
      ParentChild(
        id: _nextChildId++,
        name: name.trim(),
        birthDate: birthDate,
        grade: grade,
        imagePath: imagePath,
      ),
    );
    selectedChildIndex = children.length - 1;
    _changed();
    _syncChildData();
  }

  void updateChild(ParentChild updated) {
    final index = children.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    children[index] = updated;
    _changed();
  }

  void deleteChild(int id) {
    final keepId = selectedChild?.id;

    children.removeWhere((c) => c.id == id);

    final keptIndex = children.indexWhere((c) => c.id == keepId);
    if (keptIndex != -1) {
      selectedChildIndex = keptIndex;
    } else if (selectedChildIndex >= children.length) {
      selectedChildIndex = children.isEmpty ? 0 : children.length - 1;
    }

    _changed();

    unawaited(
      ChildAppState.instance
          .switchChild(selectedChild?.id)
          .then((_) => ChildAppState.instance.forgetChild(id))
          .then((_) => CarsStore.instance.forget(id)),
    );
  }

  void selectChild(int index) {
    if (index < 0 || index >= children.length) return;
    if (index == selectedChildIndex) return;
    selectedChildIndex = index;
    _changed();
    _syncChildData();
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

  void updateReminder({
    required int id,
    required String title,
    required DateTime dueAt,
  }) {
    final index = reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    reminders[index] = ParentReminder(
      id: id,
      title: title.trim(),
      dueAt: dueAt,
      done: reminders[index].done,
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
