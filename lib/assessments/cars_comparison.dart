import 'cars_models.dart';

enum CarsTrend { first, improved, stable, worse }

/// One of the 15 areas, before and now.
class CarsAreaChange {
  const CarsAreaChange(this.title, this.before, this.after);

  final String title;
  final int before;
  final int after;

  /// Negative means better: lower scores mean fewer difficulties.
  int get change => after - before;
}

/// Compares a CARS result with the one before it. A lower score is
/// better, so a falling total means improvement.
class CarsComparison {
  CarsComparison._({
    required this.current,
    required this.previous,
    required this.trend,
    required this.areas,
  });

  /// Changes of up to this many points in the total count as "about the
  /// same", because answers vary a little from day to day.
  static const stableMargin = 2;

  final CarsResult current;
  final CarsResult? previous;
  final CarsTrend trend;
  final List<CarsAreaChange> areas;

  factory CarsComparison.compare(CarsResult current, CarsResult? previous) {
    if (previous == null) {
      return CarsComparison._(
        current: current,
        previous: null,
        trend: CarsTrend.first,
        areas: const [],
      );
    }

    final diff = current.total - previous.total;
    final trend = diff.abs() <= stableMargin
        ? CarsTrend.stable
        : diff < 0
            ? CarsTrend.improved
            : CarsTrend.worse;

    return CarsComparison._(
      current: current,
      previous: previous,
      trend: trend,
      areas: [
        for (var i = 0; i < CarsQuestionnaire.itemCount; i++)
          CarsAreaChange(
            CarsQuestionnaire.items[i].title,
            previous.scores[i],
            current.scores[i],
          ),
      ],
    );
  }

  /// Total now minus total before (negative is better). Zero for the
  /// first assessment.
  int get totalChange =>
      previous == null ? 0 : current.total - previous!.total;

  bool get bandChanged =>
      previous != null && previous!.band != current.band;

  List<CarsAreaChange> get improvedAreas =>
      areas.where((a) => a.change < 0).toList();

  List<CarsAreaChange> get worsenedAreas =>
      areas.where((a) => a.change > 0).toList();

  int get unchangedAreas => areas.where((a) => a.change == 0).length;

  String get headline => switch (trend) {
        CarsTrend.first => 'First assessment. Later ones will be compared '
            'with this one.',
        CarsTrend.improved => 'Improvement: the total went down by '
            '${-totalChange} points.',
        CarsTrend.stable => 'About the same as last time '
            '(${_signed(totalChange)} points).',
        CarsTrend.worse => 'Higher than last time: the total went up by '
            '$totalChange points.',
      };

  static String _signed(int value) => value > 0 ? '+$value' : '$value';

  /// "+2", "-1" or "0" for a number of points.
  static String signed(int value) => _signed(value);
}
