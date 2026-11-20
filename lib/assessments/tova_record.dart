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
    this.sdRtMs,
    this.correctRejections = 0,
    this.omissionPct = 0,
    this.commissionPct = 0,
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
  final double? sdRtMs;
  final int correctRejections;
  final double omissionPct;
  final double commissionPct;

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
        'sdRtMs': sdRtMs,
        'correctRejections': correctRejections,
        'omissionPct': omissionPct,
        'commissionPct': commissionPct,
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
      sdRtMs: (json['sdRtMs'] as num?)?.toDouble(),
      correctRejections: json['correctRejections'] as int? ?? 0,
      omissionPct: (json['omissionPct'] as num?)?.toDouble() ?? 0,
      commissionPct: (json['commissionPct'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Saved TOVA activities, per child.
final tovaStore = ChildRecords<TovaRecord>(
  keyPrefix: 'mazid_tova_child_',
  fromJson: TovaRecord.fromJson,
  toJson: (record) => record.toJson(),
);
