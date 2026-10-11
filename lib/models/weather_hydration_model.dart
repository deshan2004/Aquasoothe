enum HeatRiskLevel {
  normal,
  moderate,
  high,
  severe,
}

class WeatherHydrationModel {
  final double temperatureCelsius;
  final int humidityPercent;
  final String locationName;
  final bool isSmartAdjustmentEnabled;
  final int baseGoalMl;

  const WeatherHydrationModel({
    this.temperatureCelsius = 32.5,
    this.humidityPercent = 75,
    this.locationName = 'Colombo, Sri Lanka',
    this.isSmartAdjustmentEnabled = true,
    this.baseGoalMl = 2000,
  });

  /// Calculate dynamic extra water required to prevent senior dehydration
  int get calculatedBonusMl {
    if (temperatureCelsius < 27.0) {
      return 0;
    } else if (temperatureCelsius < 31.0) {
      return 250;
    } else if (temperatureCelsius < 35.0) {
      return 500;
    } else {
      return 750;
    }
  }

  /// Total target goal taking weather into account
  int get effectiveGoalMl {
    if (!isSmartAdjustmentEnabled) return baseGoalMl;
    return baseGoalMl + calculatedBonusMl;
  }

  HeatRiskLevel get riskLevel {
    if (temperatureCelsius < 27.0) return HeatRiskLevel.normal;
    if (temperatureCelsius < 31.0) return HeatRiskLevel.moderate;
    if (temperatureCelsius < 35.0) return HeatRiskLevel.high;
    return HeatRiskLevel.severe;
  }

  /// User friendly Sinhala weather summary
  String get summarySi {
    if (temperatureCelsius < 27.0) {
      return 'සෞම්‍ය කාලගුණය (සාමාන්‍ය ජල අවශ්‍යතාව)';
    } else if (temperatureCelsius < 31.0) {
      return 'මද උණුසුම් කාලගුණය (+250ml එකතු විය)';
    } else if (temperatureCelsius < 35.0) {
      return 'අධික රස්නය - විජලන අවදානම (+500ml එකතු විය)';
    } else {
      return 'උග්‍ර තාප තත්ත්වය - අනිවාර්යයෙන් ජලය පානය කරන්න (+750ml)';
    }
  }

  /// User friendly English weather summary
  String get summaryEn {
    if (temperatureCelsius < 27.0) {
      return 'Mild Climate (Standard Hydration Goal)';
    } else if (temperatureCelsius < 31.0) {
      return 'Warm Weather (+250ml Heat Adjustment)';
    } else if (temperatureCelsius < 35.0) {
      return 'Hot Day - Dehydration Risk (+500ml Added)';
    } else {
      return 'Severe Heatwave - Hydrate Urgently (+750ml Added)';
    }
  }

  /// Sinhala senior alert text
  String get seniorAdviceSi {
    switch (riskLevel) {
      case HeatRiskLevel.normal:
        return 'සාමාන්‍ය සුවපහසු කාලගුණයකි. නියමිත පරිදි දිනපතා ජලය පානය කරන්න.';
      case HeatRiskLevel.moderate:
        return 'උණුසුම මදක් වැඩි බැවින් වැඩිහිටියන් නිතර කුඩා වතුර උගුරු කිහිපයක් පානය කිරීම සුදුසුය.';
      case HeatRiskLevel.high:
        return 'අවවාදයයි: වැඩිහිටියන්ට විජලනය (Dehydration) සහ කරකැවිල්ල ඇතිවීමේ අවදානම ඉහළයි. පැයකට වරක් වතුර වීදුරුවක් පානය කරන්න.';
      case HeatRiskLevel.severe:
        return 'හදිසි අවවාදයයි: අධික උණුසුම! සෙවණේ සිටින්න, නොකඩවා ජලය පානය කර විජලනයෙන් ආරක්ෂා වන්න.';
    }
  }

  /// English senior alert text
  String get seniorAdviceEn {
    switch (riskLevel) {
      case HeatRiskLevel.normal:
        return 'Comfortable weather. Continue your standard daily hydration routine.';
      case HeatRiskLevel.moderate:
        return 'Warm temperature. Seniors should sip water regularly throughout the day.';
      case HeatRiskLevel.high:
        return 'Senior Alert: High temperature increases dehydration and dizziness risk. Drink a glass of water every hour.';
      case HeatRiskLevel.severe:
        return 'Heat Warning: Extreme heat! Stay in the shade and drink plenty of water to avoid heat exhaustion.';
    }
  }

  WeatherHydrationModel copyWith({
    double? temperatureCelsius,
    int? humidityPercent,
    String? locationName,
    bool? isSmartAdjustmentEnabled,
    int? baseGoalMl,
  }) {
    return WeatherHydrationModel(
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      locationName: locationName ?? this.locationName,
      isSmartAdjustmentEnabled: isSmartAdjustmentEnabled ?? this.isSmartAdjustmentEnabled,
      baseGoalMl: baseGoalMl ?? this.baseGoalMl,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperatureCelsius': temperatureCelsius,
        'humidityPercent': humidityPercent,
        'locationName': locationName,
        'isSmartAdjustmentEnabled': isSmartAdjustmentEnabled,
        'baseGoalMl': baseGoalMl,
      };

  factory WeatherHydrationModel.fromJson(Map<String, dynamic> json) => WeatherHydrationModel(
        temperatureCelsius: (json['temperatureCelsius'] as num?)?.toDouble() ?? 32.5,
        humidityPercent: json['humidityPercent'] as int? ?? 75,
        locationName: json['locationName'] as String? ?? 'Colombo, Sri Lanka',
        isSmartAdjustmentEnabled: json['isSmartAdjustmentEnabled'] as bool? ?? true,
        baseGoalMl: json['baseGoalMl'] as int? ?? 2000,
      );
}
