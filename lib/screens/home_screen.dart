import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sound_model.dart';
import '../models/medication_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/alarm_provider.dart';
import '../providers/weather_hydration_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/sound_visualizer_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/breathing_exercise_sheet.dart';
import '../widgets/medication_schedule_sheet.dart';
import '../widgets/gentle_alarm_sheet.dart';
import '../widgets/weather_hydration_sheet.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final audioNotifier = ref.watch(audioServiceProvider);
    final settingsState = ref.watch(settingsProvider);
    final medicationList = ref.watch(medicationProvider);
    final alarmState = ref.watch(alarmProvider);
    final weatherState = ref.watch(weatherHydrationProvider);
    final medicationNotifier = ref.read(medicationProvider.notifier);
    final alarmNotifier = ref.read(alarmProvider.notifier);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    final lastSoundId = settingsState.lastUsedSoundId;
    final currentSound = SoundTrack.defaultTracks.firstWhere(
      (t) => t.id == lastSoundId,
      orElse: () => SoundTrack.defaultTracks[1], // Default Ocean/Deep Ocean
    );

    final isSi = settingsState.isSinhala;
    final isPlaying = audioNotifier.isPlaying && audioNotifier.currentTrack.id == currentSound.id;
    final displayName = user != null && user.name.isNotEmpty ? user.name : (isSi ? 'පරිශීලකයා' : 'Guest User');

    // Calculate dynamic time and greeting
    final now = DateTime.now();
    final hour = now.hour;
    final timeString = DateFormat('h:mm a').format(now);
    final dateString = DateFormat('EEEE, MMM d').format(now);

    String greeting;
    String subtitle;

    if (hour >= 5 && hour < 12) {
      greeting = isSi ? 'සුබ උදෑසනක්' : 'Good morning';
      subtitle = isSi ? 'නැවුම් දවසකට සූදානම් වන්න.' : 'Ready for a refreshing day.';
    } else if (hour >= 12 && hour < 17) {
      greeting = isSi ? 'සුබ දහවලක්' : 'Good afternoon';
      subtitle = isSi ? 'ප්‍රමාණවත් ලෙස ජලය පානය කරන්න.' : 'Stay hydrated and focused.';
    } else {
      greeting = isSi ? 'සුබ සැන්දෑවක්' : 'Good evening';
      subtitle = isSi ? 'විවේකීව සහ සුවබරව සිටින්න.' : 'Time to rest and restore.';
    }

    MedicationItem? nextMed;
    try {
      nextMed = medicationList.firstWhere((m) => !m.isTakenToday);
    } catch (_) {
      nextMed = medicationList.isNotEmpty ? medicationList.first : null;
    }
    final allMedsTaken = medicationList.isNotEmpty && medicationList.every((m) => m.isTakenToday);
    final takenMedsCount = medicationList.where((m) => m.isTakenToday).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Glassmorphic Background Aura Blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.38),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.32),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.15 : 0.22),
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF0C4648),
              backgroundColor: Colors.white,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 600));
                ref.invalidate(hydrationProvider);
                ref.invalidate(settingsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with logo
                    const AquaSootheHeader(isCentered: false),

                    const SizedBox(height: 24),

                    // Top Frosted Glass Pills Row (Time, Weather, Alarm)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          // Time & Date Pill
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 15, color: subtitleColor),
                                    const SizedBox(width: 7),
                                    Text(
                                      '$timeString  •  $dateString',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: subtitleColor,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Smart Weather Hydration Pill
                          ScaleButton(
                            onTap: () => showWeatherHydrationModal(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF7E47).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFF7E47).withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.thermostat_rounded, size: 15, color: Color(0xFFFF7E47)),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${weatherState.temperatureCelsius.toStringAsFixed(0)}°C ${weatherState.calculatedBonusMl > 0 ? "+${weatherState.calculatedBonusMl}ml" : ""}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF7E47),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Gentle Alarm Pill
                          ScaleButton(
                            onTap: () => showGentleAlarmModal(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFAE85).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFFAE85).withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.wb_twilight_rounded, size: 15, color: Color(0xFFE67E33)),
                                      const SizedBox(width: 5),
                                      Text(
                                        alarmState.formattedTime,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFFFFAE85) : const Color(0xFFB55710),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Greeting Section
                    Text(
                      '$greeting, $displayName.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 💊 Medication + Hydration Schedule Glass Card with Photo Banner
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(14),
                      margin: EdgeInsets.zero,
                      onTap: () => showMedicationScheduleModal(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Banner with Glass Gradient Overlay & Status Badge
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/medication_banner.jpg',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.65),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Floating Status Pill over image
                              Positioned(
                                top: 10,
                                right: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: (allMedsTaken ? const Color(0xFF5ED1C7) : const Color(0xFFFFAE85)).withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '$takenMedsCount/${medicationList.length} ${isSi ? 'බී අවසන්' : 'taken'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Floating Water Pill
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.water_drop_rounded, color: Color(0xFF70D6CE), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSi ? 'පෙති සහ වතුර' : 'Pill + 250ml Water',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Title and Subtitle Row (With Expanded to guarantee zero overflow)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFAE85), Color(0xFFF89966)],
                                  ),
                                ),
                                child: const Icon(Icons.medication_rounded, size: 17, color: Color(0xFF4D2411)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isSi ? 'බෙහෙත් සහ වතුර කාලසටහන' : 'Medication & Hydration',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
                            ],
                          ),

                          const SizedBox(height: 10),

                          if (allMedsTaken) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5ED1C7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF1E676B), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isSi
                                          ? 'අද සියලුම බෙහෙත් පෙති පානය කර වතුර ලොග් කර ඇත!'
                                          : 'All medications completed today with water logged!',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (nextMed != null) ...[
                            () {
                              final targetMed = nextMed!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule_rounded, size: 18, color: subtitleColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isSi
                                                ? 'ඊළඟ පෙත්ත: ${targetMed.nameSi} (${targetMed.scheduledTime})'
                                                : 'Next: ${targetMed.nameEn} (${targetMed.scheduledTime})',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // 1-Tap Pill Taken + Water Logged Action Button
                                  ScaleButton(
                                    onTap: () async {
                                      final loggedMl = await medicationNotifier.takeMedication(
                                        targetMed.id,
                                        ref.read(hydrationProvider.notifier),
                                      );
                                      if (context.mounted && loggedMl != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isSi
                                                  ? '💊 ${targetMed.nameSi} බී වතුර ${loggedMl}ml ලොග් කළා!'
                                                  : '💊 Took ${targetMed.nameEn} & logged ${loggedMl}ml water!',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: const Color(0xFF0C4648),
                                            duration: const Duration(seconds: 3),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFFAE85), Color(0xFFF89966)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF8AB80).withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_rounded, color: Color(0xFF4D2411), size: 20),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              isSi ? 'බෙහෙත් බී වතුර වීදුරුවක් ලොග් කරන්න' : 'Pill Taken + Log 250ml Water',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4D2411),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }(),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 🌅 Gentle Nature Wake-Up Alarm Glass Card with Photo Banner
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(14),
                      margin: EdgeInsets.zero,
                      onTap: () => showGentleAlarmModal(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Banner with Glass Gradient Overlay
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/alarm_banner.jpg',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.65),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Floating Time Chip over image
                              Positioned(
                                top: 10,
                                left: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.alarm_rounded, color: Color(0xFFFFAE85), size: 14),
                                          const SizedBox(width: 5),
                                          Text(
                                            alarmState.formattedTime,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Floating Nature Sound Badge
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.music_note_rounded, color: Color(0xFFFFB866), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSi ? 'සෙමෙන් වැඩිවන ශබ්දය' : 'Gentle Fade-in',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Controls and Title Row (Guaranteed no overflow)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFB866), Color(0xFFFFAE85)],
                                  ),
                                ),
                                child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF4D2411), size: 17),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSi ? 'මෘදු ස්වභාවික නාද ඇලාම්' : 'Gentle Nature Wake-Up Alarm',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isSi
                                          ? 'වේලාව ${alarmState.formattedTime} • ${alarmState.soundTitleSi}'
                                          : 'Wake at ${alarmState.formattedTime} • ${alarmState.soundTitleEn}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: subtitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch.adaptive(
                                value: alarmState.isEnabled,
                                activeTrackColor: const Color(0xFFFFAE85).withValues(alpha: 0.45),
                                onChanged: (val) {
                                  alarmNotifier.toggleAlarm(val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 🌡️ Smart Weather-based Hydration Glass Card with Photo Banner
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(14),
                      margin: EdgeInsets.zero,
                      onTap: () => showWeatherHydrationModal(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Banner with Glass Gradient Overlay
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/weather_banner.jpg',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.65),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Floating Temperature & Heat Bonus Pill over image
                              Positioned(
                                top: 10,
                                right: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF7E47).withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.thermostat_rounded, size: 14, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${weatherState.temperatureCelsius.toStringAsFixed(0)}°C ${weatherState.calculatedBonusMl > 0 ? "+${weatherState.calculatedBonusMl}ml" : ""}',
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
                                ),
                              ),
                              // Floating Location Chip
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on_rounded, color: Color(0xFFFFB866), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            weatherState.locationName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Title and Subtitle Row (Zero overflow)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFF7E47).withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: const Color(0xFFFF7E47).withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(Icons.thermostat_rounded, color: Color(0xFFFF7E47), size: 17),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSi ? 'කාලගුණය අනුව ජල ඉලක්කය' : 'Smart Weather Hydration',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isSi ? weatherState.summarySi : weatherState.summaryEn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: subtitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // LAST PLAYED Card with Animated Equalizer Visualizer & Glass Look
                    GlassCard(
                      borderRadius: 22,
                      blur: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      margin: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isSi ? 'අවසන් වරට වාදනය වූ' : 'LAST PLAYED',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: subtitleColor,
                                      ),
                                    ),
                                    if (isPlaying) ...[
                                      const SizedBox(width: 8),
                                      SoundVisualizerWidget(
                                        isPlaying: true,
                                        color: textColor,
                                        barWidth: 3,
                                        maxHeight: 14,
                                        barCount: 3,
                                      ),
                                      if (audioNotifier.secondsRemaining > 0) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          isSi
                                              ? '• ස්වයංක්‍රීයව නතර වේ ${audioNotifier.formattedTimeRemaining}'
                                              : '• Auto-off ${audioNotifier.formattedTimeRemaining}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: subtitleColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currentSound.id == 'ocean' ? 'Deep Ocean' : currentSound.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ScaleButton(
                            onTap: () async {
                              if (isPlaying) {
                                await audioNotifier.pause();
                              } else {
                                await audioNotifier.selectTrack(currentSound);
                                await audioNotifier.play();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isPlaying ? const Color(0xFFF8AB80) : (isDark ? const Color(0xFF1E3A40) : const Color(0xFFEFE6D8)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isPlaying ? 0.6 : 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  if (isPlaying)
                                    BoxShadow(
                                      color: const Color(0xFFF8AB80).withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: isPlaying ? const Color(0xFF4D2411) : (isDark ? Colors.white : const Color(0xFF3D2E1E)),
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Guided Breathing Exercise Glass Card (Interactive 4-7-8 & Box Breathing)
                    GlassCard(
                      borderRadius: 20,
                      blur: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      margin: EdgeInsets.zero,
                      onTap: () => showBreathingExerciseModal(context),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5ED1C7).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF5ED1C7).withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(Icons.air_rounded, color: isDark ? const Color(0xFF5ED1C7) : const Color(0xFF1E676B), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSi ? 'සන්සුන් හුස්ම ගැනීමේ අභ්‍යාසය' : 'Guided Breathing Exercise',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSi ? 'නින්දට පෙර ආතතිය දුරු කර සන්සුන් වන්න (4-7-8)' : 'Relax & lower heart rate for deep sleep',
                                  style: TextStyle(fontSize: 13, color: subtitleColor),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: subtitleColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Single Clear Entry Point to Sounds (Senior-Friendly)
                    ScaleButton(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(initialIndex: 1),
                          ),
                        );
                      },
                      child: GlassCard(
                        borderRadius: 20,
                        blur: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        margin: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.waves_rounded, size: 22, color: textColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isSi ? 'සියලු ශබ්ද ගවේෂණය' : 'Browse All Soundscapes',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 18, color: subtitleColor),
                          ],
                        ),
                      ),
                    ),

                    // Bottom padding for the floating navigation glass dock
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
