import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/child.dart';
import 'package:adhd/task_catalog.dart';
import 'package:adhd/task_catalog_picker.dart';

var _childId = 900;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ChildAppState.instance.loadData(childId: ++_childId);
  });

  test('the catalog is large, tidy and has no repeated task', () {
    expect(taskCatalog.length, greaterThanOrEqualTo(50));
    final titles = taskCatalog.map((task) => task.title).toSet();
    expect(titles.length, taskCatalog.length);
    for (final task in taskCatalog) {
      expect(taskCategories, contains(task.category));
      expect(task.points, greaterThan(0));
      if (task.minutes != null) {
        expect(task.minutes, inInclusiveRange(1, 180));
      }
    }
    for (final category in taskCategories) {
      expect(taskCatalog.where((task) => task.category == category),
          isNotEmpty);
    }
  });

  testWidgets('one tap adds a ready task and then shows it as added',
      (tester) async {
    final data = ChildAppState.instance;
    final first =
        taskCatalog.firstWhere((task) => task.category == taskCategories[0]);
    final before = data.tasks.length;

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: TaskCatalogPicker())),
    ));
    await tester.tap(find.byTooltip('Add ${first.title}'));
    await tester.pump();

    expect(data.tasks.length, before + 1);
    expect(data.tasks.last.title, first.title);
    expect(find.byTooltip('Add ${first.title}'), findsNothing);
  });

  testWidgets('the child cannot mark a task as done', (tester) async {
    final data = ChildAppState.instance;

    await tester.pumpWidget(const MaterialApp(home: ChildTasksScreen()));
    expect(find.text('Your parent checks a task when it is done.'),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.circle_outlined).first);
    await tester.pump();

    expect(data.completedCount, 0);
    expect(data.points, 0);
  });

  test('what the parent confirms reaches the child', () async {
    final data = ChildAppState.instance;
    final task = data.tasks.first;
    expect(data.completeTask(task), isTrue);

    final copy = jsonDecode(jsonEncode(data.linkData()))
        as Map<String, dynamic>;
    expect(copy['points'], task.points);

    // A child's phone that starts empty receives the result.
    await data.loadData(childId: ++_childId);
    expect(data.isCompleted(data.tasks.first), isFalse);
    await data.applySyncedContent(copy);

    expect(data.isCompleted(data.tasks.first), isTrue);
    expect(data.points, task.points);
    expect(data.completionHistory.length, 1);

    // If the parent takes the check away, the child sees it too.
    copy['lastCompletedAt'] = <String, dynamic>{};
    copy['points'] = 0;
    await data.applySyncedContent(copy);
    expect(data.isCompleted(data.tasks.first), isFalse);
    expect(data.points, 0);
  });

  test('an older copy without results keeps the local points', () async {
    final data = ChildAppState.instance;
    data.points = 12;
    await data.applySyncedContent({
      'tasks': data.linkData()['tasks'],
      'rewards': data.linkData()['rewards'],
    });
    expect(data.points, 12);
  });
}
