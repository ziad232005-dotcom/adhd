import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/child.dart';
import 'package:adhd/parent/parent_insights.dart';
import 'package:adhd/parent/parent_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ParentStore', () {
    test('keeps a valid selected child when children are added and removed',
        () {
      final store = ParentStore.instance;
      store.children.clear();
      store.selectedChildIndex = 0;

      expect(store.selectedChild, isNull);

      store.addChild(name: 'Alex', age: 9, grade: 'Grade 4');
      store.addChild(name: 'Maya', age: 7, grade: 'Grade 2');
      expect(store.selectedChild?.name, 'Maya');

      store.deleteChild(store.children.last.id);
      expect(store.selectedChild?.name, 'Alex');

      store.deleteChild(store.children.first.id);
      expect(store.selectedChild, isNull);
    });

    test('sorts reminders by due time and toggles done', () {
      final store = ParentStore.instance;
      store.reminders.clear();

      final later = DateTime.now().add(const Duration(hours: 5));
      final sooner = DateTime.now().add(const Duration(hours: 1));

      store.addReminder(title: 'Later', dueAt: later);
      store.addReminder(title: 'Sooner', dueAt: sooner);

      expect(store.reminders.first.title, 'Sooner');

      store.toggleReminder(store.reminders.first.id);
      expect(store.reminders.first.done, isTrue);
    });
  });

  group('ParentInsights', () {
    test('starts empty and counts a completed task', () {
      final data = ChildAppState.instance;
      final insights = ParentInsights(data);

      expect(insights.thisWeekCompletions, 0);
      expect(insights.streakDays, 0);
      expect(insights.weekChangeLabel, '--');
      expect(insights.dailyCompletions.length, 7);

      expect(data.completeTask(data.tasks.first), isTrue);

      expect(insights.thisWeekCompletions, 1);
      expect(insights.streakDays, 1);
      expect(insights.dailyCompletions.last, 1);
      expect(insights.weekChangeLabel, 'New');
      expect(insights.achievements.first.title, 'First Step');
    });
  });
}
