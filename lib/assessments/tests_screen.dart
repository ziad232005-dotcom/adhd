import 'package:flutter/material.dart';

import '../care/medications_screen.dart' show formatDate;
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import '../tova/tova_hub_screen.dart';
import 'cars_models.dart';
import 'cars_screen.dart';
import 'cars_store.dart';
import 'tova_record.dart';

/// The "Tests" tab: every test of the selected child in one place. The
/// same two tests are also on the child's own page.
class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final _store = ParentStore.instance;
  int? _loadedFor;

  void _loadFor(ParentChild child) {
    if (_loadedFor == child.id) return;
    _loadedFor = child.id;
    carsStore.load(child.id);
    tovaStore.load(child.id);
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Tests', showBack: false),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_store, carsStore, tovaStore]),
          builder: (context, _) {
            final child = _store.selectedChild;

            if (child == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'Add a child first. Then you can take the tests here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ParentUi.muted),
                  ),
                ),
              );
            }
            _loadFor(child);

            final cars = carsStore.latest(child.id);
            final tova = tovaStore.latest(child.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                if (_store.children.length > 1) ...[
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < _store.children.length; i++)
                        ChoiceChip(
                          label: Text(_store.children[i].name),
                          selected: _store.selectedChildIndex == i,
                          onSelected: (_) => _store.selectChild(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'For ${child.name}',
                      style: const TextStyle(color: ParentUi.muted),
                    ),
                  ),
                _TestCard(
                  icon: Icons.fact_check_rounded,
                  title: 'CARS questionnaire',
                  subtitle: 'You answer 15 short observations. About 8 '
                      'minutes. Made to share with your doctor.',
                  last: cars == null
                      ? 'Not taken yet'
                      : 'Last: ${formatDate(cars.takenAt)}, '
                          '${cars.total}/${CarsQuestionnaire.maxScore}',
                  action: cars == null ? 'Start' : 'Take again',
                  onTap: () => _open(CarsScreen(child: child)),
                ),
                _TestCard(
                  icon: Icons.center_focus_strong_rounded,
                  title: 'TOVA attention test',
                  subtitle: 'A short game your child plays. It shows how '
                      'steady their attention was.',
                  last: tova == null
                      ? 'Not done yet'
                      : 'Last: ${formatDate(tova.takenAt)}, '
                          '${tova.accuracyPct.round()}% accuracy',
                  action: 'Open',
                  onTap: () => _open(TovaHubScreen(child: child)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'These tests are not a diagnosis. Share the results with a '
                  'clinician. Every report is saved in the Reports folder.',
                  style: TextStyle(color: ParentUi.muted, fontSize: 12.5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.last,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String last;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ParentCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: ParentUi.soft,
                  child: Icon(icon, color: ParentUi.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ParentUi.dark,
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(color: ParentUi.muted, height: 1.45),
            ),
            const SizedBox(height: 6),
            Text(
              last,
              style: const TextStyle(
                color: ParentUi.purple,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: ParentUi.purple,
                shape: const StadiumBorder(),
              ),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
