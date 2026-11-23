import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/child.dart' show ChildReward;
import 'package:adhd/child_focus_ring.dart';
import 'package:adhd/child_goal_card.dart';
import 'package:adhd/child_mascot.dart';

ChildReward _reward(int id, String title, int target) =>
    ChildReward(id: id, title: title, description: '', targetPoints: target);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the next goal is the nearest reward not reached', () {
    final rewards = [_reward(1, 'Big', 100), _reward(2, 'Small', 40)];

    final goal = NextGoal.of(rewards, 10, (r) => 10 >= r.targetPoints)!;

    expect(goal.reward.title, 'Small');
    expect(goal.pointsLeft, 30);
    expect(goal.progress(10), 0.25);
  });

  test('there is no goal when every reward is reached or none exist', () {
    expect(NextGoal.of([], 5, (_) => false), isNull);
    expect(NextGoal.of([_reward(1, 'A', 5)], 5, (_) => true), isNull);
  });

  test('the greeting follows the time of day', () {
    expect(greetingFor(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(greetingFor(DateTime(2026, 1, 1, 14)), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 1, 1, 20)), 'Good evening');
  });

  testWidgets('the goal card and the focus ring show their text',
      (tester) async {
    final goal = NextGoal(reward: _reward(1, 'Ice cream', 50), pointsLeft: 30);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          NextGoalCard(goal: goal, points: 20, onOpen: () {}),
          const FocusRing(remaining: 0.5, label: '05:00'),
        ]),
      ),
    ));

    expect(find.text('Ice cream'), findsOneWidget);
    expect(find.text('30 points left'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
  });
}
