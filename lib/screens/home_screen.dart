import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../providers/custom_sound_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/sound_visualizer_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/breathing_exercise_sheet.dart';
import '../widgets/medication_schedule_sheet.dart';
import '../widgets/gentle_alarm_sheet.dart';
import '../widgets/weather_hydration_sheet.dart';
import '../widgets/unified_sound_studio_sheet.dart';
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
    final hydrationState = ref.watch(hydrationProvider);

    final medicationNotifier = ref.read(medicationProvider.notifier);
    final alarmNotifier = ref.read(alarmProvider.notifier);
    final customSounds = ref.watch(customSoundProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTeal = const Color(0xFF0C4648);
    final textColor = isDark ? const Color(0xFFE8F6F4) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF90B5B3) : const Color(0xFF506E70);
    final goldAmber = const Color(0xFFFFAE85);
    final isSi = settingsState.isSinhala;

    // Active soundtrack resolution
    final lastSoundId = settingsState.lastUsedSoundId;
    final SoundTrack heroSound;
    if (customSounds.isNotEmpty) {
      heroSound = customSounds.firstWhere(
        (t) => t.id == lastSoundId,
        orElse: () => customSounds.first,
      );
    } else {
      heroSound = SoundTrack.defaultTracks.firstWhere(
        (t) => t.id == lastSoundId,
        orElse: () => SoundTrack.defaultTracks[2], // Rainfall by default
      );
    }

    final isHeroPlaying = audioNotifier.isPlaying && audioNotifier.currentTrack.id == heroSound.id;
    final isGuest = user == null || user.isGuest;
    final displayName = (!isGuest && user.name.trim().isNotEmpty) ? user.name.trim() : (isSi ? 'යහළුවා' : 'Friend');

    // Dynamic Greeting
    final now = DateTime.now();
    final hour = now.hour;
    final timeString = DateFormat('h:mm a').format(now);
    final dateString = DateFormat('EEE, MMM d').format(now);

    String greeting;
    String greetingSubtitle;

    if (hour >= 5 && hour < 12) {
      greeting = isSi ? 'සුබ උදෑසනක්' : 'Good Morning';
      greetingSubtitle = isSi ? 'නැවුම්, සන්සුන් දවසක් අරඹන්න.' : 'Start your day calm & refreshed.';
    } else if (hour >= 12 && hour < 17) {
      greeting = isSi ? 'සුබ දහවලක්' : 'Good Afternoon';
      greetingSubtitle = isSi ? 'මනස නිවාගෙන ජලය පානය කරන්න.' : 'Stay mindful, cool & hydrated.';
    } else {
      greeting = isSi ? 'සුබ සැන්දෑවක්' : 'Good Evening';
      greetingSubtitle = isSi ? 'සිත නිවාගෙන සුවබර නින්දකට සූදානම් වන්න.' : 'Unwind and prepare for deep sleep.';
    }

    // Medication calculations
    MedicationItem? nextMed;
    try {
      nextMed = medicationList.firstWhere((m) => !m.isTakenToday);
    } catch (_) {
      nextMed = medicationList.isNotEmpty ? medicationList.first : null;
    }
    final allMedsTaken = medicationList.isNotEmpty && medicationList.every((m) => m.isTakenToday);
    final takenMedsCount = medicationList.where((m) => m.isTakenToday).length;

    // Quick Nature Sounds (4 most popular)
    final quickSounds = SoundTrack.defaultTracks.take(4).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Subtle Ambient Background Aura
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 320,
            left: -60,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.30),
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              color: primaryTeal,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await ref.read(weatherHydrationProvider.notifier).autoDetectLocationAndWeather();
                ref.invalidate(hydrationProvider);
                ref.invalidate(settingsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Branded Header
                    const AquaSootheHeader(isCentered: false),

                    const SizedBox(height: 18),

                    // 2. Greeting & Status Bar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, $displayName 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                greetingSubtitle,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Quick Glance Status Badges (Weather, Alarm, Time)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          // Weather Status Pill
                          ScaleButton(
                            onTap: () => showWeatherHydrationModal(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF1E3A40) : const Color(0xFFE6F4F2)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF5ED1C7).withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.wb_sunny_rounded, size: 15, color: Color(0xFFE67E22)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${weatherState.temperatureCelsius.toStringAsFixed(0)}°C • ${weatherState.locationName.split(',').first}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : primaryTeal,
                                    ),
                                  ),
                                  if (weatherState.calculatedBonusMl > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${weatherState.calculatedBonusMl}ml',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE67E22),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Next Alarm Pill
                          ScaleButton(
                            onTap: () => showGentleAlarmModal(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF2D231E) : const Color(0xFFFFF2EB)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: goldAmber.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    alarmState.isEnabled ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                                    size: 15,
                                    color: alarmState.isEnabled ? const Color(0xFFD97706) : subtitleColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    alarmState.isEnabled
                                        ? '${alarmState.formattedTime} (On)'
                                        : (isSi ? 'ඇලාම් Off' : 'Alarm Off'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: alarmState.isEnabled
                                          ? (isDark ? goldAmber : const Color(0xFFB45309))
                                          : subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Date Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 13, color: subtitleColor),
                                const SizedBox(width: 6),
                                Text(
                                  '$dateString • $timeString',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtitleColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================================================
                    // 3. ⭐ HERO NATURE SOUND PLAYER CARD (Instant Appeal)
                    // =========================================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF0F3237),
                                  const Color(0xFF134248),
                                  const Color(0xFF1A585F),
                                ]
                              : [
                                  const Color(0xFF0C4648),
                                  const Color(0xFF125659),
                                  const Color(0xFF1A6B6F),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTeal.withValues(alpha: isDark ? 0.5 : 0.28),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Subtle Decorative Background Waves
                          Positioned(
                            right: -25,
                            bottom: -25,
                            child: Icon(
                              Icons.waves_rounded,
                              size: 170,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Tag & Visualizer
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF70D6CE), size: 14),
                                          const SizedBox(width: 5),
                                          Text(
                                            isSi ? 'සුව නින්දේ නාදය' : 'CALMING NATURE THERAPY',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF70D6CE),
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isHeroPlaying)
                                      Row(
                                        children: [
                                          SoundVisualizerWidget(
                                            isPlaying: true,
                                            color: Colors.white,
                                            barWidth: 3,
                                            maxHeight: 16,
                                            barCount: 4,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isSi ? 'වාදනය වේ' : 'Playing',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Sound Title & Description
                                Text(
                                  heroSound.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  heroSound.description.isNotEmpty
                                      ? heroSound.description
                                      : (isSi ? 'සුවබර නින්දකට සන්සුන් ස්වභාවික නාද' : 'Pure relaxing acoustic soundscape'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Big Action Button Row (Play / Pause & Studio)
                                Row(
                                  children: [
                                    // Big Play / Pause Button
                                    ScaleButton(
                                      onTap: () async {
                                        HapticFeedback.mediumImpact();
                                        if (isHeroPlaying) {
                                          await audioNotifier.pause();
                                        } else {
                                          await audioNotifier.selectTrack(heroSound);
                                          await audioNotifier.play();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFFAE85), Color(0xFFF89966)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFAE85).withValues(alpha: 0.45),
                                              blurRadius: 14,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isHeroPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              color: const Color(0xFF4D2411),
                                              size: 26,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isHeroPlaying
                                                  ? (isSi ? 'නවතන්න' : 'Pause')
                                                  : (isSi ? 'අසන්න' : 'Play Sound'),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4D2411),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Sleep Timer & Studio Button
                                    ScaleButton(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                          ),
                                          builder: (_) => const UnifiedSoundStudioSheet(),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              audioNotifier.secondsRemaining > 0
                                                  ? audioNotifier.formattedTimeRemaining
                                                  : (isSi ? 'Mixer & Timer' : 'Mixer & Timer'),
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // 4. 🌊 QUICK NATURE SOUNDS (One-Tap Instant Play)
                    // =========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isSi ? 'ක්ෂණික ස්වභාවික නාද' : 'Quick Soundscapes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        ScaleButton(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const MainNavigationScreen(initialIndex: 1),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  isSi ? 'සියල්ල' : 'See all',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 4 Sound Cards Row
                    Row(
                      children: quickSounds.map((track) {
                        final isThisTrackPlaying = audioNotifier.isPlaying && audioNotifier.currentTrack.id == track.id;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ScaleButton(
                              onTap: () async {
                                HapticFeedback.selectionClick();
                                ref.read(settingsProvider.notifier).setLastUsedSoundId(track.id);
                                if (isThisTrackPlaying) {
                                  await audioNotifier.pause();
                                } else {
                                  await audioNotifier.selectTrack(track);
                                  await audioNotifier.play();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isThisTrackPlaying
                                      ? goldAmber.withValues(alpha: isDark ? 0.25 : 0.2)
                                      : (isDark ? const Color(0xFF13272C) : Colors.white),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isThisTrackPlaying
                                        ? const Color(0xFFF89966)
                                        : (isDark ? Colors.white.withValues(alpha: 0.1) : primaryTeal.withValues(alpha: 0.12)),
                                    width: isThisTrackPlaying ? 1.8 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isThisTrackPlaying
                                            ? goldAmber
                                            : (isDark ? Colors.white.withValues(alpha: 0.08) : primaryTeal.withValues(alpha: 0.08)),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isThisTrackPlaying ? Icons.pause_rounded : track.icon,
                                        size: 20,
                                        color: isThisTrackPlaying
                                            ? const Color(0xFF4D2411)
                                            : (isDark ? const Color(0xFF5ED1C7) : primaryTeal),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      track.title
                                          .replaceAll('Soothing ', '')
                                          .replaceAll('Cascading ', '')
                                          .replaceAll('Deep ', ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isThisTrackPlaying
                                            ? (isDark ? goldAmber : const Color(0xFFB45309))
                                            : textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 26),

                    // =========================================================
                    // 5. 🌿 DAILY WELLNESS & ROUTINES (Clean, Clear Cards)
                    // =========================================================
                    Text(
                      isSi ? 'දෛනික සුවතා සත්කාර' : 'Daily Wellness & Habits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 1: 💧 Hydration Tracker (One-Tap 250ml Logging)
                    GlassCard(
                      borderRadius: 22,
                      blur: 16,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(initialIndex: 2),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.water_drop_rounded, color: Color(0xFF0284C7), size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isSi ? 'දෛනික ජල ඉලක්කය' : 'Daily Hydration',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          '${hydrationState.todayTotalMl} / ${hydrationState.goal.dailyTargetMl} ml',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0284C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Linear Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: hydrationState.todayProgress,
                                        minHeight: 7,
                                        backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Quick 1-Tap Drink 250ml Button
                          ScaleButton(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              await ref.read(hydrationProvider.notifier).logWater(250);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF70D6CE)),
                                        const SizedBox(width: 8),
                                        Text(
                                          isSi ? '💧 වතුර 250ml සටහන් කළා!' : '💧 Logged 250ml of water!',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: primaryTeal,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF163238) : const Color(0xFFE0F2FE)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_rounded, size: 18, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 6),
                                  Text(
                                    isSi ? 'වතුර වීදුරුවක් බොන්න (+250ml)' : 'Drink a Glass of Water (+250ml)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card 2: 💊 Medication & Water Pairing Card
                    GlassCard(
                      borderRadius: 22,
                      blur: 16,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () => showMedicationScheduleModal(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: goldAmber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.medication_rounded, color: Color(0xFFE67E22), size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isSi ? 'බෙහෙත් සහ වතුර' : 'Medication & Water',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          '$takenMedsCount/${medicationList.length} ${isSi ? 'බී අවසන්' : 'done'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: allMedsTaken ? const Color(0xFF059669) : subtitleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      allMedsTaken
                                          ? (isSi ? 'අද සියලුම පෙති පානය කර ඇත ✨' : 'All medications taken for today! ✨')
                                          : (nextMed != null
                                              ? (isSi
                                                  ? 'ඊළඟ: ${nextMed.nameSi} (${nextMed.scheduledTime})'
                                                  : 'Next: ${nextMed.nameEn} (${nextMed.scheduledTime})')
                                              : (isSi ? 'කාලසටහන පරීක්ෂා කරන්න' : 'View Schedule')),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: allMedsTaken ? const Color(0xFF059669) : subtitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
                            ],
                          ),
                          if (!allMedsTaken && nextMed != null) ...[
                            const SizedBox(height: 12),
                            ScaleButton(
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                final target = nextMed!;
                                final loggedMl = await medicationNotifier.takeMedication(
                                  target.id,
                                  ref.read(hydrationProvider.notifier),
                                );
                                if (context.mounted && loggedMl != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSi
                                            ? '💊 ${target.nameSi} බී වතුර ${loggedMl}ml ලොග් කළා!'
                                            : '💊 Took ${target.nameEn} & logged ${loggedMl}ml water!',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: primaryTeal,
                                      duration: const Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: goldAmber.withValues(alpha: isDark ? 0.35 : 0.3),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: goldAmber.withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_rounded, size: 16, color: Color(0xFFB45309)),
                                    const SizedBox(width: 6),
                                    Text(
                                      isSi ? 'පෙත්ත බී වතුර වීදුරුවක් ලොග් කරන්න' : 'Took Pill + Drink 250ml Water',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Card 3: 🌅 Gentle Wake-Up Alarm Card
                    GlassCard(
                      borderRadius: 22,
                      blur: 16,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () => showGentleAlarmModal(context),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.alarm_rounded, color: Color(0xFFD97706), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSi ? 'මෘදු ස්වභාවික ඇලාමය' : 'Gentle Wake-Up Alarm',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isSi
                                      ? 'වේලාව ${alarmState.formattedTime} • සෙමෙන් වැඩිවන ශබ්දය'
                                      : 'Wake at ${alarmState.formattedTime} • Gentle Fade-In',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            value: alarmState.isEnabled,
                            activeTrackColor: const Color(0xFFD97706),
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              alarmNotifier.toggleAlarm(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Card 4: 🧘 1-Min Mindful Breathing Exercise
                    GlassCard(
                      borderRadius: 22,
                      blur: 16,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () => showBreathingExerciseModal(context),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.air_rounded, color: Color(0xFF059669), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSi ? 'සන්සුන් හුස්ම ගැනීමේ අභ්‍යාසය' : '1-Min Guided Breathing',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isSi ? 'නින්දට පෙර ආතතිය දුරු කර සන්සුන් වන්න' : '4-7-8 rhythm to de-stress & relax',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
                        ],
                      ),
                    ),

                    // Extra bottom space for floating nav bar
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
