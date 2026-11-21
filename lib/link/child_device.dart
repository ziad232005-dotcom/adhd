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

  int? _childId;
  String? _unlockCode;

  /// The child this phone is linked to, or null when it is not.
  int? get childId => _childId;

  bool get isLinked => _childId != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _childId = prefs.getInt(_childKey);
    _unlockCode = prefs.getString(_codeKey);
    if (_unlockCode == null) _childId = null;
    notifyListeners();
  }

  Future<void> link(int childId, String unlockCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_childKey, childId);
    await prefs.setString(_codeKey, unlockCode);
    _childId = childId;
    _unlockCode = unlockCode;
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
    _childId = null;
    _unlockCode = null;
    notifyListeners();
    return true;
  }
}
