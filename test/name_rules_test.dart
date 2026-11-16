import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/core/widgets/mazid_widgets.dart';

void main() {
  group('Name rules', () {
    test('accepts letters in any language and single spaces', () {
      expect(MazidValidators.personName('Ahmed Ali', 'empty'), isNull);
      expect(MazidValidators.personName('أحمد علي', 'empty'), isNull);
    });

    test('rejects digits, symbols, hyphens and empty values', () {
      expect(MazidValidators.personName('Ahmed2', 'empty'), isNotNull);
      expect(MazidValidators.personName('Ahmed@', 'empty'), isNotNull);
      expect(MazidValidators.personName('Anne-Marie', 'empty'), isNotNull);
      expect(MazidValidators.personName('   ', 'empty'), 'empty');
      expect(MazidValidators.personName('A', 'empty'), isNotNull);
    });

    test('the optional rule allows an empty value only', () {
      expect(MazidValidators.optionalPersonName(''), isNull);
      expect(MazidValidators.optionalPersonName('Sara'), isNull);
      expect(MazidValidators.optionalPersonName('Sara1'), isNotNull);
    });

    test('the formatter removes everything that is not a letter', () {
      final formatter = MazidInputFormatters.name.first;
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: ' Ah1med  #Ali',
          selection: TextSelection.collapsed(offset: 13),
        ),
      );

      expect(result.text, 'Ahmed Ali');
    });
  });
}
