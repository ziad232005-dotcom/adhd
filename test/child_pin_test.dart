import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/parent/parent_store.dart';

void main() {
  group('Child PIN', () {
    test('accepts exactly four digits', () {
      expect(ParentChild.isValidPin('1234'), isTrue);
      expect(ParentChild.isValidPin('123'), isFalse);
      expect(ParentChild.isValidPin('12345'), isFalse);
      expect(ParentChild.isValidPin('12a4'), isFalse);
    });

    test('older children without a PIN get a random valid one', () {
      final child = ParentChild.fromJson({
        'id': 1,
        'name': 'Omar',
        'grade': 'Grade 3',
      });

      expect(ParentChild.isValidPin(child.pin), isTrue);
    });

    test('random PINs are four digits and not all the same', () {
      final pins = {for (var i = 0; i < 30; i++) ParentChild.randomPin()};

      expect(pins.every(ParentChild.isValidPin), isTrue);
      expect(pins.length, greaterThan(1));
    });

    test('a damaged saved PIN is replaced', () {
      final child = ParentChild.fromJson({
        'id': 1,
        'name': 'Omar',
        'grade': 'Grade 3',
        'pin': 'abcd',
      });

      expect(ParentChild.isValidPin(child.pin), isTrue);
    });

    test('the PIN is kept when saved, loaded and copied', () {
      const child = ParentChild(
        id: 1,
        name: 'Omar',
        grade: 'Grade 3',
        pin: '4821',
      );

      expect(ParentChild.fromJson(child.toJson()).pin, '4821');
      expect(child.copyWith(name: 'Ali').pin, '4821');
      expect(child.copyWith(pin: '1111').pin, '1111');
    });
  });
}
