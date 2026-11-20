import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'cars_models.dart';
import 'cars_report_screen.dart';
import 'cars_screen.dart';
import 'cars_store.dart';

/// The assessments of one child. For now this is the CARS questionnaire,
/// which the parent answers. The TOVA attention test has its own page.
class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  @override
  void initState() {
    super.initState();
    carsStore.load(widget.child.id);
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static String _date(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Assessments'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: carsStore,
          builder: (context, _) {
            final history = carsStore.of(child.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Text(
                  'For ${child.name}',
                  style: const TextStyle(color: ParentUi.muted),
                ),
                const SizedBox(height: 14),
                _TestCard(
                  icon: Icons.fact_check_rounded,
                  title: 'CARS questionnaire',
                  subtitle: 'You answer 15 short observations about '
                      '${child.name}. About 8 minutes. Made to share with '
                      'your doctor.',
                  action: history.isEmpty ? 'Start' : 'Take again',
                  onTap: () => _open(CarsScreen(child: child)),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'CARS history (tap for PDF report)',
                    style: TextStyle(
                      color: ParentUi.dark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final result in history)
                    ParentCard(
                      onTap: () =>
                          _open(CarsReportScreen(child: child, result: result)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _date(result.takenAt),
                                  style: const TextStyle(
                                    color: ParentUi.dark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  result.band.label,
                                  style: const TextStyle(
                                    color: ParentUi.muted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${result.total}/${CarsQuestionnaire.maxScore}',
                            style: const TextStyle(
                              color: ParentUi.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'This questionnaire is not a diagnosis. Share the results with '
                  'a clinician.',
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
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
