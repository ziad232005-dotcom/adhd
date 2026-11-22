import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../assessments/cars_models.dart';
import '../assessments/cars_store.dart';
import '../assessments/tova_record.dart';
import '../core/api_client.dart';
import '../link/child_device.dart';
import '../parent/parent_store.dart';
import '../reports/report_builder.dart';

/// The secret that ties a child's phone to the parent's phone. The parent's
/// phone makes it once per child and puts it in the child's QR code.
class SyncKeys {
  const SyncKeys._();

  static final RegExp valid = RegExp(r'^[A-Za-z0-9_-]{20,64}$');

  static String _prefsKey(int childId) => 'mazid_child_sync_$childId';

  static String _make() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// The child's key; made on first use.
  static Future<String> forChild(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey(childId));
    if (saved != null && valid.hasMatch(saved)) return saved;

    final key = _make();
    await prefs.setString(_prefsKey(childId), key);
    return key;
  }

  /// The child's key, or null when no QR code was made for the child yet.
  static Future<String?> existing(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey(childId));
    return saved != null && valid.hasMatch(saved) ? saved : null;
  }
}

/// Moves test results from the child's phone to the parent's phone.
///
/// The child's phone keeps results in a small queue and sends them when the
/// server can be reached, so a game played without internet is not lost.
/// The parent's phone pulls them, adds them to the child's records and
/// makes the PDF in the reports folder.
class ResultSync {
  ResultSync({this.client = const ApiClient()});

  static final ResultSync instance = ResultSync();

  static const _pendingKey = 'mazid_sync_pending';

  final ApiClient client;
  bool _flushing = false;

  // Child's phone ---------------------------------------------------------

  /// Queues a finished test for the parent, only when this phone is the
  /// child's own and the result is the linked child's.
  Future<void> sendIfLinked({
    required int childId,
    required String kind,
    required DateTime takenAt,
    required Map<String, dynamic> data,
  }) async {
    final device = ChildDevice.instance;
    if (device.childId != childId || device.syncKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingKey) ?? [];
    pending.add(jsonEncode({
      'kind': kind,
      'id': '${takenAt.millisecondsSinceEpoch}',
      'data': data,
    }));
    await prefs.setStringList(_pendingKey, pending);

    await flush();
  }

  /// Sends what is waiting. Stops at the first failure and tries again the
  /// next time. Never throws.
  Future<void> flush() async {
    final key = ChildDevice.instance.syncKey;
    if (key == null || _flushing) return;
    _flushing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = List<String>.of(prefs.getStringList(_pendingKey) ?? []);

      while (pending.isNotEmpty) {
        final item = jsonDecode(pending.first) as Map<String, dynamic>;
        try {
          await client.post('/api/sync/push', {'key': key, ...item});
        } on ApiException {
          break;
        }
        pending.removeAt(0);
        await prefs.setStringList(_pendingKey, pending);
      }
    } catch (_) {
      // Sending is best effort; the queue is kept for the next try.
    } finally {
      _flushing = false;
    }
  }

  // Parent's phone --------------------------------------------------------

  /// Reads the results the child's phone sent and adds the new ones to the
  /// child's records, with their PDF. Returns how many were new. The child's
  /// records must be loaded. Throws [ApiException] when the server cannot
  /// be reached.
  Future<int> pull(ParentChild child) async {
    final key = await SyncKeys.existing(child.id);
    if (key == null) return 0;

    final body = await client.post('/api/sync/pull', {'key': key});
    final results = body['results'];
    if (results is! List) return 0;

    var added = 0;
    for (final item in results) {
      if (item is! Map<String, dynamic>) continue;
      final data = item['data'];
      if (data is! Map<String, dynamic>) continue;

      switch (item['kind']) {
        case 'tova':
          final record = TovaRecord.fromJson(data);
          if (record == null || _hasTova(child.id, record)) continue;
          await tovaStore.add(child.id, record);
          await ReportBuilder.saveTova(
            child.id,
            child.name,
            child.age,
            record,
          );
          added++;
        case 'cars':
          final result = CarsResult.fromJson(data);
          if (result == null || _hasCars(child.id, result)) continue;
          await carsStore.add(child.id, result);
          await ReportBuilder.saveCars(child, result);
          added++;
      }
    }
    return added;
  }

  bool _hasTova(int childId, TovaRecord record) => tovaStore
      .of(childId)
      .any((r) => r.takenAt.millisecondsSinceEpoch ==
          record.takenAt.millisecondsSinceEpoch);

  bool _hasCars(int childId, CarsResult result) => carsStore
      .of(childId)
      .any((r) => r.takenAt.millisecondsSinceEpoch ==
          result.takenAt.millisecondsSinceEpoch);
}
