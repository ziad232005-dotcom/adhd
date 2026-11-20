import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/assessments/tova_comparison.dart';
import 'package:adhd/assessments/tova_pdf.dart';
import 'package:adhd/assessments/tova_record.dart';

TovaRecord record(
  DateTime date, {
  String mode = 'Focus',
  double accuracy = 80,
  double omission = 10,
  double commission = 10,
  int early = 2,
  double? meanRt = 500,
}) =>
    TovaRecord(
      takenAt: date,
      modeTitle: mode,
      trials: 60,
      completed: true,
      hits: 20,
      omissions: 4,
      commissions: 3,
      anticipatory: early,
      accuracyPct: accuracy,
      meanRtMs: meanRt,
      omissionPct: omission,
      commissionPct: commission,
    );

void main() {
  group('TOVA comparison', () {
    final older = record(DateTime(2026, 1, 1));

    test('the first result has nothing to compare with', () {
      final c = TovaComparison.compare(older, [older]);
      expect(c.trend, TovaTrend.first);
      expect(c.previous, isNull);
    });

    test('better accuracy and fewer misses is an improvement', () {
      final newer = record(
        DateTime(2026, 2, 1),
        accuracy: 90,
        omission: 4,
        commission: 5,
        early: 0,
        meanRt: 420,
      );
      final c = TovaComparison.compare(newer, [newer, older]);
      expect(c.trend, TovaTrend.improved);
      expect(c.previous, older);
    });

    test('small changes count as about the same', () {
      final newer = record(DateTime(2026, 2, 1), accuracy: 81, early: 3);
      final c = TovaComparison.compare(newer, [newer, older]);
      expect(c.trend, TovaTrend.stable);
    });

    test('mixed results are reported as mixed', () {
      final newer = record(DateTime(2026, 2, 1), accuracy: 95, omission: 20);
      final c = TovaComparison.compare(newer, [newer, older]);
      expect(c.trend, TovaTrend.mixed);
    });

    test('only the same kind of activity is compared', () {
      final other = record(DateTime(2026, 1, 15), mode: 'Other');
      final newer = record(DateTime(2026, 2, 1), accuracy: 90);
      final c = TovaComparison.compare(newer, [newer, other, older]);
      expect(c.previous, older);
    });

    test('a missing response time cannot be compared', () {
      final newer = record(DateTime(2026, 2, 1), meanRt: null);
      final c = TovaComparison.compare(newer, [newer, older]);
      final rt = c.measures.last;
      expect(rt.verdict, isNull);
    });
  });

  test('records keep the new details when saved and loaded', () {
    final saved = record(DateTime(2026, 3, 1), omission: 12.5);
    final loaded = TovaRecord.fromJson(saved.toJson())!;
    expect(loaded.omissionPct, 12.5);
    expect(loaded.commissionPct, saved.commissionPct);
  });

  test('records saved before the new details still load', () {
    final loaded = TovaRecord.fromJson({
      'takenAt': DateTime(2026, 3, 1).toIso8601String(),
      'modeTitle': 'Focus',
      'accuracyPct': 70,
    })!;
    expect(loaded.omissionPct, 0);
    expect(loaded.sdRtMs, isNull);
  });

  test('the PDF is created', () async {
    final font = ByteData.sublistView(
      Uint8List.fromList(File('fonts/Cairo-Regular.ttf').readAsBytesSync()),
    );
    final current = record(DateTime(2026, 2, 1));
    final bytes = await TovaPdf.build(
      childName: 'Omar',
      childAge: 8,
      current: current,
      history: [current, record(DateTime(2026, 1, 1))],
      fontData: font,
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
