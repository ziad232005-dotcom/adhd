/// A new id for a record. Records are only compared by this id.
String newRecordId() => DateTime.now().microsecondsSinceEpoch.toString();

DateTime? _date(Object? value) => DateTime.tryParse('${value ?? ''}');

/// A medicine the child takes.
class Medication {
  Medication({
    String? id,
    required this.name,
    this.dose = '',
    this.times = '',
    this.active = true,
  }) : id = id ?? newRecordId();

  final String id;
  final String name;
  final String dose;

  /// Free text such as "08:00, 20:00".
  final String times;
  final bool active;

  Medication copyWith({bool? active}) => Medication(
        id: id,
        name: name,
        dose: dose,
        times: times,
        active: active ?? this.active,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dose': dose,
        'times': times,
        'active': active,
      };

  static Medication? fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    if (name.isEmpty) return null;

    return Medication(
      id: json['id'] as String?,
      name: name,
      dose: json['dose'] as String? ?? '',
      times: json['times'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }
}

enum AppointmentKind {
  doctor('Doctor'),
  therapy('Therapy session'),
  school('School meeting'),
  other('Other');

  const AppointmentKind(this.label);

  final String label;

  static AppointmentKind fromName(String? name) {
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return AppointmentKind.other;
  }
}

class Appointment {
  Appointment({
    String? id,
    required this.title,
    required this.kind,
    required this.when,
    this.done = false,
  }) : id = id ?? newRecordId();

  final String id;
  final String title;
  final AppointmentKind kind;
  final DateTime when;
  final bool done;

  Appointment copyWith({bool? done}) => Appointment(
        id: id,
        title: title,
        kind: kind,
        when: when,
        done: done ?? this.done,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind.name,
        'when': when.toIso8601String(),
        'done': done,
      };

  static Appointment? fromJson(Map<String, dynamic> json) {
    final when = _date(json['when']);
    final title = json['title'] as String? ?? '';
    if (when == null || title.isEmpty) return null;

    return Appointment(
      id: json['id'] as String?,
      title: title,
      kind: AppointmentKind.fromName(json['kind'] as String?),
      when: when,
      done: json['done'] as bool? ?? false,
    );
  }
}

/// Sleep and meals of one day.
class DailyLog {
  DailyLog({
    required this.day,
    this.sleepHours,
    Set<String>? meals,
    this.note = '',
  }) : meals = meals ?? <String>{};

  /// Only the date counts, not the time.
  final DateTime day;
  final double? sleepHours;

  /// Which of [mealNames] the child ate well.
  final Set<String> meals;
  final String note;

  static const mealNames = ['Breakfast', 'Lunch', 'Dinner'];

  static DateTime dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool sameDay(DateTime other) => dayOf(other) == day;

  Map<String, dynamic> toJson() => {
        'day': day.toIso8601String(),
        'sleepHours': sleepHours,
        'meals': meals.toList(),
        'note': note,
      };

  static DailyLog? fromJson(Map<String, dynamic> json) {
    final day = _date(json['day']);
    if (day == null) return null;

    return DailyLog(
      day: dayOf(day),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      meals: {
        for (final m in json['meals'] as List? ?? const []) '$m',
      },
      note: json['note'] as String? ?? '',
    );
  }
}

/// What happened before a hard moment, what the child did and what
/// helped. Over time this shows patterns.
class TriggerEntry {
  TriggerEntry({
    String? id,
    required this.when,
    required this.trigger,
    this.behavior = '',
    this.helped = '',
  }) : id = id ?? newRecordId();

  final String id;
  final DateTime when;
  final String trigger;
  final String behavior;
  final String helped;

  Map<String, dynamic> toJson() => {
        'id': id,
        'when': when.toIso8601String(),
        'trigger': trigger,
        'behavior': behavior,
        'helped': helped,
      };

  static TriggerEntry? fromJson(Map<String, dynamic> json) {
    final when = _date(json['when']);
    final trigger = json['trigger'] as String? ?? '';
    if (when == null || trigger.isEmpty) return null;

    return TriggerEntry(
      id: json['id'] as String?,
      when: when,
      trigger: trigger,
      behavior: json['behavior'] as String? ?? '',
      helped: json['helped'] as String? ?? '',
    );
  }
}

/// A note about the child from a teacher or the school, written by the parent.
class SchoolNote {
  SchoolNote({
    String? id,
    required this.teacherName,
    required this.text,
    DateTime? writtenAt,
  })  : id = id ?? newRecordId(),
        writtenAt = writtenAt ?? DateTime.now();

  final String id;
  final String teacherName;
  final String text;
  final DateTime writtenAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherName': teacherName,
        'text': text,
        'writtenAt': writtenAt.toIso8601String(),
      };

  static SchoolNote? fromJson(Map<String, dynamic> json) {
    final at = _date(json['writtenAt']);
    final text = json['text'] as String? ?? '';
    if (at == null || text.isEmpty) return null;

    return SchoolNote(
      id: json['id'] as String?,
      teacherName: json['teacherName'] as String? ?? 'School',
      text: text,
      writtenAt: at,
    );
  }
}
