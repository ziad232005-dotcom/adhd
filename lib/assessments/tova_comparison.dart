import 'tova_record.dart';

enum TovaTrend { first, improved, mixed, stable, worse }

/// One measure, before and now.
class TovaMeasure {
  const TovaMeasure({
    required this.label,
    required this.unit,
    required this.now,
    required this.before,
    required this.higherIsBetter,
    required this.tolerance,
  });

  final String label;
  final String unit;
  final double? now;
  final double? before;
  final bool higherIsBetter;

  /// Smaller changes count as "about the same".
  final double tolerance;

  double? get change => (now == null || before == null) ? null : now! - before!;

  /// 1 better, 0 about the same, -1 worse, null when it cannot be told.
  int? get verdict {
    final c = change;
    if (c == null) return null;
    if (c.abs() <= tolerance) return 0;
    return (c > 0) == higherIsBetter ? 1 : -1;
  }
}

/// Compares a TOVA activity with the previous one of the same kind.
class TovaComparison {
  TovaComparison._(this.previous, this.measures, this.trend);

  final TovaRecord? previous;
  final List<TovaMeasure> measures;
  final TovaTrend trend;

  /// [history] is every saved record of the child, newest first. The
  /// previous record is the next older one with the same activity.
  factory TovaComparison.compare(
    TovaRecord current,
    List<TovaRecord> history,
  ) {
    final index = history.indexWhere((r) => r.takenAt == current.takenAt);
    TovaRecord? previous;
    if (index != -1) {
      for (var i = index + 1; i < history.length; i++) {
        if (history[i].modeTitle == current.modeTitle) {
          previous = history[i];
          break;
        }
      }
    }

    TovaMeasure measure(
      String label,
      String unit,
      double? now,
      double? Function(TovaRecord) pick, {
      required bool higherIsBetter,
      required double tolerance,
    }) =>
        TovaMeasure(
          label: label,
          unit: unit,
          now: now,
          before: previous == null ? null : pick(previous),
          higherIsBetter: higherIsBetter,
          tolerance: tolerance,
        );

    final measures = [
      measure('Accuracy', '%', current.accuracyPct, (r) => r.accuracyPct,
          higherIsBetter: true, tolerance: 2),
      measure('Missed targets', '%', current.omissionPct, (r) => r.omissionPct,
          higherIsBetter: false, tolerance: 2),
      measure('Wrong presses', '%', current.commissionPct,
          (r) => r.commissionPct,
          higherIsBetter: false, tolerance: 2),
      measure('Early presses', '', current.anticipatory.toDouble(),
          (r) => r.anticipatory.toDouble(),
          higherIsBetter: false, tolerance: 1),
      measure('Mean response time', 'ms', current.meanRtMs, (r) => r.meanRtMs,
          higherIsBetter: false, tolerance: 30),
    ];

    if (previous == null) {
      return TovaComparison._(null, measures, TovaTrend.first);
    }

    final better = measures.where((m) => m.verdict == 1).length;
    final worse = measures.where((m) => m.verdict == -1).length;
    final trend = better > 0 && worse > 0
        ? TovaTrend.mixed
        : better > 0
            ? TovaTrend.improved
            : worse > 0
                ? TovaTrend.worse
                : TovaTrend.stable;

    return TovaComparison._(previous, measures, trend);
  }

  String get headline => switch (trend) {
        TovaTrend.first => 'This is the first saved result for this test.',
        TovaTrend.improved => 'Better than last time.',
        TovaTrend.mixed => 'Some measures are better and some are worse.',
        TovaTrend.stable => 'About the same as last time.',
        TovaTrend.worse => 'Harder than last time.',
      };
}
