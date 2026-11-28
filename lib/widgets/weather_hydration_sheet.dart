import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_hydration_provider.dart';
import '../services/weather_location_service.dart';
import 'scale_button.dart';

/// Global helper to show the Smart Weather-based Hydration Modal Sheet
void showWeatherHydrationModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => const WeatherHydrationSheet(),
    );
  });
}

class WeatherHydrationSheet extends ConsumerStatefulWidget {
  const WeatherHydrationSheet({super.key});

  @override
  ConsumerState<WeatherHydrationSheet> createState() => _WeatherHydrationSheetState();
}

class _WeatherHydrationSheetState extends ConsumerState<WeatherHydrationSheet> {
  bool _isTracking = false;

  Future<void> _handleLiveTrack(bool isSi) async {
    if (_isTracking) return;
    setState(() => _isTracking = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(weatherHydrationProvider.notifier).autoDetectLocationAndWeather();
      if (!mounted) return;
      final state = ref.read(weatherHydrationProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.gps_fixed_rounded, color: Color(0xFF70D6CE), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSi
                      ? '📍 ස්ථානය සහ කාලගුණය සාර්ථකව යාවත්කාලීන විය: ${state.locationName} (${state.temperatureCelsius.toStringAsFixed(1)}°C)'
                      : '📍 Live Weather Synced: ${state.locationName} (${state.temperatureCelsius.toStringAsFixed(1)}°C)',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0C4648),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTracking = false);
      }
    }
  }

  void _openLocationPicker(BuildContext context, bool isSi, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => LocationPickerSheet(isSi: isSi, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherHydrationProvider);
    final weatherNotifier = ref.read(weatherHydrationProvider.notifier);

    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
    final skyAqua = const Color(0xFF0284C7);
    final mintGlow = const Color(0xFF70D6CE);
    final textColor = isDark ? const Color(0xFFE8F6F4) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF506E70);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF0F262B).withValues(alpha: 0.90),
                      const Color(0xFF08181B).withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      const Color(0xFFEDF8F7).withValues(alpha: 0.92),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.5 : 0.18),
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
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: skyAqua.withValues(alpha: 0.18),
                        border: Border.all(
                          color: mintGlow.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.thermostat_rounded,
                        color: Color(0xFF0284C7),
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
                              color: textColor,
                            ),
                          ),
                          Text(
                            isSi ? 'උෂ්ණත්වය මත විජලනය වැළැක්වීම' : 'Dynamic heat-adjusted hydration',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
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
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
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

                const SizedBox(height: 16),

                // 🌐 Enhanced Live GPS Tracker Glass Card (live track krn ek hdnn)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF0284C7).withValues(alpha: 0.22),
                              const Color(0xFF0C4648).withValues(alpha: 0.28),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.85),
                              const Color(0xFFE0F4F2).withValues(alpha: 0.70),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF70D6CE).withValues(alpha: isDark ? 0.35 : 0.6),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                          ),
                        ),
                        child: _isTracking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                                ),
                              )
                            : const Icon(
                                Icons.near_me_rounded,
                                size: 20,
                                color: Color(0xFF0284C7),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isSi ? 'සජීවී GPS සම්බන්ධතාවය' : 'Live GPS Connected',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSi
                                  ? 'නවතම උෂ්ණත්වය ස්වයංක්‍රීයව Sync වේ'
                                  : 'Auto-detecting hyper-local weather',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScaleButton(
                        onTap: () => _handleLiveTrack(isSi),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0C4648), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF70D6CE).withValues(alpha: 0.45),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0C4648).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                isSi ? 'යාවත්කාලීන' : 'Sync Live',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 💎 Main Weather & Dynamic Goal Hero Glass Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.03),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.78),
                              Colors.white.withValues(alpha: 0.50),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.85),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Full-width Location & Change Button
                      InkWell(
                        onTap: () => _openLocationPicker(context, isSi, isDark),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  weatherState.locationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_location_alt_rounded, size: 12, color: Color(0xFF0284C7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      isSi ? 'වෙනස් කරන්න' : 'Change',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Middle Row: Temperature on Left, Dynamic Goal Box on Right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weatherState.temperatureCelsius.toStringAsFixed(1)}°',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 46,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'C',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.water_drop_rounded, size: 13, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 3),
                                  Text(
                                    isSi ? 'ආර්ද්‍රතාව: ${weatherState.humidityPercent}%' : 'Humidity: ${weatherState.humidityPercent}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Dynamic Goal Result Glass Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0284C7).withValues(alpha: 0.18),
                                  const Color(0xFF0C4648).withValues(alpha: 0.10),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF70D6CE).withValues(alpha: 0.45),
                                width: 1.3,
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
                                    color: subtitleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${weatherState.effectiveGoalMl} ml',
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                                if (weatherState.isSmartAdjustmentEnabled && weatherState.calculatedBonusMl > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '+${weatherState.calculatedBonusMl}ml ${isSi ? "රස්නය නිසා" : "Heat Bonus"}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Status summary glass pill
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0284C7)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isSi ? weatherState.summarySi : weatherState.summaryEn,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
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

                // 🛡️ Senior Health Advice & Dehydration Alert Glass Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF0284C7).withValues(alpha: 0.12),
                              const Color(0xFF0C4648).withValues(alpha: 0.16),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.75),
                              const Color(0xFFE8F6F4).withValues(alpha: 0.65),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF70D6CE).withValues(alpha: isDark ? 0.25 : 0.55),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4648).withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
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
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSi ? weatherState.seniorAdviceSi : weatherState.seniorAdviceEn,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ⚡ Smart Auto Adjustment Glass Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0.02),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.75),
                              Colors.white.withValues(alpha: 0.55),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.8),
                      width: 1.3,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0284C7).withValues(alpha: 0.14),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0284C7), size: 20),
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
                                color: textColor,
                              ),
                            ),
                            Text(
                              isSi ? 'රස්නය අනුව ඉලක්කය ස්වයංක්‍රීයව වැඩි කරන්න' : 'Automatically adapts goal on warmer days',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: weatherState.isSmartAdjustmentEnabled,
                        activeTrackColor: const Color(0xFF70D6CE),
                        activeThumbColor: Colors.white,
                        onChanged: (val) {
                          weatherNotifier.toggleSmartAdjustment(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 🌡️ Manual Temperature Slider for Custom Tuning
                Text(
                  isSi ? 'උෂ්ණත්වය සකසන්න: ${weatherState.temperatureCelsius.toStringAsFixed(0)}°C' : 'Manual Tuning: ${weatherState.temperatureCelsius.toStringAsFixed(0)}°C',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF0284C7),
                    thumbColor: const Color(0xFF0284C7),
                    inactiveTrackColor: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.12),
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

                const SizedBox(height: 14),

                // 🚀 Done / Confirm Signature Glass Button
                ScaleButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C4648), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF70D6CE).withValues(alpha: 0.45),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: 0.3),
                          blurRadius: 14,
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
                        color: Colors.white,
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

