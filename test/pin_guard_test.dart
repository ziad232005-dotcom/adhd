import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/core/pin_guard.dart';

void main() {
  final start = DateTime(2026, 11, 20, 12);

  group('PinGuard', () {
    test('accepts the right PIN', () {
      expect(PinGuard().attempt('1234', '1234', start), isTrue);
    });

    test('locks after five wrong tries, even for the right PIN', () {
      final guard = PinGuard();

      for (var i = 0; i < 5; i++) {
        expect(guard.attempt('0000', '1234', start), isFalse);
      }

      expect(guard.lockRemaining(start), const Duration(seconds: 30));
      expect(guard.attempt('1234', '1234', start), isFalse);
    });

    test('opens again after the lock and resets on success', () {
      final guard = PinGuard();
      for (var i = 0; i < 5; i++) {
        guard.attempt('0000', '1234', start);
      }

      final later = start.add(const Duration(seconds: 31));
      expect(guard.lockRemaining(later), isNull);
      expect(guard.attempt('1234', '1234', later), isTrue);
    });

    test('each lock lasts twice as long, up to a limit', () {
      final guard = PinGuard();
      var now = start;

      for (final expected in [30, 60, 120]) {
        for (var i = 0; i < 5; i++) {
          guard.attempt('0000', '1234', now);
        }
        expect(guard.lockRemaining(now), Duration(seconds: expected));
        now = now.add(Duration(seconds: expected + 1));
      }

      for (var round = 0; round < 12; round++) {
        for (var i = 0; i < 5; i++) {
          guard.attempt('0000', '1234', now);
        }
        now = now.add(const Duration(minutes: 16));
      }
      expect(
        guard.lockRemaining(now.subtract(const Duration(minutes: 16))),
        lessThanOrEqualTo(const Duration(minutes: 15)),
      );
    });

    test('each child has their own guard', () {
      expect(identical(PinGuard.forChild(1), PinGuard.forChild(1)), isTrue);
      expect(identical(PinGuard.forChild(1), PinGuard.forChild(2)), isFalse);
    });
  });
}
