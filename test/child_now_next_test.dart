import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/child.dart';
import 'package:adhd/child_calm.dart';
import 'package:adhd/child_now_card.dart';

ChildTask _task(int id, String title) =>
    ChildTask(id, title, '', Icons.task_alt_rounded, 5);

void main() {
  final tasks = [_task(1, 'Read'), _task(2, 'Tidy'), _task(3, 'Draw')];

  test('now is the first task not done and next is the one after it', () {
    final plan = NowNext.of(tasks, (task) => task.id == 1);

    expect(plan.now?.title, 'Tidy');
    expect(plan.next?.title, 'Draw');
  });

  test('with one task left there is no next', () {
    final plan = NowNext.of(tasks, (task) => task.id != 3);

    expect(plan.now?.title, 'Draw');
    expect(plan.next, isNull);
  });

  test('with every task done there is nothing now', () {
    final plan = NowNext.of(tasks, (_) => true);

    expect(plan.now, isNull);
    expect(plan.next, isNull);
  });

  testWidgets('the card shows the task and the next one', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NowNextCard(
          plan: NowNext.of(tasks, (_) => false),
          onOpen: () {},
        ),
      ),
    ));

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Next: Tidy'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('the calm minute starts and stops', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalmScreen()));

    expect(find.text('Breathe with the octopus.'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Breathe in'), findsOneWidget);

    // The animation is done only after its full length has passed, so go a
    // little further, then let the next phase start.
    await tester.pump(const Duration(seconds: 4, milliseconds: 500));
    await tester.pump();
    expect(find.text('Breathe out'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('Start'), findsOneWidget);
  });
}
