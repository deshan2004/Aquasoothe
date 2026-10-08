class CaregiverSettings {
  final bool isEnabled;
  final String caregiverName;
  final String inviteCode;
  final int cutoffHour; // e.g. 16 = 4:00 PM cutoff time if no water logged
  final int cutoffMinute;
  final DateTime? lastSyncedAt;

  CaregiverSettings({
    this.isEnabled = false,
    this.caregiverName = 'Family Member / Caregiver',
    this.inviteCode = 'AQUA-7892',
    this.cutoffHour = 16,
    this.cutoffMinute = 0,
    this.lastSyncedAt,
  });

  CaregiverSettings copyWith({
    bool? isEnabled,
    String? caregiverName,
    String? inviteCode,
    int? cutoffHour,
    int? cutoffMinute,
    DateTime? lastSyncedAt,
  }) {
    return CaregiverSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      caregiverName: caregiverName ?? this.caregiverName,
      inviteCode: inviteCode ?? this.inviteCode,
      cutoffHour: cutoffHour ?? this.cutoffHour,
      cutoffMinute: cutoffMinute ?? this.cutoffMinute,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'caregiverName': caregiverName,
        'inviteCode': inviteCode,
        'cutoffHour': cutoffHour,
        'cutoffMinute': cutoffMinute,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };

  factory CaregiverSettings.fromJson(Map<String, dynamic> json) => CaregiverSettings(
        isEnabled: json['isEnabled'] as bool? ?? false,
        caregiverName: json['caregiverName'] as String? ?? 'Family Member / Caregiver',
        inviteCode: json['inviteCode'] as String? ?? 'AQUA-7892',
        cutoffHour: json['cutoffHour'] as int? ?? 16,
        cutoffMinute: json['cutoffMinute'] as int? ?? 0,
        lastSyncedAt: json['lastSyncedAt'] != null
            ? DateTime.parse(json['lastSyncedAt'] as String)
            : null,
      );
}
