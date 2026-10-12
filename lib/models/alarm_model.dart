class AlarmModel {
  final bool isEnabled;
  final int hour;
  final int minute;
  final String soundId;
  final int fadeInMinutes;
  final String label;
  final bool isRinging;

  const AlarmModel({
    this.isEnabled = false,
    this.hour = 6,
    this.minute = 30,
    this.soundId = 'rainfall',
    this.fadeInMinutes = 5,
    this.label = 'Gentle Nature Wake-up',
    this.isRinging = false,
  });

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String get soundTitleEn {
    switch (soundId) {
      case 'ocean':
        return 'Gentle Ocean Stream';
      case 'waterfall':
        return 'Soft Mountain Stream';
      case 'rainfall':
      default:
        return 'Morning Birds & Rain';
    }
  }

  String get soundTitleSi {
    switch (soundId) {
      case 'ocean':
        return 'මෘදු මුහුදු රළ නාදය';
      case 'waterfall':
        return 'දිය පහරක ශබ්දය';
      case 'rainfall':
      default:
        return 'කුරුළු නාද සහ වැස්ස';
    }
  }

  AlarmModel copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    String? soundId,
    int? fadeInMinutes,
    String? label,
    bool? isRinging,
  }) {
    return AlarmModel(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      soundId: soundId ?? this.soundId,
      fadeInMinutes: fadeInMinutes ?? this.fadeInMinutes,
      label: label ?? this.label,
      isRinging: isRinging ?? this.isRinging,
    );
  }

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'hour': hour,
        'minute': minute,
        'soundId': soundId,
        'fadeInMinutes': fadeInMinutes,
        'label': label,
      };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
        isEnabled: json['isEnabled'] as bool? ?? false,
        hour: json['hour'] as int? ?? 6,
        minute: json['minute'] as int? ?? 30,
        soundId: json['soundId'] as String? ?? 'rainfall',
        fadeInMinutes: json['fadeInMinutes'] as int? ?? 5,
        label: json['label'] as String? ?? 'Gentle Nature Wake-up',
      );
}
