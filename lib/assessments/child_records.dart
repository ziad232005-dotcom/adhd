import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A list of saved records for each child, kept on the device. Newest
/// first. Each kind of record (CARS result, medication, ...) is one
/// instance with its own storage key.
class ChildRecords<T> extends ChangeNotifier {
  ChildRecords({
    required this.keyPrefix,
    required this.fromJson,
    required this.toJson,
  });

  final String keyPrefix;

  /// Returns null for saved data that is not a valid record.
  final T? Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T item) toJson;

  final Map<int, List<T>> _items = {};

  /// Records of a child, newest first. Call [load] first.
  List<T> of(int childId) => List.unmodifiable(_items[childId] ?? const []);

  T? latest(int childId) {
    final list = _items[childId];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  Future<void> load(int childId) async {
    final list = <T>[];

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$keyPrefix$childId');

      if (raw != null) {
        for (final item in jsonDecode(raw) as List) {
          final record = fromJson(Map<String, dynamic>.from(item as Map));
          if (record != null) list.add(record);
        }
      }
    } catch (_) {
      // Damaged data: start with an empty list rather than crash.
      list.clear();
    }

    _items[childId] = list;
    notifyListeners();
  }

  Future<void> add(int childId, T item) async {
    _items.putIfAbsent(childId, () => []).insert(0, item);
    notifyListeners();
    await _persist(childId);
  }

  Future<void> removeWhere(int childId, bool Function(T item) test) async {
    _items[childId]?.removeWhere(test);
    notifyListeners();
    await _persist(childId);
  }

  /// Replaces records for which [same] is true with [item] (or adds it).
  Future<void> put(
    int childId,
    T item, {
    required bool Function(T existing) same,
  }) async {
    final list = _items.putIfAbsent(childId, () => []);
    final index = list.indexWhere(same);

    if (index == -1) {
      list.insert(0, item);
    } else {
      list[index] = item;
    }
    notifyListeners();
    await _persist(childId);
  }

  Future<void> forget(int childId) async {
    _items.remove(childId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$keyPrefix$childId');
    } catch (_) {
      // Best effort.
    }
    notifyListeners();
  }

  Future<void> _persist(int childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$keyPrefix$childId',
        jsonEncode((_items[childId] ?? []).map(toJson).toList()),
      );
    } catch (_) {
      // Saving is best effort; the screen state is still correct.
    }
  }
}
