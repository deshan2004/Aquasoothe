enum MedicationPeriod {
  morning,
  afternoon,
  night,
}

class MedicationItem {
  final String id;
  final String name;
  final String nameSi;
  final String dosage;
  final String time;
  final MedicationPeriod period;
  final int waterMl;
  final bool isTakenToday;
  final DateTime? lastTakenDate;

  const MedicationItem({
    required this.id,
    required this.name,
    required this.nameSi,
    required this.dosage,
    required this.time,
    required this.period,
    this.waterMl = 250,
    this.isTakenToday = false,
    this.lastTakenDate,
  });

  String get nameEn => name;
  String get scheduledTime => time;

  MedicationItem copyWith({
    String? id,
    String? name,
    String? nameSi,
    String? dosage,
    String? time,
    MedicationPeriod? period,
    int? waterMl,
    bool? isTakenToday,
    DateTime? lastTakenDate,
  }) {
    return MedicationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameSi: nameSi ?? this.nameSi,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      period: period ?? this.period,
      waterMl: waterMl ?? this.waterMl,
      isTakenToday: isTakenToday ?? this.isTakenToday,
      lastTakenDate: lastTakenDate ?? this.lastTakenDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameSi': nameSi,
      'dosage': dosage,
      'time': time,
      'period': period.name,
      'waterMl': waterMl,
      'isTakenToday': isTakenToday,
      'lastTakenDate': lastTakenDate?.toIso8601String(),
    };
  }

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nameSi: json['nameSi'] as String? ?? json['name'] as String,
      dosage: json['dosage'] as String? ?? '1 Pill',
      time: json['time'] as String? ?? '08:00 AM',
      period: MedicationPeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => MedicationPeriod.morning,
      ),
      waterMl: json['waterMl'] as int? ?? 250,
      isTakenToday: json['isTakenToday'] as bool? ?? false,
      lastTakenDate: json['lastTakenDate'] != null
          ? DateTime.tryParse(json['lastTakenDate'] as String)
          : null,
    );
  }

  static List<MedicationItem> defaultSeniorMedications() {
    return [
      const MedicationItem(
        id: 'med_bp',
        name: 'Blood Pressure Tablet',
        nameSi: 'රුධිර පීඩන පෙත්ත',
        dosage: '1 Tablet (5mg)',
        time: '08:00 AM',
        period: MedicationPeriod.morning,
        waterMl: 250,
      ),
      const MedicationItem(
        id: 'med_vit',
        name: 'Multivitamin & Calcium',
        nameSi: 'මල්ටිවිටමින් සහ කැල්සියම්',
        dosage: '1 Capsule',
        time: '01:00 PM',
        period: MedicationPeriod.afternoon,
        waterMl: 250,
      ),
      const MedicationItem(
        id: 'med_joint',
        name: 'Joint Care / Sleep Supplement',
        nameSi: 'සුව නින්ද සහ සන්ධි පෙත්ත',
        dosage: '1 Tablet',
        time: '08:30 PM',
        period: MedicationPeriod.night,
        waterMl: 250,
      ),
    ];
  }
}
