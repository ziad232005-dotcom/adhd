import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/reports/report_library.dart';

void main() {
  late Directory root;
  late ReportLibrary library;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('mazid_reports');
    library = ReportLibrary(rootProvider: () async => root);
  });

  tearDown(() async => root.delete(recursive: true));

  Uint8List bytes(int n) => Uint8List.fromList([n, n, n]);

  test('saves a report in the folder of its child', () async {
    await library.save(
      childId: 3,
      kind: ReportKind.doctor,
      key: '20261121',
      title: 'For the doctor',
      bytes: bytes(1),
    );

    expect(File('${root.path}/reports/3/doctor-20261121.pdf').existsSync(), isTrue);
    expect(library.of(3), hasLength(1));
    expect(library.of(4), isEmpty);
  });

  test('saving the same key again replaces the report', () async {
    for (final n in [1, 2]) {
      await library.save(
        childId: 1,
        kind: ReportKind.weekly,
        key: '20261116',
        title: 'Week',
        bytes: bytes(n),
      );
    }

    expect(library.ofKind(1, ReportKind.weekly), hasLength(1));
    expect(await library.read(1, library.of(1).single), bytes(2));
  });

  test('reports are remembered after a restart', () async {
    await library.save(
      childId: 1,
      kind: ReportKind.cars,
      key: '1',
      title: 'CARS',
      bytes: bytes(1),
    );

    final again = ReportLibrary(rootProvider: () async => root);
    await again.load(1);

    expect(again.of(1).single.title, 'CARS');
  });

  test('delete removes the file and the entry', () async {
    final saved = await library.save(
      childId: 1,
      kind: ReportKind.tova,
      key: '9',
      title: 'TOVA',
      bytes: bytes(1),
    );

    await library.delete(1, saved);

    expect(library.of(1), isEmpty);
    expect(File('${root.path}/reports/1/tova-9.pdf').existsSync(), isFalse);
  });

  test('rejects keys that could escape the folder', () {
    expect(
      () => library.save(
        childId: 1,
        kind: ReportKind.weekly,
        key: '../x',
        title: 't',
        bytes: bytes(1),
      ),
      throwsArgumentError,
    );
  });
}
