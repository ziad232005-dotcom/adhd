import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/core/widgets/bloom_widgets.dart';

void main() {
  group('BloomPasswordPolicy', () {
    test('accepts a capital first letter, a special character and 8+ chars',
        () {
      expect(BloomPasswordPolicy.isStrong('Password.'), isTrue);
      expect(BloomPasswordPolicy.isStrong('Pass#word'), isTrue);
      expect(BloomPasswordPolicy.isStrong('Mazid2026!'), isTrue);
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(BloomPasswordPolicy.isStrong('Pass.1'), isFalse);
    });

    test('rejects a password that does not start with a capital letter', () {
      expect(BloomPasswordPolicy.isStrong('password.'), isFalse);
      expect(BloomPasswordPolicy.isStrong('pAssword.'), isFalse);
      expect(BloomPasswordPolicy.isStrong('1Password.'), isFalse);
    });

    test('rejects a password without a special character', () {
      expect(BloomPasswordPolicy.isStrong('Password1'), isFalse);
      expect(BloomPasswordPolicy.isStrong('Pass word'), isFalse);
    });
  });

  group('BloomValidators.password', () {
    test('returns a specific message for each broken rule', () {
      expect(BloomValidators.password('Ab.1'),
          'Use at least 8 characters.');
      expect(BloomValidators.password('password.'),
          'The first letter must be a capital letter.');
      expect(BloomValidators.password('Password1'),
          'Add a special character such as . # @ or !');
      expect(BloomValidators.password('Password.'), isNull);
    });
  });
}
