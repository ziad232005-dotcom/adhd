import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'care_models.dart';
import 'care_stores.dart';
import 'medications_screen.dart';

/// Sleep and meals, one entry per day. Today is edited at the top, the
/// last days are listed below.
class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  static const _sleepChoices = [4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0];

  int get _id => widget.child.id;

  @override
  void initState() {
    super.initState();
    dailyLogStore.load(_id);
  }

  DailyLog _today() {
    final today = DailyLog.dayOf(DateTime.now());
    for (final log in dailyLogStore.of(_id)) {
      if (log.sameDay(today)) return log;
    }
    return DailyLog(day: today);
  }

  Future<void> _save(DailyLog log) => dailyLogStore.put(
        _id,
        log,
        same: (existing) => existing.sameDay(log.day),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Sleep & meals'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: dailyLogStore,
          builder: (context, _) {
            final today = _today();
            final past = dailyLogStore
                .of(_id)
                .where((l) => !l.sameDay(today.day))
                .take(14)
                .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                ParentCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today • ${formatDate(today.day)}',
                        style: const TextStyle(
                          color: ParentUi.dark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hours slept last night',
                        style: TextStyle(color: ParentUi.muted, fontSize: 12.5),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final hours in _sleepChoices)
                            ChoiceChip(
                              label: Text('${hours.round()}h'),
                              selected: today.sleepHours == hours,
                              onSelected: (_) => _save(
                                DailyLog(
                                  day: today.day,
                                  sleepHours: hours,
                                  meals: today.meals,
                                  note: today.note,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Meals eaten well',
                        style: TextStyle(color: ParentUi.muted, fontSize: 12.5),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final meal in DailyLog.mealNames)
                            FilterChip(
                              label: Text(meal),
                              selected: today.meals.contains(meal),
                              onSelected: (on) {
                                final meals = {...today.meals};
                                on ? meals.add(meal) : meals.remove(meal);
                                _save(
                                  DailyLog(
                                    day: today.day,
                                    sleepHours: today.sleepHours,
                                    meals: meals,
                                    note: today.note,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (past.isNotEmpty)
                  const Text(
                    'Previous days',
                    style: TextStyle(
                      color: ParentUi.dark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                for (final log in past)
                  ParentCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatDate(log.day),
                            style: const TextStyle(
                              color: ParentUi.dark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${log.sleepHours == null ? '—' : '${log.sleepHours!.round()}h'} sleep • '
                          '${log.meals.length}/3 meals',
                          style: const TextStyle(color: ParentUi.muted),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
