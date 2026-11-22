import 'package:flutter/material.dart';

import 'child.dart' show ChildReward, childPrimary, childText;

/// The nearest reward the child has not reached yet, and how far away it is.
class NextGoal {
  const NextGoal({required this.reward, required this.pointsLeft});

  final ChildReward reward;
  final int pointsLeft;

  /// How much of the way the child has come, from 0 to 1.
  double progress(int points) =>
      (points / reward.targetPoints).clamp(0.0, 1.0).toDouble();

  /// Null when there are no rewards or all of them are reached.
  static NextGoal? of(
    List<ChildReward> rewards,
    int points,
    bool Function(ChildReward reward) isReached,
  ) {
    final waiting = rewards.where((reward) => !isReached(reward)).toList()
      ..sort((a, b) => a.targetPoints.compareTo(b.targetPoints));
    if (waiting.isEmpty) return null;

    final reward = waiting.first;
    return NextGoal(
      reward: reward,
      pointsLeft: (reward.targetPoints - points).clamp(0, reward.targetPoints),
    );
  }
}

/// "30 points left for your prize" with a bar, instead of a bare number.
class NextGoalCard extends StatelessWidget {
  const NextGoalCard({
    super.key,
    required this.goal,
    required this.points,
    required this.onOpen,
  });

  final NextGoal goal;
  final int points;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, color: childPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.reward.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: childText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${goal.pointsLeft} points left',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: goal.progress(points),
                minHeight: 10,
                color: childPrimary,
                backgroundColor: const Color(0xFFEDEAFB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
