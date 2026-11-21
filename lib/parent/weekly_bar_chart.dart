import 'package:flutter/material.dart';

import 'parent_insights.dart';
import 'parent_ui.dart';

/// Seven bars for the last 7 days. Today is highlighted.
class WeeklyBarChart extends StatelessWidget {
  final List<DateTime> days;
  final List<double> ratios;
  final List<int> counts;
  final double height;

  const WeeklyBarChart({
    super.key,
    required this.days,
    required this.ratios,
    required this.counts,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (index) {
          final isToday = index == days.length - 1;
          final ratio = ratios[index];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${counts[index]}',
                    style: const TextStyle(
                      color: ParentUi.dark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ParentUi.soft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: ratio == 0 ? 0.04 : ratio,
                        widthFactor: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? ParentUi.purple
                                : const Color(0xFFC9C1F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ParentInsights.weekdayLabels[days[index].weekday - 1],
                    style: const TextStyle(
                      color: ParentUi.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
