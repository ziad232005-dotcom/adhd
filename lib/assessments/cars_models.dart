/// One of the 15 areas a parent observes in the CARS questionnaire.
class CarsItem {
  const CarsItem(this.title, this.helper);

  final String title;
  final String helper;
}

/// A score the parent can choose for an area (1 to 4).
class CarsLevel {
  const CarsLevel(this.score, this.label, this.description);

  final int score;
  final String label;
  final String description;
}

/// How the total score is described. These are observation bands to
/// share with a clinician, not a diagnosis.
enum CarsBand {
  typical('No significant traits noticed',
      'Scores in this range suggest typical development.'),
  mildToModerate('Mild to moderate differences',
      'Some differences noted. Worth sharing with your clinician.'),
  severe('Many differences noticed',
      'Please connect with your care team soon.');

  const CarsBand(this.label, this.description);

  final String label;
  final String description;
}

class CarsQuestionnaire {
  const CarsQuestionnaire._();

  static const items = <CarsItem>[
    CarsItem('Relating to People', 'How does your child relate to people around them?'),
    CarsItem('Imitation', 'Does your child copy sounds, words, and movements?'),
    CarsItem('Emotional Response', 'Are emotional reactions appropriate to the situation?'),
    CarsItem('Body Use', 'Any unusual body movements, posture, or coordination?'),
    CarsItem('Object Use', 'How does your child play with toys and objects?'),
    CarsItem('Adaptation to Change', 'How does change in routine affect your child?'),
    CarsItem('Visual Response', 'How does your child look at things and people?'),
    CarsItem('Listening Response', 'How does your child respond to sounds and voices?'),
    CarsItem('Taste, Smell & Touch', 'Any unusual reactions to taste, smell, or touch?'),
    CarsItem('Fear or Nervousness', 'Are fears appropriate and proportionate?'),
    CarsItem('Verbal Communication', 'Language use, speech patterns, and understanding?'),
    CarsItem('Non-verbal Communication', 'Gestures, facial expressions, and body language?'),
    CarsItem('Activity Level', 'Is activity level too high, low, or just right?'),
    CarsItem('Intellectual Response', 'Consistency of thinking and learning across areas?'),
    CarsItem('General Impressions', 'Your overall sense of your child’s differences?'),
  ];

  static const levels = <CarsLevel>[
    CarsLevel(1, 'Within normal limits', 'Age-appropriate, no difficulties observed'),
    CarsLevel(2, 'Mildly different', 'Slight difficulties, occasional support needed'),
    CarsLevel(3, 'Moderately different', 'Noticeable differences, needs consistent support'),
    CarsLevel(4, 'Severely different', 'Marked differences, minimal relating in this area'),
  ];

  static int get itemCount => items.length;
  static int get maxScore => itemCount * 4;

  static int total(Iterable<int> scores) =>
      scores.fold(0, (sum, score) => sum + score);

  static CarsBand bandFor(int total) {
    if (total < 30) return CarsBand.typical;
    if (total < 37) return CarsBand.mildToModerate;
    return CarsBand.severe;
  }
}

/// A finished questionnaire for one child.
class CarsResult {
  CarsResult({
    required this.takenAt,
    required this.scores,
    this.note = '',
  });

  final DateTime takenAt;
  final List<int> scores;
  final String note;

  int get total => CarsQuestionnaire.total(scores);
  CarsBand get band => CarsQuestionnaire.bandFor(total);

  Map<String, dynamic> toJson() => {
        'takenAt': takenAt.toIso8601String(),
        'scores': scores,
        'note': note,
      };

  /// Returns null when the saved data is not a complete result.
  static CarsResult? fromJson(Map<String, dynamic> json) {
    final raw = json['scores'];
    final date = DateTime.tryParse(json['takenAt'] as String? ?? '');
    if (raw is! List || date == null) return null;

    final scores = raw.whereType<int>().toList();
    final valid = scores.length == CarsQuestionnaire.itemCount &&
        scores.every((s) => s >= 1 && s <= 4);
    if (!valid) return null;

    return CarsResult(
      takenAt: date,
      scores: scores,
      note: json['note'] as String? ?? '',
    );
  }
}
