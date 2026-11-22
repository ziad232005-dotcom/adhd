import 'package:flutter/material.dart';

import 'child.dart' show ChildTask, childPrimary, childText;
import 'core/widgets/mazid_widgets.dart';

/// The task to do now and the one after it. Tasks that are done are skipped.
class NowNext {
  const NowNext({this.now, this.next});

  final ChildTask? now;
  final ChildTask? next;

  factory NowNext.of(
    List<ChildTask> tasks,
    bool Function(ChildTask task) isDone,
  ) {
    final waiting = tasks.where((task) => !isDone(task)).toList();
    return NowNext(
      now: waiting.firstOrNull,
      next: waiting.length > 1 ? waiting[1] : null,
    );
  }
}

/// One big task so a child with a long list is not overwhelmed, and the
/// name of the one after it.
class NowNextCard extends StatelessWidget {
  const NowNextCard({super.key, required this.plan, required this.onOpen});

  final NowNext plan;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final now = plan.now;
    final next = plan.next;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: childPrimary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  now == null ? 'All done' : 'Now',
                  style: const TextStyle(
                    color: childPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  now?.title ?? 'You finished every task. Great work!',
                  style: const TextStyle(
                    color: childText,
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (now != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${now.points} points',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onOpen,
                    style: FilledButton.styleFrom(
                      backgroundColor: childPrimary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Start'),
                  ),
                ],
                if (next != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Next: ${next.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          MazidMascot(
            asset: now == null
                ? MazidAssets.octopusCelebrate
                : MazidAssets.octopusIdea,
            size: 84,
          ),
        ],
      ),
    );
  }
}
