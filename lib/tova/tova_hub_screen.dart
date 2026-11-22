import 'package:flutter/material.dart';

import '../assessments/tova_record.dart';
import '../assessments/tova_report_screen.dart';
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'tova_screens.dart';

/// The TOVA attention test of one child, apart from the assessments.
/// The child can also start it from their own screen. Every finished run is
/// saved here with a PDF report that compares it with the one before.
class TovaHubScreen extends StatefulWidget {
  const TovaHubScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<TovaHubScreen> createState() => _TovaHubScreenState();
}

class _TovaHubScreenState extends State<TovaHubScreen> {
  @override
  void initState() {
    super.initState();
    tovaStore.load(widget.child.id);
  }

  static String _date(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'TOVA attention test'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: tovaStore,
          builder: (context, _) {
            final history = tovaStore.of(child.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Text(
                  'For ${child.name}',
                  style: const TextStyle(color: ParentUi.muted),
                ),
                const SizedBox(height: 14),
                ParentCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${child.name} does this one on the screen, with you '
                        'next to them. It needs a quiet place.',
                        style: const TextStyle(
                          color: ParentUi.muted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () =>
                            _open(TovaWelcomeScreen(childId: child.id)),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: ParentUi.purple,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(history.isEmpty ? 'Start' : 'Start again'),
                      ),
                    ],
                  ),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Reports (tap for the PDF)',
                    style: TextStyle(
                      color: ParentUi.dark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final record in history)
                    ParentCard(
                      onTap: () => _open(
                        TovaReportScreen(
                          childName: child.name,
                          childAge: child.age,
                          record: record,
                          history: history,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _date(record.takenAt),
                                  style: const TextStyle(
                                    color: ParentUi.dark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${record.modeTitle} • ${record.trials} trials',
                                  style: const TextStyle(
                                    color: ParentUi.muted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${record.accuracyPct.round()}%',
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
                  'This test is not a diagnosis. Share the results with '
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
