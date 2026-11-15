import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/core/widgets/mazid_widgets.dart';

void main() {
  group('MazidPasswordPolicy', () {
    test('accepts a capital first letter, a special character and 8+ chars',
        () {
      expect(MazidPasswordPolicy.isStrong('Password.'), isTrue);
      expect(MazidPasswordPolicy.isStrong('Pass#word'), isTrue);
      expect(MazidPasswordPolicy.isStrong('Mazid2026!'), isTrue);
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(MazidPasswordPolicy.isStrong('Pass.1'), isFalse);
    });

    test('rejects a password that does not start with a capital letter', () {
      expect(MazidPasswordPolicy.isStrong('password.'), isFalse);
      expect(MazidPasswordPolicy.isStrong('pAssword.'), isFalse);
      expect(MazidPasswordPolicy.isStrong('1Password.'), isFalse);
    });

    test('rejects a password without a special character', () {
      expect(MazidPasswordPolicy.isStrong('Password1'), isFalse);
      expect(MazidPasswordPolicy.isStrong('Pass word'), isFalse);
    });
  });

  group('MazidValidators.password', () {
    test('returns a specific message for each broken rule', () {
      expect(MazidValidators.password('Ab.1'),
          'Use at least 8 characters.');
      expect(MazidValidators.password('password.'),
          'The first letter must be a capital letter.');
      expect(MazidValidators.password('Password1'),
          'Add a special character such as . # @ or !');
      expect(MazidValidators.password('Password.'), isNull);
    });
  });
}
