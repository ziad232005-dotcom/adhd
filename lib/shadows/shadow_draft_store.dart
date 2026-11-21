import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shadow_application.dart';

/// Keeps the form on the phone while the Shadow Teacher fills it in, so
/// closing the app does not lose their answers.
class ShadowDraftStore extends ChangeNotifier {
  ShadowDraftStore._();

  static final ShadowDraftStore instance = ShadowDraftStore._();

  static const _key = 'mazid_shadow_draft';

  ShadowApplication application = ShadowApplication();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        application = ShadowApplication.fromJson(json);
        notifyListeners();
      }
    } catch (_) {
      // A damaged draft is ignored; the teacher starts again.
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(application.toJson()));
  }

  void edit(void Function(ShadowApplication app) change) {
    change(application);
    notifyListeners();
    _save();
  }

  void setDocument(ShadowDocument document) =>
      edit((app) => app.documents[document.kind] = document);

  void removeDocument(String kind) =>
      edit((app) => app.documents.remove(kind));

  /// Forgets the form after it was sent.
  Future<void> clear() async {
    application = ShadowApplication();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
