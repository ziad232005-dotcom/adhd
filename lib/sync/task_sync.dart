import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../child.dart';
import '../core/api_client.dart';
import '../link/child_device.dart';
import 'result_sync.dart';

/// Moves the child's tasks and rewards from the parent's phone to the
/// child's phone, so a task added later shows up without scanning again.
///
/// The parent's phone sends a copy each time the tasks or rewards change.
/// The child's phone reads the newest copy when it opens.
class TaskSync {
  TaskSync({
    this.client = const ApiClient(),
    this.delay = const Duration(seconds: 3),
  });

  static final TaskSync instance = TaskSync();

  final ApiClient client;

  /// Waits a little so a burst of edits is sent once.
  final Duration delay;

  Timer? _timer;

  static String _sentKey(int childId) => 'mazid_tasks_sent_$childId';
  static const _appliedKey = 'mazid_tasks_applied_at';

  /// Starts listening to the child's data. Call once when the app starts.
  void start() {
    ChildAppState.instance.onContentSaved = _changed;
  }

  // Parent's phone --------------------------------------------------------

  void _changed(int? childId, Map<String, dynamic> content) {
    if (childId == null || ChildDevice.instance.isLinked) return;

    _timer?.cancel();
    _timer = Timer(delay, () => push(childId, content));
  }

  /// Sends the copy when the child has a key and the copy changed since the
  /// last time. Returns whether it was sent. Never throws.
  Future<bool> push(int childId, Map<String, dynamic> content) async {
    try {
      final key = await SyncKeys.existing(childId);
      if (key == null) return false;

      final text = jsonEncode(content);
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_sentKey(childId)) == text) return false;

      await client.post('/api/sync/tasks/put', {'key': key, 'data': content});
      await prefs.setString(_sentKey(childId), text);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Child's phone ---------------------------------------------------------

  /// Reads the parent's newest copy and applies it when it is newer than the
  /// one already applied. Returns whether something was applied. Never throws.
  Future<bool> pullIfLinked() async {
    final device = ChildDevice.instance;
    final key = device.syncKey;
    if (key == null || device.childId == null) return false;

    try {
      final body = await client.post('/api/sync/tasks/get', {'key': key});
      final data = body['data'];
      final updatedAt = body['updatedAt'];
      if (data is! Map<String, dynamic> || updatedAt is! String) return false;

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_appliedKey) == updatedAt) return false;

      await ChildAppState.instance.applySyncedContent(data);
      await prefs.setString(_appliedKey, updatedAt);
      return true;
    } catch (_) {
      return false;
    }
  }
}
