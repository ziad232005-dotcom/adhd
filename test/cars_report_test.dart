import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/assessments/cars_comparison.dart';
import 'package:adhd/assessments/cars_models.dart';
import 'package:adhd/assessments/cars_pdf.dart';

CarsResult result(int score, DateTime date, {List<int>? scores}) =>
    CarsResult(takenAt: date, scores: scores ?? List.filled(15, score));

void main() {
  group('CARS comparison', () {
    final before = result(3, DateTime(2026, 1, 1)); // total 45
    final after = result(2, DateTime(2026, 6, 1)); // total 30

    test('the first assessment has nothing to compare with', () {
      final c = CarsComparison.compare(after, null);

      expect(c.trend, CarsTrend.first);
      expect(c.areas, isEmpty);
      expect(c.totalChange, 0);
    });

    test('a lower total is an improvement', () {
      final c = CarsComparison.compare(after, before);

      expect(c.trend, CarsTrend.improved);
      expect(c.totalChange, -15);
      expect(c.improvedAreas, hasLength(15));
      expect(c.worsenedAreas, isEmpty);
      expect(c.bandChanged, isTrue);
      expect(c.headline, contains('15 points'));
    });

    test('a higher total is worse', () {
      final c = CarsComparison.compare(before, after);

      expect(c.trend, CarsTrend.worse);
      expect(c.totalChange, 15);
      expect(c.worsenedAreas, hasLength(15));
    });

    test('small changes count as about the same', () {
      final almost = result(
        0,
        DateTime(2026, 7, 1),
        scores: [3, ...List.filled(14, 2)], // 31
      );

      final c = CarsComparison.compare(almost, after); // 30 -> 31

      expect(c.trend, CarsTrend.stable);
      expect(c.totalChange, 1);
      expect(c.unchangedAreas, 14);
      expect(c.worsenedAreas, hasLength(1));
    });
  });

  group('CARS PDF', () {
    Future<Uint8List> build(List<CarsResult> history) {
      final bytes = File('fonts/Cairo-Regular.ttf').readAsBytesSync();

      return CarsPdf.build(
        childName: 'Omar',
        childAge: 8,
        current: history.first,
        history: history,
        fontData: ByteData.sublistView(bytes),
      );
    }

    test('creates a PDF for a first assessment', () async {
      final pdf = await build([result(2, DateTime(2026, 6, 1))]);

      expect(String.fromCharCodes(pdf.take(4)), '%PDF');
    });

    test('creates a PDF that compares with earlier assessments', () async {
      final pdf = await build([
        CarsResult(
          takenAt: DateTime(2026, 6, 1),
          scores: List.filled(15, 2),
          note: 'Better at school',
        ),
        result(3, DateTime(2026, 1, 1)),
      ]);

      expect(String.fromCharCodes(pdf.take(4)), '%PDF');
      expect(pdf.length, greaterThan(2000));
    });
  });
}
