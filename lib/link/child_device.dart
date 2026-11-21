import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers that this phone belongs to a child. While it does, the app
/// opens straight on the child's screen and cannot reach the parent's
/// screens until the parent types the unlock code.
class ChildDevice extends ChangeNotifier {
  ChildDevice._();

  static final ChildDevice instance = ChildDevice._();

  static const _childKey = 'mazid_child_device_child';
  static const _codeKey = 'mazid_child_device_code';
  static const _syncKey = 'mazid_child_device_sync';

  int? _childId;
  String? _unlockCode;
  String? _sync;

  /// The child this phone is linked to, or null when it is not.
  int? get childId => _childId;

  bool get isLinked => _childId != null;

  /// The secret used to send test results to the parent's phone, if any.
  String? get syncKey => _sync;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _childId = prefs.getInt(_childKey);
    _unlockCode = prefs.getString(_codeKey);
    _sync = prefs.getString(_syncKey);
    if (_unlockCode == null) _childId = null;
    notifyListeners();
  }

  Future<void> link(int childId, String unlockCode, {String? syncKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_childKey, childId);
    await prefs.setString(_codeKey, unlockCode);
    if (syncKey == null) {
      await prefs.remove(_syncKey);
    } else {
      await prefs.setString(_syncKey, syncKey);
    }
    _childId = childId;
    _unlockCode = unlockCode;
    _sync = syncKey;
    notifyListeners();
  }

  /// Whether [code] is the parent's code. Changes nothing.
  bool checkCode(String code) =>
      _unlockCode != null && code.trim() == _unlockCode;

  /// Leaves child mode when [code] is right. Returns whether it was.
  Future<bool> unlock(String code) async {
    if (_unlockCode == null || code.trim() != _unlockCode) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_childKey);
    await prefs.remove(_codeKey);
    await prefs.remove(_syncKey);
    _childId = null;
    _unlockCode = null;
    _sync = null;
    notifyListeners();
    return true;
  }
}
