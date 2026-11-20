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
        () async {
      final store = ParentStore.instance;
      store.children.clear();
      store.selectedChildIndex = 0;

      expect(store.selectedChild, isNull);

      store.addChild(name: 'Alex', birthDate: DateTime(2017, 3, 12), grade: 'Grade 4');
      store.addChild(name: 'Maya', birthDate: DateTime(2019, 6, 20), grade: 'Grade 2');
      expect(store.selectedChild?.name, 'Maya');

      store.deleteChild(store.children.last.id);
      expect(store.selectedChild?.name, 'Alex');

      store.deleteChild(store.children.first.id);
      expect(store.selectedChild, isNull);

      // Let the child-data switches finish before the next test.
      await ChildAppState.instance.switchChild(null);
    });

    test('each child keeps separate tasks and points', () async {
      final store = ParentStore.instance;
      final data = ChildAppState.instance;
      store.children.clear();
      store.selectedChildIndex = 0;

      store.addChild(name: 'Alex', birthDate: DateTime(2017, 3, 12), grade: 'Grade 4');
      await data.switchChild(store.selectedChild!.id);
      data.completeTask(data.tasks.first);
      final alexPoints = data.points;
      expect(alexPoints, greaterThan(0));

      store.addChild(name: 'Maya', birthDate: DateTime(2019, 6, 20), grade: 'Grade 2');
      await data.switchChild(store.selectedChild!.id);
      expect(data.points, 0);
      expect(data.completionHistory, isEmpty);

      store.selectChild(0);
      await data.switchChild(store.selectedChild!.id);
      expect(data.points, alexPoints);

      store.deleteChild(store.children.last.id);
      store.deleteChild(store.children.first.id);
      await data.switchChild(null);
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

  group('ParentChild', () {
    test('calculates the age from the date of birth', () {
      final birth = DateTime(2016, 5, 10);

      expect(ParentChild.ageOn(birth, DateTime(2026, 5, 9)), 9);
      expect(ParentChild.ageOn(birth, DateTime(2026, 5, 10)), 10);
      expect(ParentChild.ageOn(birth, DateTime(2026, 12, 31)), 10);
    });

    test('keeps the saved age until a date of birth is added', () {
      const legacy = ParentChild(
        id: 1,
        name: 'Alex',
        savedAge: 8,
        grade: 'Grade 3',
        pin: '1234',
      );

      expect(legacy.age, 8);
      expect(legacy.copyWith(birthDate: DateTime(2000, 1, 1)).age,
          greaterThan(20));
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
