import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/assessments/cars_models.dart';
import 'package:adhd/assessments/cars_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CARS scoring', () {
    test('has 15 areas and a top score of 60', () {
      expect(CarsQuestionnaire.itemCount, 15);
      expect(CarsQuestionnaire.maxScore, 60);
      expect(CarsQuestionnaire.levels.map((l) => l.score), [1, 2, 3, 4]);
    });

    test('bands follow the 30 and 37 limits', () {
      expect(CarsQuestionnaire.bandFor(15), CarsBand.typical);
      expect(CarsQuestionnaire.bandFor(29), CarsBand.typical);
      expect(CarsQuestionnaire.bandFor(30), CarsBand.mildToModerate);
      expect(CarsQuestionnaire.bandFor(36), CarsBand.mildToModerate);
      expect(CarsQuestionnaire.bandFor(37), CarsBand.severe);
      expect(CarsQuestionnaire.bandFor(60), CarsBand.severe);
    });

    test('a result adds up its scores', () {
      final result = CarsResult(
        takenAt: DateTime(2026, 11, 20),
        scores: List.filled(15, 2),
      );

      expect(result.total, 30);
      expect(result.band, CarsBand.mildToModerate);
    });

    test('incomplete or invalid saved data is ignored', () {
      expect(
        CarsResult.fromJson({'takenAt': '2026-11-20T10:00:00', 'scores': [1]}),
        isNull,
      );
      expect(
        CarsResult.fromJson({
          'takenAt': '2026-11-20T10:00:00',
          'scores': List.filled(15, 9),
        }),
        isNull,
      );
    });
  });

  group('CARS store', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('keeps results per child, newest first, across reloads', () async {
      await carsStore.forget(1);
      await carsStore.forget(2);

      await carsStore.add(
        1,
        CarsResult(takenAt: DateTime(2026, 6, 1), scores: List.filled(15, 2), note: 'later'),
      );

      expect(carsStore.latest(1)!.note, 'later');
      expect(carsStore.of(2), isEmpty);

      await carsStore.load(1);
      expect(carsStore.of(1), hasLength(1));
      expect(carsStore.latest(1)!.total, 30);
    });
  });
}