/// Frosted Glass Location Selector & City Search Bottom Sheet
class LocationPickerSheet extends ConsumerStatefulWidget {
  final bool isSi;
  final bool isDark;

  const LocationPickerSheet({
    super.key,
    required this.isSi,
    required this.isDark,
  });

  @override
  ConsumerState<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() => _isSearching = true);
    final results = await WeatherLocationService.searchCities(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectCity(double lat, double lon, String fullName) {
    HapticFeedback.mediumImpact();
    ref.read(weatherHydrationProvider.notifier).setCoordinatesAndFetchWeather(lat, lon, fullName);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isSi
              ? '📍 ස්ථානය සාර්ථකව වෙනස් විය: $fullName'
              : '📍 Location updated to $fullName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0C4648),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _useLiveGps() async {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    await ref.read(weatherHydrationProvider.notifier).autoDetectLocationAndWeather();
    if (!mounted) return;
    final updated = ref.read(weatherHydrationProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isSi
              ? '📍 සජීවී GPS මඟින් ස්ථානය යාවත්කාලීන විය: ${updated.locationName}'
              : '📍 Live GPS updated to ${updated.locationName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0C4648),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? const Color(0xFFE8F6F4) : const Color(0xFF0C4648);
    final subtitleColor = widget.isDark ? const Color(0xFF88ACAA) : const Color(0xFF506E70);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [
                        const Color(0xFF0F262B).withValues(alpha: 0.95),
                        const Color(0xFF08181B).withValues(alpha: 0.98),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        const Color(0xFFEDF8F7).withValues(alpha: 0.98),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: Colors.white.withValues(alpha: widget.isDark ? 0.16 : 0.8),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_city_rounded, color: Color(0xFF0284C7), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            widget.isSi ? 'ස්ථානය තෝරන්න' : 'Select Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: subtitleColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Live GPS 1-Tap Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ScaleButton(
                    onTap: _useLiveGps,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0C4648), Color(0xFF0284C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF70D6CE).withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C4648).withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.my_location_rounded, color: Color(0xFF70D6CE), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.isSi ? 'සජීවී GPS මඟින් හඳුනාගන්න' : 'Detect My Exact Live GPS Location',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (widget.isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (widget.isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: widget.isSi
                            ? 'නගරය සොයන්න (උදා: Kandy, Galle, Malabe)...'
                            : 'Search city or town (e.g. Kandy, Galle)...',
                        hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: subtitleColor, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: subtitleColor, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _handleSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Content: Either Search Results or Popular Cities
                Expanded(
                  child: _isSearching
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : _searchResults.isNotEmpty
                          ? ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = _searchResults[index];
                                final fullName = item['fullName'] as String;
                                final lat = item['lat'] as double;
                                final lon = item['lon'] as double;

                                return InkWell(
                                  onTap: () => _selectCity(lat, lon, fullName),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: (widget.isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (widget.isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.place_rounded, size: 18, color: Color(0xFF0284C7)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            fullName,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF0284C7)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isSi ? 'ශ්‍රී ලංකාවේ ප්‍රධාන නගර' : 'Popular Sri Lankan Cities',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: subtitleColor,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: WeatherLocationService.sriLankanPresetsList.map((city) {
                                      final name = city['name'] as String;
                                      final fullName = city['fullName'] as String;
                                      final lat = city['lat'] as double;
                                      final lon = city['lon'] as double;

                                      return ScaleButton(
                                        onTap: () => _selectCity(lat, lon, fullName),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                          decoration: BoxDecoration(
                                            color: (widget.isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.location_city_rounded, size: 14, color: Color(0xFF0284C7)),
                                              const SizedBox(width: 6),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],
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

