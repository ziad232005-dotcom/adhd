import 'dart:convert';
import 'dart:math';

import '../parent/parent_store.dart';

/// What the parent's QR code carries so the child's own phone can open the
/// child's screen: the child's profile, their tasks and rewards, and a
/// code the parent uses to leave child mode on that phone.
///
/// There is no server yet, so this is a copy made at the moment the QR code
/// is shown. Later changes on the parent's phone do not reach the child's.
class ChildLink {
  const ChildLink({
    required this.child,
    required this.unlockCode,
    required this.data,
    this.syncKey,
  });

  static const _prefix = 'mazid1.';
  static const _version = 1;

  /// Larger payloads make a QR code too dense to scan.
  static const maxLength = 1800;

  final ParentChild child;

  /// Six digits. The parent types it to leave child mode on the child's phone.
  final String unlockCode;

  /// Tasks and rewards as saved by the child's data store.
  final Map<String, dynamic> data;

  /// Secret that lets the child's phone send test results to the parent's.
  final String? syncKey;

  static String newUnlockCode() =>
      Random.secure().nextInt(1000000).toString().padLeft(6, '0');

  /// The text for the QR code. Tasks are dropped from the end until it is
  /// short enough to scan.
  String encode() {
    final tasks = List<dynamic>.of(data['tasks'] as List<dynamic>? ?? []);
    final rewards = data['rewards'] as List<dynamic>? ?? [];

    String build() => _prefix +
        base64Url.encode(
          utf8.encode(
            jsonEncode({
              'v': _version,
              'unlock': unlockCode,
              if (syncKey != null) 'sync': syncKey,
              'child': {
                'id': child.id,
                'name': child.name,
                'birthDate': child.birthDate?.toIso8601String(),
                'age': child.birthDate == null ? child.age : null,
                'grade': child.grade,
              },
              'data': {
                'tasks': tasks,
                'rewards': rewards,
                'nextTaskId': data['nextTaskId'],
                'nextRewardId': data['nextRewardId'],
                'note': data['note'],
              },
            }),
          ),
        );

    var text = build();
    while (text.length > maxLength && tasks.isNotEmpty) {
      tasks.removeLast();
      text = build();
    }
    return text;
  }

  /// Returns null when [text] is not a valid MAZID child code.
  static ChildLink? decode(String text) {
    final value = text.trim();
    if (!value.startsWith(_prefix) || value.length > maxLength * 2) {
      return null;
    }

    try {
      final json = jsonDecode(
        utf8.decode(base64Url.decode(value.substring(_prefix.length))),
      );
      if (json is! Map<String, dynamic> || json['v'] != _version) return null;

      final childJson = json['child'];
      final code = json['unlock'];
      final data = json['data'];
      if (childJson is! Map<String, dynamic> ||
          data is! Map<String, dynamic> ||
          code is! String ||
          !RegExp(r'^\d{6}$').hasMatch(code)) {
        return null;
      }

      final sync = json['sync'];
      final name = childJson['name'];
      if (childJson['id'] is! int ||
          name is! String ||
          name.trim().isEmpty ||
          name.length > 60) {
        return null;
      }

      return ChildLink(
        child: ParentChild.fromJson(childJson),
        unlockCode: code,
        data: data,
        syncKey: sync is String && RegExp(r'^[A-Za-z0-9_-]{20,64}$').hasMatch(sync)
            ? sync
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}
