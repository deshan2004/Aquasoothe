class HydrationLog {
  final String id;
  final DateTime timestamp;
  final int amountMl;
  final String unit; // 'ml' or 'cups'

  HydrationLog({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.unit = 'ml',
  });

  int get amountCups => (amountMl / 250).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
        'unit': unit,
      };

  factory HydrationLog.fromJson(Map<String, dynamic> json) {
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

    return HydrationLog(
      id: (json['id'] ?? '') as String,
      timestamp: parseDate(json['timestamp']),
      amountMl: json['amountMl'] as int? ?? 250,
      unit: json['unit'] as String? ?? 'ml',
    );
  }
}

class HydrationGoal {
  final int dailyTargetMl;
  final String preferredUnit; // 'ml' or 'cups'
  final int wakeHour;
  final int wakeMinute;
  final int sleepHour;
  final int sleepMinute;
  final double intervalHours; // 1.0, 1.5, 2.0, 3.0
  final bool isReminderEnabled;
  final int windDownAdvanceMinutes; // 15, 30, 45, 60
  final bool isBedtimeReminderEnabled;

  HydrationGoal({
    this.dailyTargetMl = 2000,
    this.preferredUnit = 'ml',
    this.wakeHour = 7,
    this.wakeMinute = 0,
    this.sleepHour = 22,
    this.sleepMinute = 0,
    this.intervalHours = 2.0,
    this.isReminderEnabled = true,
    this.windDownAdvanceMinutes = 30,
    this.isBedtimeReminderEnabled = true,
  });

  int get dailyTargetCups => (dailyTargetMl / 250).round();

  HydrationGoal copyWith({
    int? dailyTargetMl,
    String? preferredUnit,
    int? wakeHour,
    int? wakeMinute,
    int? sleepHour,
    int? sleepMinute,
    double? intervalHours,
    bool? isReminderEnabled,
    int? windDownAdvanceMinutes,
    bool? isBedtimeReminderEnabled,
  }) {
    return HydrationGoal(
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      wakeHour: wakeHour ?? this.wakeHour,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      sleepHour: sleepHour ?? this.sleepHour,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      intervalHours: intervalHours ?? this.intervalHours,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      windDownAdvanceMinutes: windDownAdvanceMinutes ?? this.windDownAdvanceMinutes,
      isBedtimeReminderEnabled: isBedtimeReminderEnabled ?? this.isBedtimeReminderEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyTargetMl': dailyTargetMl,
        'preferredUnit': preferredUnit,
        'wakeHour': wakeHour,
        'wakeMinute': wakeMinute,
        'sleepHour': sleepHour,
        'sleepMinute': sleepMinute,
        'intervalHours': intervalHours,
        'isReminderEnabled': isReminderEnabled,
        'windDownAdvanceMinutes': windDownAdvanceMinutes,
        'isBedtimeReminderEnabled': isBedtimeReminderEnabled,
      };

  factory HydrationGoal.fromJson(Map<String, dynamic> json) => HydrationGoal(
        dailyTargetMl: json['dailyTargetMl'] as int? ?? 2000,
        preferredUnit: json['preferredUnit'] as String? ?? 'ml',
        wakeHour: json['wakeHour'] as int? ?? 7,
        wakeMinute: json['wakeMinute'] as int? ?? 0,
        sleepHour: json['sleepHour'] as int? ?? 22,
        sleepMinute: json['sleepMinute'] as int? ?? 0,
        intervalHours: (json['intervalHours'] as num?)?.toDouble() ?? 2.0,
        isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
        windDownAdvanceMinutes: json['windDownAdvanceMinutes'] as int? ?? 30,
        isBedtimeReminderEnabled: json['isBedtimeReminderEnabled'] as bool? ?? true,
      );
}
