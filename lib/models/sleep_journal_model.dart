enum SleepRating {
  restful('Restful', '😴', 'Felt well rested & refreshed'),
  moderate('Moderate', '🙂', 'Slept adequately'),
  restless('Restless', '🥱', 'Woke up multiple times');

  final String label;
  final String emoji;
  final String description;

  const SleepRating(this.label, this.emoji, this.description);
}

class SleepLog {
  final String id;
  final DateTime date;
  final SleepRating rating;
  final int previousDayWaterMl;
  final String? notes;

  SleepLog({
    required this.id,
    required this.date,
    required this.rating,
    required this.previousDayWaterMl,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'rating': rating.name,
        'previousDayWaterMl': previousDayWaterMl,
        'notes': notes,
      };

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return SleepLog(
      id: (json['id'] ?? '') as String,
      date: parseDate(json['date']),
      rating: SleepRating.values.firstWhere(
        (e) => e.name == json['rating'],
        orElse: () => SleepRating.moderate,
      ),
      previousDayWaterMl: json['previousDayWaterMl'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }
}
