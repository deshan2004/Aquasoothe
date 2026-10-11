import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_hydration_model.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_hydration_provider.dart';
import 'glass_card.dart';
import 'scale_button.dart';

/// Global helper to show the Smart Weather-based Hydration Modal Sheet
void showWeatherHydrationModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const WeatherHydrationSheet(),
  );
}

class WeatherHydrationSheet extends ConsumerWidget {
  const WeatherHydrationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherHydrationProvider);
    final weatherNotifier = ref.read(weatherHydrationProvider.notifier);

    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
    final coral = const Color(0xFFFFAE85);
    final heatOrange = const Color(0xFFFF7E47);

    Color getRiskColor(HeatRiskLevel level) {
      switch (level) {
        case HeatRiskLevel.normal:
          return const Color(0xFF5ED1C7);
        case HeatRiskLevel.moderate:
          return const Color(0xFFFFB866);
        case HeatRiskLevel.high:
          return const Color(0xFFFF7E47);
        case HeatRiskLevel.severe:
          return const Color(0xFFFF4848);
      }
    }

    final riskColor = getRiskColor(weatherState.riskLevel);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF13272C).withValues(alpha: 0.92),
                      const Color(0xFF0C1F23).withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.90),
                      const Color(0xFFE8F6F4).withValues(alpha: 0.92),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.4 : 0.16),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: riskColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: riskColor.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.thermostat_rounded,
                        color: riskColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'කාලගුණය අනුව වතුර ඉලක්කය' : 'Smart Weather Hydration',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFE3F5F3) : primaryTeal,
                            ),
                          ),
                          Text(
                            isSi ? 'උෂ්ණත්වය මත විජලනය වැළැක්වීම' : 'Dynamic heat-adjusted hydration',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ScaleButton(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Weather & Dynamic Goal Hero Glass Card
                GlassCard(
                  borderRadius: 24,
                  blur: 20,
                  padding: const EdgeInsets.all(20),
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 15,
                                    color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    weatherState.locationName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weatherState.temperatureCelsius.toStringAsFixed(1)}°',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 44,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : primaryTeal,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'C',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: riskColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSi ? 'ආර්ද්‍රතාව: ${weatherState.humidityPercent}%' : 'Humidity: ${weatherState.humidityPercent}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          // Dynamic Goal Result Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  riskColor.withValues(alpha: 0.18),
                                  riskColor.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: riskColor.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isSi ? 'අද ඉලක්කය' : 'Adjusted Goal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${weatherState.effectiveGoalMl} ml',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : primaryTeal,
                                  ),
                                ),
                                if (weatherState.isSmartAdjustmentEnabled && weatherState.calculatedBonusMl > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: riskColor.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '+${weatherState.calculatedBonusMl}ml ${isSi ? "රස්නය නිසා" : "Heat Bonus"}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: riskColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Status summary pill
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: riskColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isSi ? weatherState.summarySi : weatherState.summaryEn,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFE3F5F3) : primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Senior Health Advice & Dehydration Alert Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.35),
                        width: 1.3,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: riskColor.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            weatherState.riskLevel == HeatRiskLevel.normal
                                ? Icons.favorite_rounded
                                : Icons.warning_amber_rounded,
                            color: riskColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'වැඩිහිටි සුවතා උපදෙස්' : 'Senior Health Notice',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSi ? weatherState.seniorAdviceSi : weatherState.seniorAdviceEn,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFFD0E6E4) : const Color(0xFF335557),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Smart Auto Adjustment Switch
                GlassCard(
                  borderRadius: 20,
                  blur: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: coral.withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFAE85), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSi ? 'ස්වයංක්‍රීය කාලගුණ වෙනස් කිරීම' : 'Smart Weather Auto-Adjust',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : primaryTeal,
                              ),
                            ),
                            Text(
                              isSi ? 'රස්නය අනුව ඉලක්කය ස්වයංක්‍රීයව වැඩි කරන්න' : 'Automatically adapts goal on warmer days',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: weatherState.isSmartAdjustmentEnabled,
                        activeTrackColor: heatOrange.withValues(alpha: 0.45),
                        onChanged: (val) {
                          weatherNotifier.toggleSmartAdjustment(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sri Lankan Climate Presets for Elderly One-Touch Selection
                Text(
                  isSi ? 'ප්‍රදේශයේ කාලගුණය තෝරන්න' : 'Select Local Climate Preset',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryTeal,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _PresetButton(
                      title: isSi ? 'නුවරඑළිය' : 'Nuwara Eliya',
                      temp: '22°C',
                      icon: Icons.ac_unit_rounded,
                      isActive: weatherState.temperatureCelsius <= 24,
                      onTap: () {
                        weatherNotifier.setPresetLocation(
                          locationName: isSi ? 'නුවරඑළිය, ශ්‍රී ලංකාව' : 'Nuwara Eliya, Sri Lanka',
                          temp: 22.0,
                          humidity: 85,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      title: isSi ? 'කොළඹ' : 'Colombo',
                      temp: '30°C',
                      icon: Icons.wb_cloudy_rounded,
                      isActive: weatherState.temperatureCelsius > 24 && weatherState.temperatureCelsius <= 31,
                      onTap: () {
                        weatherNotifier.setPresetLocation(
                          locationName: isSi ? 'කොළඹ, ශ්‍රී ලංකාව' : 'Colombo, Sri Lanka',
                          temp: 30.0,
                          humidity: 78,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      title: isSi ? 'අනුරාධපුරය' : 'Anuradhapura',
                      temp: '34°C',
                      icon: Icons.wb_sunny_rounded,
                      isActive: weatherState.temperatureCelsius > 31 && weatherState.temperatureCelsius <= 35,
                      onTap: () {
                        weatherNotifier.setPresetLocation(
                          locationName: isSi ? 'අනුරාධපුරය, ශ්‍රී ලංකාව' : 'Anuradhapura, Sri Lanka',
                          temp: 34.0,
                          humidity: 62,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      title: isSi ? 'පොළොන්නරුව' : 'Heatwave',
                      temp: '37°C',
                      icon: Icons.local_fire_department_rounded,
                      isActive: weatherState.temperatureCelsius > 35,
                      onTap: () {
                        weatherNotifier.setPresetLocation(
                          locationName: isSi ? 'පොළොන්නරුව, ශ්‍රී ලංකාව' : 'Polonnaruwa, Sri Lanka',
                          temp: 37.0,
                          humidity: 55,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Manual Temperature Slider for Custom Tuning
                Text(
                  isSi ? 'උෂ්ණත්වය සකසන්න: ${weatherState.temperatureCelsius.toStringAsFixed(0)}°C' : 'Manual Tuning: ${weatherState.temperatureCelsius.toStringAsFixed(0)}°C',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: heatOrange,
                    thumbColor: heatOrange,
                    inactiveTrackColor: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.15),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    min: 18.0,
                    max: 42.0,
                    value: weatherState.temperatureCelsius,
                    onChanged: (val) {
                      weatherNotifier.updateTemperature(val);
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Done / Confirm Button
                ScaleButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [heatOrange, const Color(0xFFFFAE85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: heatOrange.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isSi ? 'සම්පූර්ණයි' : 'Done',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4D2411),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String title;
  final String temp;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _PresetButton({
    required this.title,
    required this.temp,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTeal = const Color(0xFF0C4648);
    final heatOrange = const Color(0xFFFF7E47);

    return Expanded(
      child: ScaleButton(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? heatOrange.withValues(alpha: isDark ? 0.28 : 0.18)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? heatOrange
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : primaryTeal.withValues(alpha: 0.12)),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? heatOrange : (isDark ? Colors.white70 : primaryTeal),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? heatOrange : (isDark ? Colors.white : primaryTeal),
                ),
              ),
              Text(
                temp,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
