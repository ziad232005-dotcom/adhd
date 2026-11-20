import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/link/child_link.dart';
import 'package:adhd/parent/parent_store.dart';

ChildLink sample({int tasks = 3}) => ChildLink(
      child: ParentChild(
        id: 7,
        name: 'Omar',
        birthDate: DateTime(2018, 3, 12),
        grade: '2',
        pin: '1234',
      ),
      unlockCode: '123456',
      data: {
        'tasks': [
          for (var i = 0; i < tasks; i++)
            {'id': i, 'title': 'Task $i', 'subtitle': 'Do it', 'points': 5},
        ],
        'rewards': <dynamic>[],
        'nextTaskId': tasks,
        'nextRewardId': 1,
      },
    );

void main() {
  test('a code survives the trip to the child phone', () {
    final decoded = ChildLink.decode(sample().encode())!;
    expect(decoded.child.id, 7);
    expect(decoded.child.name, 'Omar');
    expect(decoded.child.birthDate, DateTime(2018, 3, 12));
    expect(decoded.unlockCode, '123456');
    expect((decoded.data['tasks'] as List).length, 3);
  });

  test('the child PIN is not part of the code', () {
    final text = sample().encode();
    final json = String.fromCharCodes(
      base64Url.decode(text.substring('mazid1.'.length)),
    );
    expect(json.contains('"pin"'), isFalse);
  });

  test('too many tasks are trimmed so the code can still be scanned', () {
    final text = sample(tasks: 80).encode();
    expect(text.length, lessThanOrEqualTo(ChildLink.maxLength));
    expect(ChildLink.decode(text), isNotNull);
  });

  test('anything else is rejected', () {
    expect(ChildLink.decode(''), isNull);
    expect(ChildLink.decode('hello'), isNull);
    expect(ChildLink.decode('mazid1.@@@'), isNull);
    expect(ChildLink.decode('mazid1.e30='), isNull);
  });

  test('unlock codes are six digits', () {
    for (var i = 0; i < 50; i++) {
      expect(ChildLink.newUnlockCode(), matches(RegExp(r'^\d{6}$')));
    }
  });
}
