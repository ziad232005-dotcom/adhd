import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cars_models.dart';

/// Saved CARS questionnaires, kept per child on the device.
class CarsStore extends ChangeNotifier {
  CarsStore._();

  static final CarsStore instance = CarsStore._();

  static const _keyPrefix = 'mazid_cars_child_';

  final Map<int, List<CarsResult>> _results = {};

  /// Results of a child, newest first. Loaded on first use.
  List<CarsResult> resultsFor(int childId) =>
      List.unmodifiable(_results[childId] ?? const []);

  CarsResult? latestFor(int childId) {
    final list = _results[childId];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  Future<void> load(int childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_keyPrefix$childId');
      final list = <CarsResult>[];

      if (raw != null) {
        for (final item in jsonDecode(raw) as List) {
          final result = CarsResult.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          if (result != null) list.add(result);
        }
      }

      _results[childId] = list;
    } catch (_) {
      _results[childId] = [];
    }
    notifyListeners();
  }

  Future<void> save(int childId, CarsResult result) async {
    final list = _results.putIfAbsent(childId, () => []);
    list.insert(0, result);
    notifyListeners();
    await _persist(childId);
  }

  Future<void> forget(int childId) async {
    _results.remove(childId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$childId');
    } catch (_) {
      // Best effort.
    }
    notifyListeners();
  }

  Future<void> _persist(int childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_keyPrefix$childId',
        jsonEncode(_results[childId]!.map((r) => r.toJson()).toList()),
      );
    } catch (_) {
      // Saving is best effort; the screen state is still correct.
    }
  }
}
