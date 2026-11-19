import 'child_records.dart';

/// The summary of one finished TOVA-style activity for a child.
class TovaRecord {
  TovaRecord({
    required this.takenAt,
    required this.modeTitle,
    required this.trials,
    required this.completed,
    required this.hits,
    required this.omissions,
    required this.commissions,
    required this.anticipatory,
    required this.accuracyPct,
    this.meanRtMs,
  });

  final DateTime takenAt;
  final String modeTitle;
  final int trials;
  final bool completed;
  final int hits;
  final int omissions;
  final int commissions;
  final int anticipatory;
  final double accuracyPct;
  final double? meanRtMs;

  Map<String, dynamic> toJson() => {
        'takenAt': takenAt.toIso8601String(),
        'modeTitle': modeTitle,
        'trials': trials,
        'completed': completed,
        'hits': hits,
        'omissions': omissions,
        'commissions': commissions,
        'anticipatory': anticipatory,
        'accuracyPct': accuracyPct,
        'meanRtMs': meanRtMs,
      };

  static TovaRecord? fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['takenAt'] as String? ?? '');
    if (date == null) return null;

    return TovaRecord(
      takenAt: date,
      modeTitle: json['modeTitle'] as String? ?? '',
      trials: json['trials'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      hits: json['hits'] as int? ?? 0,
      omissions: json['omissions'] as int? ?? 0,
      commissions: json['commissions'] as int? ?? 0,
      anticipatory: json['anticipatory'] as int? ?? 0,
      accuracyPct: (json['accuracyPct'] as num?)?.toDouble() ?? 0,
      meanRtMs: (json['meanRtMs'] as num?)?.toDouble(),
    );
  }
}

/// Saved TOVA activities, per child.
final tovaStore = ChildRecords<TovaRecord>(
  keyPrefix: 'mazid_tova_child_',
  fromJson: TovaRecord.fromJson,
  toJson: (record) => record.toJson(),
);
