import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The kinds of report kept in a child's reports folder.
enum ReportKind {
  weekly('Weekly reports'),
  cars('CARS reports'),
  tova('TOVA reports'),
  doctor('Doctor reports');

  const ReportKind(this.folderTitle);

  final String folderTitle;
}

/// One PDF stored in a child's reports folder.
class SavedReport {
  const SavedReport({
    required this.kind,
    required this.key,
    required this.title,
    required this.createdAt,
  });

  factory SavedReport.fromJson(Map<String, dynamic> json) => SavedReport(
        kind: ReportKind.values.byName(json['kind'] as String),
        key: json['key'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final ReportKind kind;

  /// Identifies the report inside the folder. Saving again with the same
  /// key replaces the file instead of adding a second one.
  final String key;
  final String title;
  final DateTime createdAt;

  String get fileName => '${kind.name}-$key.pdf';

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'key': key,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Keeps every report PDF of every child in one folder per child:
/// `<documents>/reports/<childId>/`. A small list in SharedPreferences
/// remembers titles and dates.
class ReportLibrary extends ChangeNotifier {
  ReportLibrary({Future<Directory> Function()? rootProvider})
      : _rootProvider = rootProvider ?? getApplicationDocumentsDirectory;

  static final ReportLibrary instance = ReportLibrary();

  final Future<Directory> Function() _rootProvider;
  final Map<int, List<SavedReport>> _byChild = {};

  static final _safeKey = RegExp(r'^[A-Za-z0-9-]+$');

  String _prefsKey(int childId) => 'mazid_reports_$childId';

  /// The reports of [childId], newest first. Call [load] first.
  List<SavedReport> of(int childId) =>
      List.unmodifiable(_byChild[childId] ?? const []);

  List<SavedReport> ofKind(int childId, ReportKind kind) =>
      of(childId).where((r) => r.kind == kind).toList();

  Future<void> load(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey(childId)) ?? const [];
    final reports = <SavedReport>[];

    for (final item in raw) {
      try {
        reports.add(
          SavedReport.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // A damaged entry is skipped; the other reports stay available.
      }
    }

    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _byChild[childId] = reports;
    notifyListeners();
  }

  Future<File> _file(int childId, SavedReport report) async {
    final root = await _rootProvider();
    final folder = Directory('${root.path}/reports/$childId');
    await folder.create(recursive: true);
    return File('${folder.path}/${report.fileName}');
  }

  /// Saves [bytes] in the child's folder, replacing a report with the same
  /// kind and key.
  Future<SavedReport> save({
    required int childId,
    required ReportKind kind,
    required String key,
    required String title,
    required Uint8List bytes,
    DateTime? createdAt,
  }) async {
    if (!_safeKey.hasMatch(key)) {
      throw ArgumentError.value(key, 'key', 'Only letters, digits and "-".');
    }
    if (!_byChild.containsKey(childId)) await load(childId);

    final report = SavedReport(
      kind: kind,
      key: key,
      title: title,
      createdAt: createdAt ?? DateTime.now(),
    );

    await (await _file(childId, report)).writeAsBytes(bytes, flush: true);

    final list = _byChild[childId]!
      ..removeWhere((r) => r.kind == kind && r.key == key)
      ..add(report)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _persist(childId, list);
    notifyListeners();
    return report;
  }

  Future<Uint8List> read(int childId, SavedReport report) async {
    return (await _file(childId, report)).readAsBytes();
  }

  Future<void> delete(int childId, SavedReport report) async {
    final file = await _file(childId, report);
    if (await file.exists()) await file.delete();

    final list = _byChild[childId] ?? [];
    list.removeWhere((r) => r.kind == report.kind && r.key == report.key);
    await _persist(childId, list);
    notifyListeners();
  }

  Future<void> _persist(int childId, List<SavedReport> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey(childId),
      [for (final r in list) jsonEncode(r.toJson())],
    );
  }
}
